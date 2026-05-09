import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:powersync/powersync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
<<<<<<< HEAD
import 'schema.dart';

=======
import '../logging/app_log.dart';
import '../services/government_facility_seed_service.dart';
import 'schema.dart';

/// True after [bootstrapSupabaseAuth] successfully calls [Supabase.initialize].
bool _supabaseSdkInitialized = false;

bool get isSupabaseSdkInitialized => _supabaseSdkInitialized;

/// Initializes Supabase and anonymous auth **at app launch** (before [initializeDatabase]).
/// Requires [dotenv.load] first. Safe no-op when URL/key missing or on web.
Future<void> bootstrapSupabaseAuth() async {
  if (kIsWeb) return;

  final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
  if (url.isEmpty || anonKey.isEmpty) {
    _supabaseSdkInitialized = false;
    appLog.w(
      'Supabase bootstrap skipped — set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or local .env',
    );
    return;
  }

  try {
    await Supabase.initialize(url: url, anonKey: anonKey);
    await ensureSupabaseAnonymousSession(Supabase.instance.client);
    _supabaseSdkInitialized = true;
    appLog.i('Supabase anonymous sign-in completed.');
  } catch (e, st) {
    _supabaseSdkInitialized = false;
    appLog.e('Supabase bootstrap failed', error: e, stackTrace: st);
  }
}

/// Ensures a JWT exists for PowerSync ([fetchCredentials]). Call after [Supabase.initialize].
Future<void> ensureSupabaseAnonymousSession(SupabaseClient client) async {
  try {
    final existing = client.auth.currentSession;
    if (existing != null && !existing.isExpired) {
      return;
    }
    if (existing != null) {
      try {
        await client.auth.refreshSession();
        final after = client.auth.currentSession;
        if (after != null && !after.isExpired) {
          return;
        }
      } catch (e, st) {
        appLog.w('Session refresh failed; re-authenticating', error: e, stackTrace: st);
      }
    }
    await client.auth.signInAnonymously();
  } catch (e, st) {
    appLog.w('Anonymous auth failed', error: e, stackTrace: st);
  }
}

>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient db;

  SupabaseConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
<<<<<<< HEAD
    final session = db.auth.currentSession;
    if (session == null) {
=======
    await ensureSupabaseAnonymousSession(db);
    final session = db.auth.currentSession;
    if (session == null) {
      appLog.w(
        'PowerSync fetchCredentials: no session — enable Anonymous sign-ins in Supabase '
        'or check SUPABASE_URL / SUPABASE_ANON_KEY',
      );
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      return null;
    }
    return PowerSyncCredentials(
      endpoint: dotenv.env['POWERSYNC_URL'] ?? '',
      token: session.accessToken,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }

    try {
      for (var op in transaction.crud) {
        if (op.op == UpdateType.put) {
          await db.from(op.table).upsert(op.opData!);
        } else if (op.op == UpdateType.patch) {
          await db.from(op.table).update(op.opData!).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          await db.from(op.table).delete().eq('id', op.id);
        }
      }
      await transaction.complete();
<<<<<<< HEAD
    } catch (e) {
      print('Upload error: $e');
=======
    } catch (e, st) {
      appLog.e('PowerSync upload error', error: e, stackTrace: st);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    }
  }
}

late PowerSyncDatabase appDb;
bool _dbInitialized = false;

Future<void> initializeDatabase() async {
  if (kIsWeb) {
<<<<<<< HEAD
    // PowerSync with SQLite doesn't work on web — skip DB init.
    // The app will still render; DB operations will be no-ops.
    print('[Database] Running on Web — PowerSync/SQLite disabled.');
=======
    appLog.i('Running on Web — PowerSync/SQLite disabled.');
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    _dbInitialized = false;
    return;
  }

  try {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'roadsos.sqlite');

    appDb = PowerSyncDatabase(schema: schema, path: path);
    await appDb.initialize();
<<<<<<< HEAD

    // To connect to the cloud, you need to configure Supabase and the connector:
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    // Authenticate anonymously so PowerSync has a token
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        await Supabase.instance.client.auth.signInAnonymously();
      }
    } catch (authError) {
      print('[Database] Anonymous auth failed: $authError');
      // If auth fails, we should ideally not throw, but continue in offline mode.
=======
    await GovernmentFacilitySeedService().importBundledSeedIfNeeded(appDb);

    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      appLog.w(
        'SUPABASE_URL / SUPABASE_ANON_KEY missing — local SQLite only. '
        'Set credentials via --dart-define or local .env (not in Dart source) and enable RLS in Supabase.',
      );
      _dbInitialized = true;
      return;
    }

    if (!_supabaseSdkInitialized) {
      appLog.e(
        'PowerSync aborted — call [bootstrapSupabaseAuth] in main() before '
        '[initializeDatabase] when Supabase credentials are set.',
      );
      _dbInitialized = true;
      return;
    }

    await ensureSupabaseAnonymousSession(Supabase.instance.client);
    if (Supabase.instance.client.auth.currentSession == null) {
      appLog.w(
        'No Supabase session — enable Anonymous provider in Supabase '
        'and check URL/anon key. PowerSync will not sync until auth succeeds.',
      );
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    }

    appDb.connect(connector: SupabaseConnector(Supabase.instance.client));
    _dbInitialized = true;
<<<<<<< HEAD
    print('[Database] PowerSync + Supabase initialized successfully.');
  } catch (e) {
    print('[Database] Initialization failed: $e');
=======
    appLog.i('PowerSync + Supabase initialized.');
  } catch (e, st) {
    appLog.e('Database initialization failed', error: e, stackTrace: st);
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
    _dbInitialized = false;
  }
}

bool get isDatabaseInitialized => _dbInitialized;
