BEGIN TRANSACTION;

CREATE TABLE rooms (
  room_no integer PRIMARY KEY
);

CREATE TABLE time_slots (
  id SERIAL PRIMARY KEY,
  s_start time NOT NULL,
  s_end time NOT NULL,
  CHECK (s_start < s_end)
);

INSERT INTO time_slots (s_start, s_end) VALUES ('09:00', '09:30');
INSERT INTO time_slots (s_start, s_end) VALUES ('09:30', '10:00');
INSERT INTO time_slots (s_start, s_end) VALUES ('10:00', '10:30');
INSERT INTO time_slots (s_start, s_end) VALUES ('10:30', '11:00');
INSERT INTO time_slots (s_start, s_end) VALUES ('11:00', '11:30');
INSERT INTO time_slots (s_start, s_end) VALUES ('11:30', '12:00');
INSERT INTO time_slots (s_start, s_end) VALUES ('12:30', '13:00');
INSERT INTO time_slots (s_start, s_end) VALUES ('13:00', '13:30');
INSERT INTO time_slots (s_start, s_end) VALUES ('13:30', '14:00');
INSERT INTO time_slots (s_start, s_end) VALUES ('14:00', '14:30');
INSERT INTO time_slots (s_start, s_end) VALUES ('14:30', '15:00');

CREATE TABLE electronic_equipment (
  id SERIAL PRIMARY KEY,
  name varchar(256) NOT NULL,
  description varchar(256),
  eq_condition varchar(256) NOT NULL
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name varchar(256) NOT NULL,
  last_name varchar(256) NOT NULL,
  date_of_birth date NOT NULL CHECK (date_of_birth <= CURRENT_DATE),
  password_hash varchar(128) NOT NULL,
  address varchar(256) NOT NULL,
  gender varchar(64) NOT NULL,
  phone_number varchar(12) NOT NULL,
  email varchar(256) NOT NULL
);

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  user_id integer REFERENCES users(id) NOT NULL,
  salary float NOT NULL CHECK (salary > 0)
);

CREATE TABLE lab_staff (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL
);

CREATE TABLE doctors (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL,
  specification varchar(64) NOT NULL
);

CREATE TABLE patients (
  id SERIAL PRIMARY KEY,
  user_id integer REFERENCES users(id) NOT NULL,
  religion varchar(64) NOT NULL,
  blood_type varchar(3) NOT NULL
);

CREATE TABLE events (
  id SERIAL PRIMARY KEY,
  description varchar(256) NOT NULL,
  time_slot_id integer REFERENCES time_slots(id) NOT NULL,
  event_date date NOT NULL
);

CREATE TABLE appointments (
  id SERIAL PRIMARY KEY,
  reason varchar(256) NOT NULL,
  is_online boolean,
  doctor_id integer REFERENCES doctors(id) NOT NULL,
  patient_id integer REFERENCES patients(id) NOT NULL,
  event_id integer REFERENCES events(id) NOT NULL
);

CREATE TABLE ambulance_staff (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL
);

CREATE TABLE ambulance_requests (
  id SERIAL PRIMARY KEY,
  staff_id integer REFERENCES ambulance_staff(id),
  user_id integer REFERENCES users(id),
  request_time timestamp NOT NULL
);

CREATE TABLE administrators (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL,
  access_priority integer NOT NULL CHECK (access_priority > 0)
);

CREATE TABLE employment_records (
  employee_id integer REFERENCES employees(id) PRIMARY KEY,
  admin_id integer REFERENCES administrators(id),
  hire_time timestamp NOT NULL,
  fire_time timestamp
);

CREATE TABLE performance_reports (
  report_time timestamp CHECK (report_time <= CURRENT_TIMESTAMP),
  employee_id integer REFERENCES employees(id),
  PRIMARY KEY (report_time, employee_id)
);

CREATE TABLE paid_services (
  id SERIAL PRIMARY KEY,
  title varchar(128) NOT NULL,
  cost float NOT NULL
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  transaction_time timestamp NOT NULL CHECK (transaction_time <= CURRENT_TIMESTAMP),
  amount float NOT NULL,
  receipt_id varchar(64) NOT NULL,
  patient_id integer REFERENCES patients(id) NOT NULL,
  paid_service_id integer REFERENCES paid_services(id) NOT NULL
);

