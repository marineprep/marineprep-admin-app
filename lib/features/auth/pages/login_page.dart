import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo and Title
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.ship,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your Marine Prep Admin account',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.gray600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Iconsax.sms),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Email is required',
                          ),
                          FormBuilderValidators.email(
                            errorText: 'Please enter a valid email',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      FormBuilderTextField(
                        name: 'password',
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Iconsax.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Password is required',
                          ),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: 'Password must be at least 6 characters',
                          ),
                        ]),
                      ),
                      // const SizedBox(height: 8),

                      // // Forgot Password Link
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () => _showForgotPasswordDialog(context),
                      //     child: const Text('Forgot Password?'),
                      //   ),
                      // ),
                      const SizedBox(height: 24),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      // Row(
                      //   children: [
                      //     Expanded(child: Divider(color: AppColors.gray300)),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         'OR',
                      //         style: TextStyle(color: AppColors.gray500),
                      //       ),
                      //     ),
                      //     Expanded(child: Divider(color: AppColors.gray300)),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),

                      // // Sign Up Link
                      // OutlinedButton(
                      //   onPressed: () => context.go('/auth/signup'),
                      //   style: OutlinedButton.styleFrom(
                      //     padding: const EdgeInsets.symmetric(vertical: 16),
                      //   ),
                      //   child: const Text(
                      //     'Create Account',
                      //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final email = formData['email'] as String;
      final password = formData['password'] as String;

      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(authNotifierProvider.notifier)
            .signIn(email: email, password: password);

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign in failed: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.of(context).pop();
                try {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .resetPassword(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to send reset email: ${e.toString()}',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
