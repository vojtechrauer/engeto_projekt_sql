
-- discord jméno: vojtechrauer_90731
-- PRIMÁRNÍ TABULKA
-- průměrná cena za produkty (pro celou republiku) sjednocená na roky + průměrný plat v daných odvětvích sjednocený na roky
CREATE OR REPLACE TABLE
	t_vojtech_rauer__project_SQL_primary_final AS
		(SELECT avg(cp.value) AS value, cpc.name , year(cp.date_to) AS `year`, 'Cena produktu v Kč' AS value_type, 'Produkt' AS name_type
		FROM czechia_price AS cp
		INNER JOIN czechia_price_category AS cpc
		ON cpc.code = cp.category_code 
		WHERE region_code IS NULL
		GROUP BY category_code, YEAR(date_to)
		UNION ALL
		SELECT avg(cp.value) AS value, cpib.name, cp.payroll_year AS `year`, 'Prům. hrubá mzda v Kč' AS value_type, 'Odvětví' AS name_type
		FROM czechia_payroll AS cp
		INNER JOIN czechia_payroll_industry_branch AS cpib
		ON cp.industry_branch_code = cpib.code -- zmizí NULL hodnoty, které nesou údaje o průměru (ten jde vypočítat i z výsledné tabulky -> nepřichází se o data)
		WHERE
			cp.value_type_code = 5958 -- kód pro průměrnou mzdu
		AND cp.calculation_code = 200 -- kód pro přepočtený průměr (přesnější, protože kalkuluje s částečnými úvazky)
		GROUP BY cpib.name, cp.payroll_year);

-- SEKUNDÁRNÍ TABULKA
-- HDP, GINI koeficient a populace pro státy ve vybraných letech
CREATE OR REPLACE TABLE
	t_vojtech_rauer_project_SQL_secondary_final AS (
		SELECT country, `year`, GDP, gini, population 
		FROM economies AS e
		WHERE `year` BETWEEN 2000 AND 2021);

-- VÝZKUMNÉ OTÁZKY
	
-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- pohled znázorňující procentuální nárůst průměrné mzdy v daném odvětví oproti předcházejícímu roku
WITH perc_increase AS (
SELECT
	name,
	`year`,
	ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name_type = 'Odvětví')
-- 
-- Výběr odvětví a let, u kterých oproti předcházejícím roku procentuálně poklesla průměrná mzda a procento poklesu
SELECT 
	*
FROM perc_increase
WHERE perc_increase < 0
ORDER BY perc_increase;

-- ODPOVĚĎ: V některých mzdy klesají. Výsledný select podává informace o odvětví a roku, ve kterém mzda poklesla oproti předcházejícímu roku, a o kolik procent. Hodnoty jsou seřazeny sestupně od největšího poklesu.


-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- časový rozptyl měřených dat -> od roku 2006, do roku 2018 pro ceny produktů
SELECT min(`year`), max(`year`)
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name_type = 'Produkt';

-- 2000 až 2021 pro mzdy
SELECT min(`year`), max(`year`)
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name_type = 'Odvětví';

-- první porovnatelné období je rok 2006, poslední rok 2018
-- deklarování proměnných pro ceny mléka a chleba v daných letech
SET @2006_bread = (SELECT value
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name = 'Chléb konzumní kmínový'
AND `year` = 2006);

SET @2018_bread = (SELECT value
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name = 'Chléb konzumní kmínový'
AND `year` = 2018);

SET @2006_milk = (SELECT value
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name = 'Mléko polotučné pasterované'
AND `year` = 2006);

SET @2018_milk = (SELECT value
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name = 'Mléko polotučné pasterované'
AND `year` = 2018);

-- průměrná mzda v daném odvětví a roce vydělená průměrnými cenami produktů v tomto roce
WITH payroll_2006 AS (SELECT value, name 
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name_type = 'Odvětví'
AND `year` = 2006),
	payroll_2018 AS (SELECT value, name 
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name_type = 'Odvětví'
AND `year` = 2018)
SELECT p06.name,
	round(p06.value / @2006_milk) AS l_milk_2006,
	round(p06.value / @2006_bread) AS kg_bread_2018,
	round(p18.value / @2018_milk) AS l_milk_2006,
	round(p18.value / @2018_bread) AS kg_bread_2018
