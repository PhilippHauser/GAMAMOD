*Storage assessment
$ontext
         This output file assess the Storages
                  Author: Philipp Hauser
$offtext

********************************************************************************
*                SETS,  VARIABLES, PARAMETERS
********************************************************************************
* "model type", "policy" and "greengas option" depend on the respective model
*  run that is choosen in the GAMS-FIle "Settings"

*Set model_type
*--------------------------------------------------------
Set
%RCP%$ontext
$ifthen %WSP%%EEV% == "" model_type /RCP/
$endif
$ontext
$offtext

*Set pol_scenario
*--------------------------------------------------------
%no_policy%$ontext
$ifthen %national_policy%%eu_policy% == ""
         pol_scenario /noPol/
$endif
$ontext
$offtext

%no_policy%$ontext
%national_policy%$ontext
%eu_policy%$ontext
         pol_scenario /noPol, natPol, euPol/


*Set green gas policy
*-------------------------------------------------------------
%greengas%$ontext
$ifthen %no_greengas% == "" green_gas_option /GG/
$endif
$ontext
$offtext

%no_greengas%$ontext
$ifthen %greengas% == "" green_gas_option /noGG/
$endif
$ontext
$offtext
;

Parameter
Storage_country(*,*,*,co,s,t,a,j)
*LNG_country_cap(*,*,*,co,*);

*load data from results file
*$if NOT set LoadXLS $onUNDF
*$if NOT set LoadXLS $gdxin %Ordner_Source%\results\RCP_noGG_noPol
*$if NOT set LoadXLS $load
*$if NOT set LoadXLS $gdxin
*$if NOT set LoadXLS $offUNDF

Variables
STORAGE_LEVEL(co,s,t,a,j)            level
;
*-------------------------------------------------------------------------------
file fx2;
put fx2;
loop((model_type,
      green_gas_option,
      pol_scenario),

         put_utility'gdxin' / '%Ordner_Source%\results\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load STORAGE_LEVEL;

         Storage_country(model_type,green_gas_option,pol_scenario,co,s,t,a,j)=Storage_Level.l(co,s,t,a,j);
         )
;


execute_unload  '%Ordner_Source%\analysis\Storage_report.gdx'

*Display LNG_annual_sums;

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Storage_report.gdx O=%Ordner_Source%\analysis\Storage_details.xlsm par=Storage_country rng=GAMS_outputNoGG!B2 rdim=7 cdim=1';
$ontext
$offtext

%greengas%$ontext
*execute 'gdxxrw.exe %Ordner_Source%\analysis\Cost_report.gdx O=%Ordner_Source%\analysis\cost_details.xlsm par=cost_details rng=GAMS_outputGG!B2 rdim=6 cdim=0';
$ontext
$offtext
*-------------------------------------------------------------------------------