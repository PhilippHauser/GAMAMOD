*GAMAMOD-DE
*Gas grid model for the German gas network
*##########################################################################
$ontext
AUTHOR: Philipp Hauser
DATE:   05.12.2020

DISCLAIMER:
The model was developed within the project LKD-EU (project funding
number: 03ET4028C). A model description is provided by Hauser (2019 and
202x). A data documentation is provided in Kinz et al. (2019). A model
application is investigated in Hauser et al. (2019).

Related Literatur:

Hauser (2019) A modelling approach for the German gas grid using highly
       resolved spatial, temporal and sectoral data (GAMAMOD-DE), ZBW -
       Leibniz Information Centre for Economics, Kiel, Hamburg, Mai 2019
Hauser (202x) Benefits and Costs of Diversification in the European Natural
       Gas Market, Dissertation, submitted in 2020
Hauser et al. (2019) Does Increasing Natural Gas Demand in the Power Sector
       Pose a Threat of Congestion to the German Gas Grid? A Model-Coupling
       Approach, Energies 2019, 12(11) 2159
Kunz et al. (2019) Electricity, Heat and Gas Sector Data for Modelling the
       German System, Schriften des Lehrstuhls für Energiewirtschaft,
       TU Dresden, Bd. 13; 28.02.2018
$offtext
*##########################################################################
*                                General Settings
*##########################################################################
$set LoadXLS_BaseData
$set LoadXLS_PowerPlant
*$set print1
*###########################################################################
*                    Data Input for Power Plants Generation
*###########################################################################
$set PowerPlantInput _2012
*$set PowerPlantInput _2012-13
*$set PowerPlantInput _2030
*$set PowerPlantInput _2030_SensPP
*###########################################################################
*                                 Modules
*###########################################################################
$set FlowModus Optimization
*###########################################################################
*                                DEFINITION
*###########################################################################
Set
          i              nodes (ID numbers are equal to QGIS-IDs)
          i_GER(i)       subset: nodes located within Germany
          i_NonGER(i)    subset: nodes located NOT in Germany
          i_exit(i)      subset: nodes with exit points
          i_DemFix(i)    subset: fixed demand in neighbouring zones
          i_ExpDem(i)    subset: export demand based on fixed flows
          pr             production facility
          st             storage facility
          st_c           storage characteristic
          l              pipelines
          a              demand secotr (a1=heat a2=indsutry a3=smallCHP)
                          /a1*a3/
          n              NUTS-Regions
          r              region (national states in Germany)
          t_d            time (days)
                         /t0001*t0366/
          t_h            time (hours)
                         /t0001*t8784/
          p_BNetzA       gas power plants (based on BNetzA list)

*used for FLowModus Simulation
****************************************************************************
          fix_POS(l)     pipelines with fixed positive flows (imp or exp)
          fix_NEG(l)     pipelines with fixed negative flows (imp or exp)
ALIAS
         (i,j), (n,nn);
Parameters
*setup
****************************************************************************
         nodesUp(i,*)                   setup nodes
         nutsUp(n,*)                    setup NUTS3-regions
         pipelinesUp(l,*)               setup pipelines
         plantsUp(p_BNetzA,*)           setup power plants
         productionUp(pr, *)            setup productino
         storagesUp(st,*)               setup storages
         timesUpModel(t_d,*)            temperature per region (2012 | 2013)
         s_patternUp(t_d,*)             storage pattern
         s_charactUp(st_c,*)            storage characteristics
         gaspriceUP(t_d,*)              gas prices for 2012 and 2030

*data interface: dispatch results of gas power plants with JMM
****************************************************************************
         genPowerPlants_UDE(p_BNetzA,t_d,*) power plant generation in JMM
