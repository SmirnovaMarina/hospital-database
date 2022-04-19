SELECT sum(200                                  -- Base value
           + 200 * ((patient_age >= 50)::int)   -- plus the 200 for people over 50
           + 50 * ((pm >= 3)::int)              -- plus the 50 for attending over 3 times per month...
             * (1 + (patient_age >= 50)::int))  -- ...times two for people over 50
FROM (
	SELECT date_part('year', age(users.date_of_birth)) as patient_age, count(*) as pm
	FROM patients
	  JOIN users ON users.id = patients.user_id
	  JOIN appointments ON patients.id = appointments.patient_id
    JOIN events ON events.id = appointments.event_id
	WHERE events.event_date >= (CURRENT_TIMESTAMP - interval '1 month')
	GROUP BY users.id
) as income;
