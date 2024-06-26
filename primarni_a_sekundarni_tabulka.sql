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