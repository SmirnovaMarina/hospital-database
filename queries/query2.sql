SELECT
  doctor_id, time_slots.s_start, COUNT(*) as total
FROM
  appointments
  JOIN events ON appointments.event_id = events.id
  JOIN doctors ON appointments.doctor_id = doctors.id
  JOIN employees ON doctors.employee_id = employees.id
  JOIN users ON employees.user_id = users.id
  JOIN time_slots ON events.time_slot_id = time_slots.id
WHERE
  event_date > date_trunc('month', CURRENT_DATE) - interval '1 year'
GROUP BY doctor_id, time_slots.s_start;
