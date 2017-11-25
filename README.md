### Fork of ScanImage r3.5 with customizations of the spine analysis module

This repository contains a forked version of ScanImage r3.5 with customizations
of the spine analysis module `scim_spineAnalysis`. Detailed information on the
changes made can be found inside the file `VK_changelog.md`. Changes
include:

* The calculation of spine fluorescence intensity is performed for spine pixels above background.
* A bug where the options of normalization with the `mean` or `median` fluorescence of the dendrite were swaped in the GUI is fixed.
* The stack browser allows lookup tables where the white value can exceed the hard-coded value of `2000` in order to take advantage of the full dynamic range of images acquired with 16 bits.
* The buttons in the stack browser are remapped to `W`, `A`, `S`, `D` for navigation in X and Y axes, `Q` and `E` in Z axis, `SPACE` is used to initiate a line annotation, and `R` is used to save the annotations to a pre-existing `ANN` file. Nagivation with the NumPad is preserved.

This version requires MATLAB 2014a or earlier as the fluorescence intensity module is not functioning properly due to changes in graphics rendering introduced in MATLAB 2014b.

ScanImage is a trademarked name by [Vidrio Technologies](https://vidriotechnologies.com/). I am not affiliated with Vidrio Technologies nor do I hold any copyright on ScanImage. I have, however, received written permission to upload my modified version here by Karel Svoboda, under whose supervision ScanImage was originally developed and who owns the copyright for this earlier version. I have used this modified version of ScanImage r3.5 for my research and it is provided here AS IS with no warranties in the hope that it may be useful to others.

#### **Reference**
Pologruto, T. T. a, Sabatini, B. L. B., & Svoboda, K. (2003). ScanImage: flexible software for operating laser scanning microscopes. *Biomed Eng Online*, **9**, 1–9. https://doi.org/10.1186/1475-925X-2-13
