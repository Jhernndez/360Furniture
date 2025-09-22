import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  // ✅ Credenciales estáticas para pruebas
  static const String supabaseUrl =
      'https://zsebtdmjdvzadsxmftxm.supabase.co'; // Reemplaza con tu URL real
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzZWJ0ZG1qZHZ6YWRzeG1mdHhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNDM4NTYsImV4cCI6MjA3MzgxOTg1Nn0.6UU1QL5VN_rsGXAy3V8tfojO48lhXbqaTiL6dwVelNU'; // Reemplaza con tu anon key real

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
