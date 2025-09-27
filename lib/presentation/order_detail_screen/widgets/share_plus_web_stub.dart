// Stub implementation for share_plus on web
class Share {
  static Future<void> share(String text, {String? subject}) async {
    // En web, usar navigator.share si está disponible, si no mostrar mensaje
    print('Compartir: $text');
    // Implementación alternativa para web si se necesita
  }
}
