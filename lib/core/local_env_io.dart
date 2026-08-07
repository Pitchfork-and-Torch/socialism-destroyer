import 'dart:io';

/// Read a gitignored `.env` from the project root when running on IO platforms.
Future<String?> readLocalEnvFile() async {
  final file = File('.env');
  if (await file.exists()) {
    return file.readAsString();
  }
  return null;
}
