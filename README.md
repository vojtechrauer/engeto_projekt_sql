# ANALÝZA DAT mezd a cen v ČR
 Projekt zpracovává odpovědi na následující vytyčené výzkumné otázky:
 
 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Z dostupných dat projekt zpracovává vlastní tabulky s informacemi o průměrných mzdách v daných pracovních odvětvích v ČR a informace o průměrných cenách produktů. Tato data jsou sjednocená na společné roky. Práce probíhala v prostředí softwaru DBeaver v databázovém systému MariaDB. Výstupem práce jsou dvě nově vytvořené tabulky a sada SQL dotazů, které uspořádávají dostupná data tak, aby odpovídaly na vytyčené otázky. Soubor obsahující SQL kód je opatřen poznámkami, které komentují mezikroky operace, např. popisují dílčí SELECTy, aby byla zřetelná cesta k výsledku, popisují číselníkové kódy, apod. 

Výsledky, které vyplývají ze SQL kódu, jsou stručně popsány v závěru každé otázky. 
