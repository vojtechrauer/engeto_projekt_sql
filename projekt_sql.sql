-- průměrná cena za produkty (pro celou republiku) sjednocená na roky + průměrný plat v daných odvětvích sjednocený na roky
CREATE OR REPLACE TABLE primary_table AS
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


-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- pohled znázorňující procentuální nárůst průměrné mzdy v daném odvětví oproti předcházejícímu roku
WITH perc_increase AS (
SELECT
	name,
	`year`,
	ROUND((value - LAG(value) OVER (PARTITION BY name ORDER BY year)) / ((LAG(value) OVER (PARTITION BY name ORDER BY year)) / 100), 2) AS perc_increase
FROM primary_table AS pt
WHERE name_type = 'Odvětví')
-- Výběr odvětví a let, u kterých oproti předcházejícím roku procentuálně poklesla průměrná mzda a procento poklesu
SELECT 
	*
FROM perc_increase
WHERE perc_increase < 0
ORDER BY perc_increase;

-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- časový rozptyl měřených dat -> od roku 2006, do roku 2018 pro ceny produktů
SELECT min(`year`), max(`year`)
FROM primary_table AS pt
WHERE name_type = 'Produkt';

-- 2000 až 2021 pro mzdy
SELECT min(`year`), max(`year`)
FROM primary_table AS pt
WHERE name_type = 'Odvětví';

-- první porovnatelné období je rok 2006, poslední rok 2018

SET @2006_bread = (SELECT value
FROM primary_table AS pt
WHERE name = 'Chléb konzumní kmínový'
AND `year` = 2006);

SET @2018_bread = (SELECT value
FROM primary_table AS pt
WHERE name = 'Chléb konzumní kmínový'
AND `year` = 2018);

SET @2006_milk = (SELECT value
FROM primary_table AS pt
WHERE name = 'Mléko polotučné pasterované'
AND `year` = 2006);

SET @2018_milk = (SELECT value
FROM primary_table AS pt
WHERE name = 'Mléko polotučné pasterované'
AND `year` = 2018);

-- průměrná mzda v daném odvětví a roce vydělená průměrnými cenami produktů v tomto roce
WITH payroll_2006 AS (SELECT value, name 
FROM primary_table AS pt
WHERE name_type = 'Odvětví'
AND `year` = 2006),
	payroll_2018 AS (SELECT value, name 
FROM primary_table AS pt
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
