function initialize(mdl)
    %INITIALIZE Set up security risk analysis on model.
    % Copyright 2024, The MathWorks, Inc.
    arguments
        mdl = gcs;
    end
    if isempty(mdl)
        error("No model specified or opened")
    end
    try
        mdlobj = systemcomposer.loadModel(mdl);
        addProfile(mdlobj);
    catch
        warning("Nothing to do - only works for System Composer files")
    end
    % any other thing you might want to do. E.g., create sheets from
    % templates, see https://mathworks.com/help/releases/R2024b/fault-analyzer/ref/safetyanalysismgr.newspreadsheet.html
    disp("Model '" + mdl + "' is ready for TARA");
end

function addProfile(archModel)
    applyProfile(archModel, "securityProfile");
end