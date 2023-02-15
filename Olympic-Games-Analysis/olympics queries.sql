--Create the tables
DROP TABLE IF EXISTS public.olympics_games;

CREATE TABLE IF NOT EXISTS public.olympics_games
(
    id integer NOT NULL,
	name character varying,
	sex character varying,
    age character varying,
	height character varying,
	weight character varying,
	team character varying,
	"NOC" character varying,
    games character varying,
    year integer,
	season character varying,
	city character varying,
	sport character varying,
	event character varying,
    medal character varying,
);

ALTER TABLE public.olympics_games
    OWNER to postgres;
	
	
DROP TABLE IF EXISTS public.regions;
CREATE TABLE IF NOT EXISTS public.regions
(
	noc character varying,
    region character varying,
	notes character varying
);

ALTER TABLE public.regions
    OWNER to postgres;

--Select all to check the data after import from csv
SELECT id, name, sex, age, height, weight, team, "NOC", games, year, season, city, sport, event, medal
	FROM olympics_games;

SELECT noc, region, notes
	FROM regions;

--1. How many olympics games have been held?
SELECT COUNT(DISTINCT games) as total_games 
	FROM olympics_games;

--2. List down all Olympics games held so far.
SELECT DISTINCT year, season, city 
	FROM olympics_games
	ORDER BY year;

--3. Mention the total number of nations who participated in each olympics game.
with all_nations as
	(SELECT games, rg.region
	FROM olympics_games og
	JOIN regions rg ON rg.noc = og."NOC"
	GROUP BY games, rg.region)
SELECT games, COUNT(1) as total_nations
	FROM all_nations
	GROUP BY games
	ORDER BY games;  

--4. Which year saw the highest and lowest no of countries participating in olympics
with all_nations as
	(SELECT games, rg.region
	FROM olympics_games og
	JOIN regions rg ON rg.noc = og."NOC"
	GROUP BY games, rg.region),
	total_nations as (SELECT games, COUNT(1) as count_nations
	FROM all_nations
	GROUP BY games
	ORDER BY games)
SELECT games, count_nations as number_of_nations
FROM total_nations
WHERE count_nations = (SELECT MIN(count_nations) FROM total_nations) OR count_nations = (SELECT MAX(count_nations) FROM total_nations)
GROUP BY games, count_nations;

--5. Which nation has participated in all of the olympic games
with all_nations as
	(SELECT games, rg.region as country
	FROM olympics_games og
	JOIN regions rg ON rg.noc = og."NOC"
	GROUP BY games, rg.region)
SELECT country, COUNT(DISTINCT games) as total_games
	FROM all_nations
	GROUP BY country
	ORDER BY total_games DESC
	LIMIT 4;

--6. Identify the sport which was played in all summer olympics.
with t1 as (SELECT COUNT(DISTINCT games) as total_summer_games
		  FROM olympics_games
		  WHERE season = 'Summer'),
t2 as (SELECT DISTINCT sport, games
	  FROM olympics_games
	  WHERE season = 'Summer'),
t3 as (SELECT sport, count(games) as total_games_played
	  FROM t2
	  GROUP BY sport)
	
SELECT *
	FROM t3
	JOIN t1 ON t1.total_summer_games = t3.total_games_played;

--7. Which Sports were just played only once in the olympics.
with t1 as (SELECT sport, games
	FROM olympics_games
	GROUP BY sport, games),
t2 as (SELECT sport, COUNT(games) as times_played 
	FROM t1
	GROUP BY sport)
SELECT t1.sport, t1.games, t2.times_played FROM t1 
	JOIN t2 ON t2.sport = t1.sport
	WHERE times_played = 1;

--8. Fetch the total no of sports played in each olympic games.
SELECT games, COUNT(DISTINCT sport) as no_sports
	FROM olympics_games
	GROUP BY games
	ORDER BY no_sports DESC;

--9. Fetch oldest athletes to win a gold medal
UPDATE 
	olympics_games
SET 
	age = REPLACE(age,'NA','0');
	
with t1 as (SELECT *
		   FROM olympics_games 
		   WHERE medal='Gold')
SELECT * 
	FROM t1
	WHERE age=(SELECT MAX(age) FROM t1);

--10. Find the Ratio of male and female athletes participated in all olympic games.
with t1 as( SELECT (
	(SELECT COUNT(id) FROM olympics_games WHERE sex = 'M' GROUP BY sex)::numeric / 
	(SELECT COUNT(id) FROM olympics_games WHERE sex = 'F' GROUP BY sex)::numeric) as ratio)
SELECT CONCAT(ROUND(ratio,2), ':1') as "ratio M:F" from t1;

