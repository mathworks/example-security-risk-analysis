% Copyright 2024 The MathWorks, Inc.

mdlName = "warehouseTasksRobotSimulationModelFaulted";
load_system(mdlName);
detectionMethodSignal = "safetyLock";
robotFMEADoc = safetyAnalysisMgr.openDocument("RobotFMEA.mldatx");
for rowIndex = 1:robotFMEADoc.Rows
    failureMode = getCell(robotFMEADoc,rowIndex,"Failure Mode");
    failureModeLinks = getLinks(failureMode);
    failureModeOutlinks = failureModeLinks.outLinks;
    faultName = getDestinationLabel(failureModeOutlinks);
    faultToSimulate = Simulink.fault.findFaults(mdlName,Name=faultName);
    faultLocation = faultToSimulate.ModelElement;
    Simulink.fault.enable(faultLocation,true); % enable fault simulation
    activate(faultToSimulate); % set as activate fault
    try
    faultSim = sim(mdlName);
    catch me % simulation should error out when Assertion detected. This indicates Detection Method worked.
    errorMessage = string(me.message); 
    detectionStatus = getCell(robotFMEADoc,rowIndex,"Detection Method");
    detectionWorked = contains(errorMessage,"Assertion detected");
    if detectionWorked
        addFlag(detectionStatus,"check");
    else
        addFlag(detectionStatus,"warning",Description="Simulation errored out without Detection Method working.")
    end
    continue
    end

    runIDs = Simulink.sdi.getAllRunIDs;
    runID = runIDs(end);
    simlogs = Simulink.sdi.exportRun(runID);
    
    % get fault and detection method signals' data
    faultSDI = simlogs.get(faultName).Values.Data;
    detectionMethodLog = simlogs.get(detectionMethodSignal).Values.Data;
    % detection method should enable one simulation step after fault trigger
    detectionMethodShift = circshift(detectionMethodLog,-1);
    detectionMethodShift(end) = detectionMethodLog(end);
    % update Spreadsheet
    detectionStatus = getCell(robotFMEADoc,rowIndex,"Detection Method");
    
    % check if Detection Method worked
    detectionMethodXORFaultActive = xor(detectionMethodShift,faultSDI);
    if any(detectionMethodXORFaultActive)
        addFlag(detectionStatus,"error",Description="Failure mode not detected during simulation.");
    else
        addFlag(detectionStatus,"check");
    end
end