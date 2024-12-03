function nadd = updateAssets(sys, sheet)
% This function collects assets from a System Composer model, and checks
% for associated threats in the "asset" sheet (SFA).
%
% Copyright 2023-2024, The MathWorks, Inc.
    [nadd, nrem] = syncAssetsWithModel(sys, sheet);
    disp(['Completed asset scan: ' num2str(nadd) ' new assets found in current arch, ' ...
          num2str(nrem) ' assets stale, now have ' ...
          num2str(sheet.Rows) ' in total'])
end

function updateModelLinks(sheet)
    % quick hack to feed column "ModelElement" with fullname/block paths
    fastSheet = sam.SheetWrapper(sheet);
    for rowIndex = 1:sheet.Rows
        cell_mdl = fastSheet.Cell(rowIndex,"ModelElement");
        cell_thrts = fastSheet.Cell(rowIndex,"LinkedThreats");
        % --
        mlinks = cell_mdl.getLinks;
        block = {};
        if numel(mlinks.outLinks) > 0
            block = slreq.structToObj(mlinks.outLinks(1).destination);
        elseif numel(mlinks.inLinks) > 0
            block = slreq.structToObj(mlinks.inLinks(1).source);
        end
        if ~isempty(block)
            if isempty(cell_mdl.Value) 
                cell_mdl.Value = getfullname(block.SimulinkHandle);
            end
        end
        
        %% update the link text for threats and run dominance analysis
        linksThreats = cell_thrts.getLinks;
        [T, ~] = sam.lookupLinkedSheetRow(linksThreats);
        % FIXME: description from lookupLinkedSheetRow?
        [linkText, ~] = sam.describeLinks(linksThreats, withArtifact=false, rowNameFromColumn='Summary');
        if height(T) > 0
            cell_thrts.Value = sam.itemizeText(linkText);
            T.Risk = tara.types.SecurityRisk(T.Risk);
            [~, domRisk] = sam.computeAggregate(@max, T, "Risk");
            cell_thrts.Description = "dominant: " + strjoin(unique(domRisk), ", ");
        else
            cell_thrts.Value = "";
            cell_thrts.Description = "";
        end
    end
end

function [nadd, nrem] = syncAssetsWithModel(sys, sheet)
    % 1. lookup model elements which stereotype "Asset" and add to this sheet. 
    % 2. check that all existing assets with ModelElement exist in the model
    % Note: assets w/o ModelElement are allowed, no warnings.
    %% get root model and check all model links
    mdl = systemcomposer.loadModel(sys); % returns root!
    prof = ensureStereotypes(mdl);
    updateModelLinks(sheet); % set ModelElement.Value from links

    %% collect assets from architecture model by stereotype
    disp("Scanning architecture '" + convertStringsToChars(sys) + "' for new assets");
    [ModelElement, inArch, ModelElementHandle] = findAssets(mdl, prof, true); % recurse from top
    Tmdlassets = table(ModelElement, ModelElementHandle, inArch);
    
    %% check for new and disappeared assets compared to Sheet
    Ttblassets = sam.sheet2table(sheet, {'ModelElement'}, ExportFlags=false);
    % set new/stale props
    if height(Tmdlassets) > 0
        Tmdlassets.Scope = arrayfun(@(x) getfullname(x), [Tmdlassets.inArch.SimulinkHandle], 'UniformOutput', false)';
        Tmdlassets.currentArch = strcmp(Tmdlassets.Scope, sys);
        Tmdlassets.isNew = ~ismember(Tmdlassets.ModelElement, Ttblassets.ModelElement);
    end
    Ttblassets.isStale = ~ismember(Ttblassets.ModelElement, Tmdlassets.ModelElement); % TEXT COMPARISON!
    % mark stale/removed
    nrem = 0;
    for r=1:height(Ttblassets)
        if Ttblassets.isStale(r) && Ttblassets.ModelElement(r) ~= ""
            nrem = nrem + 1;
            cell = sheet.getCell(r, "ModelElement");
            addFlag(cell, "error", description="Not found in model or not marked as asset");
        end
    end
    % add new ones to table
    nadd = 0;
    for r=1:height(Tmdlassets)
        if Tmdlassets.isNew(r) && Tmdlassets.currentArch(r)
            nadd = nadd + 1;
            addAsset(sheet, Tmdlassets.ModelElement{r}, Tmdlassets.Scope{r}, Tmdlassets.ModelElementHandle(r));
        end
    end
