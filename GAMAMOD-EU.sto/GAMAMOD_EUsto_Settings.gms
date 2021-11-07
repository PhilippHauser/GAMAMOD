*###########################################################################
*                                SETTINGS
*###########################################################################
* Last change: 07.12.2020
* By: Philipp Hauser
*###########################################################################
* Set star to activate year
$setglobal year2015 ""
$setglobal year2045 "*"
;
* Set star to activate scenarios
$setglobal no_policy ""
$setglobal national_policy "*"
$setglobal EU_policy ""
;
****************************************************************************
*Set star to activate option
$setglobal greengas ""
$setglobal no_greengas "*"
;
*comment this line to switch off the limitation of list file
*$setglobal sensGG
;
*Set star to activate option (which countries should be considered for GG)
$setglobal NAandEU "*"
$setglobal onlyNA ""
;
****************************************************************************
*Set star to activate model type
*(RCP = Recursive Problem, WSP = Wait and See, EEV = Expected Value)
$setglobal RCP "*"
$setglobal WSP ""
$setglobal EEV ""
;
****************************************************************************
*comment this line (*) to switch on/off the shock scenario setting
*$setglobal shock
;
***************************
*   Shock scenario settings
***************************
*set shock scenario (time)
$setglobal one_m ""
$setglobal three_m "*"
$setglobal six_m ""

*set shock scenario (region)
$setglobal NA_dis ""
$setglobal RU_dis "*"
****************************************************************************
*comment this line to switch off the limitation of list file
$setglobal LimitList
;
****************************************************************************
* Definition of strings for report parameters and sanity checks
* (Do not change settings below)
* Sanity checks
$if "%year2015%%year2030%" == "**" $abort Choose exactly one year option!;
$if "%year2030%%year2045%" == "**" $abort Choose exactly one year option!;
$if "%year2015%%year2045%" == "**" $abort Choose exactly one year option!;
$if "%year2030%%year2045%%year2015%" == "" $abort Choose exactly one year option! ;
$if "%greengas%%no_greengas%%sensGG%"" == "**" $abort Choose exactly one  option!;
$if "%greengas%%no_greengas%%sensGG%"" == "***" $abort Choose exactly one  option!;
$if "%greengas%%no_greengas%%sensGG%" == "" $abort Choose exactly one option! ;
$if "%year2015%%greengas%" == "**" $abort Uncompatible option of year "2015" and green gas investment! ;
