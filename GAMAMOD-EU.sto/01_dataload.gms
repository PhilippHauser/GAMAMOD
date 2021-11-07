*###########################################################################
*                               DATA Load
*###########################################################################
* Last change: 06.12.2020
* By: Philipp Hauser
*###########################################################################
*                                 DEFINITIONS
*###########################################################################
SET
****************************************************************************
*Determines for which years the model runs
%year2015%$ontext
         a               year /2015/
$ontext
$offtext

%year2045%$ontext
         a               year /2030, 2045/
$ontext
$offtext
****************************************************************************
         co              country
         coS(co)         countries of supply (production)
         coNS(co)        countries without supply (production)
         coSTO(co)       countries with storage capacity in 2015
         coNSTO(co)      countries with potential new storages
         coFSTO(co)      countries with fixed storages to zero
         coD(co)         countries with demand
         coL(co)         countries with LNG export facilities
         coNL(co)        countries with no LNG export facilities
         coEU(co)        countries within EU28
         coNEU(co)       compelemt of set coEU
         coSouRU(co)     Russia and pure Russian transit gas countries
         coEURU(co)      coutnries of EU28 with access to Russian gas
*for Green Gas option
         coGG(co)        countries with Green Gas option
         coNGG(co)       countries with no option of Green Gas
         coGG_NA(co)     countries with GG option (only North Africa)
         coNGG_NA(co)    countries with no GG option (only North Africa)
         coGG_EU(co)     countries with GG option (only Europe)
         coNGG_EU(co)    countries with no GG option (only Europe)

         t               time
         l               local_gas_quality
         lf(l)           fossil local gas quality
         lnf(l)          non-fossil local gas quality
         s               storage_typ     /s1,s2,s3,s4/
         j               stochastic scenario
;
*for modules
SET
         div_co(co)      diversification country;
*reading for put_utility gfxin (headers of setup-parameters)
Set y
      /  EU28, Source_RU, Russian_gas_supply, foerd, demand,
         LNG_imp_a, LNG_imp_a_ext, LNG_imp_Invest_costs,
         LNG_exp_a, p_flex, Gesamt, capacity, length, costs,
         expansion, s_inj_rise, s_inj_n, s_with_rise,
         s_with_n, s_cushion_gas, prob, demGrow30, demGrow45,
         LNG, UA/
;
ALIAS
         (co,cco), (a,aa), (j,jj);
*for loop calculation
file intern;
file text;

Parameters
*demand
****************************************************************************
         dem(a,t,co,j)                   demand
         dem_rel(t,co)                   relative demand in percentage
*setups
****************************************************************************
         countryup(co,*)                 setup on country data
         productionup(co,a,*)            setup on production data
         pr_costup(co,a,*)               setup on production costs
         timeup(t,*)                     time steps
         lng_trade_up(cco,co,*)          setupt on LNG Trade
         transmissionup(co,cco,*)        setup on pipeline transmission
         storage_rise_up(s,*)            slope for storage characteristics
         GG_up(co,*)                     assumptions for the GG scenario
*LNG
****************************************************************************
         LNG_imp_d(co)                   LNG import capcity (daily)
         LNG_exp_d(co)                   LNG export capacity (daily)
         lng_costs(cco,co,a,j)           LNG trade costs
         lng_cap(cco,co)                 LNG capacity
*production
****************************************************************************
         p_c(co,a,l,j)                   extraction cost
         p_limit_localgas(co,a,l)        maximum yearly production cap.
         p_flex(co)                      production flexibility
*storages
****************************************************************************
         storage_max(co,s)                maximum storage capacity
         storage_with(co,s)               maximal withdrawal capacity
         storage_inj (co,s)               maximal injection capacity
         storage_with_Anstieg(s)          slope of withdrawal curve
         storage_inj_Anstieg(s)           slope of injection curve
         storage_with_Schnittpunkt(s)     intersec. of the withdrawal curve
         storage_inj_Schnittpunkt(s)      intersec. of the injection curve
         storage_cushion_gas(s)           cushion-gas in storage
*transmission
****************************************************************************
         transmission_limit(co,cco,a,j)   transmission cap. [in GWh per d]
         tr_costs(co,cco)                 transmission costs [EUR per GWh]
         tr_length(co,cco)                transmission length [in km]
*load shedding costs
****************************************************************************
         Dummy                            costs for VOLL  /187713/
*expansion costs
****************************************************************************
         exp_pip_costs(co,cco)           pip. exp.costs [EUR per GWh]
         exp_pip_option(co,cco)          extension factor for pipeline [#]
         exp_pip_maximum(co,cco)         max pip.exp.cap. [GWh per d]
         exp_lng_costs(co)               LNG import exp. costs [EUR per GWh]
         exp_lng_capacity(co)            max LNG import exp.cap.[GWh per a]
         exp_sto_costs(co,s)             storage exp. costs [EUR per GWh]
         exp_sto_capacity(co,s)          max storage exp.cap. [GWh per a]
         exp_prod_costs(co,l)            exp.costs GG prod.[EUR|GWh|a]
         exp_prod_capacity(co,l)         max prod. exp. cap. [GWh per a]
*Stochhastic parameter
****************************************************************************
         scenario_up(j,*)                scenario parameter
         scenario_upE(j,*)               expected value scenario
         demGrow(j,a)                    demand grow rate in 2030 and 2045
         prob(j)                         equal probability of scenario j
         LNGmarkup(j)                    mark up on LNG price [+0%|+20%]
         UApip(j)                        available Ukraine transit [yes|no]
*Green Gas parameter
****************************************************************************
         CarbPrice                       price for CO2 emissions
;
*###########################################################################
*                                 UPLOAD
*###########################################################################
* Write gdxxrw option file
$onecho >temp.tmp
set=co                   rng=co!A2                       rdim=1 cdim=0
set=t                    rng=dem_rel_t!A1                rdim=1 cdim=0
set=l                    rng=pr_q!M2                     rdim=1 cdim=0
set=j                    rng=sc!A2                       rdim=1 cdim=0
par=dem_rel              rng=dem_rel_t!a1                rdim=1 cdim=1
par=transmissionup       rng=pip!b1                      rdim=2 cdim=1
par=lng_trade_up         rng=lng!b1                      rdim=2 cdim=1
par=countryup            rng=co!A1                       rdim=1 cdim=1
par=pr_costup            rng=pr_c!A1                     rdim=2 cdim=1
par=productionup         rng=pr_q!A1                     rdim=2 cdim=1
par=storage_rise_up      rng=s_i!P1                      rdim=1 cdim=1
par=storage_max          rng=s_q!A1                      rdim=1 cdim=1
par=storage_inj          rng=s_i!A1                      rdim=1 cdim=1
par=storage_with         rng=s_w!A1                      rdim=1 cdim=1
par=exp_sto_capacity     rng=s_q!P1                      rdim=1 cdim=1
par=exp_sto_costs        rng=s_q!U1                      rdim=1 cdim=1
par=scenario_up          rng=sc!A1                       rdim=1 cdim=1
par=scenario_upE         rng=E(sc)!A1                    rdim=1 cdim=1
par=GG_up                rng=GG!A3                       rdim=1 cdim=1
$offecho

*laod data base 2015
$onUNDF
$if set LoadXLS $call "gdxxrw Szenarien\data_base.xlsx o=Szenarien\data_base cmerge=1 @temp.tmp"
$offUNDF

$onUNDF
$gdxin Szenarien\data_base
$load  co l t j
$gdxin
$offUNDF



