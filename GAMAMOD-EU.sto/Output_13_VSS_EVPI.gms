*Stochhastic Solution Measures
$ontext
         This output file assess the measures for stochhastic solution

         Author: Philipp Hauser
$offtext

********************************************************************************
*                SETS,  VARIABLES, PARAMETERS
********************************************************************************
* "model type", "policy" and "greengas option" depend on the respective model
*  run that is choosen in the GAMS-FIle "Settings"

*Set model_type
*--------------------------------------------------------
* Sanity checks
$if "%RCP%%WSP%%EEV%" == "" $abort Choose all model type options!;
$if "%RCP%%WSP%%EEV%" == "*" $abort Choose all model type options!;
$if "%RCP%%WSP%%EEV%" == "**" $abort Choose all model type options!;


Set
%RCP%$ontext
%WSP%$ontext
%EEV%$ontext
         model_type /RCP, WSP, EEV/
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

Variable
COST;
*KONV_LNG(*,*,*);

Parameters
cost_report(*,*,*)
evaluation_report(*,*,*)
;
*-------------------------------------------------------------------------------
file fx2;
put fx2;
loop((model_type,
      green_gas_option,
      pol_scenario),

         COST.l = 0;
         put_utility'gdxin' / '%Ordner_Source%\results\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_loaddc COST;

         cost_report (model_type,green_gas_option,pol_scenario) = COST.l;

)
;
execute_unload  '%Ordner_Source%\analysis\TotalCosts_report.gdx'

loop((model_type,
      green_gas_option,
      pol_scenario),

      evaluation_report('RP', green_gas_option, pol_scenario) =
         cost_report ('RCP',green_gas_option, pol_scenario);

      evaluation_report('WS', green_gas_option, pol_scenario) =
         cost_report ('WSP',green_gas_option, pol_scenario);

      evaluation_report('EEV', green_gas_option, pol_scenario) =
         cost_report ('EEV',green_gas_option, pol_scenario);

      evaluation_report('EVPI', green_gas_option, pol_scenario) =
         cost_report ('RCP',green_gas_option, pol_scenario)
         -   cost_report ('WSP',green_gas_option, pol_scenario);

      evaluation_report('VSS', green_gas_option, pol_scenario) =
         cost_report ('EEV',green_gas_option, pol_scenario)
         -   cost_report ('RCP',green_gas_option, pol_scenario)

)
;
execute_unload  '%Ordner_Source%\analysis\TotalCosts_report.gdx'


%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\TotalCosts_report.gdx O=%Ordner_Source%\analysis\EVPI+VSS.xlsm par=evaluation_report rng=GAMS_outputNoGG!B2 rdim=3 cdim=0';
$ontext
$offtext

%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\TotalCosts_report.gdx O=%Ordner_Source%\analysis\EVPI+VSS.xlsm par=evaluation_report rng=GAMS_outputGG!B2 rdim=3 cdim=0';
$ontext
$offtext
