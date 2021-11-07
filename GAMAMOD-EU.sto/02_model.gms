*###########################################################################
*                         GAMAMOD-EU.sto MODEL
*###########################################################################
* Last change: 07.12.2020
* By: Philipp Hauser
*###########################################################################
*                              VARIABLES
*###########################################################################
Variable
         COST                        total system costs
;
Positive Variables
         LNG(co,cco,t,a,j)           LNG-Import
         Dummy_value(co,t,a,j)       value of lost load
         PQ(co,l,t,a,j)              production volume per local_gas
         STORAGE_IN(co,s,t,a,j)      storage injection
         STORAGE_OUT(co,s,t,a,j)     storage withdrawal
         STORAGE_LEVEL(co,s,t,a,j)   storage level
         TRADE(co,cco,t,a,j)         pipeline transport

*continues extension variables:
         KONV_pip(co,cco,a,j)        pipeline extension
         KONV_lng(co,a,j)            LNG import extension
         KONV_sto(co,s,a,j)          storage extension

*only in Green Gas module:
         KONV_prod(co,a,l,j)         green gas production extension
;
Equations
         OBJECTIVE                            cost minimization
*dispatch constraints:
         ENERGY_BALANCE(co,t,a,j)             energy balance
         PRODUCTION_LIMIT_MAX(co,t,l,a,j)     max. daily production
         PRODUCTION_LIMIT_LOCALGAS(co,l,a,j)  max. yearly production
         VOLL_Const(co,t,a,j)                 max. of VOLL
         STORAGE_LEVEL_CONST(co,s,t,a,j)      storage level
         STORAGE_CAPACITY_MAX(co,s,t,a,j)     max capacity of storage
         STORAGE_INJ_DAY1(co,s,t,a,j)         max injection per day (abs)
         STORAGE_INJ_DAY2(co,s,t,a,j)         max injection per day (rel)
         STORAGE_WITH_DAY1(co,s,t,a,j)        max withdrawal per day (abs)
         STORAGE_WITH_DAY2(co,s,t,a,j)        max withdrawal per day (rel)
         STORAGE_CAPACITY_MIN(co,s,t,a,j)     min stor level (cushion gas)
         STORAGE_INJ_DAY_NEW(co,s,t,a,j)      max injection per day (abs)
         STORAGE_WITH_DAY_NEW(co,s,t,a,j)     max withdrawal per day (abs)
         PIPELINE_LIMIT_CONST(co,cco,t,a,j)   pip transmission const.
         LNG_CONST_IMP (co,t,a,j)             LNG import constraints
         LNG_CONST_EXP (co,t,a,j)             LNG export constraints
         LNG_TRADE(co,cco,t,a,j)              LNG shipping network
*investment constraints:
         EXPANSION_pip_cap(co,cco,j)          pipeline expanions
         EXPANSION_lng_cap(co,j)              LNG import expansion
         EXPANSION_sto_cap(co,s,j)            sto exp (existing storages)
         EXPANSION_sto_cap_new(co,s,j)        sto exp (new storages)
*only in GG module:
         EXPANSION_prod_cap_A(co,a,l,j)       GG expansion (all countries)
         EXPANSION_prod_cap_B(co,a,l,j)       GG expansion (only NA)
*The following equations are needed in the non-stochhastic Model (WSP)
         EQ_NONANTICIPATE_PIP(co,cco,a,j,jj)  non-anticipating eq. pip
         EQ_NONANTICIPATE_LNG(co,a,j,jj)      non-anticipating eq. LNG
         EQ_NONANTICIPATE_STO(co,s,a,j,jj)    non-anticipating eq. sto
         EQ_NONANTICIPATE_PRD(co,l,a,j,jj)    non-anticipating eq. prod
*The following equations descripe the diversification policies and are only
*used for the year 2030 and 2045
         DIV_nat(co,a,j)                      National LNG Diversification
         DIV_EU(a,j)                          EU Diversification
;
*###########################################################################
*                              EQUATION
*###########################################################################
OBJECTIVE..
         COST =e=
