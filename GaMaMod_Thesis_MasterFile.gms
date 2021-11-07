*###############################################################################
*                       GaMaMod CMS 2018 master file
*###############################################################################
$ontext*
Created:         30.07.2018
Last change:     07.11.2021
* By: Philipp Hauser, Chair of Energy Economics, TU Dresden

Description:
*###############################################################################
-  Calibtarion for dissertation thesis, based on year 2015
$offtext

*###############################################################################
*                                SET DEFAULT OPTIONS
*###############################################################################
$eolcom \\

*** Version of the model (v01-v03)
*------------------------------------
$set Model_version 01 \\deterministisches Model ohne Ausbau für 2015

***Data-Input-Files       (in GaMaMod_dataload_vXX)
*-------------------------------------
$include GaMaMod_Thesis_Cal2015_v%Model_version%\Dataload_include\Basis

***Module                (in GaMaMod_model_vXX)
*----------------------------------------------
*
***Ex post calculation   (in GaMaMod_output_vXX)
*----------------------------------------------
*


*###############################################################################
*                                AUTOMATIC PATH GENERATION
*###############################################################################

***source paths
*----------------------------------------

$set GMSdata     S:\ph\GAMS\99_Thesis\2015_Kalibrierung\GAMAMOD_Thesis_Cal2015_v%Model_version%\GaMaMod_Thesis_Cal2015_dataload_v%Model_version%
$set GMSmodel    S:\ph\GAMS\99_Thesis\2015_Kalibrierung\GAMAMOD_Thesis_Cal2015_v%Model_version%\GaMaMod_Thesis_Cal2015_model_v%Model_version%
$set GMSoutp     S:\ph\GAMS\99_Thesis\2015_Kalibrierung\GAMAMOD_Thesis_Cal2015_v%Model_version%\GaMaMod_Thesis_Cal2015_output_v%Model_version%


$set data_path   %Ordner_Source%

***Results-Files
*--------------------------------------
*$set resultfile  S:\ph\GAMS\FZJ-TUD_(2015)\GaMaMod_v%Model_version%\output\results
*$set tradefile   S:\ph\GAMS\FZJ-TUD_(2015)\GaMaMod_v%Model_version%\output\Trade_neighbouring_countries
*$set toolfile    S:\ph\GAMS\FZJ-TUD_(2015)\GaMaMod_v%Model_version%\output\Tool_Importströme

*###############################################################################
*                              Executution
*###############################################################################
*$set LoadXLS
$set RunModel
$set RunOutputCalc
$eval Print 7

**print1 = Tool for LNG and im- export
**print2 = prices
**print3 = Trade_DE
**print4 = LNG use
**print5 = LNG process
**print6 = Production
**print7 = Storage Dashboard


*###############################################################################
*                                GAMS OPTIONS
*###############################################################################

*no options choosen

option ResLim = 36000;
option Iterlim = 10000000;


*###############################################################################
*                                LOAD DATA
*###############################################################################

$include %GMSdata%
         \\ lädt GaMaMod_Thesis_Cal2015_dataload
         \\ wenn "$set LoadXLS" aktiviert, dann wird GDX erstellt

*###############################################################################
*                                Model implementation
*###############################################################################

$ifthen set RunModel
$include %GMSmodel%
$endif

*###############################################################################
*                                Model output
*###############################################################################
$ifthen set RunOutputCalc
$include %GMSoutp%
$endif
