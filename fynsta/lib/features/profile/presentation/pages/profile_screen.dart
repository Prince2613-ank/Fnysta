import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fynsta/features/user/data/datasources/user_remote_data_source.dart';
import 'package:fynsta/features/user/data/repositories/user_repository_impl.dart';
import 'package:fynsta/features/user/domain/usecases/get_user.dart';
import 'package:fynsta/features/user/presentation/bloc/user_bloc.dart';
import '../../../../theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide UserBloc to this screen
    return BlocProvider(
      create: (context) => UserBloc(
        getUser: GetUser(
          UserRepositoryImpl(
            remoteDataSource: UserRemoteDataSourceImpl(client: http.Client()),
          ),
        ),
      ),
      child: const _ProfileScreenView(),
    );
  }
}

class _ProfileScreenView extends StatefulWidget {
  const _ProfileScreenView();

  @override
  State<_ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends State<_ProfileScreenView> {
  // Hardcoding the email for fetching. In a real app, this would come from a login state.
  final String _userEmail = "iamsurajtiwari1909@gmail.com";

  @override
  void initState() {
    super.initState();
    // Fetch the user data when the screen loads
    context.read<UserBloc>().add(FetchUserEvent(email: _userEmail));
  }

  void _refreshUserData() {
    context.read<UserBloc>().add(FetchUserEvent(email: _userEmail));
  }

  // Method to show the confirmation dialog for account deletion
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // First, dismiss the dialog
                Navigator.of(dialogContext).pop();
                // Then, navigate to the login screen and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

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
          // ⭐ User profile section is now built by BlocBuilder
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: state.user.profilePic != null
                        ? NetworkImage(state.user.profilePic!)
                        : const AssetImage('assets/logoo.png') as ImageProvider,
                  ),
                  title: Text(state.user.username ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(state.user.phoneNumber ?? 'No phone number'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    // Navigate to edit screen and wait for a result
                    final result =
                        await Navigator.pushNamed(context, '/edit_profile');
                    // If the result is true, it means the profile was updated
                    if (result == true) {
                      _refreshUserData();
                    }
                  },
                );
              } else if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UserError) {
                return Center(
                    child: Text('Failed to load user: ${state.message}'));
              }
              // Initial State
              return const ListTile(
                leading: CircleAvatar(radius: 30),
                title: Text('Loading...'),
              );
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
              // Show a delete confirmation dialog
              _showDeleteConfirmationDialog(context);
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