*expansion costs
         sum(j,prob(j)*(
                 sum(a, (
                 sum((co,cco),
                         KONV_pip(co,cco,a,j)*365*exp_pip_costs(co,cco)
                         *tr_length(co,cco)) +
                 sum((co),
                         KONV_lng(co,a,j)*exp_lng_costs(co))+
                 sum((co,s),
                         KONV_sto(co,s,a,j)*exp_sto_costs(co,s))
%greengas%$ontext
*costs are only considered in "GreenGas" Scenario
                 + sum((co,l),
                         KONV_prod(co,a,l,j)*exp_prod_costs(co,l))
$ontext
$offtext
                 ))
*operation costs
             + sum(a,(
                  sum((coS,t,l),PQ(coS,l,t,a,j)*p_c(coS,a,l,j))+
                  sum((cco,co,t),TRADE(co,cco,t,a,j)*tr_costs(co,cco))+
                  sum((cco,co,t),LNG(cco,co,t,a,j)*lng_costs(co,cco,a,j))+
                  sum((co,t),Dummy_value(co,t,a,j)*Dummy)
                     ))
%greengas%$ontext
*costs are only considered in "GreenGas" Scenario
             + sum(a,(
                  sum((coS,t,lf), PQ(coS,lf,t,a,j) * CarbPrice )
                     ))
$ontext
$offtext
                 ));
****************************************************************************
ENERGY_BALANCE(co,t,a,j)..
         (-1)*(                                    \\-node inflows-----
         dem(a,t,co,j) +                           \\demand
         sum((cco),TRADE(co,cco,t,a,j))+           \\exports
         sum((cco),LNG(cco,co,t,a,j))+             \\exports
         sum(s,STORAGE_IN(co,s,t,a,j))             \\storage injection
         )+                                        \\-node outflows----
         sum(l,PQ(co,l,t,a,j)) +                   \\production
         sum((cco),TRADE(cco,co,t,a,j)) +          \\imports
         DUMMY_VALUE(co,t,a,j) +                   \\load shedding
         sum(cco,LNG(co,cco,t,a,j)) +              \\imports
         sum(s,STORAGE_OUT(co,s,t,a,j))            \\storage withdrawal
                                                 =e= 0;
VOLL_Const(co,t,a,j)..
         DUMMY_VALUE(co,t,a,j) =l= dem(a,t,co,j);
****************************************************************************
*max. prodcution capacity per day
PRODUCTION_LIMIT_MAX(coS,t,l,a,j)..
         PQ(coS,l,t,a,j) =l=
*with Green Gas module:
%greengas%$ontext
         p_flex(coS)*(p_limit_localgas(coS,a,l)+
         sum(aa$(ord(aa) le ord(a)),KONV_prod(coS,a,l,j)))/365;
$ontext
$offtext
*without Green Gas module:
%no_greengas%$ontext
         p_flex(coS)*p_limit_localgas(coS,a,l)/365;
$ontext
$offtext
****************************************************************************
*max. production capacity of local gas per year
PRODUCTION_LIMIT_LOCALGAS(coS,l,a,j)..
         sum(t,PQ(coS,l,t,a,j)) =l= p_limit_localgas(coS,a,l)

%greengas%$ontext
         +sum(aa$(ord(aa) le ord(a)),KONV_prod(coS,a,l,j))
$ontext
$offtext
;
****************************************************************************
*maximum transmission via pipeline per day
PIPELINE_LIMIT_CONST(co,cco,t,a,j)..
         TRADE(co,cco,t,a,j) =l=
                 transmission_limit(co,cco,a,j)
                 + sum(aa$(ord(aa) le ord(a)),
                   KONV_pip(co,cco,a,j)$(exp_pip_option(co,cco) ne 0));
****************************************************************************
*import restriction for LNG
LNG_CONST_IMP(co,t,a,j)..
         sum(cco,LNG(co,cco,t,a,j)) =l=
                 LNG_imp_d(co)+
                 sum(aa$(ord(aa) le ord(a)),KONV_lng(co,a,j)/365);
*export restriction for LNG
LNG_CONST_EXP(coL,t,a,j)..
         sum(cco,LNG(cco,coL,t,a,j)) =l= LNG_exp_d(coL);
*transport restriction for LNG (only on existing shipping routes)
*--------------------------
LNG_Trade(co,cco,t,a,j)..
         LNG(cco,co,t,a,j) =l= lng_cap(co,cco);
