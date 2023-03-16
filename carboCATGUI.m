
% CarboCATLite is a reduced functionality version of CarboCAT2018 based on a
% version of the code from 2016 produced by Burgess, Koslowski and
% Antonatos, tidied up and recoded in parts by Burgess 2020, to run quickly
% and with a focus on 2d section output

graph.main = 0;
graph.f1 = 0;
graph.f2 = 0;
graph.f3 = 0;
graph.f4 = 0;
graph.f5 = 0;
graph.f6 = 0;
%graph.mapMovie = zeros(1,glob.maxIts);

% Create initial members of global structures used throughout the code,
% only those that are needed for the initial GUI display
glob.modelName = '';
glob.xSize = 10;
glob.ySize = 100;
stats.totalFaciesVolume = 0;

%process parameters
% glob.productionProfile='' ;
% glob.CARoutine='';
% glob.transportationRoutine='';
% glob.siliciclasticsRoutine='';
% glob.concentrationRoutine='';
% glob.soilRoutine='';
% glob.transportFaciesRoutine='';
% glob.refloodingRoutine='';
% glob.seaLevelRoutine='';
% glob.wrapRoutine='';

set(0,'RecursionLimit',1000);

glob = initializeGUI(glob, stats, graph);







