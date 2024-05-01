# CarboCAT Lite

CarboCATLite is a reduced complexity version of the CarboCAT model of carbonate platform growth developed by Peter Burgess, see [Burgess (2013)](https://doi.org/10.1016/j.cageo.2011.08.026). CarboCATLite uses a cellular automata to model spatial competition between carbonate factories whose accumulation rates are dependent on environmental conditions (e.g., subsidence and sea level driven water depth, wave energy, etc.).

## Running Instruction

### GUI

1. In Matlab, run the command

```{matlab}
run carboCATGUI
```

This will open the CarboCATLite GUI

2. Click the "initialize" button. This will import the model parameters from the _params_ folder
3. Click the "Run CA model" button to run the model. The model status is shown in the console. The run is finished if you see the message

```{matlab}
Model complete after X iterations and ready to plot
```

in the console.

4. After the run is finished, all model outputs are in the matlab workspace, and are saved into the file _CarboCATLite_outputs.mat_.

5. To plot the results, click "plot run". This will generate the chronostratigraphic diagram and a basin transect in dip direction. Both the initial conditios and the chronostrat diagram/basin transect are automatically saved as .pdf files. WARNING: Generating the plots can take a long time. Saving the plots is finished once the message ```figure saved``` is displayed in the console.

### CLI

1. In Matlab, run the command

```{matlab}
CarboCAT_cli("params/DbPlatform/paramsInputValues.txt", "params/DbPlatform/paramsProcesses.txt",
"model_run_42", "params/DbPlatform/seaLevelConst3000iterations.txt", true)
```

Input parameters:

`ParamsPath`: string, relative path to the file with parameters, e.g. "params/DbPlatform/paramsInputValues.txt"

`ProcessPath`: string, relative path to the file with the process settings, e.g. "params/DbPlatform/paramsProcesses.txt"

`OutputName`: string, name to which model outputs are saved, e.g. "model_run_42"

`SeaLevelPath`: string, relative path to the file with the sea level curve, e.g. "params/DbPlatform/seaLevelConst3000iterations.txt"

`makePlot`: logical, true or false. Should the chronostratigraphic plot be generated?


2. After the run is finished, all model outputs are saved into the file given as `OutputName`. This file can be further analyzed using scripts in the repo [MindTheGap-ERC/CarboCAT_utils](https://github.com/MindTheGap-ERC/CarboCAT_utils).


## License and copyright

Copyright for the original code (1.0.0) 2013-2023 University of Liverpool and Royal Holloway, University of London
Copyright modifications proposed here: 2023-2024 Utrecht University, the Netherlands eScience Center and University of Liverpool

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