CREATE TABLE appointment_feedback (
  id SERIAL PRIMARY KEY,
  patient_id integer REFERENCES patients(id) NOT NULL,
  appointment_id integer REFERENCES appointments(id) NOT NULL,
  feedback varchar(512) NOT NULL,
  UNIQUE (patient_id, appointment_id)
);

CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id integer REFERENCES users(id) NOT NULL,
  event_id integer REFERENCES events(id) NOT NULL,
  UNIQUE (user_id, event_id)
);

CREATE TABLE dishes (
  id SERIAL PRIMARY KEY,
  name varchar(128) NOT NULL,
  price float NOT NULL
);

CREATE TABLE purchases (
  user_id integer REFERENCES users(id),
  dish_id integer REFERENCES dishes(id),
  purchase_time timestamp NOT NULL CHECK (purchase_time <= CURRENT_TIMESTAMP),
  PRIMARY KEY (user_id, dish_id, purchase_time)
);

CREATE TABLE food_shipments (
  manufacturer varchar(128) NOT NULL,
  dish_id integer REFERENCES dishes(id),
  arrival_time timestamp CHECK (arrival_time <= CURRENT_TIMESTAMP),
  amount integer NOT NULL CHECK (amount > 0),
  PRIMARY KEY (dish_id, arrival_time)
);

CREATE TABLE weekday_t (
  value varchar(15) PRIMARY KEY
);

INSERT INTO weekday_t VALUES ('monday'),
                             ('tuesday'),
                             ('wednesday'),
                             ('thursday'),
                             ('friday'),
                             ('saturday'),
                             ('sunday');

CREATE TABLE meal_type_t (
  value varchar(15) PRIMARY KEY
);

INSERT INTO meal_type_t VALUES ('breakfast'), ('lunch'), ('dinner'), ('supper');

CREATE TABLE menus (
  id SERIAL PRIMARY KEY,
  weekday varchar(15) REFERENCES weekday_t(value) NOT NULL,
  meal_type varchar(15) REFERENCES meal_type_t(value) NOT NULL
);

CREATE TABLE menu_dishes (
  menu_id integer REFERENCES menus(id) NOT NULL,
  dish_id integer REFERENCES dishes(id) NOT NULL,
  PRIMARY KEY (menu_id, dish_id)
);

CREATE TABLE nurses (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL
);

CREATE TABLE wound_care_prescriptions (
  id SERIAL PRIMARY KEY,
  doctor_id integer REFERENCES doctors(id) NOT NULL,
  patient_id integer REFERENCES patients(id) NOT NULL
);

CREATE TABLE wound_care_records (
  id SERIAL PRIMARY KEY,
  nurse_id integer REFERENCES nurses(id),
  care_time timestamp CHECK (care_time <= CURRENT_TIMESTAMP),
  prescription_id integer REFERENCES wound_care_prescriptions(id)
);

CREATE TABLE analysis_records (
  id SERIAL PRIMARY KEY,
  patient_id integer REFERENCES patients(id),
  nurse_id integer REFERENCES nurses(id),
  lab_staff_id integer REFERENCES lab_staff(id) NOT NULL,
  time_made timestamp CHECK (time_made <= CURRENT_TIMESTAMP),
  report varchar(256) NOT NULL,
  type varchar(64) NOT NULL
);

CREATE TABLE in_patient_records (
  id SERIAL PRIMARY KEY,
  patient_id integer REFERENCES patients(id) NOT NULL,
  doctor_id integer REFERENCES doctors(id) NOT NULL,
  acceptance_date date NOT NULL CHECK (acceptance_date <= CURRENT_DATE),
  expected_release_date date CHECK (expected_release_date > acceptance_date)
);

CREATE TABLE room_occupation (
  in_patient_record_id integer REFERENCES in_patient_records(id),
  room_no integer REFERENCES rooms(room_no),
  time_from timestamp NOT NULL,
  time_until timestamp NOT NULL CHECK (time_until > time_from),
  PRIMARY KEY (in_patient_record_id, room_no)
);

CREATE TABLE inventory_items (
  id SERIAL PRIMARY KEY
);

CREATE TABLE inventory_reservation (
  id SERIAL PRIMARY KEY,
  item_id integer REFERENCES inventory_items(id) NOT NULL,
  nurse_id integer REFERENCES nurses(id) NOT NULL,
  time_from timestamp NOT NULL,
  time_until timestamp CHECK (time_until > time_from) NOT NULL
);