--11. Fetch the top 5 athletes who have won the most gold medals.
SELECT name, team, COUNT(medal) as total_medals
	FROM olympics_games
	WHERE medal = 'Gold'
	GROUP BY name, team
	ORDER BY total_medals DESC
	LIMIT 5;

--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
SELECT name, team, COUNT(medal) as total_medals,
	ROW_NUMBER() OVER(ORDER BY COUNT(medal) DESC) medals_rank
	FROM olympics_games
	WHERE medal = 'Gold' OR medal = 'Silver' OR medal = 'Bronze'
	GROUP BY name, team
	ORDER BY medals_rank
	LIMIT 5;

--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC")

SELECT region, COUNT(medal) as total_medals,
	RANK() OVER(ORDER BY COUNT(medal) DESC) medals_rank
	FROM t1
	WHERE medal = 'Gold' OR medal = 'Silver' OR medal = 'Bronze'
	GROUP BY region
	ORDER BY medals_rank
	LIMIT 5;

--14. List down total gold, silver and bronze medals won by each country.
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC")

SELECT region as country, SUM(
		CASE 
			WHEN medal = 'Gold' THEN 1
			ELSE 0
			END) as gold,
		SUM(
		CASE 
			WHEN medal = 'Silver' THEN 1
			ELSE 0
			END) as silver,	
		SUM(
		CASE 
			WHEN medal = 'Bronze' THEN 1
			ELSE 0
			END) as bronze
	FROM t1
	GROUP BY country
	ORDER BY gold DESC;

--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC")

SELECT games, region as country, SUM(
		CASE 
			WHEN medal = 'Gold' THEN 1
			ELSE 0
			END) as gold,
		SUM(
		CASE 
			WHEN medal = 'Silver' THEN 1
			ELSE 0
			END) as silver,	
		SUM(
		CASE 
			WHEN medal = 'Bronze' THEN 1
			ELSE 0
			END) as bronze
	FROM t1
	GROUP BY games, country
	ORDER BY games;

--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC"),
t2 as(SELECT games, region as country, SUM(
		CASE 
			WHEN medal = 'Gold' THEN 1
			ELSE 0
			END) as gold,
		SUM(
		CASE 
			WHEN medal = 'Silver' THEN 1
			ELSE 0
			END) as silver,	
		SUM(
		CASE 
			WHEN medal = 'Bronze' THEN 1
			ELSE 0
			END) as bronze
	FROM t1
	GROUP BY games, country
	ORDER BY games),
t3 as(SELECT games, MAX(gold) as most_gold, MAX(silver) as most_silver, MAX(bronze) as most_bronze
	 FROM t2
	 GROUP BY games),
t4 as(SELECT games,
	c1 as country_most_gold FROM (SELECT games, country as c1, gold FROM t2 WHERE (games, gold) IN (SELECT games, MAX(gold) from t2 GROUP BY games)) as country_most_gold),
t5 as(SELECT DISTINCT ON (games) games, country_most_silver FROM(SELECT games,
	c2 as country_most_silver FROM (SELECT games, country as c2, silver FROM t2 WHERE (games, silver) IN (SELECT games, MAX(silver) from t2 GROUP BY games)) as country_most_silver) as unique_most_silver),
t6 as(SELECT DISTINCT ON (games) games, country_most_bronze FROM (SELECT games,
	 c2 as country_most_bronze 
	 FROM (SELECT games, country as c2, bronze FROM t2 WHERE (games, bronze) IN (SELECT games, MAX(bronze) from t2 GROUP BY games)) as country_most_bronze) as unique_most_bronze),
t7 as (SELECT games, CONCAT(country, ' - ', gold+silver+bronze) as total_medals
	FROM t2
	WHERE (games, gold+silver+bronze) IN (SELECT games, MAX(gold+silver+bronze) FROM t2 GROUP BY games)
	ORDER BY games)	 
SELECT t3.games, CONCAT(country_most_gold, ' - ', t3.most_gold) AS country_most_gold, CONCAT(country_most_silver, ' - ', t3.most_silver) as country_most_silver, CONCAT(country_most_bronze, ' - ', t3.most_bronze) as country_most_bronze
	FROM t3
	JOIN t4 ON t4.games = t3.games
	JOIN t5 ON t5.games = t4.games
	JOIN t6 ON t6.games = t5.games
	JOIN t7 ON t7.games = t6.games
	ORDER BY games

