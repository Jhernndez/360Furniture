import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/app_logo_widget.dart';
import './widgets/language_toggle_widget.dart';
import './widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _currentLanguage = 'ES';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildBody(),
                  SizedBox(height: 2.h),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          LanguageToggleWidget(
            currentLanguage: _currentLanguage,
            onLanguageChanged: _handleLanguageChange,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 4.h),
        AppLogoWidget(currentLanguage: _currentLanguage),
        SizedBox(height: 6.h),
        _buildLoginCard(),
        SizedBox(height: 3.h),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 90.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeText(),
            SizedBox(height: 4.h),
            LoginFormWidget(
              currentLanguage: _currentLanguage,
              onLogin: _handleLogin,
              isLoading: _isLoading,
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 2.h),
              _buildErrorMessage(),
            ],
            SizedBox(height: 3.h),
            _buildForgotPasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    final forgotPasswordText = _currentLanguage == 'ES'
        ? '¿Olvidaste tu contraseña?'
        : 'Forgot your password?';

    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          forgotPasswordText,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    final welcomeText =
        _currentLanguage == 'ES' ? 'Bienvenido de vuelta' : 'Welcome back';
    final subtitleText = _currentLanguage == 'ES'
        ? 'Ingresa tus credenciales para continuar'
        : 'Enter your credentials to continue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          welcomeText,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          subtitleText,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(1.w),
          ),
          child: Text(
            password,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.secondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final footerText = _currentLanguage == 'ES'
        ? '© 2025 IT DATA SAS. Todos los derechos reservados.'
        : '© 2025 IT DATA SAS. All rights reserved.';

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        footerText,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleLanguageChange(String language) {
    setState(() {
      _currentLanguage = language;
      _errorMessage = null; // Clear error when language changes
    });
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.instance.signIn(email, password);

      if (response.user != null) {
        // Success - provide haptic feedback
        HapticFeedback.lightImpact();

        // Get user profile to determine navigation route
        final profile = await AuthService.instance.getCurrentUserProfile();
        final role = profile?['role'] ?? 'technician';

        String route = '/order-dashboard'; // default route
        if (role == 'admin') {
          route = '/admin-dashboard';
        } else if (role == 'technician') {
          route = '/order-dashboard';
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        throw Exception('Authentication failed');
      }
    } catch (error) {
      // Failed login
      HapticFeedback.vibrate();

      final errorText = _currentLanguage == 'ES'
          ? 'Credenciales incorrectas. Verifique su email y contraseña.'
          : 'Invalid credentials. Please check your email and password.';

      setState(() {
        _errorMessage = errorText;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    final resetPasswordText =
        _currentLanguage == 'ES' ? 'Restablecer Contraseña' : 'Reset Password';
    final emailHintText =
        _currentLanguage == 'ES' ? 'Ingrese su email' : 'Enter your email';
    final sendLinkText =
        _currentLanguage == 'ES' ? 'Enviar Enlace' : 'Send Link';
    final cancelText = _currentLanguage == 'ES' ? 'Cancelar' : 'Cancel';
    final instructionText = _currentLanguage == 'ES'
        ? 'Ingrese su email y le enviaremos un enlace para restablecer su contraseña.'
        : 'Enter your email and we\'ll send you a link to reset your password.';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(resetPasswordText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                instructionText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 3.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: emailHintText,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              if (errorMessage != null) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();

                      if (email.isEmpty || !email.contains('@')) {
                        setState(() {
                          errorMessage = _currentLanguage == 'ES'
                              ? 'Por favor ingrese un email válido'
                              : 'Please enter a valid email address';
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        await AuthService.instance.resetPassword(email);
                        Navigator.pop(context);

                        final successMessage = _currentLanguage == 'ES'
                            ? 'Se ha enviado un enlace de restablecimiento a su email'
                            : 'Password reset link has been sent to your email';

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(successMessage),
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = _currentLanguage == 'ES'
                              ? 'Error al enviar el enlace. Verifique su email.'
                              : 'Failed to send reset link. Please check your email.';
                        });
                      }
                    },
              child: isLoading
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(sendLinkText),
            ),
          ],
        ),
      ),
    );
  }
}