****************************************************************************
*for existing storages
****************************************************************************
*max. storage injection per day
STORAGE_INJ_DAY1(coSTO,s,t,a,j)$(storage_max(coSTO,s) ne 0)..
         STORAGE_IN(coSTO,s,t,a,j) =l=
                            storage_inj(coSTO,s);
STORAGE_INJ_DAY2(coSTO,s,t,a,j)$(storage_max(coSTO,s) ne 0)..
         STORAGE_IN(coSTO,s,t,a,j) =l=
                 storage_inj(coSTO,s)*(storage_inj_Schnittpunkt(s)
                 - storage_inj_Anstieg(s)*(STORAGE_LEVEL(coSTO,s,t--1,a,j)
                 /storage_max(coSTO,s)));
*max. withdrawal per day
STORAGE_WITH_DAY1(coSTO,s,t,a,j)$(storage_max(coSTO,s) ne 0)..
         STORAGE_OUT(coSTO,s,t,a,j) =l= storage_with(coSTO,s);
STORAGE_WITH_DAY2(coSTO,s,t,a,j)$(storage_max(coSTO,s) ne 0)..
         STORAGE_OUT(coSTO,s,t,a,j) =l=
                 storage_with(coSTO,s)*(storage_with_Schnittpunkt(s)
                 +storage_with_Anstieg(s)*(STORAGE_LEVEL(coSTO,s,t--1,a,j)
                 /storage_max(coSTO,s)));
*storage level
STORAGE_LEVEL_CONST(co,s,t,a,j)..
         STORAGE_LEVEL(co,s,t,a,j)  =e=
                 STORAGE_LEVEL(co,s,t--1,a,j) +
                 STORAGE_IN (co,s, t,a,j)*(1-0.03) -
                 STORAGE_OUT (co,s, t,a,j)*(1+0.03) ;
*max. storage level
STORAGE_CAPACITY_MAX(co,s,t,a,j)..
         STORAGE_LEVEL(co,s,t,a,j) =l=
                 storage_max(co,s)
                 +sum(aa$(ord(aa) le ord(a)),KONV_sto(co,s,a,j));
*min. storage level
STORAGE_CAPACITY_MIN(co,s,t,a,j)..
         STORAGE_LEVEL(co,s,t,a,j) =g=
                 (storage_max(co,s)
                 + sum(aa$(ord(aa) le ord(a)),KONV_sto(co,s,a,j)))
                 *storage_cushion_gas(s);
****************************************************************************
*for new storages  (simplification is needed to keep the model linear)
****************************************************************************
*max. injection per day (new storages, assumption 4%)
STORAGE_INJ_DAY_NEW(coNSTO,s,t,a,j)$(ord(a) gt 1)..
         STORAGE_IN(coNSTO,s,t,a,j) =l=
                 0.04*sum(aa$(ord(aa) le ord(a)),KONV_sto(coNSTO,s,a,j));
*max. withdrawal per day (new storages, assumption 11%)
STORAGE_WITH_DAY_NEW(coNSTO,s,t,a,j)$(ord(a) gt 1)..
         STORAGE_OUT(coNSTO,s,t,a,j) =l=
                 0.11*sum(aa$(ord(aa) le ord(a)),KONV_sto(coNSTO,s,a,j));

****************************************************************************
*expansion restriction
****************************************************************************
EXPANSION_pip_cap(co,cco,j)..
         sum(a,KONV_pip(co,cco,a,j))     =l= exp_pip_maximum(co,cco);
EXPANSION_lng_cap(coEU,j)..
         sum(a,KONV_lng(coEU,a,j))       =l= exp_lng_capacity(coEU);
EXPANSION_sto_cap(coSTO,s,j)..
         sum(a,KONV_sto(coSTO,s,a,j))    =l= exp_sto_capacity(coSTO,s);
EXPANSION_sto_cap_new(coNSTO,s,j)..
         sum(a,KONV_sto(coNSTO,s,a,j))   =l= exp_sto_capacity(coNSTO,s);
*only for Green Gas module:
*expansion is allowed in Europe and North Africa
EXPANSION_prod_cap_A(coGG,a,l,j)..
         sum(aa,KONV_prod(coGG,a,l,j))   =l= exp_prod_capacity(coGG,l);
