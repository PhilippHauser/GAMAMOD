*Check EU Diversification Policy - share of Russian gas to the EU-28
*-------------------------------------------------------------------

*Set model_type
*--------------------------------------------------------
Set
%RCP%$ontext
$ifthen %WSP%%EEV% == "" model_type /RCP/
$endif
$ontext
$offtext

*Set pol_scenario
*--------------------------------------------------------
%no_policy%$ontext
$ifthen %national_policy%%eu_policy% == ""
         pol_scenario /noPol/
$endif
$ontext
$offtext

%no_policy%$ontext
%national_policy%$ontext
%eu_policy%$ontext
         pol_scenario /noPol, natPol, euPol/


*Set green gas policy
*-------------------------------------------------------------
%greengas%$ontext
$ifthen %no_greengas% == "" green_gas_option /GG/
$endif
$ontext
$offtext

%no_greengas%$ontext
$ifthen %greengas% == "" green_gas_option /noGG/
$endif
$ontext
$offtext
;

Positive Variable
TRADE(co,cco,t,a,j)
;
Parameter
importRU(co,a,j)
importRU_det(co,cco,a,j)
report_K(*,*,*,a,*,j)
report_K2(*,*,*,a,*,*,j)
;
file fx2;
put fx2;
loop((model_type,
     green_gas_option,
     pol_scenario),
$onUNDF
         put_utility'gdxin' / '%Ordner_Source%\results\' model_type.tl:0 '_' green_gas_option.tl:0 '_' pol_scenario.tl:0;
         execute_load TRADE, coEU, coEURU, coSouRU, dem;
         importRU(co,a,j)=NO;
         importRU_det(co,cco,a,j)=NO;
         importRU(coSouRU,a,j) = sum((t,coEU),TRADE.l(coSouRU,coEU,t,a,j));
         importRU_det(coSouRU,coEU,a,j) = sum(t,TRADE.l(coSouRU,coEU,t,a,j));

         report_K(model_type,green_gas_option,pol_scenario,a,'import_RU',j) =
                 sum(coSouRU, importRU(coSouRU,a,j));

         report_K(model_type,green_gas_option,pol_scenario,a,'dem',j) =
                 sum((t, coEU),
                         dem(a,t,coEU,j));

         report_K(model_type,green_gas_option,pol_scenario,a, 'share',j) =
                 report_K(model_type,green_gas_option,pol_scenario,a,'import_RU',j) /
                 report_K(model_type,green_gas_option,pol_scenario,a,'dem',j);

         report_K2(model_type,green_gas_option,pol_scenario,a,coSouRu,coEU,j)=
                  importRU_det(coSouRU,coEU,a,j);

$offUNDF
);

execute_unload '%Ordner_Source%\analysis\Russian_Supply.gdx' ;

%no_greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Russian_Supply.gdx O=%Ordner_Source%\analysis\Russia_supply.xlsm par=report_K rng=GAMS_outputNoGG!B2 rdim=6 cdim=0';
execute 'gdxxrw.exe %Ordner_Source%\analysis\Russian_Supply.gdx O=%Ordner_Source%\analysis\Russia_supply.xlsm par=report_K2 rng=GAMS_outputNoGG!L2 rdim=7 cdim=0';
$ontext
$offtext

%greengas%$ontext
execute 'gdxxrw.exe %Ordner_Source%\analysis\Russian_Supply.gdx O=%Ordner_Source%\analysis\Russia_supply.xlsm par=report_K rng=GAMS_outputGG!B2 rdim=6 cdim=0';
$ontext
$offtext

*Display report_K, importRU, coEURU, coSouRU, TRADE.l
;