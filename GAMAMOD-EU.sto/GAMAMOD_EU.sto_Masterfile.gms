*###########################################################################
*                       GAMAMOD-EU.sto MASTER FILE
*###########################################################################
$ontext
CREATED:         25.09.2019
LAST CHANGE:     06.12.2019
AUTHOR:          Philipp Hauser

DISCLAIMER:
The model was developed within the projects KonStGas (FKZ: 0325576D)
and Erdgas-BRidGE (FKZ: 03ET4055A). A model description is provided in
Hauser (202xa). An application is given in Hauser (202xa amd 202xb).

Related Literature:

Hauser (202xa) Benefits and Costs of Diversification in the European Nautral
       Gas Market, Dissertation, sumbitted in 2020
Hauser (202xb) Does 'More' Equal 'Better' - Analyzing the Impact of
       Diversification Strategies on Infrastructure in the European Gas
       Market, submitted

$offtext
*###########################################################################
*                                I
*###########################################################################
$eolcom \\
$include GAMAMOD_EUsto_Settings
*###########################################################################
*                      AUTOMATIC PATH GENERATION
*###########################################################################
***source paths (caution: start model from mod computer 11)
*----------------------------------------
$set GMSdata     S:\PH\02_Modelle\01_GAMAMOD-EU\02_GAMAMOD-EUsto\01_GAMS_Code\01_dataload
$set GMSmodel    S:\PH\02_Modelle\01_GAMAMOD-EU\02 GAMAMOD-EU.sto (stochastisch, 2030; 2045)\01 GAMS Code\02_model
$set GMSoutp     S:\PH\02_Modelle\01_GAMAMOD-EU\02 GAMAMOD-EU.sto (stochastisch, 2030; 2045)\01 GAMS Code\03_output
$set data_path   Szenarien
*###########################################################################
*                              EXECUTION
*###########################################################################
$offlisting
$set LoadXLS
*$set RunModel
*$set RunOutputCalc
*$eval Print 33
**print1 = Tool for LNG and im- export
**print2 = prices
**print3 = Trade_DE
**print4 = LNG use
**print5 = LNG process
**print6 = Production
**print7 = Storage Dashboard
**print8 = Diversification check
*Checks
**print9 = EU Diversification Policy Check
*analysis
*------------------------------------------
**print 10 = Total Cost
**print 11 = Pipeline Investments
**print 12 = LNG and Storage investments
**print 13 = VSS + EVPI
**print 30 = GG production facilities
**print 31 = noGG WSP pipelie invest
**print 32 = noGG WSP LNG and storage invest
**print 33 = Analysis Shock

*###########################################################################
*                                GAMS OPTIONS
*###########################################################################
option ResLim = 72000;
option Iterlim = 10000000;
$ifthen set LimitList
$include LimitList
$endif
*###########################################################################
*                                LOAD DATA
*###########################################################################
$include %GMSdata%
*###########################################################################
*                           MODEL IMPLEMENTATION
*###########################################################################
$ifthen set RunModel
$include %GMSmodel%
$endif
*###########################################################################
*                              MODEL OUTPUT
*###########################################################################
$ifthen set RunOutputCalc
$include %GMSoutp%
$endif