*mappings
****************************************************************************
         map_in(i,n)                    maps nodes to NUTS
         map_ni(n,i)                    maps NUTS w\o nodes to exit-nodes
         map_pi(p_BNetzA,i)             maps gas plants to NUTS
         map_nr(n,r)                    maps NUTS to REGIONS
         map_tt(t_h,t_d)                maps time (hours) to time (days)
         map_pri(pr,i)                  maps production facilities to nodes
         map_sti(st,i)                  maps storage facilities to nodes
         map_lij(l,i,j)                 maps lines to node i and j
         map_lfix(l,*)                  maps subset for fixed flows
         map_stc(st,st_c)               maps storages types (aq df sc)
         map_pr(p_BNetzA,r)             maps power plants to regions r
*demand
****************************************************************************
         dem(n,t_d,a)                   demand per NUTS region
         dem_i(i,t_d)                   demand at node i
         dem_i_gasPowerPlant(i,t_d)     demand from power plants
         dem_i_sum                      controll parameter for demand
         numbNodes(n)                   number of nodes in NUTS layer n
         tempmodel_prep(t_d,r)          preperation for tempModel
         tempModel(t_d,n)               daily temperature in region r
         tempRef                        reference temperature
                                        /40/
         h_Factor(n,t_d)                load factor (heat based gas demand)
         KW(n)                          customers value
*for Model and t
         par_A(n,t_d)                   form parameter A
         par_B(n,t_d)                   form parameter B
         par_C(n,t_d)                   form parameter C
         par_D(n,t_d)                   form parameter D

*electricity sector
         genPowerPlants_h(p_BNetzA,t_h) hourly gas power plants demand
         genPowerPlants_d(p_BNetzA,t_d) daily gas power plants demand
         numbNinR(r)                    number of NUTS-zones per region

*industry sector
         industryDem(n)                 industrial gas demand [GWh_th \d]
         industryRelFactor(t_d)         relative industrial factor

*Fixed Demand in neighbouring zones (Steinitz and Deutschendorf)
         fixedDem(t_d,i)                fixed Demand (all fixed demands)
         fixedDem_choosed(t_d,i)        fixed Demand realted to moduls
         exportDem(t_d,i)               demand at export nodes
*Losses
         losses(t_d)                    losses
*production
****************************************************************************
         p_limit(pr)                    production limit [GWh per day]
         p_flex(pr)                     flexible production
         p_c (pr,t_d)                   production costs
         bafa(t_d)                      bafa price in 2015
         p_markup(pr)                   mark up on prices
         p_limit_yearly(pr)             yearly production limit
*pipelines
****************************************************************************
         transmission_limit(l)          transmission capacity
         flow_fixed_POS(t_d,l)          fixed positive flows
         flow_fixed_NEG(t_d,l)          fixed negative flows
         tr_costs(l)                    transmission costs pipelines
*Storages
****************************************************************************
         storage_max(st)                maximum storage capacity
         storage_with_max(st)           maximum withdrawn capacity GWh\d
         storage_inj_max(st)            maximum injection capacity GWh\d
         st_wIntersec(st_c)             intersection withdrawn
         st_iIntersec(st_c)             intersection injection
         st_wSlope(st_c)                slope withdrawn
         st_iSlope(st_c)                slope injection
         sinj_c                         costs for injection
         swith_c                        costs for withdrawn
         s_loose                        efficiency looses
         s_pattern(t_d)                 storage pattern
*Costs of LoadCutting
****************************************************************************
         Dummy(a)                       costs in EUR\GWh
                                        /a1 187713, a2 93856, a3 93855/
         Dummy2                         costs for additional load
                                        /200000/
         Dummy3                         load shedding costs power plants
                                        /93855/
         LoadCutFactor(a)               maximum load cutting
                                        /a1 1 , a2 0.5 , a3 1/
