% open model
open("WareHouseTaskRobotArchitecture")

% open sheets
sheets = ["07 Security Analysis/assets.mldatx", ...
          "07 Security Analysis/threats.mldatx", ...
          "07 Security Analysis/countermeasures.mldatx", ...
          "04 Safety Analysis/RobotHazardAssessment.mldatx"
      ];
startSafetyAnalysisManager(sheets);