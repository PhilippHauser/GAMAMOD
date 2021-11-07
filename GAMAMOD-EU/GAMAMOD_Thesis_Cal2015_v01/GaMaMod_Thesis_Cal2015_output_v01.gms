*###############################################################################
*                              GaMaMod output file
*###############################################################################
*
* Last change: 10.02.2015
* By: PH

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

$ifThen %print% == 5
Parameter
LNG_process(cco,co,t,*);

Variable
LNG(co,cco,t);

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\analysis\%data%analysis_' i_loop.tl:0;
         execute_load LNG;
         LNG_process(co,cco,t,i_loop) = NO;
         LNG_process(co,cco,t,i_loop) = LNG.l(co,cco,t);
*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

execute_unload  '%Ordner_Source%\analysis\%data%lng_process.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%lng_process.gdx O=%Ordner_Source%\analysis\lng_process.xlsm par=LNG_process rng=data!c1';

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
*Storage report
$ifThen %print% == 7
Positive Variable
storage_in(co,s,t)
storage_out(co,s,t)
storage_level(co,s,t)


Parameter
storage_report(co,t,s,i_loop,*)
storage_level_report(co,t,s,i_loop)

loop(i_loop,
$onUNDF
         put_utility  intern 'gdxin' / '%Ordner_Source%\analysis\%data%analysis_' i_loop.tl:0;
         execute_load storage_out storage_in;
         storage_report(co,t,s,i_loop,"in")=NO;
         storage_report(co,t,s,i_loop,"out")=NO;
         storage_report(co,t,s,i_loop,"in")=storage_in.l(co,s,t);
         storage_report(co,t,s,i_loop,"out")=storage_out.l(co,s,t);

         storage_level_report(co,t,s,i_loop)=storage_level.l(co,s,t);


*         execute 'gdxxrw.exe %Ordner_Source%\results\%data%_results_' i_loop.tl:0; 'O=%Ordner_Source%\analysis\prices.xlsm equ=ENERGY_Balance.m rng=%data%';
$offUNDF
);

execute_unload  '%Ordner_Source%\analysis\%data%storage_report.gdx'
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%storage_report.gdx O=%Ordner_Source%\analysis\storage_report.xlsm par=storage_report rng=data!e1 rdim=2 cdim=3';
execute 'gdxxrw.exe %Ordner_Source%\analysis\%data%storage_report.gdx O=%Ordner_Source%\analysis\storage_report.xlsm par=storage_level_report rng=data_sl!e1 rdim=2 cdim=2';

$endif


