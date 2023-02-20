--- Average Trip Miles on per Hour
SELECT
  EXTRACT(HOUR FROM trip_start_timestamp) hour,
  ROUND(AVG(trip_miles), 2) avg_miles
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
GROUP BY 1
ORDER BY 1;

--- Average Trip Cost, Tips, Duration per Weekday and Hour
WITH weekdays AS(
SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek)

SELECT
  ROUND(AVG(trip_total), 2) trip_total_cost,
  ROUND(AVG(tips), 2) avg_tips,
  CONCAT(ROUND(AVG(trip_seconds) / 60, 2), ' hrs') trip_duration,
  daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM trip_start_timestamp))] weekday,
  EXTRACT(HOUR FROM trip_start_timestamp) hour
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`, weekdays
WHERE trip_seconds > 0
  AND fare > 0
GROUP BY 4, 5
ORDER BY 4, 5;

--- Training Data
WITH weekdays AS(
SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek)

SELECT
  trip_total trip_total_cost,
  tips,
  CONCAT(ROUND(trip_seconds / 60, 2), ' hrs') trip_duration,
  daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM trip_start_timestamp))] weekday,
  EXTRACT(HOUR FROM trip_start_timestamp) hour
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`, weekdays
WHERE trip_seconds > 0
  AND fare > 0;

--- Taxi Fare Model
CREATE OR REPLACE MODEL chicago_taxi.taxi_fare_model
OPTIONS
  (model_type='linear_reg', labels=['trip_total_cost']) AS
WITH weekdays AS(
SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek)

SELECT
  trip_total trip_total_cost,
  tips,
  CONCAT(ROUND(trip_seconds / 60, 2), ' hrs') trip_duration,
  daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM trip_start_timestamp))] weekday,
  EXTRACT(HOUR FROM trip_start_timestamp) hour
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`, weekdays
WHERE trip_seconds > 0
  AND fare > 0
LIMIT 25000;

--- Model Results
SELECT * FROM ML.PREDICT(MODEL `sql-practice-375701.chicago_taxi.taxi_fare_model`,( 
WITH weekdays AS(
SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek)

SELECT
  trip_total trip_total_cost,
  tips,
  CONCAT(ROUND(trip_seconds / 60, 2), ' hrs') trip_duration,
  daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM trip_start_timestamp))] weekday,
  EXTRACT(HOUR FROM trip_start_timestamp) hour
FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`, weekdays
WHERE trip_seconds > 0
  AND fare > 0
LIMIT 25000));