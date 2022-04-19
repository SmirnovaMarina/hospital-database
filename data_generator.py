from faker import Faker
from faker.providers import person
from faker.providers import date_time
from faker.providers import internet
from faker.providers import address
from faker.providers import phone_number
from faker.providers import lorem
from hashlib import md5
from datetime import datetime, timedelta
import random

faker = Faker()
faker.add_provider(person)
faker.add_provider(date_time)
faker.add_provider(internet)
faker.add_provider(lorem)

class User:
    @classmethod
    def get_random(cls, id=0):
        user = User()
        user.id = id
        user.gender = random.choice(('M', 'F'))
        user.first_name = faker.first_name_male() if user.gender == 'M' else faker.first_name_female()
        user.last_name = faker.last_name_male() if user.gender == 'M' else faker.last_name_female()
        user.date_of_birth = str(faker.date_of_birth())
        user.password_hash = md5(faker.password().encode()).hexdigest()
        user.address = faker.address().replace('\n', ' ')
        user.phone_number = '+' + ''.join([str(faker.random_digit()) for i in range(11)])
        user.email = faker.email()

        return user

    def __str__(self):
        return '({}, {!r}, {!r}, {!r}, {!r}, {!r}, {!r}, {!r}, {!r})'.format(self.id, self.first_name, self.last_name, self.date_of_birth, self.password_hash, self.address, self.gender, self.phone_number, self.email)

class Room:
    def get_random(cls, rno=0):
        room = Room()
        room.number = rno
        return room

    def __str__(self):
        return '({}, {}, {}::money)'

class Employee:
    @classmethod
    def get_random(cls, user_id, id=0):
        employee = Employee()
        employee.id = id
        employee.user_id = user_id
        employee.salary = str(faker.random_int(100, 100000)) + '::money'

        return employee

    def __str__(self):
        return '({}, {}, {})'.format(self.id, self.user_id, self.salary)

class Doctor:
    @classmethod
    def get_random(cls, employee_id, id=0):
        doctor = Doctor()
        doctor.id = id
        doctor.employee_id = employee_id
        doctor.specification = random.choice(('pediatrician', 'surgeon', 'cardiologyst', 'nephrologist', 'ophtalmologist'))

        return doctor

    def __str__(self):
        return '({}, {}, {!r})'.format(self.id, self.employee_id, self.specification)

class Patient:
    @classmethod
    def get_random(cls, user_id, id=0):
        patient = Patient()
        patient.id = id
        patient.user_id = user_id
        patient.religion = random.choice(('Judaism', 'Christianity', 'Islam', 'Buddhism', 'Atheism'))
        patient.blood_type = random.choice(('O', 'A', 'B', 'AB')) + random.choice(('+', '-'))

        return patient

    def __str__(self):
        return '({}, {}, {!r}, {!r})'.format(self.id, self.user_id, self.religion, self.blood_type)

class Event:
    @classmethod
    def get_random(cls, timeslot_id, time_range, id=0, precise_time=None):
        event = Event()
        event.id = id
        event.description = faker.text(256).replace('\n', ' ')
        event.timeslot_id = timeslot_id
        if precise_time is None:
            event.date = str(faker.date_between(time_range))
        else:
            event.date = str(precise_time)

        return event

    def __str__(self):
        return '({}, {!r}, {}, {!r})'.format(self.id, self.description, self.timeslot_id, self.date)

class Appointment:
    @classmethod
    def get_random(cls, doctor_id, patient_id, event_id, id=0):
        appointment = Appointment()
        appointment.id = id
        appointment.reason = faker.text(256).replace('\n', ' ')
        appointment.is_online = random.choice(('True', 'False'))
        appointment.doctor_id = doctor_id
        appointment.patient_id = patient_id
        appointment.event_id = event_id

        return appointment

    def __str__(self):
        return '({}, {!r}, {!r}, {}, {}, {})'.format(self.id, self.reason, self.is_online, self.doctor_id, self.patient_id, self.event_id)


def get_insert(obj, db):
    return 'INSERT INTO {} VALUES {};'.format(db, obj)

def get_insert_range(lst):
    return ',\n\t'.join([str(i) for i in lst])

def random_timeslot_id():
    return faker.random_int(1, 11)

def random_id(lst):
    return faker.random_int(0, len(lst) - 1)

users = []
employees = []
doctors = []
patients = []

user_count = 500
employee_count = 100
doctors_count = 50
patient_count = 400

appointments_count = 500