end

function addAsset(sheet, apath, ~, ahnd)
    % ADDASSET: insert a new row in the current sheet, describing the asset
    % - ahnd: systemcomposer.Model.Element
    sheet.addRow;
    cell = sheet.getCell(sheet.Rows, "ModelElement");
    cell.Value = apath;
    try
        if isa(ahnd, 'systemcomposer.arch.BaseConnector')
            % cannot link to connector -> get source
            slreq.createLink(ahnd.SourcePort,cell);
        else
            slreq.createLink(ahnd,cell);
        end
    catch
        warning('Could not set link to asset');
    end
    addFlag(cell, "check", description="New asset");
    
    % map element type to asset type and applicable cybersec properties
    csprops = tara.functions.getCybersecProperties();
    switch class(ahnd)
        case {'systemcomposer.arch.Connector','systemcomposer.arch.ComponentPort','systemcomposer.arch.ArchitecturePort'}
            atype = "Flow";
            sheet.getCell(sheet.Rows, "Confidentiality").Value = true;
            sheet.getCell(sheet.Rows, "Integrity").Value = true;
            sheet.getCell(sheet.Rows, "Availability").Value = true;
        otherwise
            atype = "Process";
            for pp = 1:numel(csprops)
                prop = csprops{pp};
                sheet.getCell(sheet.Rows, prop).Value = true;
            end
    end
    atypes = string(enumeration('tara.types.AssetType')); % all variants
    if ~any(strcmp(atypes, atype))
        atype = atypes(1);
    end
    sheet.getCell(sheet.Rows, "AssetType").Value = atype;
end

function prof = ensureStereotypes(mdl)
    % check if the model has a profile with stereotype 'Asset'
    if isempty(mdl.Profiles)
        error('Model has no profiles. Please add one first')
    end
    prof = [];
    thisprof = mdl.Profiles;
    streoname = arrayfun(@(profile) {profile.Stereotypes.Name}, thisprof, 'UniformOutput', false);
    for i = 1:length(streoname)
        if any(cellfun(@(name) strcmp(name,"securityAsset"), streoname{i}))
            prof = thisprof(i);
        end
    end
    if isempty(prof)
        error("Profile with stereotype 'securityAsset' not found in model!");
    end
end

function [assetPath,assetArch,assetElements] = findAssets(arch, prof, recurse)
    % FINDASSETS: finds all elements in the model with stereotype "Asset"
    import systemcomposer.query.*
    constraint = HasStereotype(IsStereotypeDerivedFrom([prof.Name '.securityAsset']));
    findIt = @(what) find(arch, constraint, Recurse=recurse,...
                          IncludeReferenceModels=true, ElementType=what);
    [~, el1] = findIt("Component"); % -> el[]
    el2 = findIt("Port"); % -> el[]
    el3 = findIt("Connector"); % el[]
    assetElements = vertcat(el1(:), el2(:), el3(:));
    assetPath = arrayfun(@(x) getfullname(x.SimulinkHandle), assetElements, 'UniformOutput', false);
    assetArch = arrayfun(@(x) getArchOfAsset(x),assetElements, UniformOutput=true);
    % some connectors can yield more than one path name...take first one
    function p = removeArrayInPaths(x)
        if isa(x, "cell")
            p = x{1};
        else
            p = x;
        end
    end
    assetPath = cellfun(@removeArrayInPaths, assetPath, 'UniformOutput',false);
end

function arch = getArchOfAsset(el)
    if isa(el, 'systemcomposer.arch.ComponentPort')
        arch = el.Parent.Parent;        
    else
        arch = el.Parent;
    end
end

