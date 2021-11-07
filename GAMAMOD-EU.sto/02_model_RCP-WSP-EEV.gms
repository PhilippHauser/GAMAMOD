*###########################################################################
*                GAMAMOD-EU.sto SOLVE STATEMENTS (RCP, WSP, EEV)
*###########################################################################
* Last change: 07.12.2020
* By: Philipp Hauser
*###########################################################################
*                                RCP amd WSP
*###########################################################################
*1.1 GAMAMOD_EU_RCP_GG_noPol
*No Policy, Green Gas, Recursive Problem
%no_policy%$ontext
%greengas%$ontext
%RCP%$ontext
         GAMAMOD_EU_RCP_noPol.optfile = 1;
$ifThen %sensGG% == ""
         Solve GAMAMOD_EU_RCP_noPol minimizing COST using lp;
         execute_unload 'Szenarien\results\RCP_GG_noPol';
$endif
$ontext
$offtext
****************************************************************************
*1.2 GAMAMOD_EU_WSP_GG_noPol
*No Policy, Green Gas, Wait and See Problem
%no_policy%$ontext
%greengas%$ontext
%WSP%$ontext
         GAMAMOD_EU_WSP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         execute_unload 'Szenarien\results\WSP_GG_noPol';
$ontext
$offtext
****************************************************************************
*1.3 GAMAMOD_EU_RCP_noGG_noPol
*No Policy, No Green Gas, Recursive Problem
%no_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
         GAMAMOD_EU_RCP_noPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_noPol minimizing COST using lp;
         execute_unload 'Szenarien\results\RCP_noGG_noPol';
$ontext
$offtext
****************************************************************************
*1.4 GAMAMOD_EU_WSP_noGG_noPol
*No Policy, no Green Gas, Wait and See Problem
%no_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
         GAMAMOD_EU_WSP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         execute_unload 'Szenarien\results\WSP_noGG_noPol';
$ontext
$offtext
*****************************************************************************
*****************************************************************************
*2.1 GAMAMOD_EU_RCP_GG_natPol
*National Policy, Green Gas, Recursive Problem
%national_policy%$ontext
%greengas%$ontext
%RCP%$ontext
         GAMAMOD_EU_RCP_natPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_natPol minimizing COST using lp;
         execute_unload 'Szenarien\results\RCP_GG_natPol';
$ontext
$offtext
****************************************************************************
*2.2 GAMAMOD_EU_WSP_GG_natPol
*National Policy, Green Gas, Wait and See Problem
%national_policy%$ontext
%greengas%$ontext
%WSP%$ontext
         GAMAMOD_EU_WSP_natPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_natPol minimizing COST using lp;
         execute_unload 'Szenarien\results\WSP_GG_natPol';
$ontext
$offtext
****************************************************************************
*2.3 GAMAMOD_EU_RCP_noGG_natPol
*National Policy, No Green Gas, Recursive Problem
%national_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
         GAMAMOD_EU_RCP_natPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_natPol minimizing COST using lp;
         execute_unload 'Szenarien\results\RCP_noGG_natPol';
$ontext
$offtext
****************************************************************************
*2.4 GAMAMOD_EU_WSP_noGG_natPol
*National Policy, no Green Gas, Wait and See Problem
%national_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
         GAMAMOD_EU_WSP_natPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_natPol minimizing COST using lp;
         execute_unload 'Szenarien\results\WSP_noGG_natPol';
$ontext
$offtext
*****************************************************************************
*****************************************************************************
*3.1 GAMAMOD_EU_RCP_GG_euPol
*EU Policy, Green Gas, Recursive Problem
%EU_policy%$ontext
%greengas%$ontext
%RCP%$ontext
         GAMAMOD_EU_RCP_euPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_euPol minimizing COST using lp;
         execute_unload 'Szenarien\results\RCP_GG_euPol';
$ontext
$offtext
****************************************************************************
*3.2 GAMAMOD_EU_WSP_GG_euPol
*EU Policy, Green Gas, Wait and See Problem
%EU_policy%$ontext
%greengas%$ontext
%WSP%$ontext
         GAMAMOD_EU_WSP_euPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_euPol minimizing COST using lp;
         execute_unload 'Szenarien\results\WSP_GG_euPol';
$ontext
$offtext
****************************************************************************
*3.3 GAMAMOD_EU_RCP_noGG_euPol
*EU Policy, No Green Gas, Recursive Problem
%EU_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
         GAMAMOD_EU_RCP_euPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_euPol minimizing COST using lp;
         execute_unload 'Szenarien\results\RCP_noGG_euPol';
