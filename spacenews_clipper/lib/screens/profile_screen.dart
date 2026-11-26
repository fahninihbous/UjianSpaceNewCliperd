import 'package:flutter/material.dart';
import '../constants/api_constant.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/space_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Tentang Aplikasi')),
      body: FutureBuilder<dynamic>(
        future: AuthService().getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: SpaceTheme.accentAmber));
          }
          final user = snapshot.data ?? {'name': '-', 'email': '-'};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SpaceTheme.accentAmber, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: SpaceTheme.surfaceCard,
                      child: Icon(Icons.person, size: 42, color: SpaceTheme.accentAmber),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    title: Text(
                      user['name']?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    subtitle: Text(
                      user['email']?.toString() ?? '-',
                      style: const TextStyle(color: SpaceTheme.textMuted),
                    ),
                    leading: const Icon(Icons.verified_user, color: SpaceTheme.accentCyan),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Identitas Pembuat Aplikasi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SpaceTheme.accentAmber),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      // GANTI DENGAN NAMA KAMU SENDIRI
                      const ListTile(
                        leading: Icon(Icons.badge_outlined, color: SpaceTheme.textMuted),
                        title: Text('Nama Siswa', style: TextStyle(color: SpaceTheme.textMuted, fontSize: 12)),
                        subtitle: Text('Muhammad Defahni Putra Salamudin', style: TextStyle(color: Colors.white)),
                      ),
                      const Divider(height: 1, color: SpaceTheme.borderSubtle),
                      const ListTile(
                        leading: Icon(Icons.school_outlined, color: SpaceTheme.textMuted),
                        title: Text('Kelas / No. Absen', style: TextStyle(color: SpaceTheme.textMuted, fontSize: 12)),
                        subtitle: Text('XII RPL 2 / Absen 21', style: TextStyle(color: Colors.white)),
                      ),
                      const Divider(height: 1, color: SpaceTheme.borderSubtle),
                      const ListTile(
                        leading: Icon(Icons.rocket_outlined, color: SpaceTheme.textMuted),
                        title: Text('Tema Proyek', style: TextStyle(color: SpaceTheme.textMuted, fontSize: 12)),
                        subtitle: Text('SpaceNews Clipper', style: TextStyle(color: Colors.white)),
                      ),
                      const Divider(height: 1, color: SpaceTheme.borderSubtle),
                      ListTile(
                        leading: const Icon(Icons.api, color: SpaceTheme.textMuted),
                        title: const Text('Sumber Public API', style: TextStyle(color: SpaceTheme.textMuted, fontSize: 12)),
                        subtitle: Text(ApiConstant.publicApiUrl, style: const TextStyle(color: SpaceTheme.accentCyan)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F1D1D),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('LOGOUT'),
                    onPressed: () async {
                      await AuthService().logout();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, AppRouting.login, (route) => false);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}