import 'package:flutter/material.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/provider/User%20provider.dart';
import 'package:health_fit_strong/provider/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser ?? authProvider.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.photoUrl != null
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(user.name, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                _buildMenuItem(context, Icons.edit, 'Edit Profile', () => context.push('/edit-profile')),
                _buildMenuItem(context, Icons.calendar_today, 'My Bookings', () => context.push('/calendar')),
                _buildMenuItem(context, Icons.favorite, 'Favorites', () {}),
                _buildMenuItem(context, Icons.payment, 'Payment Methods', () {}),
                _buildMenuItem(context, Icons.settings, 'Settings', () {}),
                _buildMenuItem(context, Icons.help, 'Help & Support', () {}),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}