import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _loading        = false;
  String? _error;
  bool _success        = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; _success = false; });

    try {
      await AuthService.changePassword(
          _currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      setState(() { _success = true; _loading = false; });
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Could not connect to server'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textSub(context), size: 20),
                    ),
                    Text('Change Password',
                        style: GoogleFonts.inter(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context))),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Center(
                            child: Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkGreen : Colors.white,
                                border: Border.all(
                                    color: const Color(0xFFFFCA28).withOpacity(0.5)),
                                boxShadow: [BoxShadow(
                                    color: const Color(0xFFFFCA28).withOpacity(0.2),
                                    blurRadius: 20)],
                              ),
                              child: const Icon(Icons.lock_outline_rounded,
                                  color: Color(0xFFFFCA28), size: 32),
                            ),
                          ),
                          const SizedBox(height: 28),

                          GlassCard(
                            padding: const EdgeInsets.all(4),
                            child: Column(children: [
                              _passField(
                                ctrl: _currentCtrl,
                                label: 'Current Password',
                                obscure: _obscureCurrent,
                                onToggle: () => setState(
                                    () => _obscureCurrent = !_obscureCurrent),
                                validator: (v) =>
                                    (v?.isEmpty ?? true) ? 'Required' : null,
                              ),
                              Divider(height: 1,
                                  color: primary.withOpacity(0.1)),
                              _passField(
                                ctrl: _newCtrl,
                                label: 'New Password',
                                obscure: _obscureNew,
                                onToggle: () => setState(
                                    () => _obscureNew = !_obscureNew),
                                validator: (v) {
                                  if (v?.isEmpty ?? true) return 'Required';
                                  if (v!.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              ),
                              Divider(height: 1,
                                  color: primary.withOpacity(0.1)),
                              _passField(
                                ctrl: _confirmCtrl,
                                label: 'Confirm New Password',
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                                validator: (v) {
                                  if (v?.isEmpty ?? true) return 'Required';
                                  if (v != _newCtrl.text)
                                    return 'Passwords do not match';
                                  return null;
                                },
                              ),
                            ]),
                          ),

                          const SizedBox(height: 20),

                          // Error
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF5350).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFEF5350)
                                        .withOpacity(0.4)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFEF5350), size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!,
                                    style: const TextStyle(
                                        color: Color(0xFFEF5350),
                                        fontSize: 13))),
                              ]),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Success
                          if (_success) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF66BB6A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF66BB6A)
                                        .withOpacity(0.4)),
                              ),
                              child: const Row(children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    color: Color(0xFF66BB6A), size: 16),
                                SizedBox(width: 8),
                                Text('Password changed successfully!',
                                    style: TextStyle(
                                        color: Color(0xFF66BB6A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ),
                            const SizedBox(height: 16),
                          ],

                          GlowingButton(
                            label: _loading ? 'Updating...' : 'Update Password',
                            icon: Icons.check_rounded,
                            onTap: _loading ? () {} : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passField({
    required TextEditingController ctrl,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: AppColors.textPrimary(context)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
              color: AppColors.textSub(context), size: 20),
          onPressed: onToggle,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
      ),
      validator: validator,
    );
  }
}
