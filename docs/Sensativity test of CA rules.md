# Sensaitivity test of changing the CA rules
**bold text**

The model CarboCAT (Burgess 2013) used Cellular Automata (CA) rules to simulate the biological competetion among different carbonate factories during the carbonate platform growth. In this model, three basic Facies are considered: T, M and C, representing facies code 1, 2 and 3, respectively. 

In the CA rules, the current facies distribution depends on the previous facies distribution: a facies could only exist if the amount of same facies in the neighboring cells are in a certain range (I would say 'comfortable range' in the following text). For example, if not enough same facies (species) are in the neighborhood, the species in this cell would die out. If too much same species in the neighborhood, this cell would also die out because of competition. It looks like a reasonable assertion. However, actual values of thecomfortable range is hardly determined, and herein we would like to show that the choice of the values are important: the model outputs are very sensitive to the CA rules.

The default CA rules are listed in the following table. Prodction CA (no wave selection process is involved).

| Dist | Min Neighbors | Max Neighbors | Min Triggers | Max Triggers | Facies code |
|....|.............|.............|............|............|...........|
|2|2|10|4|10|1|
|2|4|10|6|10|2|
|2|4|10|6|10|3|

## Scenario 1
We first tested the scenario 1 to increase the tolerance of species (i.e., facies) in over-crowded settings:

| Dist | Min Neighbors | Max Neighbors | Min Triggers | Max Triggers | Facies code |
| ----- | ------- | ---- |----- | --------- | ----- |
| 2 | 2 | 16 | 4 | 16 | 1 |
| 2 | 4 | 16 | 6 | 16 | 2 |
| 2 | 4 | 16 | 6 | 16 | 3 |

Note that this amendments are randomly choosed, and aim to just look how sensative the CA does in the reef evolution process.

We extracted the horizontal slices from this scenarios.

![iteration = 10, maxneighbor = 16] (https://osf.io/ngq9b)
<figurecaption> iteration = 10, maxneighbor = 16.

![iteration = 100, maxneighbor = 16] (https://osf.io/guz7m)
<figurecaption> iteration = 100, maxneighbor = 16.

![iteration = 500, maxneighbor = 16] (https://osf.io/27umk)
<figurecaption> iteration = 500, maxneighbor = 16.

![iteration = 1000, maxneighbor = 16] (https://osf.io/w7ehb)
<figurecaption> iteration = 1000, maxneighbor = 16.

![iteration = 1500, maxneighbor = 16] (https://osf.io/5wzcd)
<figurecaption> iteration = 1500, maxneighbor = 16.

![iteration = 2000, maxneighbor = 16] (https://osf.io/czfq8)
<figurecaption> iteration = 2000, maxneighbor = 16.

In this trial, we can clearly see that the dominated species changes from red to green and then red again. Potentially, such transformations are relatde to sea-level oscillations.

## Scenario 2
We then tested scenario 2, decreasing the tolerance of species in over-corowded settings:

| Dist | Min Neighbors | Max Neighbors | Min Triggers | Max Triggers | Facies code |
| ----- | ------- | ---- |----- | --------- | ----- |
| 2 | 2 | 8 | 4 | 8 | 1 |
| 2 | 4 | 8 | 6 | 8 | 2 |
| 2 | 4 | 8 | 6 | 8 | 3 |

We extracted the horizontal slices from this scenarios.

![iteration = 10, maxneighbor = 8] (https://osf.io/ryvha)
<figurecaption> iteration = 10, maxneighbor = 8.

![iteration = 100, maxneighbor = 8] (https://osf.io/j4n7z)
<figurecaption> iteration = 100, maxneighbor = 8.
https://osf.io/ujhm4
![iteration = 500, maxneighbor = 8] (https://osf.io/ujhm4)
<figurecaption> iteration = 500, maxneighbor = 8.

![iteration = 1000, maxneighbor = 8] (https://osf.io/bk5ft)
<figurecaption> iteration = 1000, maxneighbor = 8.

This carbonate platform then drowns at iteration = ~1200, completely different from the previous scenario.

## Some thoughts
It seems that, CA rules could significantly influence the evolution of carbonate platform: smaller range of tolerance would increase the competetionamong the organisms, and drown the platform. This means that it is vital to choose a resonable rule for CA.