--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC"),
t2 as(SELECT games, region as country, SUM(
		CASE 
			WHEN medal = 'Gold' THEN 1
			ELSE 0
			END) as gold,
		SUM(
		CASE 
			WHEN medal = 'Silver' THEN 1
			ELSE 0
			END) as silver,	
		SUM(
		CASE 
			WHEN medal = 'Bronze' THEN 1
			ELSE 0
			END) as bronze
	FROM t1
	GROUP BY games, country
	ORDER BY games),
t3 as(SELECT games, MAX(gold) as most_gold, MAX(silver) as most_silver, MAX(bronze) as most_bronze
	 FROM t2
	 GROUP BY games),
t4 as(SELECT games,
	c1 as country_most_gold FROM (SELECT games, country as c1, gold FROM t2 WHERE (games, gold) IN (SELECT games, MAX(gold) from t2 GROUP BY games)) as country_most_gold),
t5 as(SELECT DISTINCT ON (games) games, country_most_silver FROM(SELECT games,
	c2 as country_most_silver FROM (SELECT games, country as c2, silver FROM t2 WHERE (games, silver) IN (SELECT games, MAX(silver) from t2 GROUP BY games)) as country_most_silver) as unique_most_silver),
t6 as(SELECT DISTINCT ON (games) games, country_most_bronze FROM (SELECT games,
	 c2 as country_most_bronze 
	 FROM (SELECT games, country as c2, bronze FROM t2 WHERE (games, bronze) IN (SELECT games, MAX(bronze) from t2 GROUP BY games)) as country_most_bronze) as unique_most_bronze),
t7 as (SELECT games, CONCAT(country, ' - ', gold+silver+bronze) as total_medals
	FROM t2
	WHERE (games, gold+silver+bronze) IN (SELECT games, MAX(gold+silver+bronze) FROM t2 GROUP BY games)
	ORDER BY games)	 
SELECT t3.games, CONCAT(country_most_gold, ' - ', t3.most_gold) AS country_most_gold, CONCAT(country_most_silver, ' - ', t3.most_silver) as country_most_silver, 
	CONCAT(country_most_bronze, ' - ', t3.most_bronze) as country_most_bronze, t7.total_medals
	FROM t3
	JOIN t4 ON t4.games = t3.games
	JOIN t5 ON t5.games = t4.games
	JOIN t6 ON t6.games = t5.games
	JOIN t7 ON t7.games = t6.games
	ORDER BY games

--18. Which countries have never won gold medal but have won silver/bronze medals?
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC"),
t2 as(SELECT games, region as country, SUM(
		CASE 
			WHEN medal = 'Gold' THEN 1
			ELSE 0
			END) as gold,
		SUM(
		CASE 
			WHEN medal = 'Silver' THEN 1
			ELSE 0
			END) as silver,	
		SUM(
		CASE 
			WHEN medal = 'Bronze' THEN 1
			ELSE 0
			END) as bronze
	FROM t1
	GROUP BY games, country
	ORDER BY games)
	
SELECT * FROM (SELECT country, SUM(gold) as golds, SUM(silver) as silvers, SUM(bronze) as bronzes
	FROM t2
	GROUP BY country) as subq
	WHERE golds = 0 AND (bronzes > 0 OR silvers > 0)
	ORDER BY silvers DESC

--19. In which Sport/event, Argentina has won highest medals.
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC"),
t2 as(SELECT games, region as country, sport, SUM(
		CASE 
			WHEN medal = 'Gold' THEN 1
			ELSE 0
			END) as gold,
		SUM(
		CASE 
			WHEN medal = 'Silver' THEN 1
			ELSE 0
			END) as silver,	
		SUM(
		CASE 
			WHEN medal = 'Bronze' THEN 1
			ELSE 0
			END) as bronze
	FROM t1
	GROUP BY games, country, sport
	ORDER BY games),
t3 as(SELECT games, country, sport, total_medals FROM(SELECT games, country, sport, gold+silver+bronze as total_medals from t2
	WHERE country = 'Argentina') as subq),
t4 as(SELECT sport, SUM(total_medals) as total_medals
	FROM t3
	GROUP BY sport)
SELECT sport, total_medals FROM t4
	WHERE total_medals = (SELECT MAX(total_medals) FROM t4)

--20. Break down all olympic games where Argentina won medal for Hockey and how many medals in each olympic games
with t1 as(SELECT * 
		   FROM olympics_games og
		   JOIN regions rg ON rg.noc = og."NOC"),
t2 as(SELECT games, region as country, sport, SUM(
		CASE 
			WHEN medal <> 'NA' THEN 1
			ELSE 0
			END) as medals
	FROM t1
	GROUP BY games, country, sport
	ORDER BY games)
SELECT * FROM t2 
	WHERE country = 'Argentina' AND sport = 'Hockey' AND medals <> 0
	ORDER BY medals DESC