*expansion is allowed only in North Africa
EXPANSION_prod_cap_B(coGG_NA,a,l,j)..
         sum(aa,KONV_prod(coGG_NA,a,l,j))=l= exp_prod_capacity(coGG_NA,l);

****************************************************************************
*non-anticipating equation
****************************************************************************
EQ_NONANTICIPATE_PIP(co,cco,a,j,jj)..
         KONV_pip(co,cco,a,j) =e= KONV_pip(co,cco,a,jj);
EQ_NONANTICIPATE_LNG(co,a,j,jj)..
         KONV_lng(co,a,j) =e= KONV_lng(co,a,jj);
EQ_NONANTICIPATE_STO(co,s,a,j,jj)..
         KONV_sto(co,s,a,j) =e= KONV_sto(co,s,a,jj);
EQ_NONANTICIPATE_PRD(co,l,a,j,jj)..
         KONV_prod(co,a,l,j) =e= KONV_prod(co,a,l,jj);
****************************************************************************
*diversification
****************************************************************************
*National LNG Diversification strategy:
DIV_nat(coEU,a,j)$((LNG_imp_d(coEU) ne 0)OR(countryup(coEU,'LNG_imp_a_ext') ne 0))..
         sum((t,cco),LNG(coEU,cco,t,a,j))/sum(t,dem(a,t,coEU,j))=g= 0.1;
*EU Diversification strategy:
DIV_EU(a,j)..
         sum((t,coSouRU,coEURU),TRADE(coSouRU,coEURU,t,a,j)) =l=
         sum((t,coEU),dem(a,t,coEU,j))*0.2;
*###########################################################################
*                        MODEL STATEMENTS
*###########################################################################
*all available models so far:
*1.1 GAMAMOD_EU_RCP_noPol
*1.2 GAMAMOD_EU_WSP_noPol
*2.1 GAMAMOD_EU_RCP_natPol
*2.2 GAMAMOD_EU_WSP_natPol
*3.1 GAMAMOD_EU_RCP_euPol
*3.2 GAMAMOD_EU_WSP_euPol

********************************************************************************
*1 No Policy Models
*#1.1
Model GAMAMOD_EU_RCP_noPol
/
*Standard Equations for all models
OBJECTIVE, ENERGY_BALANCE, VOLL_CONST
PRODUCTION_LIMIT_MAX,PRODUCTION_LIMIT_LOCALGAS
PIPELINE_LIMIT_CONST
LNG_CONST_IMP, LNG_CONST_EXP,
*LNG_TRADE
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX, STORAGE_CAPACITY_MIN
STORAGE_INJ_DAY_NEW, STORAGE_WITH_DAY_NEW
EXPANSION_pip_cap,  EXPANSION_lng_cap, EXPANSION_sto_cap, EXPANSION_sto_cap_new
*GreenGas
%greengas%$ontext
%NAandEU%$ontext
EXPANSION_prod_cap_A
$ontext
$offtext
%greengas%$ontext
%onlyNA%$ontext
EXPANSION_prod_cap_B
$ontext
$offtext
*RCP
EQ_NONANTICIPATE_PIP
EQ_NONANTICIPATE_LNG
EQ_NONANTICIPATE_STO
EQ_NONANTICIPATE_PRD
/

