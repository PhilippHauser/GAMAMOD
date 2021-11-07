*Investment in LNG import terminals and storages - analysis
*Output_12

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
$ifthen %national_policy%%eu_policy% == "" pol_scenario /noPol/
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

Parameters
exp_sto_costs(co,s)
cost_details(*,*,*,*,*,*)
invest_report_pip(*,*,*,co,cco,a,j)
invest_report_lng(*,*,*,co,a,j)
invest_report_sto(*,*,*,co,s,a,j)
p_c(co,a,l,j)
tr_costs(co,cco)
lng_costs(co,cco,a,j)
;

KONV_pip.l(co,cco,a,j) = 0;


$if NOT set LoadXLS $onUNDF
$if NOT set LoadXLS $gdxin %Ordner_Source%\%data%
$if NOT set LoadXLS $load  exp_sto_costs
$if NOT set LoadXLS $gdxin
$if NOT set LoadXLS $offUNDF

$if NOT set LoadXLS $onUNDF
$if NOT set LoadXLS $gdxin %Ordner_Source%\results\RCP_noGG_noPol
$if NOT set LoadXLS $load  p_c tr_costs lng_costs exp_pip_costs tr_length exp_lng_costs
$if NOT set LoadXLS $gdxin
$if NOT set LoadXLS $offUNDF

*-------------------------------------------------------------------------------
file fx2;
put fx2;
loop((model_type,
      green_gas_option,
      pol_scenario),

         put_utility'gdxin' / '%Ordner_Source%\results\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load KONV_pip, KONV_sto, KONV_lng, KONV_prod, PQ, TRADE, LNG, Dummy_value;

         invest_report_lng (model_type,green_gas_option, pol_scenario, co, a,j) = KONV_lng.l(co,a,j);
         invest_report_sto (model_type,green_gas_option, pol_scenario, co, s, a, j) = KONV_sto.l(co,s,a,j);
);

execute_unload  '%Ordner_Source%\analysis\Invest_report_lng.gdx'


%no_greengas%$ontext
*execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_pip.gdx O=%Ordner_Source%\analysis\invest_report_pip.xlsm par=invest_report_pip rng=GAMS_outputNoGG!B2 rdim=7 cdim=0';
*execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_pip.gdx O=%Ordner_Source%\analysis\cost_details.xlsm par=cost_details rng=GAMS_outputNoGG!B2 rdim=6 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_lng.gdx O=%Ordner_Source%\analysis\invest_report_lng.xlsm par=invest_report_lng rng=GAMS_outputNoGG!B2 rdim=6 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_lng.gdx O=%Ordner_Source%\analysis\invest_report_sto.xlsm par=invest_report_sto rng=GAMS_outputNoGG!B2 rdim=7 cdim=0';
$ontext
$offtext
