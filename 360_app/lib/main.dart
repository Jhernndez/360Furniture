import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zsebtdmjdvzadsxmftxm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzZWJ0ZG1qZHZ6YWRzeG1mdHhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNDM4NTYsImV4cCI6MjA3MzgxOTg1Nn0.6UU1QL5VN_rsGXAy3V8tfojO48lhXbqaTiL6dwVelNU',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '360 APP Web',
      home: const SupabaseTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({Key? key}) : super(key: key);

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .limit(1);
      setState(() {
        _result = 'Conexión exitosa. Resultado: ' + data.toString();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error al conectar con Supabase: ' + e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Supabase')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text(_result ?? '', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
