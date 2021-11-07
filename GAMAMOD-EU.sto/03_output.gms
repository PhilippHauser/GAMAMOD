*###############################################################################
*                              GaMaMod output file
*###############################################################################
*
* Last change: 10.02.2015
* By: PH

$ontext
*$ifthen set RunOutputCalc
*Overview
*-------------------------------------------------------------------------------
Parameter
Export(co,t)
Import(co,t)
Gesamt(co,*);

*Trade
*-------------------------------------------------------------------------------
Parameter
Gesamt_trade(cco,co)
Gesamt_LNG(cco,co);

*Biogas
*-------------------------------------------------------------------------------
Parameter
Biogas_use(co)
Biogas_rel(co);

$ifthen not set RunModel
Positive Variable
*Variable
LNG(co,cco,t)                    LNG-Import
Dummy_value(co,t)                Dummy-Wert
p_q_l(co,l,t)                    production volume per local_gas
storage_in(co,s,t)               injection
storage_out(co,s,t)              withdrawal
storage_level(co,s,t)            level
trade(co,cco,t)                  Handel
;
$endif

loop(i_loop,


*alte Daten löschen
Export(co,t)= NO;
Import(co,t)= NO;
Gesamt(co,'Export')= NO;
Gesamt(co,'Import')=NO;
Gesamt(co,'Nettoimport')=NO;
Gesamt(co,'Produktion')=NO;
Gesamt(co,'Speicher') =NO;
Gesamt(co,'Dummy')=NO;
Gesamt(co,'Nachfrage')=NO;

Gesamt_trade(cco,co) =NO;
Gesamt_LNG(cco,co) =NO;

Biogas_use(co) = NO;
Biogas_rel(co) = NO;

$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\results\%data%_results_' i_loop.tl:0;
         execute_load trade LNG Dummy_value storage_in storage_out storage_level p_q_l dem P_limit_localgas;
$offUNDF

*neu Beschreiben
Export(co,t)= sum((cco),trade.l(co,cco,t))+sum(cco,LNG.l(cco,co,t));
Import(co,t)= sum((cco),trade.l(cco,co,t))+sum(cco,LNG.l(co,cco,t));
Gesamt(co,'Export')= sum(t,Export(co,t));
Gesamt(co,'Import')=sum(t,Import(co,t));
Gesamt(co,'Nettoimport')=Gesamt(co,'Import')-Gesamt(co,'Export');
Gesamt(co,'Produktion')=sum((t,l),p_q_l.l(co,l,t));
Gesamt(co,'Speicher') =sum((t,s),storage_in.l(co,s,t));
Gesamt(co,'Dummy')=sum(t,Dummy_value.l(co,t));
Gesamt(co,'Nachfrage')=sum(t,dem(t,co));

Gesamt_trade(cco,co) =sum(t,trade.l(cco,co,t));
Gesamt_LNG(cco,co) = sum(t,LNG.l(cco,co,t));

Biogas_use(co) = sum (t,p_q_l.l(co,'local_gas5',t));
*Biogas_rel(co) = Biogas_use(co)/P_limit_localgas(co,'local_gas5');

         putclose
         put_utility  text 'gdxout' / '%Ordner_Source%\analysis\%data%analysis_' i_loop.tl:0;
         execute_unload;
);
*$endif
$offtext

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*#Modul - Im-Export Deutschland
*-------------------------------------------------------------------------------
$ifthen set trade_de
*Aggregation Trade auf Monate
*-------------------------------------------------------------------------------
Set
         m /1*12, total/
         k(co) Auswertungsländer /DE_NCG, DE_GP/
;

Parameter
         Start_day(m)/

         1        1
         2       32
         3       60
         4       91
         5       121
         6       152
         7       182
         8       213
         9       244
         10      274
         11      305
         12      335
         total     1
/
;
Parameter
         End_day(m)/

         1        31
         2        59
         3        90
         4       120
         5       151
         6       181
         7       212
         8       243
         9       273
         10      304
         11      334
         12      365
         total   365
/
;
Variable
         trade(co,cco,t);

Parameters
Trade_DE(*,cco,*,m)
Trade_DE_gesamt(cco,m)
;
$GDXIN output\results.gdx
$loaddc trade
$GDXIN

Loop(m,Trade_DE('Import',cco,k,m)=
         sum(t$
         ((ord(t)>=Start_day(m))AND(ord(t) <= End_day(m))),trade.l(cco,k,t)))

