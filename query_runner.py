# pylint: disable=import-error,C0103
import os
from pick import pick
from pypager.source import GeneratorSource
from pypager.pager import Pager
from tabulate import tabulate
from psycopg2 import connect


DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://localhost/hospital')
db = connect(DATABASE_URL)


def page(content):
    '''Output the `content` string through a pager.'''
    def _generator():
        for line in content.splitlines():
            yield [('', line + '\n')]

    pager = Pager()
    pager.add_source(GeneratorSource(_generator()))
    pager.run()


def browse_db():
    title = ('Which tables would you like to see?\n'
             'Use <Space> to select several options and <Enter> to confirm selection.')
    options = [
        'time_slots',
        'users',
        'employees',
        'doctors',
        'patients',
        'events',
        'appointments'
    ]
    table_names = pick(options, title, multi_select=True, min_selection_count=1)
    output = ''
    for table_name, _ in table_names:
        c = db.cursor()
        c.execute(f'SELECT * FROM {table_name}')
        output += ' ' + table_name + '\n'
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        c.close()
    page(output)


def run_queries():
    title = 'Which query to run?'
    options = [
        'Query 1: Forgotten bag',
        'Query 2: Statistics on appointments per doctors',
        'Query 3: Frequently visiting patients',
        'Query 4: Monthly income',
        'Query 5: Experienced, long-serving doctors'
    ]
    option, index = pick(options, title)
    with open(f'queries/query{index + 1}.sql') as query_file:
        query_text = query_file.read()

    c = db.cursor()
    if index == 0:
        title = 'Pick a patient to run the query with'
        c.execute('''SELECT patients.id, first_name, last_name FROM
                  users JOIN patients ON patients.user_id = users.id''')
        options = [(id, fn + ' ' + ln) for id, fn, ln in c]
        option, index = pick(options, title, options_map_func=lambda x: x[1])

        output = ' Doctors who could have seen the bag\n'
        c.execute(query_text, (option[0],) * 3)
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        page(output)
    elif index == 1:
        with open('queries/query2-1.sql') as aux_query_file:
            aux_query_text = aux_query_file.read()

        output = ' Total appointments\n'
        c.execute(query_text)
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        output += ' Average appointments\n'
        c.execute(aux_query_text)
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        page(output)
    elif index == 2:
        output = ' Patients who require home visits\n'
        c.execute(query_text)
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        page(output)
    elif index == 3:
        output = ' Monthly income\n'
        c.execute(query_text)
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        page(output)
    elif index == 4:
        output = 'Experienced doctors\n'
        c.execute(query_text)
        output += tabulate(c.fetchall(),
                           headers=[i[0] for i in c.description],
                           tablefmt='fancy_grid') + '\n\n'
        page(output)
    c.close()


while True:
    try:
        title = 'You may choose to browse the database or run queries.'
        options = ['Browse the database', 'Run queries', 'Quit']
        option, index = pick(options, title)
        if option == 'Quit':
            break
        elif index == 0:
            browse_db()
        elif index == 1:
            run_queries()
    except KeyboardInterrupt:
        break
