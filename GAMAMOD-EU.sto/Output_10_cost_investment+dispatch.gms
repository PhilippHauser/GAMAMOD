*Cost assessment
$ontext
         This output file assess the dispatch and investment costs.

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
*parameters from model in order to load data
exp_sto_costs(co,s)
p_c(co,a,l,j)
tr_costs(co,cco)
lng_costs(co,cco,a,j)

*"new" parameters fro writing in EXCEL
cost_details(*,*,*,*,*,*)
;

*load data from data input
$if NOT set LoadXLS $onUNDF
$if NOT set LoadXLS $gdxin %Ordner_Source%\%data%
$if NOT set LoadXLS $load  exp_sto_costs
$if NOT set LoadXLS $gdxin
$if NOT set LoadXLS $offUNDF

*load data from results file
$if NOT set LoadXLS $onUNDF
$if NOT set LoadXLS $gdxin %Ordner_Source%\results\RCP_noGG_noPol
$if NOT set LoadXLS $load  p_c tr_costs lng_costs exp_pip_costs tr_length exp_lng_costs exp_prod_costs
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

         cost_details(model_type,green_gas_option,pol_scenario,'2.1_prod_costs',a,j)=sum((co,l,t),PQ.l(co,l,t,a,j)*p_c(co,a,l,j));
         cost_details(model_type,green_gas_option,pol_scenario,'2.2_trade_costs',a,j)=sum((co,cco,t),TRADE.l(co,cco,t,a,j)*tr_costs(co,cco));
         cost_details(model_type,green_gas_option,pol_scenario,'2.3_LNG_costs',a,j)=sum((co,cco,t),LNG.l(cco,co,t,a,j)*lng_costs(co,cco,a,j));
         cost_details(model_type,green_gas_option,pol_scenario,'2.4_VOLL_costs',a,j)=sum((co,t),Dummy_value.l(co,t,a,j)*Dummy);

         cost_details(model_type,green_gas_option,pol_scenario,'1.4_exp_prod',a,j)=sum((co,l),KONV_prod.l(co,a,l,j)*exp_prod_costs(co,a,l));
         cost_details(model_type,green_gas_option,pol_scenario,'1.2_exp_LNG',a,j)=sum(co,KONV_lng.l(co,a,j)*exp_lng_costs(co));
         cost_details(model_type,green_gas_option,pol_scenario,'1.3_exp_storages',a,j)=sum((co,s),KONV_sto.l(co,s,a,j)*exp_sto_costs(co,s));
         cost_details(model_type,green_gas_option,pol_scenario,'1.1_exp_pipelines',a,j)=sum((co,cco),KONV_pip.l(co,cco,a,j)*365*exp_pip_costs(co,cco)         \\ KONV_pip [GWh/d] * 365 = yearly transport capacity
                         *tr_length(co,cco));
)
;


execute_unload  '%Ordner_Source%\analysis\Cost_report.gdx'

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Cost_report.gdx O=%Ordner_Source%\analysis\cost_details.xlsm par=cost_details rng=GAMS_outputNoGG!B2 rdim=6 cdim=0';
$ontext
$offtext

%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Cost_report.gdx O=%Ordner_Source%\analysis\cost_details.xlsm par=cost_details rng=GAMS_outputGG!B2 rdim=6 cdim=0';
$ontext
$offtext