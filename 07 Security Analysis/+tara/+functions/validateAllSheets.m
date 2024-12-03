function validateAllSheets()
    % Run validation function on all spreadsheets, and show summary figure.
    % Copyright 2024, The MathWorks, Inc.
    openSecurityAnalysis; % open all sheets
    out = struct();
    shs = safetyAnalysisMgr.getOpenDocuments;
    for i=1:size(shs,2)
        sh = shs(i);
        [~,shname] = fileparts(sh.FileName);
        sam.validateSheet(sh);
        [~, flags] = sam.summarizeSheet(sh);
        out(i).sheetname = shname;
        out(i).findings.error = getValue(flags,"error");
        out(i).findings.warning = getValue(flags,"warning");
        out(i).findings.ok = getValue(flags,"check");
        out(i).vect = [out(i).findings.error out(i).findings.warning out(i).findings.ok];
    end
    Doplot(out, ["r","y","g"])
end

function out = getValue(in,keyname)
    if in.isKey(keyname)
        out = in(keyname);
    else
        out = 0;
    end
end

function Doplot(data, colors)
    x = [];
    y = [];
    for i=1:size(data,2)
        x = [x string(data(i).sheetname)];
        y = [y;data(i).vect];
    end
    bar(x,y,'stacked')
    colororder(colors);
    legend(fieldnames(data(1).findings))
    title("Threat & Risk Model Validation")
    ylabel("Nr. of Findings")
    xlabel("Analysis Sheets Name")
    grid("minor")
end