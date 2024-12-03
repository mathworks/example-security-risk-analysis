function nadd = suggestThreatsStride(sheetThreats, sheetAssets, selectedAssetsOnly)
%SUGGESTTHREATSSTRIDE This suggests threats for the assets based on the 
% simplified STRIDE model. Use it on the "assets" sheet with a selection.
%
% Applicable threats are solely suggested based on the security properties
% in the asset sheet. To make sure you have the right properties there,
% use tara.functions.validateAssets() on the assets sheet.
%
% Sets Comment -> Suggested for new threats and links them to asset.
%
% Copyright 2024, The MathWorks, Inc.
arguments
    sheetThreats (1,1) safetyAnalysisMgr.Spreadsheet
    sheetAssets (1,1) safetyAnalysisMgr.Spreadsheet
    selectedAssetsOnly (1,1) logical = true % if false, then ALL assets are considered
end
assert(any(strcmp(sheetThreats.getColumnLabels(), "Risk")), "first argument is not the threats sheet");
assert(any(strcmp(sheetAssets.getColumnLabels(), "AssetType")), "second argument is not the asset sheet");

% These are the columns with the cysec props we require in both sheets:
cyberprops_names = tara.functions.getCybersecProperties();
assert(all(arrayfun(@(x) ismember(x, sheetAssets.getColumnLabels), cyberprops_names)), ...
       "Asset sheet does not have all of the required columns: " + strjoin(cyberprops_names, ", "));
assert(all(arrayfun(@(x) ismember(x, sheetThreats.getColumnLabels), cyberprops_names)), ...
       "Threats sheet does not have all of the required columns: " + strjoin(cyberprops_names, ", "));

% get selected assets
if selectedAssetsOnly
    [sheets, rows] = sam.getSelectedSheetsAndRows();
    if ~isempty(sheets)
        Tasset = table(sheets', rows', 'VariableNames', ["Sheet", "RowNum"]);
        Tasset.isAsset = cellfun(@(x) strcmp(x.FileName, sheetAssets.FileName), Tasset.Sheet);
        Tasset = Tasset(Tasset.isAsset,:);
        assetRows = Tasset.RowNum';
    else
        assetRows = [];
    end
else
    assetRows = 1:sheetAssets.Rows;
end
disp([num2str(numel(assetRows)) ' assets selected for STRIDE']);
strdatetime = string(datetime);

% for each asset, check if threat is missing
nadd = 0;
fastSheet = sam.SheetWrapper(sheetAssets);
for rowIndex = assetRows
    cell_thrts = fastSheet.Cell(rowIndex,"LinkedThreats");
    cell_aname = fastSheet.Cell(rowIndex,"ModelElement");
    cells_props = cellfun(@(p) fastSheet.Cell(rowIndex,p), cyberprops_names);
    %% check which threats are needed
    cyberprops = dictionary(cyberprops_names, arrayfun(@(x) x.Value, cells_props));
    propsAndThreats = requiredThreatsForAsset(cyberprops);
    %% get existing/linked threats
    [Tthreats, ~] = sam.lookupLinkedSheetRow(cell_thrts.getLinks);
    propsCovered = strings(0);
    if ~isempty(Tthreats)
        for propName = cyberprops_names
            if any(cellfun(@(x) x, Tthreats.(propName)))
                propsCovered(end+1) = propName; %#ok<AGROW>
            end
        end
    end
    %% determine which ones are missing and add them
    propsMissing = setdiff(propsAndThreats.keys, propsCovered);
    for mp = propsMissing'
        nadd = nadd + 1;
        [~, aname_short] = fileparts(cell_aname.Value);
        addThreat(sheetThreats, propsAndThreats(mp), mp, cell_thrts, string(aname_short), strdatetime);
    end
end
disp(['Suggested ' num2str(nadd) ' new threats for selected asset(s)']);
end

function addThreat(sheetT, threat, csprop, cell_in_asset, asset_name, strwhen)
% adds a new threat to the sheet and links it to the given asset
sheetT.addRow();
rowT = sheetT.Rows;
sheetT.getCell(rowT, "Summary").Value = threat + " on " + asset_name;
simpleDescription = "Asset '" + asset_name + "' could suffer from " + threat;
sheetT.getCell(rowT, "Summary").Description = simpleDescription;
sheetT.getCell(rowT, csprop).Value = true;
sheetT.getCell(rowT, "Comment").Value = "Suggested at " + strwhen;
row_in_threats = sheetT.getRow(rowT);
slreq.createLink(cell_in_asset, row_in_threats); % outgoing
end

function dict_threats = requiredThreatsForAsset(dict_props)
% returns a dict of the threats that apply to the given properties
dict_threats = configureDictionary("string", "string");
for prop = dict_props.keys'
    if dict_props(prop)
        switch prop
            case "Authenticity"
                threat = "Spoofing";
            case "Integrity"
                threat = "Tampering";
            case "Confidentiality"
                threat = "Information Disclosure";
            case "NonRepudiation"
                threat = "Repudiation";
            case "Availability"
                threat = "DoS";
            case "Authorization"
                threat = "ElevOfPriv";
            otherwise
                threat = "??";
        end
        dict_threats(prop) = threat;
    end
end
end

