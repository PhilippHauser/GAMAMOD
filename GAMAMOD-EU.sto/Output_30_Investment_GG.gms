*Investment in LNG import terminals and storages - analysis
*Output_30

Set

model_type /RCP/
green_gas_option /GG/
pol_scenario /noPol/
CO2price /025, 035, 050, 060, 070, 080, 100, 150, 200, 300, 450/
region /NA, all/
;

Variables
KONV_prod(co,a,l,j)
;

Parameters
exp_sto_costs(co,s)
cost_details(*,*,*,*,*,*)
invest_report_GG(*,*,*,*,*,co,a,j)
p_c(co,a,l,j)
tr_costs(co,cco)
lng_costs(co,cco,a,j)
;

KONV_prod.l(co,a,l,j) = 0;


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
      pol_scenario,
      CO2price,
      region),

         put_utility'gdxin' / 'S:\PH\GAMS\99_Thesis\2015-2050_Expansion\Szenarien\results\saved_results#\2020.10.14_GreenGas\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0 '_' region.tl:0 '_' CO2price.tl:0 '_EUR-CO2';
         execute_load KONV_prod;

         invest_report_GG (model_type,green_gas_option, pol_scenario, region, CO2price, co, a,'j1') = sum(l,KONV_prod.l(co,a,l,'j1'));

);

execute_unload  '%Ordner_Source%\analysis\Invest_report_GG.gdx'


%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_GG.gdx O=%Ordner_Source%\analysis\invest_report_GG.xlsm par=invest_report_GG rng=GAMS_outputGG!B2 rdim=8 cdim=0';
$ontext
$offtext