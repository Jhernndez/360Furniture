import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  // ✅ Configuración directa para web y variables de entorno para desktop
  static String get supabaseUrl {
    const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    // Configuración directa para web
    return 'https://zsebtdmjdvzadsxmftxm.supabase.co';
  }

  static String get supabaseAnonKey {
    const envKey =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Configuración directa para web
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzZWJ0ZG1qZHZ6YWRzeG1mdHhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNDM4NTYsImV4cCI6MjA3MzgxOTg1Nn0.H8kqN1-C7wUzTyFxDwjgFUgn8OHw4WurRJLpJUWI4os';
  }

  // Inicializar Supabase - se llama desde main()
  static Future<void> initialize() async {
    print('🔧 Inicializando Supabase...');
    print('🔧 URL: ${supabaseUrl}');
    print('🔧 AnonKey: ${supabaseAnonKey.substring(0, 20)}...');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('✅ Supabase inicializado correctamente');
  }

  // Obtener cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Método para probar la conexión a Supabase haciendo una consulta simple
  Future<void> testConnection() async {
    try {
      print('🔧 Probando conexión a Supabase...');
      // Cambiar a una tabla que sabemos que existe
      final data = await client.from('user_profiles').select().limit(1);
      print('✅ Conexión a Supabase exitosa. Resultado: $data');
    } catch (e) {
      print('❌ Error al conectar con Supabase: $e');
    }
  }
}
