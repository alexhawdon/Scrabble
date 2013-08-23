PRAGMA foreign_keys = ON;

CREATE TABLE member (
	id						INTEGER PRIMARY KEY,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	email					TEXT NOT NULL,
	phone					TEXT NOT NULL,
	joined					DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	games_played			INTEGER DEFAULT 0 NOT NULL,
	cumulative_score		INTEGER DEFAULT 0 NOT NULL,
	average_score			INTEGER DEFAULT 0 NOT NULL,
	best_game				INTEGER REFERENCES game(id),
	games_won				INTEGER DEFAULT 0 NOT NULL,
	games_drawn				INTEGER DEFAULT 0 NOT NULL,
	games_lost				INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE game (
	id					INTEGER PRIMARY KEY,
	played_date			TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	player_one			INTEGER REFERENCES member(id) NOT NULL,
	player_two			INTEGER REFERENCES member(id) NOT NULL,
	player_one_score	INTEGER NOT NULL,
	player_two_score	INTEGER NOT NULL
);