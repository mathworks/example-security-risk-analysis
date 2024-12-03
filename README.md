# Example of Security Threat and Risk Analysis with MATLAB and Simulink
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=cannyp3/example-security-risk-analysis&project=Robot.prj)

This project demonstrates a simplified model-based security threat and risk analysis in MATLAB&reg; and Simulink&reg;.

It demonstrates how to:
 * identify assets and threats (STRIDE method) in an architectural model,
 * estimate the feasibility of attack (simplified method),
 * automatically calculate security risk (simplified method),
 * define countermeasures and allocate security goals to the model,
 * validate the completeness and consistenty of the risk analysis,
 * obtain information on the effectiveness of the countermeasure with attack simulation,
 * update the risk analysis and identify stale data,
 * export results to Excel.

 The advantages of a model-based risk analysis are:
 * rich, extensible and customizable threat meta-model
   * tabular views with links to models and requirements
   * validation of tables for completeness and consistency
   * custom analysis and validation functions with the full power of MATLAB
 * traceability from model to risk to countermeasures
   * allocate vulnerabilities and security goals/countermeasures to model
   * trace all relationships through the risk model
 * consistency: co-evolves the system and risk analysis
   * automatically picks up new assets from model
   * staleness checks
   * change analysis
 * security guidance:
   * suggests threats based on the STRIDE model
   * dominance analysis to focus on the driving risk factors
 * synergy with other MathWorks products
   * link to safety impacts from FHA
   * attacks can be simulated (attack library, non-intrusive)
   * countermeasures and their effectiveness can be simulated (e.g., ID(P)S)
   * end-to-end tracability from high-level requirements to source code


## Prerequisites and Installation
For this tutorial to work you either need to use MATLAB Online or if you using a desktop installation make sure is at least R2024b Update1.
The following products are needed in order for this example to function correctly: 
 * MATLAB&reg;
 * Simulink&reg;
 * System Composer&trade;
 * Simulink Fault Analyzer&trade;
 * Requirements Toolbox&trade;
 * Stateflow&reg;
 * Navigation Toolbox&trade;

## Usage
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=cannyp3/example-security-risk-analysis&project=Robot.prj)

To get started, open the project `Robot.prj`. If the live script did not open yet, click "openTutorial" in the project shortcuts, or open `doc/Tutorial.mlx`.

## Disclaimer and Applicability
This project is a simplified, industry-agnostic example for security risk and threat analysis. 
It is provided without any implied guarantees, to demonstrate product features and workflows.
If you are interested in applying this workflow to a specific industry or certification standard, contact [MathWorks](mailto:embedded-security@groups.mathworks.com) to obtain the appropriate support package.