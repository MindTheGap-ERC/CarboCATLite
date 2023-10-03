# CarboCATLite

CarboCATLite is a reduced complexity version of the CarboCAT model of carbonate platform growth developed by Peter Burgess, see [Burgess (2013)](https://doi.org/10.1016/j.cageo.2011.08.026). CarboCATLite uses a cellular automata to model spatial competition between carbonate factories whose accumulation rates are dependent on environmental conditions (e.g., subsidence and sea level driven water depth, wave energy, etc.).

## Running Instructions

double click on the file carboCATGUI.m to open Matlab and load this file.
Run the function either by enterting the function name carboCATGUI at the command prompt,
or by clicking run in the editor tab

The GUI should be reasonably intuitive; click on the Initialise button to set up the model
ready to run, then click on Run CA Model, then on PLot run and you should see the
results from the paramsProcess.txt and the paramsInputValues.txt input files I have set up
in the params folder. You can edit both of these files to run different models.
You can also use the code in the utilities folder to make new initial topography,
intial facies maps, sea-level curves and other inputs you might need to create
useful models

Any questions, e-mail peter.burgess [at] liverpool.ac.uk

## Author

__Peter Burgess__  
University of Liverpool  
Web page: [www.liverpool.ac.uk/environmental-sciences/staff/peter-burgess](https://www.liverpool.ac.uk/environmental-sciences/staff/peter-burgess/)  
ORCID: [0000-0002-3812-4231](https://orcid.org/0000-0002-3812-4231)  
email: peter.burgess [at] liverpool.ac.uk

## License and copyright

Copyright 2013-2023 University of Liverpool and Royal Holloway, University of London

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

## References

   Burgess, Peter M. "CarboCAT: A cellular automata model of heterogeneous carbonate strata." Computers & geosciences 53 (2013): 129-140. DOI: [10.1016/j.cageo.2011.08.026](https://doi.org/10.1016/j.cageo.2011.08.026)