*###########################################################################
*                                 UPLOAD
*###########################################################################
* Write gdxxrw option file
$onUNDF
$onecho >temp.tmp
set=i                    rng=Nodes!A5                      rdim=1 cdim=0
set=l                    rng=Pipelines!A3                  rdim=1 cdim=0
set=n                    rng=NUTS!A4                       rdim=1 cdim=0
set=r                    rng=Region!C5                     rdim=1 cdim=0
set=pr                   rng=Production!B3                 rdim=1 cdim=0
set=st                   rng=Storage!A2                    rdim=1 cdim=0
set=st_c                 rng=StoragePattern!O2             rdim=1 cdim=0
set=p_BNetzA             rng=Mapping!I3                    rdim=1 cdim=0
par=nodesup              rng=Nodes!A4                      rdim=1 cdim=1
par=pipelinesup          rng=Pipelines!A2                  rdim=1 cdim=1
par=NUTSup               rng=NUTS!D3                       rdim=1 cdim=1
par=productionUp         rng=Production!B2                 rdim=1 cdim=1
par=gasPriceUp           rng=Production!N2                 rdim=1 cdim=1
par=storagesUp           rng=Storage!A1                    rdim=1 cdim=1
par=s_charactUp          rng=StoragePattern!O1             rdim=1 cdim=1
par=s_patternUp          rng=StoragePattern!C1             rdim=1 cdim=1
par=losses               rng=Losses!A1                     rdim=1 cdim=0
par=fixedDem             rng=Fixed_Dem!A2                  rdim=1 cdim=1
par=flow_fixed_POS       rng=FLOW_POS!A1                   rdim=1 cdim=1
par=flow_fixed_NEG       rng=FLOW_NEG!A1                   rdim=1 cdim=1
par=timesupModel         rng=Temp!A3                       rdim=1 cdim=1
par=industryDem          rng=industry!A2                   rdim=1 cdim=0
par=industryRelFactor    rng=industry!H2                   rdim=1 cdim=0
par=map_in               rng=Mapping!A2                    rdim=2 cdim=0
par=map_nr               rng=Mapping!E2                    rdim=2 cdim=0
par=map_pi               rng=Mapping!I2                    rdim=2 cdim=0
par=map_ni               rng=Mapping!M2                    rdim=2 cdim=0
par=map_lfix             rng=Mapping!Q2                    rdim=1 cdim=1
par=map_pr               rng=Mapping!X2                    rdim=2 cdim=0
par=map_pri              rng=Production!B3                 rdim=2 cdim=0
par=map_sti              rng=Storage!A2                    rdim=2 cdim=0
par=map_lij              rng=Pipelines!A3                  rdim=3 cdim=0
par=map_stc              rng=Storage!D2                    rdim=2 cdim=0
$offecho
****************************************************************************
$onUNDF
$onecho >temp2.tmp
par=genPowerPlants_UDE   rng=GAMS!A2                       rdim=2 cdim=1
$offecho
****************************************************************************
*Load data base
$onUNDF
$if set LoadXLS_BaseData $call "gdxxrw Data_Input_GAMAMOD-DE.xlsx squeeze=N cmerge=1 MaxDupeErrors=100 trace=3 @temp.tmp"
$gdxin Data_Input_GAMAMOD-DE
$load i n r pr st p_BNetzA l st_c
$load nodesup pipelinesup NUTSup timesupModel s_patternUp s_charactUp
$load productionUp  storagesUp
$load industryDem fixedDem gasPriceUp industryRelFactor losses
$OnEps
$load flow_fixed_POS flow_fixed_NEG
$OffEps
$load map_in map_ni map_nr map_pri map_sti map_lij map_stc map_lfix
$load map_pi map_pr
$gdxin
$offUNDF
;
****************************************************************************
*Load JMM results on gas power plant dispatch
$onUNDF
$if set LoadXLS_PowerPlant
$call "gdxxrw Data_Input_PowerPlants_JMM%PowerPlantInput%.xlsx cmerge=1 MaxDupeErrors=100 trace=3 @temp2.tmp"
$gdxin Data_Input_PowerPlants_JMM%PowerPlantInput%
$load genPowerPlants_UDE
$offUNDF
;
*###########################################################################
*                                 ASSIGNMENTS
*###########################################################################
*Subset definition
         i_DemFix(i)$(nodesup(i,'i_DemFix') eq 1) = yes;
         i_GER(i)$(nodesup(i,'i_GER') eq 1) = yes;
         i_NonGER(i)$(nodesup(i,'i_GER') ne 1) = yes;
         i_exit(i_GER)$(nodesup(i_GER,'exit_point') eq 1) = yes;
         map_lij(l,i,j)$(map_lij(l,i,j) ne 0) = 1;
         i_ExpDem(i)=
                 sum(l,map_lfix(l,'FLOW_POS_O')*sum(j,map_lij(l,j,i)))
               + sum(l,map_lfix(l,'FLOW_NEG_O')*sum(j,map_lij(l,i,j)));
         numbNinR(r)=sum(n, map_nr(n,r));

