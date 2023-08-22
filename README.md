# CarboCAT Lite

CarboCATLite is a reduced complexity version of the CarboCAT model of carbonate platform growth developed by Peter Burgess, see [Burgess (2013)](https://doi.org/10.1016/j.cageo.2011.08.026). CarboCATLite uses a cellular automata to model spatial competition between carbonate factories whose accumulation rates are dependent on environmental conditions (e.g., subsidence and sea level driven water depth, wave energy, etc.).

## Running Instruction

1. In Matlab, run the command

```{matlab}
CarboCAT_cli("params\DbPlatform\paramsInputValues.txt", "params\DbPlatform\paramsProcesses.txt", "model_run_42", "params\DbPlatform\seaLevelConst3000iterations.txt", true)
```

Input parameters:

`ParamsPath`: string, relative path to the file with parameters, e.g. "params\DbPlatform\paramsInputValues.txt"

`ProcessPath`: string, relative path to the file with the process settings, e.g. "params\DbPlatform\paramsProcesses.txt"

`OutputName`: string, name to which model outputs are saved, e.g. "model_run_42"

`SeaLevelPath`: string, relative path to the file with the sea level curve, e.g. "params\DbPlatform\seaLevelConst3000iterations.txt"

`makePlot`: logical, true or false. Should the chronostratigraphic plot be generated?

2. After the run is finished, all model outputs are saved into the file given as `OutputName`.

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
