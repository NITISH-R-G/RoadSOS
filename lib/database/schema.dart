import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('emergency_facilities', [
    Column.text('name'),
    Column.text('type'),
    Column.real('latitude'),
    Column.real('longitude'),
    Column.text('contact_number'),
    Column.text('capabilities'),
<<<<<<< HEAD
=======
    Column.text('data_source'),
    Column.text('state_code'),
    Column.text('district'),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
  ]),
  Table('reported_incidents', [
    Column.real('latitude'),
    Column.real('longitude'),
    Column.integer('severity'),
    Column.text('services_needed'),
    Column.text('status'),
    Column.text('reported_at'),
<<<<<<< HEAD
  ])
=======
    Column.text('created_at'),
    Column.integer('extended_retention'),
  ]),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
]);
