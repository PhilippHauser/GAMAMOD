*infrastructure (KONV_pip, KONV_sto, KONV_lng, KONV_prod)
*DUMMY Variable
*Cost - aufgeschlüsselt (Investment, Production, ...)

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
$if NOT set LoadXLS $load  p_c tr_costs lng_costs
$if NOT set LoadXLS $gdxin
$if NOT set LoadXLS $offUNDF



*no Policy
*1.1 No Policy, green gas, RCP
execute_load 'S:\PH\GAMS\99_Thesis\2015-2050_Expansion\Szenarien\results\saved_results#\2020.10.14_GreenGas\RCP_GG_noPol_all_200_EUR-CO2', KONV_pip;
%no_policy%$ontext
%greengas%$ontext
%RCP%$ontext

invest_report_pip ('RCP','GG', 'no_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext

*1.3 No Policy, no green gas, RCP
execute_load '%Ordner_Source%\results\RCP_noGG_noPol', KONV_pip, KONV_sto, KONV_lng, KONV_prod, PQ, TRADE, LNG, Dummy_value;
%no_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext

cost_details('RCP','no_GG', 'no_Pol','2.1_prod_costs',a,j)=sum((co,l,t),PQ.l(co,l,t,a,j)*p_c(co,a,l,j));
cost_details('RCP','no_GG', 'no_Pol','2.2_trade_costs',a,j)=sum((co,cco,t),TRADE.l(co,cco,t,a,j)*tr_costs(co,cco));
cost_details('RCP','no_GG', 'no_Pol','2.3_LNG_costs',a,j)=sum((co,cco,t),LNG.l(cco,co,t,a,j)*lng_costs(co,cco,a,j));
**lng_costs(cco,co,a,j
cost_details('RCP','no_GG', 'no_Pol','2.4_VOLL_costs',a,j)=sum((co,t),Dummy_value.l(co,t,a,j)*Dummy);

cost_details('RCP','no_GG', 'no_Pol','1.4_exp_prod',a,j)=sum((co,l),KONV_prod.l(co,a,l,j)*1000);
cost_details('RCP','no_GG', 'no_Pol','1.2_exp_LNG',a,j)=sum(co,KONV_lng.l(co,a,j)*21090);
cost_details('RCP','no_GG', 'no_Pol','1.3_exp_storages',a,j)=sum((co,s),KONV_sto.l(co,s,a,j)*exp_sto_costs(co,s));
cost_details('RCP','no_GG', 'no_Pol','1.1_exp_pipelines',a,j)=sum((co,cco),KONV_pip.l(co,cco,a,j)*14.32);

invest_report_pip ('RCP','no_GG', 'no_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext

*1.4 No Policy, no green gas, WSP
execute_load '%Ordner_Source%\results\WSP_noGG_noPol', KONV_pip;
%no_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
invest_report_pip ('WSP','no_GG', 'no_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext



**********************************************************
*1.3 nat Policy, no green gas, RCP
execute_load '%Ordner_Source%\results\RCP_noGG_natPol', KONV_pip;
%national_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
invest_report_pip ('RCP','no_GG', 'nat_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext

*1.4 national Policy, no green gas, WSP
execute_load '%Ordner_Source%\results\WSP_noGG_natPol', KONV_pip;
%national_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
invest_report_pip ('WSP','no_GG', 'nat_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext


*1.3 eu Policy, no green gas, RCP
execute_load '%Ordner_Source%\results\RCP_noGG_euPol', KONV_pip;
%eu_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
invest_report_pip ('RCP','no_GG', 'eu_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext

*1.4 eu Policy, no green gas, WSP
execute_load '%Ordner_Source%\results\WSP_noGG_euPol', KONV_pip;
%eu_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
invest_report_pip ('WSP','no_GG', 'eu_Pol', co,cco,a,j) = KONV_pip.l(co,cco,a,j);
$ontext
$offtext

execute_unload  '%Ordner_Source%\analysis\Invest_report_pip.gdx'

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_pip.gdx O=%Ordner_Source%\analysis\invest_report_pip.xlsm par=invest_report_pip rng=GAMS_outputNoGG!B2 rdim=7 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_pip.gdx O=%Ordner_Source%\analysis\cost_details.xlsm par=cost_details rng=GAMS_outputNoGG!B2 rdim=6 cdim=0';
$ontext
$offtext

%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Invest_report_pip.gdx O=%Ordner_Source%\analysis\invest_report_pip.xlsm par=invest_report_pip rng=GAMS_outputGG!B2 rdim=7 cdim=0';
$ontext
$offtext

*Display invest_report_pip, cost_details, exp_sto_costs
