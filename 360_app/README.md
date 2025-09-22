# 360 APP Web

Este proyecto Flutter web permite probar la conexión a Supabase y está listo para desplegar en Netlify.

## Configuración

- Las credenciales de Supabase están en `lib/main.dart`.
- Modifica la tabla de prueba en el widget si lo necesitas.

## Uso

1. Instala dependencias:
   flutter pub get
2. Ejecuta en local:
   flutter run -d chrome
3. Para producción, compila:
   flutter build web

## Despliegue en Netlify

- Sube la carpeta `/build/web` como sitio estático.

---

Este proyecto es solo para web y muestra el resultado de la conexión a Supabase en pantalla.
