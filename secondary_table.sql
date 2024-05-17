CREATE TABLE t_vojtech_rauer_project_SQL_secondary_final AS (
SELECT country, `year`, GDP, gini, population 
FROM economies AS e
WHERE `year` BETWEEN 2000 AND 2021);