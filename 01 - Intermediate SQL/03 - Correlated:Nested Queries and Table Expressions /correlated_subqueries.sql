-- Basic Correlated Subqueries
-- 01. examine matches with scores that are extreme outliers for each country -- above 3 times the average score
SELECT 
	-- Select country ID, date, home, and away goals from match
	main.country_id,
    date,
    main.home_goal, 
    away_goal
FROM match AS main
WHERE 
	-- Filter the main query by the subquery
	(home_goal + away_goal) > 
        (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
         FROM match AS sub
         -- Join the main query to the subquery in WHERE
         WHERE main.country_id = sub.country_id);


-- Correlated subquery with multiple conditions
-- 02. What was the highest scoring match for each country, in each season?
SELECT 
	-- Select country ID, date, home, and away goals from match
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE 
	-- Filter for matches with the highest number of goals scored
	(home_goal + away_goal) = 
        (SELECT MAX(sub.home_goal + sub.away_goal)
         FROM match AS sub
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);




-- Nested simple subqueries
-- 03. Examine the highest total number of goals in each season, overall, and during July across all seasons.
SELECT
	-- Select the season and max goals scored in a match
	season,
    MAX(home_goal + away_goal) AS max_goals,
    -- Select the overall max goals scored in a match
   (SELECT MAX(home_goal + away_goal) FROM match) AS overall_max_goals,
   -- Select the max number of goals scored in any match in July
   (SELECT MAX(home_goal + away_goal) 
    FROM match
    WHERE id IN (
          SELECT id FROM match WHERE EXTRACT(MONTH FROM DATE) = 07)) AS july_max_goals
FROM match
GROUP BY season;




-- Nest a subquery in FROM
-- 04. What's the average number of matches per season where a team scored 5 or more goals? How does this differ by country?
-- Select matches where a team scored 5+ goals

-- Step 1
SELECT
	country_id,
    season,
	id
FROM match
WHERE home_goal >= 5 OR away_goal >=5 ;

-- Step 2
-- Count match ids
SELECT
    country_id,
    season,
    COUNT(id) AS matches
-- Set up and alias the subquery
FROM (
	SELECT
    	country_id,
    	season,
    	id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5 ) AS subquery
-- Group by country_id and season
GROUP BY country_id, season;

-- Final answer
SELECT
	c.name AS country,
    -- Calculate the average matches per season
	AVG(id) AS avg_seasonal_high_scores
FROM country AS c
-- Left join outer_s to country
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS inner_s
  -- Close parentheses and alias the subquery
  GROUP BY country_id, season) AS outer_s
ON c.id = outer_s.country_id
GROUP BY country;


-- Common Table Expressions(CTE)
-- Clean up with CTEs
-- 05. Using CTE, generate a list of countries and the number of matches in each country with more than 10 total goals.
-- Set up your CTE
WITH match_list AS (
    SELECT 
      country_id, 
      id
    FROM match
    WHERE (home_goal + away_goal) >= 10)
-- Select league and count of matches from the CTE
SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM league AS l
-- Join the CTE to the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;




-- Organizing with CTEs
-- 06. Look at details about matches with very high scores using CTEs. 
-- Set up your CTE
WITH match_list AS (
  -- Select the league, date, home, and away goals
    SELECT 
      name AS league, 
      m.date, 
      m.home_goal, 
      m.away_goal,
       (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN league as l ON m.country_id = l.id)
-- Select the league, date, home, and away goals from the CTE
SELECT league, date, home_goal, away_goal
FROM match_list
-- Filter by total goals
WHERE total_goals >= 10;




-- CTEs with nested subqueries
-- 07. Declare a CTE that calculates the total goals from matches in August of the 2013/2014 season
-- Set up your CTE
WITH match_list AS (
    SELECT 
      country_id,
       (home_goal + away_goal) AS goals
    FROM match
    -- Create a list of match IDs to filter data in the CTE
    WHERE id IN (
       SELECT id
       FROM match
       WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = '08'))
-- Select the league name and average of goals in the CTE
SELECT 
  l.name,
    AVG(match_list.goals)
FROM league AS l
-- Join the CTE onto the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;














