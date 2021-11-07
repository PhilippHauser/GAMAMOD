*Pipeline Import Flows
*-------------------------------------------------------------------

* Sanity checks
$if "%RCP%" == "" $abort Choose all model type options!;
$if "%RCP%%WSP%%EEV%" == "***" $abort Choose all model type options!;
$if "%RCP%%WSP%%EEV%" == "**" $abort Choose all model type options!;

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

Positive Variable
TRADE(co,cco,t,a,j)
;
Parameter
report_K2(*,*,*,a,*,*,j)
;
file fx2;
put fx2;
loop((model_type,
     green_gas_option,
     pol_scenario),
$onUNDF
         put_utility'gdxin' / '%Ordner_Source%\results\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load TRADE, coEU, coEURU, coSouRU, dem;

         report_K2(model_type,green_gas_option,pol_scenario,a,co,cco,j)=
                  sum(t,TRADE.l(co,cco,t,a,j));

$offUNDF
);

execute_unload '%Ordner_Source%\analysis\Trade.gdx' ;

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Trade.gdx O=%Ordner_Source%\analysis\Trade.xlsm par=report_K2 rng=GAMS_outputNoGG!B2 rdim=7 cdim=0';
$ontext
$offtext
*Display report_K, importRU, coEURU, coSouRU, TRADE.l
;
