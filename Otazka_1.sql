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

/* ODPOVĚĎ: V některých odvětvích mzdy klesají,
   nejvýraznější pokles zaznamenalo peněžnictví a pojišťovnictví v roce 2013,
   činnosti v oblasti nemovitostí v roce 2020 a ubytování, stravování a pohostintví v roce 2020.
   
   Výsledný select podává informace o odvětví a roku,
   ve kterém mzda poklesla oproti předcházejícímu roku, a o kolik procent.
   Hodnoty jsou seřazeny sestupně od největšího poklesu.*/