Loop(m,Trade_DE('Export',cco,k,m)=
         sum(t$
         ((ord(t)>=Start_day(m))AND(ord(t) <= End_day(m))),trade.l(k,cco,t)))
;
Trade_DE('Import',cco,'DE',m) =
         Trade_DE('Import',cco,'DE_NCG',m) +
         Trade_DE('Import',cco,'DE_GP',m)
;
Trade_DE('Export',cco,'DE',m) =
         Trade_DE('Export',cco,'DE_NCG',m) +
         Trade_DE('Export',cco,'DE_GP',m)
;
Trade_DE_gesamt(cco,m) = Trade_DE('Import',cco,'DE',m) -
                         Trade_DE('Export',cco,'DE',m)
;

execute_unload 'output\Trade_DE.gdx', Trade_DE, Trade_DE_gesamt;
$endif

*###############################################################################
*                                   PRINT
*###############################################################################
*-------------------------------------------------------------------------------

*Überträgt Trade_Gesamt und LNG_Trade in Tool-Datei
$ifThen %print% == 1

execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%analysis_2015.gdx  O=%Ordner_Source%\analysis\Trade_all.xlsm par=Gesamt_trade  rng=Input_Transfer!b2 rdim=2 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%analysis_2015.gdx  O=%Ordner_Source%\analysis\Trade_all.xlsm par=Gesamt_LNG    rng=Input_LNG!b2 rdim=2 cdim=0';
$endif
*-------------------------------------------------------------------------------

*Überträgt Preise
$ifThen %print% == 2

Parameter
price(co,t,*);

$ifthen not set RunModel
Equations
ENERGY_BALANCE(co,t)                     energy balance;
$endif

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\results\%data%_results_' i_loop.tl:0;
         execute_load ENERGY_BALANCE;
*option clear = price;
         price(co,t,i_loop) = NO;
         price(co,t,i_loop) =  ENERGY_BALANCE.m(co,t);
*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

execute_unload  '%Ordner_Source%\analysis\%data%preise.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%preise.gdx O=%Ordner_Source%\analysis\prices.xlsm par=price rng=data!b1';

$endif
*-------------------------------------------------------------------------------

$ifThen %print% ==3

Parameter
Gesamt_trade(cco,co)
Trade_DE_overview(cco,co,*);

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\analysis\%data%analysis_' i_loop.tl:0;
         execute_load Gesamt_trade;
         Trade_DE_overview(cco,co,i_loop) = NO;
         Trade_DE_overview('DE_NCG',co,i_loop) =  Gesamt_trade('DE_NCG',co);
         Trade_DE_overview('DE_GP',co,i_loop) =  Gesamt_trade('DE_GP',co);
         Trade_DE_overview(co,'DE_NCG',i_loop) =  Gesamt_trade(co,'DE_NCG');
         Trade_DE_overview(co,'DE_GP',i_loop) =  Gesamt_trade(co,'DE_GP');
*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

execute_unload  '%Ordner_Source%\analysis\%data%_Trade_DE.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%_Trade_DE.gdx O=%Ordner_Source%\analysis\Trade_DE.xlsm par=Trade_DE_overview';
$endif
*-------------------------------------------------------------------------------

$ifThen %print% == 4
Parameter
Gesamt_LNG(cco,co)
LNG_overview(cco,co,*);

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\analysis\%data%analysis_' i_loop.tl:0;
         execute_load Gesamt_LNG;
         LNG_overview(co,cco,i_loop) = NO;
         LNG_overview(co,cco,i_loop) =  Gesamt_LNG(cco,co);
*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

execute_unload  '%Ordner_Source%\analysis\%data%lng_overview.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%lng_overview.gdx O=%Ordner_Source%\analysis\lng_overview.xlsm par=LNG_overview rng=data!b1';

$endif
*-------------------------------------------------------------------------------
*LNG Analysis
$ifThen %print% == 5
$include GaMaMod_Thesis_v%Model_version%\Output_05_LNG-Analysis
$endif

*-------------------------------------------------------------------------------
*Production Report
$ifThen %print% == 6
Variable
p_q_l(co,l,t)

Parameter
Produktion_report(co,i_loop)
Produktion_report_det(co,l,i_loop);

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\analysis\%data%analysis_' i_loop.tl:0;
         execute_load p_q_l;
         Produktion_report(co,i_loop) = NO;
         Produktion_report(co,i_loop) = sum((t,l),p_q_l.l(co,l,t));

         Produktion_report_det(co,l,i_loop) = NO;
         Produktion_report_det(co,l,i_loop) = sum(t,p_q_l.l(co,l,t));
