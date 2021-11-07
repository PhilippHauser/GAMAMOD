*###############################################################################
*                               DATA Load
*###############################################################################
*
* Last change: 18.05.2018
* By: PH


*Version
*-----------------------------
*v01
*-----------------------------
* Set k(co) Subset aller Produzentenländer
*###############################################################################
*                                 DEFINITIONS
*###############################################################################

SET

         co              country
         coS(co)         countries of supply
         coD(co)         countries with demand
         coL(co)         countries with LNG export facilities
         t               time
         l               local_gas_quality
         s               storage_typ     /s1,s2,s3,s4/
;
SET \\ für Module
         div_co(co)      Diversification country
;

Set y \\ Auslesen für put_utility gdxin
      / foerd, demand, LNG_imp_a,
        LNG_exp_a, p_flex, Gesamt, capacity,
        costs, s_inj_rise, s_inj_n, s_with_rise,
        s_with_n, s_cushion_gas/
;

file intern;
file text;

ALIAS
         (co,cco)
;


Parameters

*Nachfrage
********************************************************************************

         dem(t,co)                       demand
         dem_rel(t,co)                   relative demand in percentage
*Setups
********************************************************************************
         countryup(co,*)                 country data
         productionup(co,*)              production data
         pr_costup(co,*)                 cost per country
         timeup(t,*)                     Time-Data
         lng_trade_up(cco,co,*)          LNG Trade costs
         transmissionup(co,cco,*)        Transmission Parameter
         storage_rise_up(s,*)            Rises for Storage injection and withdrawn

*LNG Parameter
********************************************************************************

         LNG_imp_d(co)                   LNG Importkapazität täglich
         LNG_exp_d(co)                   LNG Exportkapazität täglich
         lng_costs(cco,co)               lng trade costs
         lng_cap(cco,co)                 lng capacity

*Produktions Parameter
********************************************************************************
         p_c(co,l)                       extraction cost
*         P_limit(co)                     Maximum daily production in t
         P_limit_localgas(co,l)          Maximum yearly production of local gas l
         p_flex(co)                      flexibility of production

*Speicher Parameter
********************************************************************************
*storage_c bezeichnet sowohl die Ein- als auch Ausspeicherkosten

         storage_max(co,s)                 Maximum storage capacity
         storage_c(co,s)                   cost of storage
         storage_with(co,s)                maximal withdraw
         storage_inj (co,s)                maximal inject.
         storage_duration_cost(s)            Store cost for GWh per d
         storage_with_Anstieg(s)          Anstieg der Einspeicherkennlinie
         storage_inj_Anstieg(s)          Anstieg der Einspeicherkennlinie
         storage_with_Schnittpunkt(s)     Schnittpunkt der Einspeicherkennlinie
         storage_inj_Schnittpunkt(s)     Schnittpunkt der Einspeicherkennlinie
         storage_cushion_gas(s)          Percentage of Cushion-Gas per storage

*Übertragungskosten Pipelines
********************************************************************************
         transmission_limit(co,cco)      transmission capacity
         tr_costs(co,cco)                Transmission costs pipelines

*Kosten der Lastabschaltung
********************************************************************************
         Dummy                           Kosten  /187713/

*Value of lost load, Lochner(2011) 55€/MBTU forn 50% Industry, than 100€/MBTU
* 1 MBTU = 293 kWh
*55€/MBTU ~ 187.713 €/GWh
*100€/MBTU ~ 341.296 €/GWh
         ;

*###############################################################################
*                                 UPLOAD
*###############################################################################
* Write gdxxrw option file
$onecho >temp.tmp

set=co                   rng=country!A2                  rdim=1 cdim=0
set=t                    rng=time!A1                     rdim=1 cdim=0
set=l                    rng=Production!J2               rdim=1 cdim=0

par=dem_rel              rng=demand!a1                   rdim=1 cdim=1
par=transmissionup       rng=transmission!b1             rdim=2 cdim=1
par=countryup            rng=country!A1                  rdim=1 cdim=1
par=pr_costup            rng=production_costs!A1         rdim=1 cdim=1
par=productionup         rng=production!A1               rdim=1 cdim=1
par=storage_rise_up      rng=storage_Injection!P1        rdim=1 cdim=1


par=storage_max                  rng=Storage_Capacity!A1         rdim=1 cdim=1
par=storage_c                    rng=Storage_Costs!A1            rdim=1 cdim=1
par=storage_inj                  rng=Storage_Injection!A1        rdim=1 cdim=1
par=storage_with                 rng=Storage_Withdraw!A1         rdim=1 cdim=1
par=storage_duration_cost        rng=Storage_Costs!N12            rdim=1 cdim=0


par=timeup               rng=time!A1                     rdim=1 cdim=1
par=lng_trade_up         rng=lng!b1                      rdim=2 cdim=1



$offecho

*execute_unload 'europe_country.gdx' ;

$onUNDF
$if set LoadXLS $call "gdxxrw %Ordner_Source%\%data1%.xlsx o=%Ordner_Source%\%data1% cmerge=1 @temp.tmp"
*$if set LoadXLS $call "gdxxrw %Ordner_Source%\%data2%.xlsx o=%Ordner_Source%\%data2% cmerge=1 @temp.tmp"
$offUNDF

$onUNDF
$gdxin %Ordner_Source%\%data%2015
$load  co l t
$gdxin
$offUNDF



