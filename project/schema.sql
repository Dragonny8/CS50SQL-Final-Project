-- Represent teams in the league
CREATE TABLE teams (
    id INTEGER,
    name TEXT NOT NULL UNIQUE,
    PRIMARY KEY(id)
);

-- Represent conferences in the league
CREATE TABLE conferences (
    id INTEGER,
    name TEXT NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

-- Represent conference of each team
CREATE TABLE team_conference (
    id INTEGER,
    conference_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL UNIQUE,
    PRIMARY KEY (id),
    FOREIGN KEY (conference_id) REFERENCES conferences(id),
    FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- Represent results of the games and future fixtures
CREATE TABLE results (
    id INTEGER,
    home_team_id INTEGER,
    away_team_id INTEGER,
    home_score INTEGER,
    away_score INTEGER,
    date TIMESTAMP,
    winner INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (home_team_id) REFERENCES teams(id),
    FOREIGN KEY (away_team_id) REFERENCES teams(id),
    FOREIGN KEY (winner) REFERENCES teams(id)
);

-- View to see results with team names directly
CREATE VIEW "team_results" AS
SELECT
date,
teams1.name AS home_team,
home_score,
away_score,
teams2.name AS away_team,
teams3.name AS winner
FROM results
JOIN teams AS teams1 ON results.home_team_id = teams1.id
JOIN teams AS teams2 ON results.away_team_id = teams2.id
JOIN teams AS teams3 ON results.winner = teams3.id;

-- Triggers to automatically define winner of game upon insertion or update
CREATE TRIGGER define_winner
AFTER INSERT ON results
FOR EACH ROW
WHEN NEW.home_score IS NOT NULL AND NEW.away_score IS NOT NULL
BEGIN
    UPDATE results
    SET winner = CASE
        WHEN NEW.home_score > NEW.away_score THEN NEW.home_team_id
        WHEN NEW.away_score > NEW.home_score THEN NEW.away_team_id
    END
    WHERE id = NEW.id;
END;

CREATE TRIGGER define_winner_2
AFTER UPDATE ON results
FOR EACH ROW
WHEN NEW.home_score IS NOT NULL AND NEW.away_score IS NOT NULL
BEGIN
    UPDATE results
    SET winner = CASE
        WHEN NEW.home_score > NEW.away_score THEN NEW.home_team_id
        WHEN NEW.away_score > NEW.home_score THEN NEW.away_team_id
    END
    WHERE id = NEW.id;
END;


-- Create indexes to speed up most common queries
CREATE INDEX winner_search ON results(winner);
CREATE INDEX conference_search ON team_conference(conference_id);
CREATE INDEX home_team_search ON results(home_team_id);
CREATE INDEX away_team_search ON results(away_team_id);
CREATE INDEX game_date_search ON results(date);


-- Temporary table to import results in csv
CREATE TABLE temp_results (
    date TIMESTAMP,
    away_team_id INTEGER,
    away_score INTEGER,
    home_team_id INTEGER,
    home_score INTEGER
);
