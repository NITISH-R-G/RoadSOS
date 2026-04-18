import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:powersync/powersync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'schema.dart';

class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient db;

  SupabaseConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = db.auth.currentSession;
    if (session == null) {
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
    } catch (e) {
      print('Upload error: $e');
    }
  }
}

late PowerSyncDatabase appDb;
bool _dbInitialized = false;

Future<void> initializeDatabase() async {
  if (kIsWeb) {
    // PowerSync with SQLite doesn't work on web — skip DB init.
    // The app will still render; DB operations will be no-ops.
    print('[Database] Running on Web — PowerSync/SQLite disabled.');
    _dbInitialized = false;
    return;
  }

  try {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'roadsos.sqlite');

    appDb = PowerSyncDatabase(schema: schema, path: path);
    await appDb.initialize();

    // To connect to the cloud, you need to configure Supabase and the connector:
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
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
      }

      appDb.connect(connector: SupabaseConnector(Supabase.instance.client));
    } else {
      print('[Database] Missing Supabase credentials in .env. Running entirely offline.');
    }
    _dbInitialized = true;
    print('[Database] PowerSync + Supabase initialized successfully.');
  } catch (e) {
    print('[Database] Initialization failed: $e');
    _dbInitialized = false;
  }
}

bool get isDatabaseInitialized => _dbInitialized;
