import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('emergency_facilities', [
    Column.text('name'),
    Column.text('type'),
    Column.real('latitude'),
    Column.real('longitude'),
    Column.text('contact_number'),
    Column.text('capabilities'),
  ]),
  Table('reported_incidents', [
    Column.real('latitude'),
    Column.real('longitude'),
    Column.integer('severity'),
    Column.text('services_needed'),
    Column.text('status'),
    Column.text('reported_at'),
  ])
]);
