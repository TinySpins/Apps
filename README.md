## Apps
Tiny standalone Matlab applications for macOS and Windows. Mostly without a GUI.

These applications are contained in single scripts, but often have several dependencies that are not published in this repository. The dependencies can be accessed by downloading and installing the available packages for each application.

Generally, these applications are only useful for very specific use cases. So basically, if I did not personally ask you to get a specific application from this repository to use, the applications probably wont be of any use to you.

The different applications are described below.


### ViewAcqTime.m
Application for extraction and visualization of the AcquisitionTime DICOM tag for two series of cardiac MRI data. One labelled Rest and one labelled Stress. The application uses the naming of the directories for identifying and sorting files. Therefore the data directories for both scans must be located in the same main folder. Each of these directories must contain the string 'AcqTime' as part of their name. Additionally, the Rest and Stress scan directory must contain the string 'Rest' or 'Stress' as part of their name, respectively. The name of the main folder does not matter.
