*###########################################################################
*                GAMAMOD-EU.sto SOLVE STATEMENTS (shock scenario)
*###########################################################################
* Last change: 07.12.2020
* By: Philipp Hauser
*###########################################################################
Set
         green_gas_option /noGG/
         model_type /RCP/
         shockDuration /1M, 2M, 3M, 6M/
****************************************************************************
%no_policy%$ontext
         pol_scenario /noPol/
$ontext
$offtext

%national_policy%$ontext
         pol_scenario /natPol/
$ontext
$offtext

%eu_policy%$ontext
         pol_scenario /euPol/
$ontext
$offtext
;
****************************************************************************
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);
Parameter
shockDays(shockDuration)
/
1M       31
2M       60
3M       91
6M       181
/
;
****************************************************************************
%year2045%$ontext
         demGrow(j,'2045') = scenario_up('j1','demGrow45');
$ontext
$offtext
****************************************************************************
*file to save loop results
file fx2;
put fx2;
file fx3;
put  fx3;
****************************************************************************
loop((model_type,
     green_gas_option,
     pol_scenario,
     shockDuration),
          KONV_pip.l(co,cco,a,j)=0;
          KONV_lng.l(co,a,j)=0;
          KONV_sto.l(co,s,a,j)=0;
          KONV_prod.l(co,a,l,j)=0;
$onUNDF
         put_utility'gdxin' / '%Ordner_Source%\results\ShockResults\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load KONV_pip.l, KONV_lng.l, KONV_sto.l, KONV_prod.l;
                 konv_fx_pip(co,cco,a,j)=KONV_pip.l(co,cco,a,j);
                 konv_fx_lng(co,a,j)=KONV_lng.l(co,a,j);
                 konv_fx_sto(co,s,a,j)=KONV_sto.l(co,s,a,j);
                 konv_fx_prd(co,a,l,j)=KONV_prod.l(co,a,l,j);
$offUNDF
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
****************************************************************************
*Select scneario for supply disruption (*) Russia or North Africa
*Russia
*         PQ.fx('RU',l,t,a,j)$(ord(t) le shockDays(shockDuration)) = 0;

*North Africa
         PQ.fx('DZ',l,t,a,j)$(ord(t) le shockDays(shockDuration)) = 0;
         PQ.fx('EG',l,t,a,j)$(ord(t) le shockDays(shockDuration)) = 0;
         PQ.fx('LY',l,t,a,j)$(ord(t) le shockDays(shockDuration)) = 0;
****************************************************************************
$onecho >cplex.opt
names 0
$offecho
         GAMAMOD_EU_RCP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         putclose
*Select path for saving results (*) Russia or North Africa
*         put_utility fx3 'gdxout' / 'Szenarien\results\RCP_noGG_' pol_scenario.tl:0 '_shock_RU_' shockDuration.tl:0;
         put_utility fx3 'gdxout' /'Szenarien\results\RCP_noGG_' pol_scenario.tl:0'_shock_NA_' shockDuration.tl:0;
         execute_unload;
);
*---------------------------------------------------------------------------
