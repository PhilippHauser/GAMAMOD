*Investment in Pipelines
*Output_11.2

Set

model_type /WSP/
green_gas_option /noGG/
pol_scenario /noPol, natPol, euPol/
;

Variables
KONV_pip(co,cco,a,j)
;

Parameters
exp_sto_costs(co,s)
cost_details(*,*,*,*,*,*)
invest_report_WSP_noGG(*,*,*,co,cco,a,j)
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

         put_utility'gdxin' / 'S:\PH\GAMS\99_Thesis\2015-2050_Expansion\Szenarien\results\saved_results#\2020.07.24_EnergyPolicy Paper\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load KONV_pip;

         invest_report_WSP_noGG (model_type,green_gas_option, pol_scenario, co,cco, a,j) = KONV_pip.l(co,cco,a,j);

);

execute_unload  '%Ordner_Source%\analysis\Invest_report_WSP_noGG.gdx'


%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_WSP_noGG.gdx O=%Ordner_Source%\analysis\invest_report_WSP_noGG.xlsm par=invest_report_WSP_noGG rng=GAMS_outputNoGG!B2 rdim=7 cdim=0';
$ontext
$offtext