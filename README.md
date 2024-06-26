# ANALÝZA DAT mezd a cen v ČR

Projekt zpracovává odpovědi na vytyčené výzkumné otázky týkající se mezd a cen v České republice. Použity jsou datové materiály z volně dostupných zdrojů národního katalogu otevřených dat (NKOD). Jeho cílem je poskytnout přehledně informace o vývoji mezd, ať už samostatně, nebo ve vztahu ke zdražování (resp. zlevňování) potravin na českém trhu. Práce probíhala v prostředí softwaru DBeaver v databázovém systému MariaDB. Výstupem práce jsou dvě nově vytvořené tabulky a sada SQL dotazů, které uspořádávají dostupná data tak, aby odpovídaly na vytyčené otázky. Dostupný je jak soubor s kompletním kódem pro tvorbu tabulek i SELECTů jednotlivých otázek (kompletni_projekt_sql.sql), tak soubor obsahující pouze kód pro tvorbu tabulek (primarni_a_sekundarni_tabulka.sql) a soubory přehledně rozdělené podle výzkumných otázek, na které odpovídají. Kód je opatřen poznámkami, které komentují mezikroky operace, např. popisují dílčí SELECTy, aby byla zřetelná cesta k výsledku, popisují číselníkové kódy, apod. 

**Primární tabulka** obsahuje data o průměrných cenách produktů a průměrných mzdách v odvětví v ČR. Data jsou sjednocena na roky, aby umožňovala porovnání. Data o mzdách jsou v tabulce NKOD uvedena za kvartály, primární tabulka projektu proto svoji výslednou hodnotu pro rok a odvětví počítá jako průměr hodnot za kvartály v tabulce NKOD. Data o cenách jsou v tabulce NKOD rozčleněna podle krajů a obsahují hodnoty měřené v každém měsíci daného roku. Pro účely našeho projektu jsou hodnoty v primární tabulce vypočteny jako průměr cen produktů za všechny měsíce ve všech krajích.

**Sekundářní tabulka** obsahuje data o výši HDP, GINI koeficientu a populaci České republiky a dalších zemí světa. Byla rovněž utvořena z tabulky dostupné v NKOD očištěním nepotřebných hodnot, které jou pro účely našeho projektu irrelevantní. 

## Výzkumné otázky a odpovědi:
 
 **1. OTÁZKA: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
 ODPOVĚĎ: V některých odvětvích mzdy klesají, nejvýraznější pokles zaznamenalo peněžnictví a pojišťovnictví v roce 2013, činnosti v oblasti nemovitostí v roce 2020 a ubytování, stravování a pohostinství v roce 2020.
   

 **2. OTÁZKA: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
 ODPOVĚĎ: Konkrétní množství litrů mléka a kilogramů chleba, které si lze koupit za průměrný plat v daném odvětví, se odvíjí od průměrného platu pro daný rok v daném odvětví. Na horních příčkách se tak umisťuje např. peněžnictví a pojišťovnictví - v roce 2006 si za průměrný plat v tomto odvětví bylo možné pořídit 2 772 litrů mléka a 2 483 kilogramů chleba. Hodnoty pro rok 2018 mají jen zanedbatelný rozdíl oproti roku 2006 (2 769 litrů mléka a 2 264 kilogramů chleba). Ve spodních příčkách nalezneme ubytování, stravování a pohostinství (809 litrů mléka a 724 kilogramů chleba pro rok 2006, 972 litrů mléka a 795 kilogramů chleba pro rok 2018).
    
 **3. OTÁZKA: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**
 ODPOVĚĎ: Nejpomaleji zdražují (resp. dokonce zlevňujÍ) cukr a rajčata.
    
 **4. OTÁZKA: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
 ODPOVĚĎ: V žádném roce nebyl nárůst cen výrazně vyšší než průměrné zdražení všech produktů v daném roce. Nejvyšší rozdíl mezi růstem cen a mezd byl v roce 2013, kde ceny potravin průměrně vzrostly o 6,7 % oproti průměrnému růstu mezd.
    
 **5. OTÁZKA: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?**
 ODPOVĚĎ: Vyšší nárůst HDP odkazuje k vyšším hodnotám procentuálního růstu mezd a cen (nejvyšší růst HDP v letech 2006 a 2007 se projevil výraznějším růstem mezd a cen v letech 2006, 2007 a 2008), ale neplatí striktně přímá úměra (třetí nejvýraznější růst HDP v roce 2015 doprovázejí nízké hodnoty růstu cen a mezd).

Otázky a odpovědi jsou rovněž uvedeny v závěru každého SQL dotazu, spolu se stručným popisem tabulky, ze které lze odpovědi vyčíst.
