*Analysis of Shock Scenario
*Output_33

Set
pol_scenario /noPol, natPol, euPol/
shockRegion /RU, NA/                                \\RU Rssia, NA North Aftrica
shockDuration /1M, 2M, 3M, 6M/
;

Variables
Dummy_value(co,t,a,j)
;

Parameters
exp_sto_costs(co,s)
cost_details(*,*,*,*,*,*)
VOLL_report_RCP_noGG(*,*,*,co,a,j)
p_c(co,a,l,j)
tr_costs(co,cco)
lng_costs(co,cco,a,j)
;

Dummy_value.l(co,t,a,j) = 0;


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
loop((pol_scenario,
         shockRegion,
         shockDuration),

         Dummy_value.l(co,t,a,j) = 0;
         put_utility'gdxin' / 'S:\PH\GAMS\99_Thesis\2015-2050_Expansion\Szenarien\results\saved_results#\2020.10.09_Shock\RCP_noGG_' pol_scenario.tl:0 '_shock_' shockRegion.tl:0 '_' shockDuration.tl:0;
         execute_load Dummy_value;

         VOLL_report_RCP_noGG (pol_scenario, shockRegion, shockDuration, co, a,j) = sum(t,Dummy_value.l(co,t,a,j));

);

execute_unload  '%Ordner_Source%\analysis\VOLL_report_RCP_noGG.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\VOLL_report_RCP_noGG.gdx O=%Ordner_Source%\analysis\VOLL_report_RCP_noGG.xlsm par=VOLL_report_RCP_noGG rng=GAMS_outputNoGG!B2 rdim=6 cdim=0';
