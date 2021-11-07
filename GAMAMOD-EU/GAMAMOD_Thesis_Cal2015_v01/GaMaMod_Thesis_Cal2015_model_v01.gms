*###############################################################################
*                               GaMaMod Model
*###############################################################################
*
* Last change: 30.10.2015
* By: PH


Variable
c                                system costs

;
Positive Variables
LNG(co,cco,t)                    LNG-Import
Dummy_value(co,t)                Dummy-Wert
P_Q_L(co,l,t)                    production volume per local_gas
storage_in(co,s,t)               injection
storage_out(co,s,t)              withdrawal
storage_level(co,s,t)            level
TRADE(co,cco,t)                  Handel


;

Equations

OBJECTIVE                                cost minimization
ENERGY_BALANCE(co,t)                     energy balance

PRODUCTION_LIMIT_MAX(co,t,l)             Max daily Limit of production
PRODUCTION_LIMIT_MIN(co,t,l)             Min daily Limit of production
PRODUCTION_LIMIT_LOCALGAS(co,l)          Max yearly production of local gas 1
*PRODUCTION_LIMIT_YEAR(co)                Max LNG + Pipeline per year


STORAGE_LEVEL_CONST(co,s,t)                storage level
STORAGE_CAPACITY_MAX(co,s,t)               maximum capacity of storage
STORAGE_INJ_DAY1(co,s,t)                    maximum injection per day
STORAGE_INJ_DAY2(co,s,t)                    maximum injection per day
STORAGE_WITH_DAY1(co,s,t)                   maximum withdrawal per day
STORAGE_WITH_DAY2(co,s,t)                   maximum withdrawal per day
STORAGE_CAPACITY_MIN(co,s,t)                 cushion gas per storage

PIPELINE_LIMIT_CONST(co,cco,t)           transmission constraints

LNG_CONST_IMP (co,t)                     LNG Import constraints
LNG_CONST_EXP (co,t)                     LNG Import constraints
LNG_TRADE(co,cco,t)                      LNG Trade Volumes

*#Module

DIV(div_co,cco)                          Diversification nach Vorgabe in Prozent
DIV_LNG(div_co,cco)                      Diversification for LNG

*BIOMASS(co,l)                            Biomasse Einspeisepflicht

*RUSSIA2011_1(co,cco,t)                     Nord Stream only in Nov and Dec
*RUSSIA2011_2(co,cco,t)                     Nord Stream only in Nov and Dec

;
*objective
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

OBJECTIVE..
*Folgende Kosten werden betrachtet:
* Produktionskosten
* Übertragungskosten (Pipelines)
* Übertragungskosten (LNG + Verflüssigung + Regasifizierung)
* Kosten für abgeschaltete Lasten
* Speicherkosten (Einspeicherkosten, Lagerkosten, Ausspeicherkosten)


         c =e=   sum((coS,t,l),P_Q_L(coS,l,t)*p_c(coS,l))+
                 sum((cco,co,t),TRADE(co,cco,t)*tr_costs(co,cco))+
                 sum((cco,co,t),LNG(cco,co,t)*lng_costs(co,cco))+
                 sum((co,t),Dummy_value(co,t)*Dummy)
*                 sum((co,s,t),storage_in(co,s,t)*storage_c(co,s))+
*                 sum((co,s,t),storage_level(co,s,t)*storage_duration_cost(s))+
*                 sum((co,s,t),storage_out(co,s,t)*storage_c(co,s))
;


*Energybalance
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*        Nachfrage + Export + LNG_Exp. + Einspeicherung -
*        - (Produktion + Import + LNG_Imp   + Ausspeicherung   + Dummy )
*        =  0
*

ENERGY_BALANCE(co,t)..
         (-1)*(dem(t,co) + sum((cco),trade(co,cco,t))+ sum((cco),LNG(cco,co,t))
                 +sum(s,storage_in(co,s,t)))
         + sum(l,p_q_l(co,l,t)) + sum((cco),trade(cco,co,t)) + Dummy_value(co,t)
                 + sum(cco,LNG(co,cco,t)) + sum(s,storage_out(co,s,t))
         =e= 0;


