-- Query to find results of a team
SELECT * FROM results
WHERE home_team_id = (
    SELECT id FROM teams
    WHERE name IS 'Los Angeles Lakers'
)
OR away_team_id = (
    SELECT id FROM teams
    WHERE name IS 'Los Angeles Lakers'
);


-- Query to find average home vs away points, to check for home advantage overall
SELECT ROUND(AVG(home_score), 1) AS 'Average Home Points', ROUND (AVG (away_score), 1) AS 'Average Away Points'
FROM results;

-- Query to find average points home vs away for a determined team
SELECT ROUND(AVG(home_score), 1) AS 'Average Team Home Points', ROUND (AVG (away_score), 1) AS 'Average Team Away Points'
FROM results
WHERE home_team_id = (
    SELECT id FROM teams
    WHERE name IS 'Los Angeles Lakers'
)
OR away_team_id = (
    SELECT id FROM teams
    WHERE name IS 'Los Angeles Lakers'
);


-- Query to find the %win rate of a team against a division (in this case Boston Celtics vs the eastern conference)
SELECT ROUND(SUM(CASE WHEN winner = (SELECT id FROM teams WHERE name = 'Boston Celtics') THEN 1 ELSE 0 END) * 1.0 /COUNT(*) *100, 1) AS win_percentage from  results
WHERE (
home_team_id = (
    SELECT id FROM teams
    WHERE name = 'Boston Celtics'
) AND away_team_id IN (
    SELECT team_id FROM team_conference
    WHERE conference_id IS (
        SELECT id FROM conferences
        WHERE name IS "Eastern"
    )
) AND winner IS NOT NULL)
OR away_team_id = (
    SELECT id FROM teams
    WHERE name IS 'Boston Celtics'
) AND home_team_id IN (
    SELECT team_id FROM team_conference
    WHERE conference_id IS (
        SELECT id FROM conferences
        WHERE name IS "Eastern"
    )
AND WINNER IS NOT NULL
);

-- Query to find all results
SELECT * FROM team_results;

-- Query to see games of a team
SELECT * FROM team_results
WHERE away_team = 'Boston Celtics'
OR home_team = 'Boston Celtics';



-- Populate conferences
INSERT INTO conferences (name)
VALUES
('Eastern'),
('Western');

-- Populate teams
INSERT INTO teams (name)
VALUES
('Memphis Grizzlies'),
('Cleveland Cavaliers'),
('Denver Nuggets'),
('Boston Celtics'),
('New York Knicks'),
('Atlanta Hawks'),
('Chicago Bulls'),
('Dallas Mavericks'),
('Oklahoma City Thunder'),
('Sacramento Kings'),
('Indiana Pacers'),
('Houston Rockets'),
('Milwaukee Bucks'),
('Toronto Raptors'),
('Detroit Pistons'),
('Phoenix Suns'),
('Los Angeles Lakers'),
('Golden State Warriors'),
('San Antonio Spurs'),
('Utah Jazz'),
('Miami Heat'),
('Los Angeles Clippers'),
('Minnesota Timberwolves'),
('Washington Wizards'),
('Portland Trail Blazers'),
('Brooklyn Nets'),
('Philadelphia 76ers'),
('New Orleans Pelicans'),
('Charlotte Hornets'),
('Orlando Magic');

-- Assign conference to teams
INSERT INTO team_conference (team_id, conference_id)
VALUES
(1, 2),
(2, 1),
(3, 2),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 2),
(9, 2),
(10, 2),
(11, 1),
(12, 2),
(13, 1),
(14, 1),
(15, 1),
(16, 2),
(17, 2),
(18, 2),
(19, 2),
(20, 2),
(21, 1),
(22, 2),
(23, 2),
(24, 1),
(25, 2),
(26, 1),
(27, 1),
(28, 2),
(29, 1),
(30, 1);

-- import of a csv file (as reference taken from https://www.basketball-reference.com/leagues/NBA_2025_games-december.html)
.import --csv --skip 1 nbadecember.csv temp_results

-- Update of results that weren't played yet
UPDATE temp_results SET home_score = NULL WHERE home_score ="";
UPDATE temp_results SET away_score = NULL WHERE away_score ="";


-- transcription of results from temporary table to final table with substitution of names per teams.id as in the pre-assigned table
INSERT INTO results (date, home_team_id, away_team_id, home_score, away_score)
SELECT
    temp_results.date,
    teams1.id AS home_team_id,
    teams2.id AS away_team_id,
    temp_results.home_score,
    temp_results.away_score
FROM temp_results
JOIN teams AS teams1 ON temp_results.home_team_id = teams1.name
JOIN teams AS teams2 ON temp_results.away_team_id = teams2.name;
