# -*- coding: utf-8 -*-
import re
import csv
import sys
import codecs
import random
import urllib.request
import json
from datetime import datetime

# output in utf-8
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())


def create_schedule(reportfd, schedulefd):
    fieldnames=['short_description', 'location', 'starting_time', 'end_time', 'duration',
                'long_description', 'correspondence','booking_type', 'created_by', 'approved',
                'professor', 'exam', 'degree', 'last_change']
    writer = csv.DictWriter(schedulefd, fieldnames=fieldnames)
    writer.writeheader()
    reader = csv.DictReader(reportfd)
    locations = _get_locations()
    for row in reader:
        row_dict = {'short_description': row['Breve Descrizione'],
                    'location': locations[row['Sala']],
                    'starting_time': _extract_datetime(row['Ora Inizio']),
                    'end_time': _extract_datetime(row['Ora Fine']),
                    'duration': row['Durata'],
                    'long_description': row['Descrizione completa'],
                    'correspondence': row['Corrispondenza'],
                    'booking_type': row['Tipo di prenotazione'],
                    'created_by': row['Creato da'],
                    'approved': _convert_to_bool(row['Stato dell\'approvazione']),
                    'professor': row['Docente'],
                    'exam': _convert_to_bool(row['E\' un esame?']),
                    'degree': row['Corso di Studi'],
                    'last_change': _extract_datetime(row['Ultima Modifica'])}
        writer.writerow(row_dict)


def _extract_datetime(string):
    month_dict = {'gennaio': 'January',
                  'febbraio': 'February',
                  'marzo': 'March',
                  'aprile': 'April',
                  'maggio': 'May',
                  'giugno': 'June',
                  'luglio': 'July',
                  'agosto': 'August',
                  'settembre': 'September',
                  'ottobre': 'October',
                  'novembre': 'November',
                  'dicembre': 'December'}
    day_dict = {'lunedì': 'Monday',
                'martedì': 'Tuesday',
                'mercoledì': 'Wednesday',
                'giovedì': 'Thursday',
                'venerdì': 'Friday',
                'sabato': 'Saturday',
                'domenica': 'Sunday'}
    # Month replacement
    monthj = re.compile('|'.join(month_dict.keys()))
    string = monthj.sub(lambda m: month_dict[m.group(0)], string)
    # Day replacement
    dayj = re.compile('|'.join(day_dict.keys()))
    string = dayj.sub(lambda m: day_dict[m.group(0)], string)
    # end format is: "2016-05-30T12:54:55.691Z"
    #                "%Y-%m-%dT%H:%M:%S"
    dt = datetime.strptime(string, '%H:%M:%S - %A %d %B %Y')
    dtstring = dt.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    return dtstring

def _convert_to_bool(string):
    return "true" if string == 'Yes' or string == 'Approvato' else "false"

def _get_locations():
    url = "https://ibeacon.stamplayapp.com/api/cobject/v1/location"
    response = urllib.request.urlopen(url)
    data = json.loads(response.read().decode('utf8'))
    location_dict = {}
    for location in data['data']:
        location_dict[location['name']] = location['id']
    return location_dict

with open('report.csv', 'r', encoding='utf-8') as reportfd, \
     open('schedule.csv', 'w', encoding='utf-8') as schedulefd:
    create_schedule(reportfd, schedulefd)
