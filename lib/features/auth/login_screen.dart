import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_sections.dart';
import '../../app/app_state.dart';
import '../../core/models/restaurant_models.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  UserRole _selectedRole = UserRole.admin;
  bool _obscurePin = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _fillCredentials(UserRole role, String pin) {
    setState(() {
      _selectedRole = role;
      _pinController.text = pin;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final success = context.read<AppState>().login(
      _selectedRole,
      _pinController.text.trim(),
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto para el rol seleccionado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/Logo 02.jpg',
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.eco,
                            size: 96,
                            color: AppColors.forest,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Paso del Río',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.forest,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ECO HOTEL & RESTAURANTE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 28),
                        DropdownButtonFormField<UserRole>(
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Rol',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: UserRole.values
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.label),
                                ),
                              )
                              .toList(),
                          onChanged: (role) {
                            if (role == null) return;
                            setState(() => _selectedRole = role);
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'PIN',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePin
                                  ? 'Mostrar PIN'
                                  : 'Ocultar PIN',
                              onPressed: () {
                                setState(() => _obscurePin = !_obscurePin);
                              },
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese el PIN';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _submit,
                          icon: const Icon(Icons.login),
                          label: const Text('Ingresar'),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _AccessHint(
                              roleLabel: 'Admin',
                              pin: 'admin123',
                              role: UserRole.admin,
                              onTap: () => _fillCredentials(UserRole.admin, 'admin123'),
                            ),
                            _AccessHint(
                              roleLabel: 'Recepción',
                              pin: 'recep123',
                              role: UserRole.reception,
                              onTap: () => _fillCredentials(UserRole.reception, 'recep123'),
                            ),
                            _AccessHint(
                              roleLabel: 'Mesero',
                              pin: 'mesero123',
                              role: UserRole.waiter,
                              onTap: () => _fillCredentials(UserRole.waiter, 'mesero123'),
                            ),
                            _AccessHint(
                              roleLabel: 'Cocina',
                              pin: 'cocina123',
                              role: UserRole.kitchen,
                              onTap: () => _fillCredentials(UserRole.kitchen, 'cocina123'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Procesos disponibles en línea',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.forest,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...kAppSections.map(
                          (section) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(section.icon, color: AppColors.leaf),
                            title: Text(section.label),
                            subtitle: Text(section.summary),
                            trailing: const Text(
                              'Online',
                              style: TextStyle(
                                color: AppColors.leaf,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              context.read<AppState>().applyWebSlug(section.slug);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Al ingresar se abrirá ${section.label}.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessHint extends StatelessWidget {
  const _AccessHint({
    required this.roleLabel,
    required this.pin,
    required this.role,
    required this.onTap,
  });

  final String roleLabel;
  final String pin;
  final UserRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.touch_app_outlined, size: 16),
      label: Text('$roleLabel: $pin'),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }
}