*Optimization
$if %FlowModus% == "Optimization" fix_POS(l)$(map_lfix(l,'FLOW_POS_O')eq 1)=yes;
$if %FlowModus% == "Optimization" fix_NEG(l)$(map_lfix(l,'FLOW_NEG_O')eq 1)=yes;

*Scenario based sets and parameters
****************************************************************************
*Defines the considered time scope for optimization
Set
$if %PowerPlantInput% == "_2012" tt(t_d) subset to run model /t0001*t0366/;
$if %PowerPlantInput% == "_2030" tt(t_d) subset to run model /t0001*t0365/;
$if %PowerPlantInput% == "_2030_SensPP" tt(t_d) subset to run model /t0001*t0365/;

*Gas price (Choose with (*) the relevant scenario)
$if %PowerPlantInput% == "_2012" bafa(t_d)=gasPriceUp(t_d,'NCG_Q_2012');
*$if %PowerPlantInput% == "_2012" bafa(t_d)=gasPriceUp(t_d,'BAFA_price_2012');
*$if %PowerPlantInput% == "_2030" bafa(t_d)=gasPriceUp(t_d,'2030_N');
$if %PowerPlantInput% == "_2030" bafa(t_d)=gasPriceUp(t_d,'NCG_Q_2030');
$if %PowerPlantInput% == "_2030_SensPP" bafa(t_d)=gasPriceUp(t_d,'2030_N');

*Sensitivities
*$if %PowerPlantInput% == "_2030" bafa(t_d)=gasPriceUp(t_d,'2030_A');
*$if %PowerPlantInput% == "_2030" bafa(t_d)=gasPriceUp(t_d,'2030_S');
;
*---------------------------------------------------------------------------
*                CALCULATION OF HEAT BASED GAS DEMAND    (a1)
*---------------------------------------------------------------------------
*NUTS-3 Temperature for each day
         tempModel_prep(t_d,r) = timesupModel(t_d,r);
         tempModel(t_d,n)      = sum(r,tempModel_prep(t_d,r)*map_nr(n,r));
*Parameter A-D
         par_A(n,t_d)          = NUTSup(n,'A');
         par_B(n,t_d)          = NUTSup(n,'B');
         par_C(n,t_d)          = NUTSup(n,'C');
         par_D(n,t_d)          = NUTSup(n,'D');
*h-Factor
         h_Factor(n,t_d)       = par_A(n,t_d)/
                                 (1+ (par_B(n,t_d)/(tempModel(t_d,n)
                                 -tempRef))**par_C(n,t_d))
                                 + par_D(n,t_d);
*KW-Wert
         KW(n)                 = 0;
         KW(n)$(sum(t_d,h_Factor(n,t_d)) gt 0)
                               = NUTSup(n,'Ref-Dem')/
                                 sum(t_d,h_Factor(n,t_d));
*regional gas based demand for heating
         dem(n,t_d,'a1')       = 0;
         dem(n,t_d,'a1')       = KW(n)*h_Factor(n,t_d);
