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

/* ODPOVĚĎ: Vyšší nárůst HDP odkazuje k vyšším hodnotám procentuálního růstu mezd a cen
 * (nejvyšší růst HDP v letech 2006 a 2007 se projevil výraznějším růstem mezd a cen v letech 2006, 2007 a 2008),
 * ale neplatí striktně přímá úměra (třetí nejvýraznější růst HDP v roce 2015 doprovázejí nízké hodnoty růstu cen a mezd). */