*#1.2
Model GAMAMOD_EU_WSP_noPol
/
*Standard Equations for all models
OBJECTIVE, ENERGY_BALANCE, VOLL_CONST
PRODUCTION_LIMIT_MAX,PRODUCTION_LIMIT_LOCALGAS
PIPELINE_LIMIT_CONST
LNG_CONST_IMP, LNG_CONST_EXP,
*LNG_TRADE
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX, STORAGE_CAPACITY_MIN
STORAGE_INJ_DAY_NEW, STORAGE_WITH_DAY_NEW
EXPANSION_pip_cap,  EXPANSION_lng_cap, EXPANSION_sto_cap, EXPANSION_sto_cap_new
*GreenGas
%greengas%$ontext
%NAandEU%$ontext
EXPANSION_prod_cap_A
$ontext
$offtext
%greengas%$ontext
%onlyNA%$ontext
EXPANSION_prod_cap_B
$ontext
$offtext
*WSP
*-
/;
********************************************************************************
*2 National Policy Models
*#2.1
Model GAMAMOD_EU_RCP_natPol
/
OBJECTIVE, ENERGY_BALANCE, VOLL_CONST
PRODUCTION_LIMIT_MAX,PRODUCTION_LIMIT_LOCALGAS
PIPELINE_LIMIT_CONST
LNG_CONST_IMP, LNG_CONST_EXP,
*LNG_TRADE
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX, STORAGE_CAPACITY_MIN
STORAGE_INJ_DAY_NEW, STORAGE_WITH_DAY_NEW
EXPANSION_pip_cap,  EXPANSION_lng_cap, EXPANSION_sto_cap, EXPANSION_sto_cap_new
*GreenGas
%greengas%$ontext
%NAandEU%$ontext
EXPANSION_prod_cap_A
$ontext
$offtext
%greengas%$ontext
%onlyNA%$ontext
EXPANSION_prod_cap_B
$ontext
$offtext
*RCP
EQ_NONANTICIPATE_PIP
EQ_NONANTICIPATE_LNG
EQ_NONANTICIPATE_STO
EQ_NONANTICIPATE_PRD
*Policy
DIV_nat
/;

*#2.2
Model GAMAMOD_EU_WSP_natPol
/
OBJECTIVE, ENERGY_BALANCE, VOLL_CONST
PRODUCTION_LIMIT_MAX,PRODUCTION_LIMIT_LOCALGAS
PIPELINE_LIMIT_CONST
LNG_CONST_IMP, LNG_CONST_EXP,
*LNG_TRADE
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX, STORAGE_CAPACITY_MIN
STORAGE_INJ_DAY_NEW, STORAGE_WITH_DAY_NEW
EXPANSION_pip_cap,  EXPANSION_lng_cap, EXPANSION_sto_cap, EXPANSION_sto_cap_new
*GreenGas
%greengas%$ontext
%NAandEU%$ontext
EXPANSION_prod_cap_A
$ontext
$offtext
%greengas%$ontext
%onlyNA%$ontext
EXPANSION_prod_cap_B
$ontext
$offtext
*WSP
*-
*Policy
DIV_nat
/;
********************************************************************************
*3 EU28 Policy Models
*#3.1
Model GAMAMOD_EU_RCP_euPol
/
OBJECTIVE, ENERGY_BALANCE, VOLL_CONST
PRODUCTION_LIMIT_MAX,PRODUCTION_LIMIT_LOCALGAS
PIPELINE_LIMIT_CONST
LNG_CONST_IMP, LNG_CONST_EXP,
*LNG_TRADE
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX, STORAGE_CAPACITY_MIN
STORAGE_INJ_DAY_NEW, STORAGE_WITH_DAY_NEW
EXPANSION_pip_cap,  EXPANSION_lng_cap, EXPANSION_sto_cap, EXPANSION_sto_cap_new
*GreenGas
%greengas%$ontext
%NAandEU%$ontext
EXPANSION_prod_cap_A
$ontext
$offtext
%greengas%$ontext
%onlyNA%$ontext
EXPANSION_prod_cap_B
$ontext
$offtext
*RCP
EQ_NONANTICIPATE_PIP
EQ_NONANTICIPATE_LNG
EQ_NONANTICIPATE_STO
EQ_NONANTICIPATE_PRD
*Policy
DIV_EU
/;

