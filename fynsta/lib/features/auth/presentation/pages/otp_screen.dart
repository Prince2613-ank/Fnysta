import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../../theme/dnd_toggle.dart';
import '../../../../theme/theme_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OTPScreen extends StatelessWidget {
  final String email;
  const OTPScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        sendOtp: SendOtp(
          AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSourceImpl(client: http.Client()),
          ),
        ),
        verifyOtp: VerifyOtp(
          AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSourceImpl(client: http.Client()),
          ),
        ),
      ),
      child: _OTPScreenView(email: email),
    );
  }
}

class _OTPScreenView extends StatefulWidget {
  final String email;
  const _OTPScreenView({required this.email});

  @override
  State<_OTPScreenView> createState() => _OTPScreenViewState();
}

class _OTPScreenViewState extends State<_OTPScreenView> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
          fontSize: 22,
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.grey.shade800
            : const Color.fromARGB(255, 147, 146, 146),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [DndToggle()],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedIn) {
            // TODO: Store the token securely (e.g., using flutter_secure_storage)
            print('Authentication successful! Token: ${state.token}');
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/logoo.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'OTP Verification',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'An 4 digit code has been sent to your number',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 16),
              ),
              const SizedBox(height: 60),
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6, // API is expecting a 6-digit OTP
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: const Color(0xFFFFC107)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final otp = _otpController.text.trim();
                        if (otp.length == 6) {
                          context.read<AuthBloc>().add(
                              VerifyOtpEvent(email: widget.email, otp: otp));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Verify OTP',
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
                  text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 14),
                      children: [
                        const TextSpan(text: "If you din't receive a code? "),
                        TextSpan(
                            text: "Resend",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold))
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
