# CarboCAT Lite

Lite version of the CarboCAT model by Peter Burgess. See also Burgess (2013).

## Running Instruction

1. Run the file _carboCATGUI.m_ in Matlab
2. Click the "initialize" button. This will get the model parameters
3. Click the "Run CA model" button to run the model. The model status is shown in the console
4. After the run is finished, all model outputs appear in the matlab workspace
5. To plot the results, click "plot run". WARNING: Generating the plots can take a long time.

## Branches

The branch "archive_original_version" is read only. It contains a version of CarboCAT Lite last modified on the 15th Feb 2021.

## Old README

Content of the old README.txt file:

"double click on the file carboCATGUI.m to open Matlab and load this file.
Run the function either by enterting the function name carboCATGUI at the command prompt,
or by clicking run in the editor tab

The GUI should be reasonably intuitive; click on the Initialise button to set up the model
ready to run, then click on Run CA Model, then on PLot run and you should see the
results from the paramsProcess.txt and the paramsInputValues.txt input files I have set up
in the params folder. You can edit both of these files to run different models.
You can also use the code in the utilities folder to make new initial topography,
intial facies maps, sea-level curves and other inputs you might need to create
useful models

Any questions, e-mail peter.burgess@liverpool.ac.uk"

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
   Burgess, Peter M. "CarboCAT: A cellular automata model of heterogeneous carbonate strata." Computers & geosciences 53 (2013): 129-140.
