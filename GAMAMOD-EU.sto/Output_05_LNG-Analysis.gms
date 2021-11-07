*LNG assessment
$ontext
         This output file assess the LNG supply and LNG extension.
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
LNG_annual_sums(*,*,*,*,co,a,j)
LNG_country(*,*,*,co,cco,a,j)
LNG_country_cap(*,*,*,co,*);

*load data from results file
$if NOT set LoadXLS $onUNDF
$if NOT set LoadXLS $gdxin %Ordner_Source%\results\RCP_noGG_noPol
$if NOT set LoadXLS $load  LNG_imp_d
$if NOT set LoadXLS $gdxin
$if NOT set LoadXLS $offUNDF

Variables
KONV_pip(co,cco,a,j)                 continous variable for pipeline extension
KONV_lng(co,a,j)                     continous variable for LNG import extension
KONV_sto(co,s,a,j)
KONV_prod(co,a,l,j)
PQ(co,l,t,a,j)
TRADE(co,cco,t,a,j)
LNG(cco,co,t,a,j)
Dummy_value(co,t,a,j)
;
*-------------------------------------------------------------------------------
file fx2;
put fx2;
loop((model_type,
      green_gas_option,
      pol_scenario),

         put_utility'gdxin' / '%Ordner_Source%\results\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load KONV_lng, LNG;

         LNG_country(model_type,green_gas_option,pol_scenario,co,cco,a,j)=sum(t,LNG.l(co,cco,t,a,j));
         LNG_country_cap(model_type,green_gas_option,pol_scenario,co,'2030')=KONV_lng.l(co,'2030','j1')+LNG_imp_d(co)*365;
         LNG_country_cap(model_type,green_gas_option,pol_scenario,co,'2045')=KONV_lng.l(co,'2030','j1')+KONV_lng.l(co,'2045','j1')+LNG_imp_d(co)*365;
         LNG_country_cap(model_type,green_gas_option,pol_scenario,co,'2015')=LNG_imp_d(co)*365;

         LNG_annual_sums(model_type,green_gas_option,pol_scenario,'import',co,a,j)=sum((cco,t),LNG.l(co,cco,t,a,j));
         LNG_annual_sums(model_type,green_gas_option,pol_scenario,'export',co,a,j)=sum((cco,t),LNG.l(cco,co,t,a,j));
         )
;


execute_unload  '%Ordner_Source%\analysis\LNG_report.gdx'

*Display LNG_annual_sums;

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\LNG_report.gdx O=%Ordner_Source%\analysis\LNG_details.xlsm par=LNG_annual_sums rng=GAMS_outputNoGG!B2 rdim=7 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\LNG_report.gdx O=%Ordner_Source%\analysis\LNG_details.xlsm par=LNG_country rng=GAMS_outputNoGG!O2 rdim=7 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\LNG_report.gdx O=%Ordner_Source%\analysis\LNG_details.xlsm par=LNG_country_cap rng=GAMS_outputNoGG!Z2 rdim=5 cdim=0';
$ontext
$offtext

%greengas%$ontext
*execute 'gdxxrw.exe %Ordner_Source%\analysis\Cost_report.gdx O=%Ordner_Source%\analysis\cost_details.xlsm par=cost_details rng=GAMS_outputGG!B2 rdim=6 cdim=0';
$ontext
$offtext
*-------------------------------------------------------------------------------

