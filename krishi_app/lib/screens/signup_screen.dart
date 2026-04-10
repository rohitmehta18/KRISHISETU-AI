import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/section_header.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _landCtrl = TextEditingController();

  String? _farmerType, _farmingType, _waterSource, _irrigationType, _language;
  bool _usesPesticides = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  final List<String> _allCrops = [
    'Wheat', 'Rice', 'Maize', 'Cotton', 'Sugarcane',
    'Soybean', 'Groundnut', 'Vegetables', 'Fruits', 'Pulses',
  ];
  final Set<String> _selectedCrops = {};

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _ageCtrl.dispose(); _regionCtrl.dispose(); _landCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      final result = await AuthService.signup({
        'name':           _nameCtrl.text.trim(),
        'email':          _emailCtrl.text.trim(),
        'password':       _passCtrl.text,
        'age':            _ageCtrl.text.trim(),
        'region':         _regionCtrl.text.trim(),
        'farmerType':     _farmerType,
        'landSize':       _landCtrl.text.trim(),
        'farmingType':    _farmingType,
        'crops':          _selectedCrops.toList(),
        'waterSource':    _waterSource,
        'irrigationType': _irrigationType,
        'usesPesticides': _usesPesticides,
        'language':       _language,
      });
      if (!mounted) return;
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, a, __) => DashboardScreen(username: result.name),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Could not connect to server'; _loading = false; });
    }
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: TextStyle(color: AppColors.textPrimary(context), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: validator ?? (v) => (v?.isEmpty ?? true) ? 'Required' : null,
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final primary = AppColors.primary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: isDark ? const Color(0xFF0D2016) : Colors.white,
      style: TextStyle(color: AppColors.textPrimary(context), fontSize: 15),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSub(context)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: AppColors.bgGradient(context)),
          ),

          Positioned(top: -60, right: -60,
            child: Container(width: 220, height: 220,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [primary.withOpacity(0.07), Colors.transparent])))),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSub(context), size: 20),
                          ),
                          const SizedBox(width: 4),
                          Text('Create Account', style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          )),
                          const Spacer(),
                          const ThemeToggleButton(),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            const SizedBox(height: 4),

                            SectionHeader(title: 'Farmer Profile', icon: Icons.person_outline_rounded),
                            GlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                              _field(ctrl: _nameCtrl, label: 'Full Name', icon: Icons.badge_outlined),
                              const SizedBox(height: 14),
                              _field(ctrl: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                                type: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v?.isEmpty ?? true) return 'Required';
                                  if (!v!.contains('@')) return 'Enter valid email';
                                  return null;
                                }),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 15),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: AppColors.textSub(context), size: 20),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v?.isEmpty ?? true) return 'Required';
                                  if (v!.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _field(ctrl: _ageCtrl, label: 'Age', icon: Icons.cake_outlined,
                                type: TextInputType.number,
                                validator: (v) {
                                  if (v?.isEmpty ?? true) return 'Required';
                                  if (int.tryParse(v!) == null) return 'Enter valid age';
                                  return null;
                                }),
                              const SizedBox(height: 14),
                              _field(ctrl: _regionCtrl, label: 'Region / Location', icon: Icons.location_on_outlined),
                            ])),

                            const SizedBox(height: 22),

                            SectionHeader(title: 'Farming Details', icon: Icons.agriculture_outlined),
                            GlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                              _dropdown(label: 'Type of Farmer', icon: Icons.people_outline_rounded,
                                items: ['Small', 'Medium', 'Large'], value: _farmerType,
                                onChanged: (v) => setState(() => _farmerType = v)),
                              const SizedBox(height: 14),
                              _field(ctrl: _landCtrl, label: 'Land Size (acres)', icon: Icons.landscape_outlined,
                                type: TextInputType.number),
                              const SizedBox(height: 14),
                              _dropdown(label: 'Type of Farming', icon: Icons.eco_outlined,
                                items: ['Organic', 'Traditional', 'Mixed'], value: _farmingType,
                                onChanged: (v) => setState(() => _farmingType = v)),
                            ])),

                            const SizedBox(height: 18),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text('Crops Grown', style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textSub(context), fontWeight: FontWeight.w600)),
                            ),

                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: _allCrops.map((crop) {
                                final sel = _selectedCrops.contains(crop);
                                return GestureDetector(
                                  onTap: () => setState(() => sel ? _selectedCrops.remove(crop) : _selectedCrops.add(crop)),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: sel ? AppColors.primary(context).withOpacity(0.15) : AppColors.surface(context).withOpacity(0.5),
                                      border: Border.all(
                                        color: sel ? AppColors.primary(context) : AppColors.primary(context).withOpacity(0.2),
                                        width: sel ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(crop, style: TextStyle(
                                      color: sel ? AppColors.primary(context) : AppColors.textSub(context),
                                      fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                    )),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 22),

                            SectionHeader(title: 'Water & Irrigation', icon: Icons.water_drop_outlined),
                            GlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                              _dropdown(label: 'Water Source', icon: Icons.water_outlined,
                                items: ['Borewell', 'Canal', 'Rain', 'Others'], value: _waterSource,
                                onChanged: (v) => setState(() => _waterSource = v)),
                              const SizedBox(height: 14),
                              _dropdown(label: 'Irrigation Type', icon: Icons.shower_outlined,
                                items: ['Sprinkler', 'Drip', 'Manual'], value: _irrigationType,
                                onChanged: (v) => setState(() => _irrigationType = v)),
                            ])),

                            const SizedBox(height: 22),

                            SectionHeader(title: 'Farming Preferences', icon: Icons.tune_rounded),
                            GlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary(context).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.science_outlined, color: AppColors.primary(context), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Uses Pesticides', style: TextStyle(
                                    color: AppColors.textPrimary(context), fontSize: 14, fontWeight: FontWeight.w500)),
                                  Text(_usesPesticides ? 'Yes' : 'No', style: TextStyle(
                                    color: AppColors.textSub(context).withOpacity(0.7), fontSize: 12)),
                                ])),
                                Switch(
                                  value: _usesPesticides,
                                  onChanged: (v) => setState(() => _usesPesticides = v),
                                  activeColor: AppColors.primary(context),
                                  activeTrackColor: AppColors.primary(context).withOpacity(0.3),
                                ),
                              ]),
                              Divider(height: 24, color: AppColors.primary(context).withOpacity(0.1)),
                              _dropdown(label: 'Preferred Language', icon: Icons.language_outlined,
                                items: ['English', 'Hindi', 'Marathi', 'Punjabi', 'Telugu', 'Tamil', 'Kannada', 'Bengali'],
                                value: _language, onChanged: (v) => setState(() => _language = v)),
                            ])),

                            const SizedBox(height: 32),

                            // Error banner
                            if (_error != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF5350).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEF5350).withOpacity(0.4)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF5350), size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_error!,
                                    style: const TextStyle(color: Color(0xFFEF5350), fontSize: 13))),
                                ]),
                              ),
                              const SizedBox(height: 16),
                            ],

                            GlowingButton(
                              label: _loading ? 'Creating Account...' : 'Create Account',
                              icon: Icons.check_circle_outline_rounded,
                              onTap: _loading ? () {} : _createAccount,
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
