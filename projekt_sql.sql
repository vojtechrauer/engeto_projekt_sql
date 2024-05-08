-- průměrná cena za produkty (pro celou republiku) sjednocená na roky + průměrný plat v daných odvětvích sjednocený na roky
CREATE OR REPLACE TABLE primary_table AS (
SELECT avg(cp.value) AS value, cpc.name , year(cp.date_to) AS `year`, 'Cena produktu v Kč' AS value_type, 'Produkt' AS name_type
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
GROUP BY cpib.name, cp.payroll_year );


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

-- 
SELECT min(`year`), max(`year`)
FROM primary_table AS pt
WHERE name_type = 'Produkt';

SELECT min(`year`), max(`year`)
FROM primary_table AS pt
WHERE name_type = 'Odvětví'

