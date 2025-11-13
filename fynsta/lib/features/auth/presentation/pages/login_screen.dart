import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../theme/dnd_toggle.dart';
import '../../../../theme/theme_provider.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../../user/data/repositories/user_repository_impl.dart';
import '../../../user/domain/usecases/get_user.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../home/presentation/pages/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We provide the UserBloc here
    return BlocProvider(
      create: (context) => UserBloc(
        getUser: GetUser(
          UserRepositoryImpl(
            remoteDataSource: UserRemoteDataSourceImpl(client: http.Client()),
          ),
        ),
      ),
      child: const _LoginScreenView(),
    );
  }
}

// ⭐ FIX: Correctly defined _LoginScreenView as a StatefulWidget
class _LoginScreenView extends StatefulWidget {
  const _LoginScreenView();

  @override
  State<_LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          DndToggle(),
        ],
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: state.user),
              ),
              (route) => false,
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logoo.png',
                    height: 90,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Hi Welcome!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email to continue',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontSize: 16),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                          color: themeProvider.isDarkMode
                              ? Colors.grey.shade800
                              : const Color.fromARGB(255, 147, 144, 144),
                          thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Log in or Sign up',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.9),
                            fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                          color: themeProvider.isDarkMode
                              ? const Color.fromARGB(255, 147, 144, 144)
                              : const Color.fromARGB(255, 147, 144, 144),
                          thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final email = _emailController.text.trim();
                          if (email.isNotEmpty) {
                            context
                                .read<UserBloc>()
                                .add(FetchUserEvent(email: email));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('LOGIN',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 12,
                          height: 1.5),
                      children: [
                        const TextSpan(
                            text: 'By signing up, you agree to our '),
                        TextSpan(
                          text: 'Terms of Use',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
