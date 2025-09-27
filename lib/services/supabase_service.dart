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
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;
    
    // Configuración directa para web
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzZWJ0ZG1qZHZ6YWRzeG1mdHhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNDM4NTYsImV4cCI6MjA3MzgxOTg1Nn0.H8kqN1-C7wUzTyFxDwjgFUgn8OHw4WurRJLpJUWI4os';
  }

  // Inicializar Supabase - se llama desde main()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Obtener cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Método para probar la conexión a Supabase haciendo una consulta simple
  Future<void> testConnection() async {
    try {
      // Cambia 'users' por el nombre de una tabla existente en tu proyecto
      final data = await client.from('users').select().limit(1);
      print('Conexión a Supabase exitosa. Resultado: $data');
    } catch (e) {
      print('Excepción al conectar con Supabase: $e');
    }
  }
}
