import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoWidget extends StatelessWidget {
  final String currentLanguage;

  const AppLogoWidget({
    Key? key,
    required this.currentLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        SizedBox(height: 2.h),
        _buildAppName(),
        SizedBox(height: 1.h),
        _buildTagline(),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40.w,
      height: 40.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: Image.asset(
          'assets/images/logo.png', // ← Ajusta si tu logo está en otra ruta
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      '360 App',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTagline() {
    final tagline = currentLanguage == 'ES'
        ? 'Registro de Servicios'
        : 'Registred Services';

    return Text(
      tagline,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.25,
      ),
      textAlign: TextAlign.center,
    );
  }
}
