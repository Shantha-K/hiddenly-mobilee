import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB2F4FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildTile(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'Change your profile details',
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.settings_outlined,
              title: 'Accounts',
              subtitle: 'Privacy, security, change number',
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Change your notification settings',
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Help center, contact us, privacy policy',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}