*---------------------------------------------------------------------------
*                CALCULATION OF INDUSTEY BASED GAS DEMAND   (a2)
*---------------------------------------------------------------------------
*demand for industry generation per NUTS region n
         dem(n,t_d,'a2')       =0 ;
         dem(n,t_d,'a2')       = industryDem(n)*366*industryRelFactor(t_d);
*---------------------------------------------------------------------------
*                CALCULATION OF SMALL CHP PLANT BASED GAS DEMAND   (a3)
*---------------------------------------------------------------------------
*demand for small chp power plants in federal states (only in 2030)
         dem(n,t_d,'a3')       = 0;
         dem(n,t_d,'a3')$(sum(r,numbNinR(r)*map_nr(n,r)) gt 0)
                               = sum((r,p_BNetzA),
                                 genPowerPlants_UDE(p_BNetzA,t_d,'Value')
                                 *map_pr(p_BNetzA,r)*map_nr(n,r)
                                 )/1000/sum(r,numbNinR(r)*map_nr(n,r));
*-------------------------------------------------------------------------------
*                SUMMATION and ALLOCATION of NUTS3 DEMAND TO NODES
*-------------------------------------------------------------------------------
*counts numbers of EXIT-nodes per NUTS3 region
         numbNodes(n)          = NUTSup(n,'numbNodesExit');
*fixed demand
         fixedDem_choosed(t_d,i)    = 0;
*add generation power plants and convert from MWh_th into GWh_th
         dem_i_gasPowerPlant(i,t_d) =
                sum(p_BNetzA,
                genPowerPlants_UDE(p_BNetzA,t_d,'Value')*map_pi(p_BNetzA,i)
                )/1000;
         dem_i(i,t_d)          = 0;
*allocation of sector specific gas demand to total gas demand per node
         dem_i(i_exit,t_d)     =
*...heat and industry
                 sum((a,n)$(numbNodes(n) gt 0),
                         (dem(n,t_d,a)*map_in(i_exit,n))/
                         (sum(nn,numbNodes(nn)*map_in(i_exit,nn))))
                 + sum((a,n)$(numbNodes(n) eq 0),
                         dem(n,t_d,a)*map_ni(n,i_exit))
*...gas power plants
                 + dem_i_gasPowerPlant(i_exit,t_d)
*...fixed demand (basically for neghbouring countries)
                 + fixedDem_choosed(t_d,i_exit)
                 + losses(t_d)/card(i_exit);
*total sum of gas demand
         dem_i_sum = sum((i,t_d),dem_i(i,t_d));
*export
         exportDem(t_d,i_ExpDem(i))=
                 sum(l,flow_fixed_POS(t_d,l)*sum(j,map_lij(l,j,i)))
                 + sum(l,flow_fixed_NEG(t_d,l)*sum(j,map_lij(l,i,j)));
Parameter
         exportDem_sum(i)    Summme Export;
         exportDem_sum(i)    = sum(t_d,exportDem(t_d,i));
*---------------------------------------------------------------------------
*                    ASSIGNING PIPELINE PARAMETERS
*---------------------------------------------------------------------------
          transmission_limit(l)  = pipelinesup(l,'limit');
          tr_costs(l)$(transmission_limit(l) gt 0) =
                                   0.17 * pipelinesup(l,'Länge')/1000;
*--------------------------------------------------------------------------
*                   ASSIGNING PRODUCTION PARAMETERS
*--------------------------------------------------------------------------
*daily production limit
         p_limit(pr)           = productionUp(pr,'p_limit');
*daily production flexibility
         p_flex(pr)            = productionUp(pr,'flexFactor');