$ontext
$offtext
****************************************************************************
*3.4 GAMAMOD_EU_WSP_noGG_euPol
*EU Policy, no Green Gas, Wait and See Problem
%EU_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
         GAMAMOD_EU_WSP_euPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_euPol minimizing COST using lp;
         execute_unload 'Szenarien\results\WSP_noGG_euPol';
$ontext
$offtext
*###########################################################################
*                              EEV
*###########################################################################
*EEV
*1.5 GAMAMOD_EU_EEV_GG_noPol
*No Policy, Green Gas, Expected Value Solution
%EEV%$ontext
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_upE(j,'demGrow30');
         prob(j) = scenario_upE(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_upE(j,'LNG');
         UApip(j) = scenario_upE(j,'UA');
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_upE(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%no_policy%$ontext
%greengas%$ontext
         GAMAMOD_EU_WSP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         konv_fx_pip(co,cco,a,j)  = KONV_pip.l(co,cco,a,'j1');
         konv_fx_lng(co,a,j)      = KONV_lng.l(co,a,'j1');
         konv_fx_sto(co,s,a,j)    = KONV_sto.l(co,s,a,'j1');
%EEV%$ontext
%greengas%$ontext
         konv_fx_prd(co,a,l,j)    = KONV_prod.l(co,a,l,'j1');
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         konv_fx_prd(co,a,l,j)    = 0;
$ontext
$offtext

%EEV%$ontext
%no_policy%$ontext
%greengas%$ontext
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%no_policy%$ontext
%greengas%$ontext
         GAMAMOD_EU_WSP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         execute_unload '%Ordner_Source%\results\EEV_GG_noPol';
$ontext
$offtext
********************************************************************************
*EEV
*1.6 GAMAMOD_EU_EEV_noGG_noPol
*No Policy, No Green Gas, Expected Value Solution
%EEV%$ontext
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_upE(j,'demGrow30');
         prob(j) = scenario_upE(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_upE(j,'LNG');
         UApip(j) = scenario_upE(j,'UA');
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_upE(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%no_policy%$ontext
%no_greengas%$ontext
         GAMAMOD_EU_WSP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         konv_fx_pip(co,cco,a,j)  = KONV_pip.l(co,cco,a,'j1');
         konv_fx_lng(co,a,j)      = KONV_lng.l(co,a,'j1');
         konv_fx_sto(co,s,a,j)    = KONV_sto.l(co,s,a,'j1');
%EEV%$ontext
%greengas%$ontext
         konv_fx_prd(co,a,l,j)    = KONV_prod.l(co,a,l,'j1');
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         konv_fx_prd(co,a,l,j)    = 0;
$ontext
$offtext

%EEV%$ontext
%no_policy%$ontext
%no_greengas%$ontext
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%no_policy%$ontext
%no_greengas%$ontext
         GAMAMOD_EU_WSP_noPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_noPol minimizing COST using lp;
         execute_unload '%Ordner_Source%\results\EEV_noGG_noPol';
$ontext
$offtext
********************************************************************************
*EEV
*2.5 GAMAMOD_EU_EEV_GG_nationalPol
*National Policy, Green Gas, Expected Value Solution
%EEV%$ontext
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_upE(j,'demGrow30');
         prob(j) = scenario_upE(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_upE(j,'LNG');
         UApip(j) = scenario_upE(j,'UA');
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_upE(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%national_policy%$ontext
%greengas%$ontext
         GAMAMOD_EU_WSP_natPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_natPol minimizing COST using lp;
         konv_fx_pip(co,cco,a,j)  = KONV_pip.l(co,cco,a,'j1');
         konv_fx_lng(co,a,j)      = KONV_lng.l(co,a,'j1');
         konv_fx_sto(co,s,a,j)    = KONV_sto.l(co,s,a,'j1');
%EEV%$ontext
%greengas%$ontext
         konv_fx_prd(co,a,l,j)    = KONV_prod.l(co,a,l,'j1');
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         konv_fx_prd(co,a,l,j)    = 0;
$ontext
$offtext

%EEV%$ontext
%greengas%$ontext
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%national_policy%$ontext
%greengas%$ontext
         GAMAMOD_EU_WSP_natPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_natPol minimizing COST using lp;
         execute_unload '%Ordner_Source%\results\EEV_GG_natPol';
$ontext
$offtext
********************************************************************************
*EEV
*2.6 GAMAMOD_EU_EEV_noGG_natPol
*National Policy, No Green Gas, Expected Value Solution
%EEV%$ontext
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;

         demGrow(j,'2030') = scenario_upE(j,'demGrow30');
         prob(j) = scenario_upE(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_upE(j,'LNG');
         UApip(j) = scenario_upE(j,'UA');
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_upE(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%national_policy%$ontext
%no_greengas%$ontext
         GAMAMOD_EU_WSP_natPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_natPol minimizing COST using lp;
         konv_fx_pip(co,cco,a,j)  = KONV_pip.l(co,cco,a,'j1');
         konv_fx_lng(co,a,j)      = KONV_lng.l(co,a,'j1');
         konv_fx_sto(co,s,a,j)    = KONV_sto.l(co,s,a,'j1');
%EEV%$ontext
%greengas%$ontext
         konv_fx_prd(co,a,l,j)    = KONV_prod.l(co,a,l,'j1');
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         konv_fx_prd(co,a,l,j)    = 0;
$ontext
$offtext

%EEV%$ontext
%national_policy%$ontext
%no_greengas%$ontext
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%national_policy%$ontext
%no_greengas%$ontext
         GAMAMOD_EU_WSP_natPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_natPol minimizing COST using lp;
         execute_unload '%Ordner_Source%\results\EEV_noGG_natPol';
$ontext
$offtext
********************************************************************************
*EEV
*3.5 GAMAMOD_EU_EEV_GG_euPol
*EU Policy, Green Gas, Expected Value Solution
%EEV%$ontext
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_upE(j,'demGrow30');
         prob(j) = scenario_upE(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_upE(j,'LNG');
         UApip(j) = scenario_upE(j,'UA');
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);

$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_upE(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%EU_policy%$ontext
%greengas%$ontext
         GAMAMOD_EU_WSP_euPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_euPol minimizing COST using lp;
         konv_fx_pip(co,cco,a,j)  = KONV_pip.l(co,cco,a,'j1');
         konv_fx_lng(co,a,j)      = KONV_lng.l(co,a,'j1');
         konv_fx_sto(co,s,a,j)    = KONV_sto.l(co,s,a,'j1');
%EEV%$ontext
%greengas%$ontext
         konv_fx_prd(co,a,l,j)    = KONV_prod.l(co,a,l,'j1');
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         konv_fx_prd(co,a,l,j)    = 0;
$ontext
$offtext

%EEV%$ontext
%greengas%$ontext
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%eu_policy%$ontext
%greengas%$ontext
         GAMAMOD_EU_WSP_euPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_euPol minimizing COST using lp;
         execute_unload '%Ordner_Source%\results\EEV_GG_euPol';
$ontext
$offtext
********************************************************************************
*EEV
*3.6 GAMAMOD_EU_EEV_noGG_noPol
*EU Policy, No Green Gas, Expected Value Solution
%EEV%$ontext
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_upE(j,'demGrow30');
         prob(j) = scenario_upE(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_upE(j,'LNG');
         UApip(j) = scenario_upE(j,'UA');
Parameters
         konv_fx_pip(co,cco,a,j)
         konv_fx_lng(co,a,j)
         konv_fx_sto(co,s,a,j)
         konv_fx_prd(co,a,l,j);
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_upE(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%eu_policy%$ontext
%no_greengas%$ontext
         GAMAMOD_EU_WSP_euPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_euPol minimizing COST using lp;
         konv_fx_pip(co,cco,a,j)  = KONV_pip.l(co,cco,a,'j1');
         konv_fx_lng(co,a,j)      = KONV_lng.l(co,a,'j1');
         konv_fx_sto(co,s,a,j)    = KONV_sto.l(co,s,a,'j1');
%EEV%$ontext
%greengas%$ontext
         konv_fx_prd(co,a,l,j)    = KONV_prod.l(co,a,l,'j1');
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         konv_fx_prd(co,a,l,j)    = 0;
$ontext
$offtext

%EEV%$ontext
%no_greengas%$ontext
         KONV_pip.fx(co,cco,a,j)  =konv_fx_pip(co,cco,a,j);
         KONV_lng.fx(co,a,j)      =konv_fx_lng(co,a,j);
         KONV_sto.fx(co,s,a,j)    =konv_fx_sto(co,s,a,j);
         KONV_prod.fx(co,a,l,j)   =konv_fx_prd(co,a,l,j);
         demGrow(j,a) = NO;
         prob(j) = NO;
         LNGmarkup(j) = NO;
         UApip(j) = NO;
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.2*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
$ontext
$offtext

%EEV%$ontext
%year2045%$ontext
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
$ontext
$offtext

%EEV%$ontext
%eu_policy%$ontext
%no_greengas%$ontext
         GAMAMOD_EU_WSP_euPol.optfile = 1;
         Solve GAMAMOD_EU_WSP_euPol minimizing COST using lp;
         execute_unload '%Ordner_Source%\results\EEV_noGG_euPol';
$ontext
$offtext
