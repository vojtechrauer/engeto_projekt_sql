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

/* ODPOVĚĎ: V žádném roce nebyl nárůst cen výrazně vyšší než průměrné zdražení všech produktů v daném roce.
   Nejvyšší rozdíl mezi růstem cen a mezd byl v roce 2013, kde ceny potravin průměrně vzrostly o 6,7 % oproti průměrnému růstu mezd.
   
   Tabulka zobrazuje rozdíl percentuálního meziročního nárůstu cen potravin oproti percentuálnímu meziročnímu nárůstu mezd. */