*production costs
         p_c(pr,t_d)           = 0;
         p_c(pr,t_d)           =
                 sum(i$(map_pri(pr,i)AND nodesup(i,'foerd_c') ne 0),
                 nodesup(i,'foerd_c')*map_pri(pr, i));
         p_c(pr,t_d)$(sum(i ,nodesup(i,'cross-border')*map_pri(pr,i)) eq 1) =
                 bafa(t_d);
*annual production limit
         p_limit_yearly(pr)     = productionUp(pr,'year');
*--------------------------------------------------------------------------
*                   ASSIGNING STORAGE PARAMETERS
*--------------------------------------------------------------------------
*maximum storage volume
         storage_max(st)       = storagesUp(st,'storage_limit');
*storage withdrawn and injection
         storage_with_max(st)  = storagesUp(st,'s_with_max');
         storage_inj_max (st)  = storagesUp(st, 's_inj_max');
*storage loses in percentages
         s_loose(st) = storagesUp(st,'s_loose');
*storage pattern
         s_pattern(t_d)        = s_patternUp(t_d,'rel');
*storage characteristics
         st_iIntersec(st_c)    = s_charactUp(st_c,"s_inj_n");
         st_wIntersec(st_c)    = s_charactUp(st_c,"s_with_n");
         st_iSlope(st_c)       = s_charactUp(st_c,"s_inj_rise");
         st_wSlope(st_c)       = s_charactUp(st_c,"s_with_rise");
*---------------------------------------------------------------------------
*                   ADJUSTMENT for SCENARIO 2030
*---------------------------------------------------------------------------
*Production Capacity NL=0 and DE=0
$if %modelRun% == "_2030" p_limit('pr_15')=0;
$if %modelRun% == "_2030" p_limit('pr_01')=0;
$if %modelRun% == "_2030" p_limit('pr_02')=0;
$if %modelRun% == "_2030" p_limit('pr_03')=0;
$if %modelRun% == "_2030" p_limit('pr_04')=0;
$if %modelRun% == "_2030" p_limit('pr_05')=0;
$if %modelRun% == "_2030" p_limit('pr_06')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_15')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_01')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_02')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_03')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_04')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_05')=0;
$if %modelRun% == "_2030_SensPP" p_limit('pr_06')=0;

*Nord Stream I+II is in operation
$if %modelRun% == "_2030" transmission_limit('l1801')=pipelinesup('l1801','limit')*4;
$if %modelRun% == "_2030_SensPP" transmission_limit('l1801')=pipelinesup('l1801','limit')*4;
execute_unload 'dataload_GasGridGermany_dynamic_v18_%modelRun%.gdx'
;
*###########################################################################
*                        VARIABLES
*###########################################################################
Variable
         COST                           total system costs
;
Positive Variables
         DUMMY_VALUE1(a,i,tt)           load shedding (heat | industry)
         DUMMY_VALUE2(i,tt)             load increase
         DUMMY_VALUE3(i,tt)             load shedding of power plants
         FLOW_POS(l,tt)                 flow on lines pos
         FLOW_NEG(l,tt)                 flow on lines neg
         P_Q(pr,tt)                     production
         STORAGE_IN(st,tt)              storage injection
         STORAGE_WITH(st,tt)            storage withdrawal
         STORAGE_LEVEL(st,tt)           storage level
;
*###########################################################################
*                        DECLARATION of EQUATIONS
*###########################################################################
Equations
         OBJECTIVE                            cost minimization
         ENERGY_BALANCE(i,tt)                 energy balance
         DUMMY_BALANCE(n,tt,a)                load shedding bal. (regions)
         DUMMY_BALANCE2(i,tt)                 load shed. bal. (power plants)
*Production Constraints
         PRODUCTION_LIMIT_1(pr,tt)            daily production limit
         PRODUCTION_LIMIT_2(pr)               yearly production limit
*Pipeline Constraints
         PIPELINE_FLOW_POS(l,tt)              gas flow in pos. direction
         PIPELINE_FLOW_NEG(l,tt)              gas flow in neg. direction

         FLOW_POS_FIX_EQ(l,tt)                imports and exports
         FLOW_NEG_FIX_EQ(l,tt)                imports and exports