*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

execute_unload  '%Ordner_Source%\analysis\%data%production_report.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%production_report.gdx O=%Ordner_Source%\analysis\production_report.xlsm par=Produktion_report rng=data!c1';
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%production_report.gdx O=%Ordner_Source%\analysis\production_report.xlsm par=Produktion_report_det rng=data!e1';
$endif

*-------------------------------------------------------------------------------
*Storage Analysis
$ifThen %print% == 7
$include GaMaMod_Thesis_v%Model_version%\Output_07_STORAGE-Analysis
$endif
*-------------------------------------------------------------------------------
*Diversification check
$ifThen %print% == k8
Positive Variable
TRADE(co,cco,t,a)


Parameter
ntDIV_report(co,a,i_loop,*)

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\results\results_NationalPolicy_%data%' i_loop.tl:0;
         execute_load TRADE, coEU;
         ntDIV_report(co,a,i_loop,'Factor')=NO;

         ntDIV_report(coEU,a,i_loop,'Factor')=
                 sum(cco,
                 ((
                         sum(t,
                         TRADE.l(cco,coEU,t,a))+1
                                                 )/10**10)
                 +1);


*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

Display ntDIV_report;
$endif

*-------------------------------------------------------------------------------
*EU policy check
$ifThen %print% == 9
$include GaMaMod_Thesis_v%Model_version%\Output_09_Russian-Gas-Supply-Analysis
$endif

*-------------------------------------------------------------------------------
*Infrastructure expansion (pipeline)
$ifThen %print% == 20

Variable COST;
Parameters

cost_report(*,*,*)
evaluation_report(*,*,*)
;

COST.l = 0;

