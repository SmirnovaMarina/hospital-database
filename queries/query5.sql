SELECT
  d.id, users.first_name, users.last_name
  -- doctor_id is displayed for identifying the doctors, first name and last name are for convenience
FROM
  doctors d                                       -- All doctors
  JOIN employees ON d.employee_id = employees.id  -- ... with their employee info
  JOIN users ON employees.user_id = users.id      -- ... and their user info
WHERE
(  -- The number of doctor's appointments for last 10 years is greater than or equal to 100
  SELECT
    COUNT(DISTINCT a.patient_id)
  FROM
    appointments a                      -- All appointments
    JOIN events e ON a.event_id = e.id  -- ... with their event info
  WHERE
    a.doctor_id = d.id -- Where the doctor was involved
  AND
    date_part('year', e.event_date) > date_part('year', CURRENT_TIMESTAMP) - 10  -- Years after current - 10
  AND
    date_part('year', e.event_date) <= date_part('year', CURRENT_TIMESTAMP)  -- Years before or equal to current
) >= 100
AND
(  -- The number of last years when the doctor had >= 5 appointments is exactly 10 (all 10 years satisfy the requirement)
  SELECT
    COUNT(DISTINCT date_part('year', e1.event_date))  -- Count years where the doctor has >= 5 appointments
  FROM
    events e1 JOIN appointments a1 ON e1.id = a1.event_id  -- All appointments with event info
  WHERE
    date_part('year', e1.event_date) > date_part('year', CURRENT_TIMESTAMP) - 10  -- years after current - 10
  AND
    date_part('year', e1.event_date) <= date_part('year', CURRENT_TIMESTAMP)  -- years before or equal to current
  AND
  (  -- The number of appointments of the doctor at that year >= 5
    SELECT
      COUNT(DISTINCT a2.patient_id)  -- Count appointments of the doctor at that year
    FROM
      appointments a2 JOIN events e2 ON a2.event_id = e2.id  -- All appointments with event info
    WHERE
      a2.doctor_id = d.id  -- Where the doctor was involved
    AND
      date_part('year', e1.event_date) = date_part('year', e2.event_date)  -- At that year
  ) >= 5
) = 10;  