users = [User.get_random(i) for i in range(user_count)]
employees = [Employee.get_random(i, i) for i in range(employee_count)]
doctors = [Doctor.get_random(i, i) for i in range(doctors_count)]
patients = [Patient.get_random(i + employee_count, i) for i in range(0, user_count - employee_count)]

events = [Event.get_random(random_timeslot_id(), '-15y', i) for i in range(appointments_count)]
events += [Event.get_random(random_timeslot_id(), '-1M', i) for i in range(appointments_count, appointments_count * 2)]
appointments = [Appointment.get_random(random_id(doctors), random_id(patients), i, i) for i in range(appointments_count * 2)]

print(get_insert(get_insert_range(users), 'users'))
print(get_insert(get_insert_range(employees), 'employees'))
print(get_insert(get_insert_range(doctors), 'doctors'))
print(get_insert(get_insert_range(patients), 'patients'))

print(get_insert(get_insert_range(events), 'events'))
print(get_insert(get_insert_range(appointments), 'appointments'))

print('\n-- Custom inserts:\n')

appointments_special = []
events_special = []
users_special = []
employees_special = []
doctors_special = []

# Query 1
expected_user = User.get_random(len(users) + len(users_special))
expected_user.first_name = 'L' + expected_user.first_name.lower()
users_special.append(expected_user)

expected_employee = Employee.get_random(expected_user.id, len(employees) + len(employees_special))
employees_special.append(expected_employee)

expected_doctor = Doctor.get_random(expected_employee.id, len(doctors) + len(doctors_special))
doctors_special.append(expected_doctor)

searching_patient = patients[0]

last_event = Event.get_random(random_timeslot_id(), '', len(events) + len(events_special), precise_time=datetime.now())
events_special.append(last_event)

last_appointment = Appointment.get_random(expected_doctor.id, searching_patient.id, last_event.id, len(appointments) + len(appointments_special))
appointments_special.append(last_appointment)

# Query 3

exp_patient = patients[0]
exp_doctor = doctors[0]
today = datetime.now()

for day in range(30):
    evt = Event.get_random(random_timeslot_id(), '', len(events) + len(events_special), precise_time=today - timedelta(days=day))
    events_special.append(evt)
    apt = Appointment.get_random(exp_doctor.id, exp_patient.id, evt.id, id=len(appointments) + len(appointments_special))
    appointments_special.append(apt)

# Query 5
exp_doctor = doctors[0]
patient_idx = 0

for year in range(10):
    for patient_count in range(10):
        evt = Event.get_random(random_timeslot_id(), '', len(events) + len(events_special), precise_time=datetime(2019 - year, 1, 1))
        events_special.append(evt)
        apt = Appointment.get_random(exp_doctor.id, patients[patient_idx].id, evt.id, id=len(appointments) + len(appointments_special))
        appointments_special.append(apt)
        patient_idx += 1

print(get_insert(get_insert_range(users_special), 'users'))
print(get_insert(get_insert_range(employees_special), 'employees'))
print(get_insert(get_insert_range(doctors_special), 'doctors'))

print(get_insert(get_insert_range(events_special), 'events'))
print(get_insert(get_insert_range(appointments_special), 'appointments'))

