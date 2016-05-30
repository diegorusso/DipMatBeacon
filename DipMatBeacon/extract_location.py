# -*- coding: utf-8 -*-
import re
import csv
import sys
import codecs
import random
from datetime import datetime

# output in utf-8
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())


def extract_location(reportfd, locationfd):
    reader = csv.DictReader(reportfd)
    writer = csv.DictWriter(locationfd, fieldnames=['name', 'floor', 'building', 'minor', 'mayor' ])
    locations = set()
    for row in reader:
        locations.add(row['Sala'])
    writer.writeheader()
    for location in locations:
        row_dict = {'name': location,
                    'floor': random.randrange(-1,3),
                    'building': random.choice(['Informatica', 'Fisica'])}
        writer.writerow(row_dict)

with open('report.csv', 'r', encoding='utf-8') as reportfd, \
        open('location.csv', 'w', encoding='utf-8') as locationfd:
    extract_location(reportfd, locationfd)
