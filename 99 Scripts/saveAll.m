function saveAll()
    %% save all models
    disp('Saving all models...');
    mdlSim = systemcomposer.loadModel("WareHouseTaskRobotSimulationModel");
    mdlSim.save();
    mdlArch = systemcomposer.loadModel("WareHouseTaskRobotArchitecture");
    mdlArch.save();
    
    %% save all sheets
    disp('Saving all sheets...');
    bd = safetyAnalysisMgr.getOpenDocuments;
    for bb = bd
        bb.save();
    end
    
    %% save all reqs
    disp('Saving all requirements...');
    slreq.saveAll;
    
    disp('All work is saved.');
end