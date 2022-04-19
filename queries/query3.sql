SELECT
  users.first_name, users.last_name
FROM
  patients
  JOIN users ON patients.user_id = users.id
WHERE (
  SELECT
    COUNT(*)
  FROM
    (SELECT
       CAST(EXTRACT(DAY FROM events.event_date - (Now() - interval '1 month')) AS INTEGER) / 7 AS week, appointments.patient_id
     FROM
       events, appointments
     WHERE
         appointments.event_id = events.id
       AND
         events.event_date <= Now()
       AND
         events.event_date >= Now() - interval '1 month'
     GROUP BY patient_id, week
     HAVING COUNT(*) >= 2
     ) AS w1
  WHERE
    w1.patient_id = patients.id
  GROUP BY w1.patient_id
  HAVING COUNT(*) >= 4
) >= 0;
