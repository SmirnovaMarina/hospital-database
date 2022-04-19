SELECT
  users.first_name, users.last_name
FROM
  doctors
  JOIN appointments ON doctors.id = appointments.doctor_id
  JOIN patients ON appointments.patient_id = patients.id
  JOIN events ON appointments.event_id = events.id
  JOIN time_slots ON events.time_slot_id = time_slots.id
  JOIN employees ON doctors.employee_id = employees.id
  JOIN users ON users.id = employees.user_id
WHERE
  patients.id = %s
  AND (users.first_name SIMILAR TO '(M|L)%%') != (users.last_name SIMILAR TO '(M|L)%%')
  AND events.event_date = (
    SELECT
      MAX(e1.event_date)
    FROM
      events e1
      JOIN appointments a1 ON e1.id = a1.event_id
    WHERE a1.patient_id = %s
  )
  AND time_slots.s_start = (
    SELECT
      MAX(time_slots.s_start)
    FROM
      events e1
      JOIN appointments a1 ON e1.id = a1.event_id
      JOIN time_slots on e1.time_slot_id = time_slots.id
    WHERE a1.patient_id = %s
  );