*#3.2
Model GAMAMOD_EU_WSP_euPol
/
OBJECTIVE, ENERGY_BALANCE, VOLL_CONST
PRODUCTION_LIMIT_MAX,PRODUCTION_LIMIT_LOCALGAS
PIPELINE_LIMIT_CONST
LNG_CONST_IMP, LNG_CONST_EXP,
*LNG_TRADE
STORAGE_INJ_DAY1, STORAGE_INJ_DAY2
STORAGE_WITH_DAY1, STORAGE_WITH_DAY2
STORAGE_LEVEL_CONST, STORAGE_CAPACITY_MAX, STORAGE_CAPACITY_MIN
STORAGE_INJ_DAY_NEW, STORAGE_WITH_DAY_NEW
EXPANSION_pip_cap,  EXPANSION_lng_cap, EXPANSION_sto_cap, EXPANSION_sto_cap_new
*GreenGas
%greengas%$ontext
%NAandEU%$ontext
EXPANSION_prod_cap_A
$ontext
$offtext
%greengas%$ontext
%onlyNA%$ontext
EXPANSION_prod_cap_B
$ontext
$offtext
*WSP
*-
*Policy
DIV_EU
/;
****************************************************************************
*Data load
****************************************************************************
$onUNDF
$gdxin %Ordner_Source%\%data%
$load  dem_rel
$load  countryup, productionup,  pr_costup, scenario_up, scenario_upE
$load  storage_max, storage_with, storage_inj
$load  storage_rise_up, exp_sto_capacity, exp_sto_costs
$load  transmissionup,  lng_trade_up, GG_up
$gdxin
$offUNDF
*###########################################################################
*                                 ASSIGNMENTS
*###########################################################################
*subsets
*----------------------------
         coEU(co)$(countryup(co,'EU28') <> 0) = YES;
         coNEU(co) = not coEU(co);
         coSTO(co)$(sum(s,storage_max(co,s)) <> 0) = YES;
         coNSTO(co)$(sum(s,storage_max(co,s)) = 0) = YES$coEU(co);
         coFSTO(co) = YES$(not coSTO(co) AND not coNSTO(co));
         coD(co)$(countryup(co,'demand') <> 0) = YES;
         coL(co)$(countryup(co,'LNG_exp_a') <> 0) = YES;
         coNL(co) = not coL(co);
         coSouRU(co)$(countryup(co,'Source_RU') <> 0) = YES;
         coEURU(co)$(countryup(co,'Russian_gas_supply') <> 0) = YES;
*for Green Gas module:
         coGG(co)$(GG_up(co,'Capacity') <> 0)= YES;
         coNGG(co) = not coGG(co);
         coGG_NA(co)=YES$(not coEU(co) AND coGG(co));
         coNGG_NA(co)= not coGG_NA(co);
         coS(co)$((countryup(co,'foerd') <> 0) OR coGG(co)) = YES;
         coNS(co) = not coS(co);
         lnf('local_gas5')= YES;
         lf(l)=not lnf(l);
*Scenario independent data
*---------------------------------
         p_Limit_localgas(co,a,l) = productionup(co,a,l);
         p_flex(co) = countryup(co,'p_flex');
         LNG_imp_d(co) = countryup (co, 'LNG_imp_a')/365;
         LNG_exp_d(co) = countryup (co, 'LNG_exp_a')/365;
         lng_cap(cco,co) = lng_trade_up(cco,co,'capacity');
         transmission_limit(co,cco,a,j) = transmissionup(co,cco,'capacity');
         tr_costs(co,cco) = transmissionup(co,cco,'costs');
         tr_length(co,cco) = transmissionup(co,cco,'length');
         storage_inj_Anstieg(s) = storage_rise_up(s,'s_inj_rise');
         storage_inj_Schnittpunkt(s) = storage_rise_up (s,'s_inj_n');
         storage_with_Anstieg(s) = storage_rise_up(s,'s_with_rise');
         storage_with_Schnittpunkt(s) = storage_rise_up (s,'s_with_n');
         storage_cushion_gas(s) = storage_rise_up(s,'s_cushion_gas');
         exp_pip_option(co,cco) = transmissionup(co,cco,'expansion');
         exp_pip_maximum(co,cco) = transmissionup(co,cco,'exp_abs');
         exp_pip_costs(co,cco) = 1.12;
         exp_lng_costs(co) = countryup(co,'LNG_imp_Invest_costs');
         exp_lng_capacity(co) = countryup(co,'LNG_imp_a_ext');
*General scneario related parameters
*---------------------------------
         prob(j) = scenario_up(j,'prob');
         LNGmarkup(j)=1+0.5*scenario_up(j,'LNG');
         UApip(j) = scenario_up(j,'UA');
*Green Gas scenario parameter
*-------------------------------
         exp_prod_costs(co,l) = GG_up(co,'Invest');
         exp_prod_capacity(co,'local_gas5') = GG_up(co,'Capacity');