*1.1 No Policy, green gas, RCP
execute_load '%Ordner_Source%\results\RCP_GG_noPol', COST;
%no_policy%$ontext
%greengas%$ontext
%RCP%$ontext
cost_report ('RCP','GG', 'no_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*1.2 No Policy, green gas, WSP
execute_load '%Ordner_Source%\results\WSP_GG_noPol', COST;
%no_policy%$ontext
%greengas%$ontext
%WSp%$ontext
cost_report ('WSP','GG', 'no_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*1.3 No Policy, no green gas, RCP
execute_load '%Ordner_Source%\results\RCP_noGG_noPol', COST;
%no_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
cost_report ('RCP','no_GG', 'no_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*1.4 No Policy, no green gas, WSP
execute_load '%Ordner_Source%\results\WSP_noGG_noPol', COST;
%no_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
cost_report ('WSP','no_GG', 'no_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*1.5 No Policy, green gas, EEV
execute_load '%Ordner_Source%\results\EEV_GG_noPol', COST;
%no_policy%$ontext
%greengas%$ontext
%EEV%$ontext
cost_report ('EEV','GG', 'no_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*1.6 No Policy, no green gas, EEV
execute_load '%Ordner_Source%\results\EEV_noGG_noPol', COST;
%no_policy%$ontext
%no_greengas%$ontext
%EEV%$ontext
cost_report ('EEV','no_GG', 'no_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext




*2.1 National Policy, green gas, RCP
execute_load '%Ordner_Source%\results\RCP_GG_natPol', COST;
%national_policy%$ontext
%greengas%$ontext
%RCP%$ontext
cost_report ('RCP','GG', 'nat_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*2.2 National Policy, green gas, WSP
execute_load '%Ordner_Source%\results\WSP_GG_natPol', COST;
%national_policy%$ontext
%greengas%$ontext
%WSP%$ontext
cost_report ('WSP','GG', 'nat_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*2.3 National Policy, no green gas, RCP
execute_load '%Ordner_Source%\results\RCP_noGG_natPol', COST;
%national_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
cost_report ('RCP','no_GG', 'nat_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*2.4 National Policy, no green gas, WSP
execute_load '%Ordner_Source%\results\WSP_noGG_natPol', COST;
%national_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
cost_report ('WSP','no_GG', 'nat_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*2.5 National Policy, green gas, EEV
execute_load '%Ordner_Source%\results\EEV_GG_natPol', COST;
%national_policy%$ontext
%greengas%$ontext
%EEV%$ontext
cost_report ('EEV','GG', 'nat_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*2.6 National Policy, no green gas, EEV
execute_load '%Ordner_Source%\results\EEV_noGG_natPol', COST;
%national_policy%$ontext
%no_greengas%$ontext
%EEV%$ontext
cost_report ('EEV','no_GG', 'nat_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext




*3.1 EU Policy, green gas, RCP
execute_load '%Ordner_Source%\results\RCP_GG_EUPol', COST;
%EU_policy%$ontext
%greengas%$ontext
%RCP%$ontext
cost_report ('RCP','GG', 'EU_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*3.2 EU Policy, green gas, WSP
execute_load '%Ordner_Source%\results\WSP_GG_EUPol', COST;
%EU_policy%$ontext
%greengas%$ontext
%WSP%$ontext
cost_report ('WSP','GG', 'EU_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*3.3 EU Policy, no green gas, RCP
execute_load '%Ordner_Source%\results\RCP_noGG_EUPol', COST;
%EU_policy%$ontext
%no_greengas%$ontext
%RCP%$ontext
cost_report ('RCP','no_GG', 'EU_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*3.4 EU Policy, no green gas, WSP
execute_load '%Ordner_Source%\results\WSP_noGG_EUPol', COST;
%EU_policy%$ontext
%no_greengas%$ontext
%WSP%$ontext
cost_report ('WSP','no_GG', 'EU_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*3.5 EU Policy, green gas, EEV
execute_load '%Ordner_Source%\results\EEV_GG_euPol', COST;
%eu_policy%$ontext
%greengas%$ontext
%EEV%$ontext
cost_report ('EEV','GG', 'eu_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext

*3.6 National Policy, no green gas, EEV
execute_load '%Ordner_Source%\results\EEV_noGG_euPol', COST;
%eu_policy%$ontext
%no_greengas%$ontext
%EEV%$ontext
cost_report ('EEV','no_GG', 'eu_Pol') = COST.l;
COST.l = 0;
$ontext
$offtext


*Writing results for RCP and WSP
evaluation_report('1.1_RCP', 'GG', 'noPol') = cost_report ('RCP','GG', 'no_Pol');
evaluation_report('1.1_RCP', 'GG', 'natPol') = cost_report ('RCP','GG', 'nat_Pol');
evaluation_report('1.1_RCP', 'GG', 'EUPol') = cost_report ('RCP','GG', 'eu_Pol');
evaluation_report('1.2_WSP', 'GG', 'noPol') = cost_report ('WSP','GG', 'no_Pol');
evaluation_report('1.2_WSP', 'GG', 'natPol') = cost_report ('WSP','GG', 'nat_Pol');
evaluation_report('1.2_WSP', 'GG', 'EUPol') = cost_report ('WSP','GG', 'eu_Pol');
evaluation_report('1.3_EEV', 'GG', 'noPol') = cost_report ('EEV','GG', 'no_Pol');
evaluation_report('1.3_EEV', 'GG', 'natPol') = cost_report ('EEV','GG', 'nat_Pol');
evaluation_report('1.3_EEV', 'GG', 'EUPol') = cost_report ('EEV','GG', 'eu_Pol');

evaluation_report('1.1_RCP', 'no_GG', 'noPol') = cost_report ('RCP','no_GG', 'no_Pol');
evaluation_report('1.1_RCP', 'no_GG', 'natPol') = cost_report ('RCP','no_GG', 'nat_Pol');
evaluation_report('1.1_RCP', 'no_GG', 'EUPol') = cost_report ('RCP','no_GG', 'eu_Pol');
evaluation_report('1.2_WSP', 'no_GG', 'noPol') = cost_report ('WSP','no_GG', 'no_Pol');
evaluation_report('1.2_WSP', 'no_GG', 'natPol') = cost_report ('WSP','no_GG', 'nat_Pol');
evaluation_report('1.2_WSP', 'no_GG', 'EUPol') = cost_report ('WSP','no_GG', 'eu_Pol');
evaluation_report('1.3_EEV', 'no_GG', 'noPol') = cost_report ('EEV','no_GG', 'no_Pol');
evaluation_report('1.3_EEV', 'no_GG', 'natPol') = cost_report ('EEV','no_GG', 'nat_Pol');
evaluation_report('1.3_EEV', 'no_GG', 'EUPol') = cost_report ('EEV','no_GG', 'eu_Pol');


*EVPI berechnen
evaluation_report('EVPI', 'no_GG', 'noPol') =
         cost_report ('RCP','no_GG', 'no_Pol')
         -   cost_report ('WSP','no_GG', 'no_Pol')
;

evaluation_report('EVPI', 'no_GG', 'natPol') =
         cost_report ('RCP','no_GG', 'nat_Pol')
         -   cost_report ('WSP','no_GG', 'nat_Pol')
;

evaluation_report('EVPI', 'no_GG', 'EUPol') =
         cost_report ('RCP','no_GG', 'EU_Pol')
         -   cost_report ('WSP','no_GG', 'EU_Pol')
;

evaluation_report('EVPI', 'GG', 'noPol') =
         cost_report ('RCP','GG', 'no_Pol')
         -   cost_report ('WSP','GG', 'no_Pol')
;

evaluation_report('EVPI', 'GG', 'natPol') =
         cost_report ('RCP','GG', 'natPol')
         -   cost_report ('WSP','GG', 'nat_Pol')
;

evaluation_report('EVPI', 'GG', 'EUPol') =
         cost_report ('RCP','GG', 'EU_Pol')
         -   cost_report ('WSP','GG', 'EU_Pol')
;

*VSS berechnen
evaluation_report('VSS', 'no_GG', 'noPol') =
         cost_report ('EEV','no_GG', 'no_Pol')
         -   cost_report ('RCP','no_GG', 'no_Pol')
;
evaluation_report('VSS', 'no_GG', 'natPol') =
         cost_report ('EEV','no_GG', 'nat_Pol')
         -   cost_report ('RCP','no_GG', 'nat_Pol')
;
evaluation_report('VSS', 'no_GG', 'EUPol') =
         cost_report ('EEV','no_GG', 'EU_Pol')
         -   cost_report ('RCP','no_GG', 'EU_Pol')
;
evaluation_report('VSS', 'GG', 'noPol') =
         cost_report ('EEV','GG', 'no_Pol')
         -   cost_report ('RCP','GG', 'no_Pol')
;
evaluation_report('VSS', 'GG', 'natPol') =
         cost_report ('EEV','GG', 'nat_Pol')
         -   cost_report ('RCP','GG', 'nat_Pol')
;
evaluation_report('VSS', 'GG', 'EUPol') =
         cost_report ('EEV','GG', 'EU_Pol')
         -   cost_report ('RCP','GG', 'EU_Pol')
;


execute_unload  '%Ordner_Source%\analysis\COST_report.gdx'

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\COST_report.gdx O=%Ordner_Source%\analysis\cost_report.xlsm par=evaluation_report rng=GAMS_outputNoGG!A1';
$ontext
$offtext

%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\COST_report.gdx O=%Ordner_Source%\analysis\cost_report.xlsm par=evaluation_report rng=GAMS_outputGG!A1';
$ontext
$offtext




Display cost_report, evaluation_report

$endif

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------INVESTMENT--------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Investment Variable Pipelines
$ifThen %print% == 10
$include GaMaMod_Thesis_v%Model_version%\Output_10_cost_investment+dispatch
$endif


*Investment Variable Pipelines
$ifThen %print% == 11
$include GaMaMod_Thesis_v%Model_version%\Output_11_investment_pipelines
$endif

*Investment Variable Pipelines in WSP
$ifThen %print% == 31
$include GaMaMod_Thesis_v%Model_version%\Output_31_Investment_WSP_noGG
$endif

*Investment Variable LNG and Storage
$ifThen %print% == 12
$include GaMaMod_Thesis_v%Model_version%\Output_12_investment_LNG
$endif

*Investment LNG and STO in WSP
$ifThen %print% == 32
$include GaMaMod_Thesis_v%Model_version%\Output_32_investment_WSP_noGG_LNG
$endif

*VSS + EVPI
$ifThen %print% == 13
$include GaMaMod_Thesis_v%Model_version%\Output_13_VSS_EVPI
$endif

*VSS + EVPI
$ifThen %print% == 14
$include GaMaMod_Thesis_v%Model_version%\Output_14_Trade
$endif




*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------Green Gas  -------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Investment Variable GG facility based on CO2 price
$ifThen %print% == 30
$include GaMaMod_Thesis_v%Model_version%\Output_30_Investment_GG
$endif


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------Shock ---- -------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Shock Analysis
$ifThen %print% == 33
$include GaMaMod_Thesis_v%Model_version%\Output_33_Analysis_shock
$endif