*Storage Constraints
         STORAGE_LEVEl_CONST_START(st,tt)     storage level first periode
         STORAGE_LEVEL_CONST_1(st,tt)         storage level balance
         STORAGE_LEVEL_CONST_2(st,tt)         storage level max
         STORAGE_LEVEL_CONST_END(st,tt)       storage level last periode
         STORAGE_WITH_CONST(st,tt)            max withraw absolut
         STORAGE_INJ_CONST (st,tt)            max injection absolut
         STORAGE_WITH_CONST_2(st,tt)          max withdrawal relative
         STORAGE_INJ_CONST_2(st,tt)           max injection relative
;
*###########################################################################
*                        DEFINITION of EQUATIONS
*###########################################################################
OBJECTIVE..
         COST =e=
                 sum((pr,tt),P_Q(pr,tt)*p_c(pr,tt))+
                 sum((l,tt),(FLOW_pos(l,tt)+FLOW_neg(l,tt))
                 *tr_costs(l))+
                 sum((a,i,tt),DUMMY_VALUE1(a,i,tt)*Dummy(a))+
                 sum((i,tt),DUMMY_VALUE2(i,tt)*Dummy2)+
                 sum((i,tt),DUMMY_VALUE3(i,tt)*Dummy3);
ENERGY_BALANCE(i,tt)..
        (-1)*(
*demand
        dem_i(i,tt)
*demand at export nodes
        + exportDem(tt,i)
*exports from i to j
        + sum((j,l)$(map_lij(l,i,j) ne 0),FLOW_pos(l,tt)*map_lij(l,i,j))
        + sum((j,l)$(map_lij(l,j,i) ne 0),FLOW_neg(l,tt)*map_lij(l,j,i))
*storage injection
        +sum(st$map_sti(st,i), STORAGE_IN(st,tt))
*load shedding
        +DUMMY_VALUE2(i,tt)
        )+
*production
        sum(pr$map_pri(pr,i),P_Q(pr,tt))
*imports from j to i
        + sum((j,l)$(map_lij(l,i,j) ne 0),FLOW_neg(l,tt)*map_lij(l,i,j))
        + sum((j,l)$(map_lij(l,j,i) ne 0),FLOW_pos(l,tt)*map_lij(l,j,i))
*storag withdrawal
        + sum(st$map_sti(st,i), STORAGE_WITH(st,tt))
        + sum(a,DUMMY_VALUE1(a,i,tt))
        + DUMMY_VALUE3(i,tt)
                                                 =e= 0;
*load shedding balance
*---------------------------------------------------------------------------
DUMMY_BALANCE(n,tt,a)..
         sum(i$map_in(i,n), DUMMY_VALUE1(a,i,tt))
         + sum(i$map_ni(n,i), DUMMY_VALUE1(a,i,tt))
         =l= dem(n,tt,a)*LoadCutFactor(a);
DUMMY_BALANCE2(i,tt)$(dem_i_gasPowerPlant(i,tt) gt 0)..
         DUMMY_VALUE3(i,tt) =l= dem_i_gasPowerPlant(i,tt);
DUMMY_VALUE3.fx(i,tt)$(dem_i_gasPowerPlant(i,tt) eq 0) = 0;

*production-constraints
*---------------------------------------------------------------------------
PRODUCTION_LIMIT_1(pr,tt)..
         P_Q(pr,tt) =l= p_limit(pr)*p_flex(pr);
PRODUCTION_LIMIT_2(pr)..
         sum(tt,P_Q(pr,tt)) =l= p_limit(pr)*card(tt);

*pipeline constraints
*---------------------------------------------------------------------------
PIPELINE_FLOW_POS(l,tt)$(transmission_limit(l) ne 0)..
         FLOW_pos(l,tt) =l= transmission_limit(l);
