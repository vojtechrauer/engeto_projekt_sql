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

/* ODPOVĚĎ: Nejpomaleji zdražuje (resp. dokonce zlevňuje) cukr.

   Výsledný select zobrazuje produkty seřazené podle průměrného
   nárůstu ceny oproti předcházejícímu roku, seřazené vzestupně
   od nejmenšího nárůstu.
   Dvě horní hodnoty (cukr a rajčata) průměrně meziročně zlevňují. */
