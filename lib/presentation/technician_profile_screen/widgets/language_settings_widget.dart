import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LanguageSettingsWidget extends StatefulWidget {
  final VoidCallback? onChanged;

  const LanguageSettingsWidget({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  State<LanguageSettingsWidget> createState() => _LanguageSettingsWidgetState();
}

class _LanguageSettingsWidgetState extends State<LanguageSettingsWidget> {
  String _selectedLanguage = 'English';

  final List<LanguageOption> _languages = [
    LanguageOption(
      name: 'English',
      nativeName: 'English',
      code: 'en',
      flag: '🇺🇸',
    ),
    LanguageOption(
      name: 'Spanish',
      nativeName: 'Español',
      code: 'es',
      flag: '🇪🇸',
    ),
  ];

  void _selectLanguage(String language) {
    if (_selectedLanguage != language) {
      setState(() {
        _selectedLanguage = language;
      });
      widget.onChanged?.call();
      _showLanguageChangedSnackBar();
    }
  }

  void _showLanguageChangedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $_selectedLanguage'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Restart App',
          onPressed: () {
            // Simulate app restart for language change
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Restart the app to apply language changes'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language,
                    color: Colors.teal,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Language Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Choose your preferred language',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
            SizedBox(height: 2.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedLanguage == language.name;

                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryLight.withValues(alpha: 0.05)
                        : AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryLight.withValues(alpha: 0.3)
                          : AppTheme.borderSubtleLight,
                    ),
                  ),
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    value: language.name,
                    groupValue: _selectedLanguage,
                    onChanged: (String? value) {
                      if (value != null) {
                        _selectLanguage(value);
                      }
                    },
                    title: Row(
                      children: [
                        Text(
                          language.flag,
                          style: TextStyle(fontSize: 6.w),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              language.nativeName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    secondary: isSelected
                        ? Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: AppTheme.onPrimaryLight,
                              size: 4.w,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Changing the language will require restarting the app to take full effect.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningLight,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageOption {
  final String name;
  final String nativeName;
  final String code;
  final String flag;

  LanguageOption({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.flag,
  });
}