****************************************************************************
*data depending on the modeled year
*----------------------------------
*2015
%year2015%$ontext
         demGrow(j,'2015') = 0;
         dem('2015',t,coNEU,j) = dem_rel(t,coNEU)*countryup(coNEU,'dem_15');
         lng_costs(cco,co,a,j) = lng_trade_up(cco,co,'Gesamt');
         p_c(co,a,l,j) = pr_costup(co,a,l)*10**4;
         p_c(coL$(ne 'NO'),a,l,j) = LNGmarkup(j)*pr_costup(coL,a,l)*10**4;
         KONV_pip.fx(co,cco,a,j) = 0;
         KONV_lng.fx(co,a,j)= 0;
         KONV_sto.fx(co,s,a,j) = 0;
$ontext
$offtext
*2045
%year2045%$ontext
         demGrow(j,'2030') = scenario_up(j,'demGrow30');
         demGrow(j,'2045') = scenario_up(j,'demGrow45');
         dem('2030',t,coNEU,j) =dem_rel(t,coNEU)*countryup(coNEU,'dem_30');
         dem('2030',t,coEU,j) =  dem_rel(t,coEU)*countryup(coEU,'dem_30')
                                 *(1 + demGrow(j,'2030'));
         dem('2045',t,coNEU,j) = dem_rel(t,coNEU)*countryup(coNEU,'dem_45');
         dem('2045',t,coEU,j)  = dem_rel(t,coEU)*countryup(coEU,'dem_45')
                                 *(1 + demGrow(j,'2030'))
                                 *(1+demGrow(j,'2045'));
         lng_costs(cco,co,a,j) = lng_trade_up(cco,co,'Gesamt')*LNGmarkup(j);
         p_c(co,a,l,j) = pr_costup(co,a,l)*10**4;
         p_c(coL,a,l,j) = LNGmarkup(j)*pr_costup(coL,a,l)*10**4;
         p_c(co,a,'local_gas5',j) = GG_up(co,'costs');
         p_c('NO',a,l,j) = pr_costup('NO',a,l)*10**4;
         transmission_limit('RU','UA',a,j) =
                 transmissionup('RU','UA','capacity')*UApip(j);
$ontext
$offtext
****************************************************************************
*fixing variables
         KONV_lng.fx(coNEU,a,j) = 0;
         KONV_sto.fx(coFSTO,s,a,j)= 0;
*Green Gas (all EU+NA)
%greengas%$ontext
%NAandEU%$ontext
         KONV_prod.fx(coNGG,a,l,j) = 0;
$ontext
$offtext
*Green Gas (all NA)
%greengas%$ontext
%onlyNA%$ontext
         KONV_prod.fx(coNGG_NA,a,l,j) = 0;
$ontext
$offtext
         STORAGE_IN.fx(coFSTO,s,t,a,j) =0;
         STORAGE_OUT.fx(coFSTO,s,t,a,j)=0;
         STORAGE_LEVEL.fx(coFSTO,s,t,a,j) = 0;
         PQ.fx(coNS,l,t,a,j) = 0;
         LNG.fx(cco,coNL,t,a,j) = 0;
*CPLEX otions
$onecho > cplex.opt
names 0
lpmethod 4
threads 8
parallelmode -1
$offecho
*###########################################################################
*                        SOLVE MODULES
*###########################################################################
*shock scenario
$ifthen set shock
$include 02_model_shock
$endif
*Green Gas Sensitivity
$ifthen set sensGG
$include 02_model_GreenGasSensitivity
$endif
*###########################################################################
*                        SOLVE STATEMENTS
*###########################################################################
*overview
*1 No Policy
*1.1 green gas - RCP
*1.2 green gas - WSP
*1.3 no green gas - RCP
*1.4 no green gas - WSP
*1.5 green gas - EEV
*1.6 no green gas - EEV

*2 National Policy
*2.1 green gas - RCP
*2.2 green gas - WSP
*2.3 no green gas - RCP
*2.4 no green gas - WSP
*2.5 green gas - EEV
*2.6 no green gas - EEV

*3 EU Policy
*3.1 green gas - RCP
*3.2 green gas - WSP
*3.3 no green gas - RCP
*3.4 no green gas - WSP
*3.5 green gas - EEV
*3.6 no green gas - EEV

****************************************************************************
$ifthen.one not set sensGG
$ifthen.two not set shock
$include  02_model_RCP-WSP-EEV
$endif.two
$endif.one

