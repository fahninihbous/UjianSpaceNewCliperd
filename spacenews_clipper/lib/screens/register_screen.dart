import 'package:flutter/material.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/space_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await AuthService().register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRouting.main, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi gagal! Email mungkin sudah dipakai.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SpaceTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: SpaceTheme.borderSubtle),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.rocket_launch, size: 46, color: SpaceTheme.accentAmber),
                      SizedBox(height: 10),
                      Text(
                        'Gabung ke SpaceNews Clipper',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Simpan artikel antariksa & kelola kategori misi pribadimu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: SpaceTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline, color: SpaceTheme.accentAmber),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
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
                    labelText: 'Password (min 6 karakter)',
                    prefixIcon: const Icon(Icons.lock_outline, color: SpaceTheme.accentAmber),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: SpaceTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: SpaceTheme.accentAmber))
                    : ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text('DAFTAR'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}