CREATE TABLE medicine (
  id SERIAL PRIMARY KEY,
  name varchar(256) NOT NULL,
  description varchar(256)
);

CREATE TABLE pharmacists (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL
);

CREATE TABLE drug_prescriptions (
  id SERIAL PRIMARY KEY,
  patient_id integer REFERENCES patients(id) NOT NULL,
  doctor_id integer REFERENCES doctors(id) NOT NULL,
  medicine_id integer REFERENCES medicine(id) NOT NULL,
  prescription_time timestamp CHECK (prescription_time <= CURRENT_TIMESTAMP) NOT NULL,
  amount integer CHECK (amount > 0) NOT NULL,
  recurrence_period interval,
  time_until timestamp CHECK (time_until > prescription_time)
);

CREATE TABLE changes_in_stock (
  id SERIAL PRIMARY KEY,
  medicine_id integer REFERENCES medicine(id),
  arrival_time timestamp CHECK (arrival_time <= CURRENT_TIMESTAMP),
  delta_amount integer NOT NULL,
  pharmacist_id integer REFERENCES pharmacists(id),
  prescription_id integer REFERENCES drug_prescriptions(id)
);

CREATE TABLE it_employees (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL
);

CREATE TABLE bugs (
  id SERIAL PRIMARY KEY,
  priority integer NOT NULL CHECK (priority > 0),
  description varchar(256) NOT NULL,
  report_time timestamp NOT NULL CHECK (report_time <= CURRENT_TIMESTAMP),
  reporter_id integer REFERENCES users(id) NOT NULL
);

CREATE TABLE bug_fixes (
  bug_id integer REFERENCES bugs(id),
  fixer_id integer REFERENCES it_employees(id) NOT NULL,
  fix_time timestamp NOT NULL CHECK (fix_time <= CURRENT_TIMESTAMP),
  PRIMARY KEY (bug_id)
);

CREATE TABLE repair_requests (
  id SERIAL PRIMARY KEY,
  date_opened timestamp NOT NULL CHECK (date_opened <= CURRENT_TIMESTAMP),
  description varchar(256),
  creator_id integer REFERENCES employees(id) NOT NULL,
  equipment_id integer REFERENCES electronic_equipment(id) NOT NULL
);

CREATE TABLE repair_request_responses (
  request_id integer REFERENCES repair_requests(id) NOT NULL,
  repair_time timestamp NOT NULL,
  assignee_id integer REFERENCES it_employees(id),
  PRIMARY KEY (request_id)
);

CREATE TABLE maintenance_duties (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES it_employees(id),
  equipment_id integer REFERENCES electronic_equipment(id),
  start_date date NOT NULL,
  period interval NOT NULL
);

CREATE TABLE system_features (
  id SERIAL PRIMARY KEY,
  priority integer NOT NULL,
  description varchar(256) NOT NULL,
  implemented boolean NOT NULL
);

CREATE TABLE system_feature_work (
  feature_id integer REFERENCES system_features(id) NOT NULL,
  employee_id integer REFERENCES it_employees(id) NOT NULL,
  PRIMARY KEY (feature_id, employee_id)
);

CREATE TABLE cleaners (
  id SERIAL PRIMARY KEY,
  employee_id integer REFERENCES employees(id) NOT NULL
);

CREATE TABLE cleaning_duties (
  id SERIAL PRIMARY KEY,
  cleaning_time timestamp NOT NULL,
  cleaner_id integer REFERENCES cleaners(id),
  room_no integer REFERENCES rooms(room_no) NOT NULL
);

CREATE TABLE cleaning_requests (
  id SERIAL PRIMARY KEY,
  request_author_id integer REFERENCES employees(id) NOT NULL,
  room_no integer REFERENCES rooms(room_no) NOT NULL,
  deadline_time timestamp NOT NULL,
  reason varchar(256)
);

CREATE TABLE cleaning_request_responses (
  request_id integer REFERENCES cleaning_requests(id) NOT NULL,
  cleaning_time timestamp NOT NULL,
  assignee_id integer REFERENCES cleaners(id),
  PRIMARY KEY (request_id)
);

COMMIT TRANSACTION;
