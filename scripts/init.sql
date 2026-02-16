CREATE TABLE src_fighters (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE src_weight_classes (
    id SERIAL PRIMARY KEY,
    class_name VARCHAR(50),
    weight_limit_kg DECIMAL(5, 2)
);

CREATE TABLE src_events (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    city VARCHAR(50),
    event_date DATE
);

CREATE TABLE src_bouts (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES src_events(id),
    class_id INT REFERENCES src_weight_classes(id),
    fighter_a_id INT REFERENCES src_fighters(id),
    fighter_b_id INT REFERENCES src_fighters(id),
    winner_id INT REFERENCES src_fighters(id),
    result_method VARCHAR(50) 
);

INSERT INTO src_fighters (full_name, country) VALUES
('Jerzy Kulej', 'Poland'), ('Sugar Ray Robinson', 'USA'),
('Tomasz Adamek', 'Poland'), ('Muhammad Ali', 'USA'),
('Mike Tyson', 'USA'), ('Andrzej Golota', 'Poland'),
('Tyson Fury', 'UK'), ('Oleksandr Usyk', 'Ukraine'),
('Floyd Mayweather Jr.', 'USA'), ('Manny Pacquiao', 'Philippines');

INSERT INTO src_weight_classes (class_name, weight_limit_kg) VALUES
('Welterweight', 77.1), ('Heavyweight', 120.2);

INSERT INTO src_events (event_name, city, event_date) VALUES
('KSW 67: Poland vs USA', 'Warsaw', '2025-10-01'),
('Boxing Fight Night', 'Ohio', '2025-01-15'),
('Legendary Night', 'Las Vegas', '2024-12-10'),
('Riyadh Season: Ring of Fire', 'Riyadh', '2025-05-18'),
('Spodek Heavyweights', 'Katowice', '2025-02-20');

INSERT INTO src_bouts (event_id, class_id, fighter_a_id, fighter_b_id, winner_id, result_method) VALUES
(1, 1, 1, 2, 1, 'DECISION'), (1, 2, 3, 4, 4, 'KO'),
(2, 1, 1, 3, NULL, 'DRAW'), (2, 2, 2, 4, 4, 'TKO'),
(3, 1, 9, 10, 9, 'DECISION'), (3, 2, 4, 5, 4, 'KO'),
(4, 2, 7, 8, 8, 'DECISION'), (4, 2, 3, 6, 3, 'TKO'),
(5, 2, 6, 7, 7, 'KO'), (5, 1, 2, 10, 2, 'KO');

CREATE TABLE dim_fighter (
    fighter_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE dim_weight_class (
    class_id INT PRIMARY KEY,
    class_name VARCHAR(50),
    weight_limit_kg DECIMAL(5, 2)
);

CREATE TABLE dim_location (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(50) UNIQUE
);

CREATE TABLE dim_time (
    time_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    month INT,
    day INT
);

CREATE TABLE fact_bouts (
    fact_id SERIAL PRIMARY KEY,
    fighter_id INT REFERENCES dim_fighter(fighter_id),
    opponent_id INT REFERENCES dim_fighter(fighter_id),
    time_id INT REFERENCES dim_time(time_id),
    location_id INT REFERENCES dim_location(location_id),
    class_id INT REFERENCES dim_weight_class(class_id),
    is_win INT,
    is_loss INT,
    is_draw INT,
    is_ko_tko INT
);

INSERT INTO dim_fighter (fighter_id, full_name, country)
SELECT id, full_name, country FROM src_fighters;

INSERT INTO dim_weight_class (class_id, class_name, weight_limit_kg)
SELECT id, class_name, weight_limit_kg FROM src_weight_classes;

INSERT INTO dim_location (city)
SELECT DISTINCT city FROM src_events;

INSERT INTO dim_time (full_date, year, month, day)
SELECT DISTINCT
    event_date,
    EXTRACT(YEAR FROM event_date),
    EXTRACT(MONTH FROM event_date),
    EXTRACT(DAY FROM event_date)
FROM src_events;

INSERT INTO fact_bouts (fighter_id, opponent_id, time_id, location_id, class_id, is_win, is_loss, is_draw, is_ko_tko)
SELECT
    b.fighter_a_id AS fighter_id, b.fighter_b_id AS opponent_id, dt.time_id, dl.location_id, b.class_id,
    CASE WHEN b.winner_id = b.fighter_a_id THEN 1 ELSE 0 END AS is_win,
    CASE WHEN b.winner_id = b.fighter_b_id THEN 1 ELSE 0 END AS is_loss,
    CASE WHEN b.winner_id IS NULL THEN 1 ELSE 0 END AS is_draw,
    CASE WHEN b.winner_id = b.fighter_a_id AND b.result_method IN ('KO', 'TKO') THEN 1 ELSE 0 END AS is_ko_tko
FROM src_bouts b
JOIN src_events e ON b.event_id = e.id
JOIN dim_time dt ON e.event_date = dt.full_date
JOIN dim_location dl ON e.city = dl.city
UNION ALL
SELECT
    b.fighter_b_id AS fighter_id, b.fighter_a_id AS opponent_id, dt.time_id, dl.location_id, b.class_id,
    CASE WHEN b.winner_id = b.fighter_b_id THEN 1 ELSE 0 END AS is_win,
    CASE WHEN b.winner_id = b.fighter_a_id THEN 1 ELSE 0 END AS is_loss,
    CASE WHEN b.winner_id IS NULL THEN 1 ELSE 0 END AS is_draw,
    CASE WHEN b.winner_id = b.fighter_b_id AND b.result_method IN ('KO', 'TKO') THEN 1 ELSE 0 END AS is_ko_tko
FROM src_bouts b
JOIN src_events e ON b.event_id = e.id
JOIN dim_time dt ON e.event_date = dt.full_date
JOIN dim_location dl ON e.city = dl.city;