FROM payroll_2006 AS p06
INNER JOIN payroll_2018 AS p18
ON p06.name = p18.name;
-- ODPOVĚĎ: viz výsledná tabulka

-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- pohled průměrného procentuálního nárůstu ceny produktů oproti předcházejícímu roku
WITH perc_increase_price AS (
SELECT
	name,
	`year`,
	ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase
FROM t_vojtech_rauer__project_SQL_primary_final AS pt
WHERE name_type = 'Produkt')
-- průměrná hodnota procentuálního narůstu ceny produktů, seřazená od nejmenší k největší
SELECT 
	name, round(avg(perc_increase), 2) AS avg_perc_increase
FROM perc_increase_price
GROUP BY name
ORDER BY avg_perc_increase;
-- ODPOVĚĎ: výsledný select zobrazuje produkty seřazené podle průměrného nárůstu ceny oproti předcházejícímu roku, seřazené vzestupně od nejmenšího nárůstu. Dvě horní hodnoty (cukr a rajčata), dokonce průměrně meziročně zlevňují



-- 4.) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH
	increase_price AS -- procentuální nárůst cen produktů oproti předchozímu roku
		(SELECT
		name,
		`year`,
		ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase_price
		FROM t_vojtech_rauer__project_SQL_primary_final AS pt
		WHERE name_type = 'Produkt'),
	increase_wage AS -- procentuální nárůst mzdy v daném odvětví oproti předchozímu roku
		(SELECT
		name,
		`year`,
		ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase_wage
		FROM t_vojtech_rauer__project_SQL_primary_final AS pt
		WHERE name_type = 'Odvětví')
SELECT avg(perc_increase_price) - avg(perc_increase_wage) AS diff_perc_inc, ip.`year` -- rozdíl průměrného narůstu cen produktů v daném roce a průměrného nárůstu mezd všech odvětví
FROM increase_price AS ip
INNER JOIN increase_wage AS iw
ON ip.`year` = iw.`year`
WHERE ip.`year` BETWEEN 2007 AND 2018
GROUP BY ip.`year`
ORDER BY diff_perc_inc DESC;
-- ODPOVĚĎ: V žádném roce nebyl nárůst cen výrazně vyšší než průměrné zdražení všech produktů v daném roce. Nejvyšší rozdíl mezi růstem cen a mezd byl v rice 2013, kde ceny potravin průměrně vzrostly o 6,7 % oproti průměrnému růstu mezd

-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

WITH 	
		hdp_inc AS
		(SELECT
		country,
		`year`,
		round((gdp - lag(gdp) OVER (ORDER BY `year`)) / (lag(gdp) OVER (ORDER BY `year`)/100), 2) AS perc_inc_gdp
FROM t_vojtech_rauer_project_SQL_secondary_final
WHERE country = 'Czech republic'),
		price_inc AS -- procentuální nárůst cen produktů oproti předchozímu roku
		(SELECT
		name,
		`year`,
		ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase_price
		FROM t_vojtech_rauer__project_SQL_primary_final AS pt
		WHERE name_type = 'Produkt'),
		wage_inc AS -- procentuální nárůst mzdy v daném odvětví oproti předchozímu roku
		(SELECT
		name,
		`year`,
		ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase_wage
		FROM t_vojtech_rauer__project_SQL_primary_final AS pt
		WHERE name_type = 'Odvětví')
SELECT
	hi.`year`,
	round(avg(perc_increase_wage), 2) AS wage,
	round(avg(perc_increase_price), 2) AS price,
	round(avg(perc_inc_gdp), 2) AS gdp
FROM hdp_inc AS hi
INNER JOIN wage_inc AS wi
ON hi.`year` = wi.`year`
INNER JOIN price_inc AS pi
ON wi.`year` = pi.`year`
GROUP BY hi.`year`
ORDER BY gdp DESC;

-- ODPOVĚĎ: Vyšší nárůst HDP odkazuje k vyšším hodnotám procentuálního růstu mezd a cen (nejvyšší růst HDP v letech 2006 a 2007 se projevily výraznějším růstem mezd a cen v letech 2006, 2007 a 2008), ale neplatí striktně přímá úměra (třetí nejvýraznější růst HDP v roce 2015 doprovázejí nízké hodnoty růstu cen a mezd)