PIPELINE_FLOW_NEG(l,tt)$(transmission_limit(l) ne 0)..
         FLOW_neg(l,tt) =l= transmission_limit(l);
FLOW_POS_FIX_EQ(fix_POS(l),tt)..
         FLOW_pos(l,tt) =e= flow_fixed_pos(tt,l);
FLOW_NEG_FIX_EQ(fix_NEG(l),tt)..
         FLOW_neg(l,tt) =e= flow_fixed_neg(tt,l);

*Storage-constraints
*---------------------------------------------------------------------------
STORAGE_LEVEl_CONST_START(st,tt)$(ord(tt) eq 1)..
         STORAGE_LEVEL(st,tt) =e=
                 storage_max(st)*s_pattern(tt)
                 +(1-s_loose(st)/100)*STORAGE_IN(st,tt)
                 -(1+s_loose(st)/100)*STORAGE_WITH(st,tt)
;
STORAGE_LEVEL_CONST_1(st,tt)$(ord(tt) ne 1)..
         STORAGE_LEVEL(st,tt) =e=
                 STORAGE_LEVEL(st,tt-1)
                 +(1-s_loose(st)/100)*STORAGE_IN(st,tt)
                 -(1+s_loose(st)/100)*STORAGE_WITH(st,tt)
;
STORAGE_LEVEL_CONST_2(st,tt)..
         STORAGE_LEVEL(st,tt) =l= storage_max(st)
;
STORAGE_LEVEL_CONST_END(st,tt)$(ord(tt) eq card(tt))..
         STORAGE_LEVEL(st,tt) =e=  storage_max(st)*s_pattern(tt)
;
STORAGE_WITH_CONST(st,tt)..
         STORAGE_WITH(st,tt) =l= storage_with_max(st)
;
STORAGE_INJ_CONST(st,tt)..
         STORAGE_IN(st,tt) =l= storage_inj_max(st)
;
STORAGE_WITH_CONST_2(st,tt)$(ord(tt) ne 1)..
         STORAGE_WITH(st,tt) =l=
                 storage_with_max(st)*(
                 sum(st_c,st_wIntersec(st_c)*map_stc(st,st_c))
                 +sum(st_c,st_wSlope(st_c)*map_stc(st,st_c))
                 *STORAGE_LEVEL(st,tt-1)/storage_max(st))
;
STORAGE_INJ_CONST_2(st,tt)$(ord(tt) ne 1)..
         STORAGE_IN(st,tt) =l=
                 storage_inj_max(st)*(
                 sum(st_c,st_iIntersec(st_c)*map_stc(st,st_c))-
                 sum(st_c,st_iSlope(st_c)*map_stc(st,st_c))*
                 STORAGE_LEVEL(st,tt-1)/storage_max(st))
;
Storage_IN.fx(st,tt) = 0;
Storage_WITH.fx(st,tt)=0;

Model GAMAMOD_DE  /
OBJECTIVE
ENERGY_BALANCE
PRODUCTION_LIMIT_1, PRODUCTION_LIMIT_2
DUMMY_BALANCE, DUMMY_BALANCE2
PIPELINE_FLOW_POS, PIPELINE_FLOW_NEG
FLOW_POS_FIX_EQ, FLOW_NEG_FIX_EQ
STORAGE_LEVEL_CONST_START
STORAGE_LEVEL_CONST_1, STORAGE_LEVEL_CONST_2
STORAGE_LEVEL_CONST_END
STORAGE_WITH_CONST, STORAGE_INJ_CONST
STORAGE_WITH_CONST_2, STORAGE_INJ_CONST_2
/;
Option reslim = 10000;
Option Profile=2;
GAMAMOD_DE.dictfile=0;
Solve GAMAMOD_DE minimizing COST using lp;
execute_unload 'RESULTS_GAMAMOD-DE_%modelRun%.gdx';