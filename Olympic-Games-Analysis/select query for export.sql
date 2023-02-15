SELECT id, name,
	CASE WHEN sex ='M' THEN 'Male' ELSE 'Female' END as sex,
	age, 
	CASE WHEN CAST(age AS INTEGER) = 0 THEN 'Not registered'
		WHEN CAST(age AS INTEGER) < 18 THEN 'Under 18'
		WHEN CAST(age AS INTEGER) BETWEEN 18 AND 30 THEN '18-30'
		ELSE 'Over 30' END AS Age_group,
	height, weight,
	og."NOC" as Nation_code, rg.region AS Country,
	games, year, season, sport, event,
	CASE WHEN medal = 'NA' THEN 'Not registered' ELSE medal end as medal
FROM olympics_games og
LEFT JOIN regions rg ON rg.noc = og."NOC"
WHERE season = 'Summer'