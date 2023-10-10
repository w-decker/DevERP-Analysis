# DevERP-Analysis

<!--Buttons-->
## Description
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=w-decker/DevERP-Analysis)

Analysis code used to in the [DevERP Simplified](https://github.com/w-decker/DevERP-Simplified) project.

This repository houses the analysis code for the DevERP project. Below is a table detailing each `.m` file directly necessary for analyzing the standard measurement error (SME)-- one of the metrics of data quality defined in this particular study. 

| File                                   | Description                                                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| [main.m](main.m)                       | Main file for analysis.                                                                                                              |
| [analyzeSME2.m](analyzeSME2.m)         | Function for analyzing standarized measurement error (SME) in ERP data                                                               |
| [epochWrapper.m](epochWrapper.m)       | Wrapper function for epoching each dataset to prepare for SME analysis. See epoch[param].m files for individual epoching procedures. |
| [checkeventcodes.m](checkeventcodes.m) | Iterates through all raw data files to determine which paradigm they belong to.                                                      |

## Open in MATLAB Online
You now have the ability to integrate GitHub and MATLAB online with a valid MATLAB license. The button provided at the top of this file allows you to directly interact with the MATLAB code in this repository in MATLAB's online platform.