*Production-constraints
*-------------------------------------------------------------------------------
*        Maximale Produktionskapazität per day
PRODUCTION_LIMIT_MAX(co,t,l)..   p_q_l(co,l,t) =l= p_flex(co)*P_limit_localgas(co,l)/365;
PRODUCTION_LIMIT_MIN(co,t,l)..   p_q_l(co,l,t) =g= 0*P_limit_localgas(co,l)/365;

*        Maximale jährliche Förderkapazität local gas
PRODUCTION_LIMIT_LOCALGAS(co,l).. sum(t,p_q_l(co,l,t)) =l= P_limit_localgas(co,l);

*BIOMASS(co,l).. sum(t, p_q_l(co,'local_gas5',t)) =e= P_limit_localgas(co,'local_gas5');
*        Maximale jährliche Förderung LNG + Pipeline
*PRODUCTION_LIMIT_YEAR(co).. sum((l,t),p_q_l(co,l,t))+sum((cco,t),LNG(cco,co,t))
*                                         =l= p_limit(co)*365 ;

*Pipeline-constraints
*-------------------------------------------------------------------------------
*        Maximale und minimale Durchleitung per day

PIPELINE_LIMIT_CONST(co,cco,t)..   trade(co,cco,t) =l= transmission_limit(co,cco);

*        Module Russia 2011
*RUSSIA2011_1(co,cco,t)$(ord(t) gt 305)..  trade('RU','DE_GP',t) =l= transmission_limit('RU', 'DE_GP');
*RUSSIA2011_2(co,cco,t)$(ord(t) lt 305)..  trade('RU','DE_GP',t) =e= 0;

*LNG-constraints
*-------------------------------------------------------------------------------
*        Im- und Exportkapazität für LNG
LNG_CONST_IMP(co,t)..         sum(cco,LNG(co,cco,t)) =l=     LNG_imp_d(co);
LNG_CONST_EXP(co,t)..         sum(cco,LNG(cco,co,t)) =l=     LNG_exp_d(co);

*        Nur LNG auf vorhandenen Strecken
LNG_Trade(co,cco,t)..         LNG(cco,co,t) =l= lng_cap(co,cco);



*Storage-constraints
*-------------------------------------------------------------------------------
*        Maximale Ein- und Ausspeicherung per day
STORAGE_INJ_DAY1(co,s,t)$(storage_max(co,s) ne 0)..

                                         storage_in(co,s,t) =l=
                                         storage_inj(co,s);

STORAGE_INJ_DAY2(co,s,t)$(storage_max(co,s) ne 0)..

                                         storage_in(co,s,t) =l=
                                         storage_inj(co,s)*(storage_inj_Schnittpunkt(s)-
                                         storage_inj_Anstieg(s)*(storage_level(co,s,t--1)/storage_max(co,s)));

STORAGE_WITH_DAY1(co,s,t)..              storage_out(co,s,t) =l= storage_with(co,s);
STORAGE_WITH_DAY2(co,s,t)$(storage_max(co,s) ne 0)..

                                         storage_out(co,s,t) =l=
                                         storage_with(co,s)*(storage_with_Schnittpunkt(s)+
                                         storage_with_Anstieg(s)*(storage_level(co,s,t--1)/storage_max(co,s)));

*        Speicherstand
STORAGE_LEVEL_CONST(co,s,t)..          storage_level(co,s,t)  =e= storage_level(co,s,t--1) +
                                                       storage_in (co,s, t)*(1-0.03) - \\kcons = 3% nach Lochner 2011
                                                       storage_out  (co,s, t)*(1+0.03) ;
*        Maximaler und minimaler Speicherstand
STORAGE_CAPACITY_MAX(co,s,t)..       storage_level(co,s,t) =l= storage_max(co,s);

*Cushion-Gas Constraint

STORAGE_CAPACITY_MIN(co,s,t)..        storage_level(co,s,t) =g= storage_max(co,s)*storage_cushion_gas(s);

*Diversification
DIV(div_co,cco)..        sum((t),trade(cco,div_co,t)) =l= sum(t, dem(t,div_co))*0.7;
DIV_LNG(div_co,cco)..    sum((t),LNG(div_co,cco,t)) =l= sum(t, dem(t,div_co))*0.7;