# Other tables population
print('''
INSERT INTO lab_staff (employee_id) VALUES (46), (47);
INSERT INTO ambulance_staff (employee_id) VALUES (44), (45);
INSERT INTO ambulance_requests (staff_id, user_id, request_time) VALUES (1, 1, '2019-08-12T22:00:12'), (2, 2, '2019-10-12T09:12:12');
INSERT INTO administrators (employee_id, access_priority) VALUES (42, 1), (43, 4);
INSERT INTO employment_records (employee_id, admin_id, hire_time, fire_time) VALUES (2, 1, '2010-01-12T09:00:00', CURRENT_TIMESTAMP), (30, 2, '2016-09-09T09:00:00', NULL);
INSERT INTO performance_reports (report_time, employee_id) VALUES ('2018-10-12T14:12:12', 3), ('2017-10-12T15:12:12', 23);
INSERT INTO paid_services (title, cost) VALUES ('X-Ray', '200'::money), ('Standard Blood Analysis', '100'::money);
INSERT INTO transactions (transaction_time, amount, receipt_id, patient_id, paid_service_id) VALUES ('2019-11-12T11:12:12', '200'::money , 1, 1, 1), ('2019-11-18T11:12:12', '100'::money , 2, 1, 2);
INSERT INTO appointment_feedback (patient_id, appointment_id, feedback) VALUES (1, 1, 'A wonderful doctor!'), (2, 3, 'Satisfactory service! But used to be better!');
INSERT INTO notifications (user_id, event_id) VALUES (22, 1), (13, 7), (15, 9);
INSERT INTO dishes (name, price) VALUES ('Fish and chips', '100'::money), ('Vanilla Cheese Cake', '21'::money);
INSERT INTO purchases (user_id, dish_id, purchase_time) VALUES (1, 2, '2018-11-12T14:12:12'), (14, 1, '2019-11-12T14:12:12');
INSERT INTO food_shipments (manufacturer, dish_id, arrival_time, amount) VALUES ('KazanEcoFood', 1, '2019-11-12T09:00:12', 100), ('KazanEcoFood', 2, '2019-11-12T08:12:12' , 100);
INSERT INTO menus (weekday, meal_type) VALUES ('monday', 'lunch'), ('tuesday', 'breakfast');
INSERT INTO menu_dishes (menu_id, dish_id) VALUES (1, 1), (2, 2);
INSERT INTO rooms (room_no) VALUES (300), (101), (203);
INSERT INTO nurses (employee_id) VALUES (35), (56);
INSERT INTO wound_care_prescriptions (doctor_id, patient_id) VALUES (1, 1), (2, 2);
INSERT INTO wound_care_records (nurse_id, care_time, prescription_id) VALUES (1, '2018-12-12T12:12:12', 1);
INSERT INTO analysis_records (patient_id, nurse_id, lab_staff_id, time_made, report, type) VALUES
  (12, 1, 1, '2018-12-12T12:12:12', 'report', 'blood');
INSERT INTO in_patient_records (patient_id, doctor_id, acceptance_date, expected_release_date) VALUES
  (12, 1, '2018-12-12T12:12:12', '2018-12-13T12:12:12');
INSERT INTO room_occupation (in_patient_record_id, room_no, time_from, time_until) VALUES
  (1, 101, '2018-12-12T12:12:12', '2018-12-13T12:12:12');
INSERT INTO inventory_items (id) VALUES (1), (2), (3);
INSERT INTO inventory_reservation (item_id, nurse_id, time_from, time_until) VALUES
  (1, 1, '2018-12-12T12:12:12', '2018-12-13T12:12:12');
INSERT INTO medicine (name, description) VALUES ('Citramon', 'To cure headache'), ('Korvalol', 'To teach TCS');
INSERT INTO pharmacists (employee_id) VALUES (20), (21), (22);
INSERT INTO drug_prescriptions (patient_id, doctor_id, medicine_id, prescription_time, amount, recurrence_period, time_until) VALUES
  (1, 2, 1, '2018-12-12T12:12:12', 5, null, null);
INSERT INTO changes_in_stock (medicine_id, arrival_time, delta_amount, pharmacist_id, prescription_id) VALUES
  (1, '2018-12-12T12:12:12', 5, 1, 1);
INSERT INTO it_employees (employee_id) VALUES (30), (31), (32);
INSERT INTO electronic_equipment (name, description, eq_condition) VALUES ('TV', null, 'satisfactory');
INSERT INTO bugs (priority, description, report_time, reporter_id) VALUES
  (1, 'DMD lab is falling apart', '2018-12-12T12:12:12', 1);
INSERT INTO bug_fixes (bug_id, fixer_id, fix_time) VALUES
  (1, 1, '2018-12-12T12:12:12');
INSERT INTO repair_requests (date_opened, description, creator_id, equipment_id) VALUES
  ('2018-12-12T12:12:12', 'Please fix my TV', 1, 1);
INSERT INTO repair_request_responses (request_id, repair_time, assignee_id) VALUES (1, '2018-12-12T12:12:12', 1);
INSERT INTO maintenance_duties (employee_id, equipment_id, start_date, period) VALUES (1, 1, '2018-12-12T12:12:12', interval '1 month');
INSERT INTO system_features (priority, description, implemented) VALUES (1, 'Make the project better', false);
INSERT INTO system_feature_work (feature_id, employee_id) VALUES (1, 1);
INSERT INTO cleaners (employee_id) VALUES (1), (2);
INSERT INTO cleaning_duties (cleaning_time, cleaner_id, room_no) VALUES
  ('2018-12-12T12:12:12', 1, 101);
INSERT INTO cleaning_requests (request_author_id, room_no, deadline_time, reason) VALUES
  (1, 101, '2018-12-12T12:12:12', 'It dirty tho');
INSERT INTO cleaning_request_responses (request_id, cleaning_time, assignee_id) VALUES
  (1, '2018-12-12T12:12:12', 1);
''')
