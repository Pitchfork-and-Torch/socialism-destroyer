import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../services/database_service.dart';
import '../services/knowledge_service.dart';
import '../services/local_storage_service.dart';
import '../themes/app_fonts.dart';
import 'local_env_stub.dart'
    if (dart.library.io) 'local_env_io.dart' as local_env;

/// Bootstrap state returned after all platform initialization completes.
class AppBootstrap {
  const AppBootstrap({required this.onboardingComplete});

  final bool onboardingComplete;
}

/// Centralized cold-start initialization for all platforms.
abstract final class AppInitializer {
  static bool _deferredSearchStarted = false;

  static Future<AppBootstrap> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppFonts.configure();

    await _initDatabaseFactory();
    await _loadEnvironment();
    await _initHive();

    if (kIsWeb) {
      scheduleDeferredSearchIndex();
    } else {
      await _initSearchIndex();
    }

    final onboardingComplete = await _readOnboardingFlag();

    return AppBootstrap(onboardingComplete: onboardingComplete);
  }

  /// Post-frame claim search index — safe to defer on web.
  static void scheduleDeferredSearchIndex() {
    if (!kIsWeb || _deferredSearchStarted) return;
    _deferredSearchStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initSearchIndex();
    });
  }

  static Future<void> _initDatabaseFactory() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<void> _loadEnvironment() async {
    // Prefer gitignored filesystem .env (local secrets; never a Flutter asset).
    // Fall back to bundled .env.example so CI/web/offline still boot.
    try {
      final contents = await local_env.readLocalEnvFile();
      if (contents != null && contents.trim().isNotEmpty) {
        dotenv.testLoad(fileInput: contents);
        return;
      }
    } catch (_) {
      // Fall through to bundled example.
    }
    try {
      await dotenv.load(fileName: '.env.example');
    } catch (_) {
      // Optional — app runs offline with bundled assets.
    }
  }

  static Future<void> _initHive() async {
    await Hive.initFlutter();
    await LocalStorageService().init();
  }

  static Future<void> _initSearchIndex() async {
    final claims = await KnowledgeService().getClaims();
    await DatabaseService.instance.init(claims);
  }

  static Future<bool> _readOnboardingFlag() async {
    return isOnboardingComplete();
  }

  /// Live onboarding flag — used by routing so completion is not stale.
  static bool isOnboardingComplete() {
    if (!Hive.isBoxOpen(LocalStorageService.settingsBox)) return false;
    final box = Hive.box(LocalStorageService.settingsBox);
    return box.get('onboarding_complete', defaultValue: false) as bool;
  }

  static Future<void> markOnboardingComplete() async {
    final box = Hive.box(LocalStorageService.settingsBox);
    await box.put('onboarding_complete', true);
  }
}