Model A_B_Model
/
*-------------------------------------------------------------------------------
OBJECTIVE
ENERGY_BALANCE
*-------------------------------------------------------------------------------
*constraints--------------------------------------------------------------------
*#Produktionsbedingungen
PRODUCTION_LIMIT_MAX,
*PRODUCTION_LIMIT_MIN
PRODUCTION_LIMIT_LOCALGAS
*PRODUCTION_LIMIT_YEAR

*#Pipelinebedingungen
PIPELINE_LIMIT_CONST

*#LNG-Bedingungnen
LNG_CONST_IMP, LNG_CONST_EXP
LNG_TRADE


*#Speichergleichungen
*STORAGE_START
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX
STORAGE_CAPACITY_MIN

*#Module
*$ifthen set biomass_duty
*BIOMASS
*$endif

*$ifthen set Russia_2011
*RUSSIA2011_1
*Russia2011_2
*$endif
*Diversification
*DIV, DIV_LNG

/;

*$ontext
loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\%data%' i_loop.tl:0;
         execute_load  dem_rel;
         execute_load  countryup, timeup, productionup,  pr_costup;
         execute_load  storage_max, storage_c, storage_with, storage_inj, storage_duration_cost;
         execute_load  storage_rise_up;
         execute_load  transmissionup,  lng_trade_up;

$offUNDF
*$offtext

*###############################################################################
*                                 ASSIGNMENTS
*###############################################################################

*leeren der Parameter aus Vorschleife
         coS(co) = NO;
         coD(co) = NO;
         coL(co) = NO;
         dem(t,co) = NO;
         p_c(co,l) = NO;
         p_Limit_localgas(co,l) = NO;
         p_flex(co) = NO;
         LNG_imp_d(co) = NO;
         LNG_exp_d(co) = NO;
         lng_costs(cco,co) = NO;
         lng_cap(cco,co) = NO;
         transmission_limit(co,cco) = NO;
         tr_costs(co,cco) = NO;
         storage_inj_Anstieg(s)  = NO;
         storage_inj_Schnittpunkt(s)  = NO;
         storage_with_Anstieg(s)  = NO;
         storage_with_Schnittpunkt(s)  = NO;
         storage_cushion_gas(s)   = NO;

*Neue Daten für Parameter

         coS(co)$(countryup(co,'foerd') <> 0) = YES;
         coD(co)$(countryup(co,'demand') <> 0) = YES;
         coL(co)$(countryup(co,'LNG_exp_a') <> 0) = YES;

         dem(t,co) =  dem_rel(t,co)*countryup(co,'demand');

         p_c(co,l) = pr_costup(co,l)*10**4;
*         p_limit(co) = countryup (co, 'foerd');
         P_Limit_localgas(co,l) = productionup(co,l);
         p_flex(co) = countryup(co,'p_flex');

         LNG_imp_d(co) = countryup (co, 'LNG_imp_a')/365;
         LNG_exp_d(co) = countryup (co, 'LNG_exp_a')/365;

         lng_costs(cco,co) = lng_trade_up(cco,co,'Gesamt');
         lng_cap(cco,co) = lng_trade_up(cco,co,'capacity');

         transmission_limit(co,cco) = transmissionup(co,cco,'capacity');
         tr_costs(co,cco) = transmissionup(co,cco,'costs');

         storage_inj_Anstieg(s) = storage_rise_up(s,'s_inj_rise');
         storage_inj_Schnittpunkt(s) = storage_rise_up (s,'s_inj_n');
         storage_with_Anstieg(s) = storage_rise_up(s,'s_with_rise');
         storage_with_Schnittpunkt(s) = storage_rise_up (s,'s_with_n');

         storage_cushion_gas(s) = storage_rise_up(s,'s_cushion_gas');


$onecho > cplex.opt
names 0
$offecho


         A_B_model.optfile = 1;


         Solve A_B_Model minimizing c using lp;

         putclose

         put_utility  text 'gdxout' / '%Ordner_Source%\results\%data%_results_' i_loop.tl:0;
         execute_unload;
         );

*execute_unload 'results.gdx'
