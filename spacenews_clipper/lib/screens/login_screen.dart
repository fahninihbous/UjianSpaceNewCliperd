import 'package:flutter/material.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/space_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await AuthService().login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouting.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal! Cek email & password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: SpaceTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SpaceTheme.borderSubtle),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.satellite_alt, size: 64, color: SpaceTheme.accentAmber),
                        SizedBox(height: 12),
                        Text(
                          'SpaceNews Clipper',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Masuk untuk menjelajah & mengarsipkan berita antariksa',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: SpaceTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: SpaceTheme.accentAmber),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: SpaceTheme.accentAmber),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass ? Icons.visibility_off : Icons.visibility,
                          color: SpaceTheme.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: SpaceTheme.accentAmber))
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text('LOGIN'),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRouting.register),
                    child: const Text(
                      'Belum punya akun? Daftar di sini',
                      style: TextStyle(color: SpaceTheme.accentCyan),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}