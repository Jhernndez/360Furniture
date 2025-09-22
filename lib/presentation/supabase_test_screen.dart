import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

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
      final data =
          await SupabaseService.instance.client.from('users').select().limit(1);
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
