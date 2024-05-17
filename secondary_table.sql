CREATE TABLE t_vojtech_rauer_project_SQL_secondary_final AS (
SELECT country, `year`, GDP, gini, population 
FROM economies AS e
WHERE `year` BETWEEN 2000 AND 2021);

SELECT
		country,
		`year`,
		round((gdp - lag(gdp) OVER (ORDER BY `year`)) / (lag(gdp) OVER (ORDER BY `year`)/100), 2) AS perc_inc_gdp,
		gini
FROM t_vojtech_rauer_project_SQL_secondary_final
WHERE country = 'Czech republic';

