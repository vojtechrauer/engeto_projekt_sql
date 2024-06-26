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
	round(p06.value / (SELECT value
						FROM t_vojtech_rauer__project_SQL_primary_final AS pt
						WHERE name = 'Mléko polotučné pasterované'
						AND `year` = 2006)) AS l_milk_2006,
	round(p06.value / (SELECT value
						FROM t_vojtech_rauer__project_SQL_primary_final AS pt
						WHERE name = 'Chléb konzumní kmínový'
						AND `year` = 2006)) AS kg_bread_2018,
	round(p18.value / (SELECT value
						FROM t_vojtech_rauer__project_SQL_primary_final AS pt
						WHERE name = 'Mléko polotučné pasterované'
						AND `year` = 2018)) AS l_milk_2006,
	round(p18.value / (SELECT value
						FROM t_vojtech_rauer__project_SQL_primary_final AS pt
						WHERE name = 'Chléb konzumní kmínový'
						AND `year` = 2018)) AS kg_bread_2018
FROM payroll_2006 AS p06
INNER JOIN payroll_2018 AS p18
ON p06.name = p18.name;

/* ODPOVĚĎ: viz výsledná tabulka. Konkrétní množství litrů mléka a kilogramů chleba,
 * které si lze koupit za průměrný plat v daném odvětví, se odvíjí od průměrného platu
 * pro daný rok v daném odvětví. Na horních příčkách se tak umisťuje např. peněžnictví
 * a pojišťovnictví - v roce 2006 si za průměrný plat v tomto odvětví bylo možné pořídit
 * 2 772 litrů mléka a 2 483 kilogramů chleba. Hodnoty pro rok 2018 mají jen zanedbatelný rozdíl
 * oproti roku 2006 (2 769 litrů mléka a 2 264 kilogramů chleba). Ve spodních příčkách nalezneme
 * ubytování, stravování a pohostinství (809 litrů mléka a 724 kilogramů chleba pro rok 2006,
 * 972 litrů mléka a 795 kilogramů chleba pro rok 2018) */
