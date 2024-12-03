% Copyright 2024 The MathWorks, Inc.

function exampleHelperVisualizeExecuteRobots(f, robotPoses, wayPoints, logicalMap, startLocations, goalLocations, loadingStations, showPaths, xLim, yLim, robotMeshes)

%% Initilize working variables
map = binaryOccupancyMap(logicalMap);
numRobots = size(robotPoses, 2);
numLoad = size(loadingStations, 1);
numGoals = size(goalLocations, 1);
numStarts = size(startLocations, 1);

%% Extract data from inputs

% Construct translation from state
xyz = [robotPoses(1:2,:); zeros(1,numRobots)]; % 2-D so z is zero

% Create quaternion from rotation state
theta = robotPoses(3,:);

%% Visualize Results
ax = f.CurrentAxes;
show(map,'Parent', ax);
light
hold(ax, 'on');
plotTransforms([goalLocations, zeros(numGoals, 1)], eul2quat(zeros(numGoals, 3)), 'MeshFilePath', 'exampleWarehouseBlockExecuteTasks.stl', 'MeshColor', 'g', 'Parent', ax,'FrameSize',2);
plotTransforms([loadingStations, zeros(numLoad, 1)], eul2quat(zeros(numLoad, 3)), 'MeshFilePath', 'exampleWarehouseBlockExecuteTasks.stl', 'MeshColor', 'b', 'Parent', ax,'FrameSize',2);
plotTransforms([startLocations, zeros(numStarts, 1)], eul2quat(zeros(numLoad, 3)), 'MeshFilePath', 'exampleWarehouseBlockExecuteTasks.stl', 'MeshColor', 'k', 'Parent', ax,'FrameSize',2);
text(loadingStations(:, 1), loadingStations(:, 2), 2, 'Sorting Station', 'FontSize', 12);
text(goalLocations(:, 1), goalLocations(:, 2), ones(numGoals, 1)* 2, 'Unloading Station', 'FontSize', 12);
text(startLocations(:, 1), startLocations(:, 2), ones(numStarts, 1)* 2, 'Charging Station', 'FontSize', 12);


for robotIdx = 1:numRobots
    
    % Extract the information for the ith robot
    robotQuaternion = eul2quat([0 0 theta(robotIdx)], 'xyz');
    worldToRobotTForm = [axang2rotm([0 0 1 theta(robotIdx)]) xyz(:,robotIdx); 0 0 0 1];
    robotPathWaypoints = wayPoints(:,:,robotIdx);
    
    robotMesh = robotMeshes{1};
    meshTranslation = robotMeshes{2};
    robotTform = worldToRobotTForm*trvec2tform(meshTranslation);
    
    % Plot the robot
    plotTransforms(robotTform(1:3,4)', robotQuaternion, 'MeshFilePath', robotMesh, 'Parent', ax,'FrameSize',3);
    
    % Plot the path
    if showPaths
        plot(robotPathWaypoints(:,1), robotPathWaypoints(:,2), 'x-');
    end
end

% Select the view
xlim(xLim');
ylim(yLim');
zlim([0 2]);

drawnow;
hold(ax, 'off');
end
