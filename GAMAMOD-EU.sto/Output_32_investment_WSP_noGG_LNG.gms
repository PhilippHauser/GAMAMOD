*Investment in LNG import terminals and storages - WSP analysis
*Output_32


Set

model_type /WSP/
green_gas_option /noGG/
pol_scenario /noPol, natPol, euPol/
;

Variables
KONV_lng(co, a,j)
KONV_sto(co,s,a,j)
;

Parameters
exp_sto_costs(co,s)
cost_details(*,*,*,*,*,*)
invest_report_WSP_noGG_lng(*,*,*,co,a,j)
invest_report_WSP_noGG_sto(*,*,*,co,s,a,j)
p_c(co,a,l,j)
tr_costs(co,cco)
lng_costs(co,cco,a,j)
;

KONV_lng.l(co, a,j)=0;
KONV_sto.l(co,s,a,j)=0;


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
         execute_load KONV_sto, KONV_lng;

         invest_report_WSP_noGG_lng (model_type,green_gas_option, pol_scenario, co, a,j) = KONV_lng.l(co,a,j);
         invest_report_WSP_noGG_sto (model_type,green_gas_option, pol_scenario, co, s, a, j) = KONV_sto.l(co,s,a,j);

);

execute_unload  '%Ordner_Source%\analysis\Invest_report_WSP_noGG_lng-sto.gdx'


%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_WSP_noGG_lng-sto.gdx O=%Ordner_Source%\analysis\invest_report_lng_WSP_noGG.xlsm par=invest_report_WSP_noGG_lng rng=LNG_WSP!B2 rdim=6 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_WSP_noGG_lng-sto.gdx O=%Ordner_Source%\analysis\invest_report_lng_WSP_noGG.xlsm par=invest_report_WSP_noGG_sto rng=STO_WSP!B2 rdim=7 cdim=0';
$ontext
$offtext


