import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Fnysta', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.translate)),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          // User profile section
          ListTile(
            leading: const CircleAvatar(
              radius: 30,
              // You can replace this with an actual user image
              backgroundImage: AssetImage('assets/logoo.png'),
            ),
            title: const Text('Priyanshu Gupta',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('+91 9142542120'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to the detailed profile editing screen
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
          const Divider(height: 32),

          // Menu items
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            text: 'Notification',
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          SwitchListTile(
            secondary: Icon(isDarkMode ? Icons.nights_stay : Icons.wb_sunny),
            title: const Text('Dark Appearance'),
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.workspace_premium_outlined, // Crown Icon
            text: 'Subscriptions',
            trailingText: 'Free Plan',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.language_outlined, // Globe Icon
            text: 'Change Language',
            trailingText: 'English(US)',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.star_border, // Happy face icon
            text: 'Rate us',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.chat_bubble_outline, // Chat icon
            text: 'Contact us',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.check_circle_outline, // Checkmark icon
            text: 'Follow us',
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Account',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Show a delete confirmation dialog
            },
          )
        ],
      ),
    );
  }

  // Helper widget to build menu items consistently
  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String text,
      String? trailingText,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trailingText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
