*###########################################################################
*                GAMAMOD-EU.sto SOLVE STATEMENTS (Green Gas Sensitivity)
*###########################################################################
* Last change: 07.12.2020
* By: Philipp Hauser
*###########################################################################
%NAandEU%$ontext
SET
cp carb price /25,35,60,80,100,150,200,300,450,600/;
Parameter
cp_value(cp) carb price value
/
25       25
35       35
60       60
80       80
100      100
150      150
200      200
300      300
450      450
600      600
/;
put text;
loop(cp,
         CarbPrice=0;
         CarbPrice=cp_value(cp)*224/0.6;
         GAMAMOD_EU_RCP_noPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_noPol minimizing COST using lp;
         putclose
         put_utility text 'gdxout' / '%Ordner_Source%\results\RCP_GG_natPol_all_'cp.tl:0 '_EUR-CO2';
         execute_unload;
);
$ontext
$offtext

%onlyNA%$ontext
SET
cp carb price /50,60,80,100,150,200,300,450,600/;
Parameter
cp_value(cp) carb price value
/
50       50
60       60
80       80
100      100
150      150
200      200
300      300
450      450
600      600
/;
put text;
loop(cp,
         CarbPrice=0;
         CarbPrice=cp_value(cp)*224/0,6;
         GAMAMOD_EU_RCP_noPol.optfile = 1;
         Solve GAMAMOD_EU_RCP_noPol minimizing COST using lp;
         putclose
         put_utility text 'gdxout' \ '%Ordner_Source%\results\RCP_GG_natPol_NA_'cp.tl:0 '_EUR-CO2';
         execute_unload;
);
$ontext
$offtext
