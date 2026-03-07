import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLogin = true;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const LogoWidget(size: 200, showText: true),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _isLogin ? 'Welcome Back' : 'Create Your Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Error Banner
              Consumer<AuthService>(
                builder: (context, authService, _) {
                  if (authService.errorMessage != null) {
                    return Column(
                      children: [
                        ErrorBanner(
                          message: authService.errorMessage!,
                          onDismiss: () {
                            authService.clearErrorMessage();
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Form Fields
              if (_isLogin)
                _buildLoginForm()
              else
                _buildRegisterForm(),

              const SizedBox(height: AppSpacing.lg),

              // Login/Register Button
              Consumer<AuthService>(
                builder: (context, authService, _) {
                  return ElevatedButton(
                    onPressed: authService.isLoading ? null : _handleSubmit,
                    child: authService.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_isLogin ? 'Login' : 'Register'),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Toggle Login/Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                      context.read<AuthService>().clearErrorMessage();
                    },
                    child: Text(
                      _isLogin ? 'Register' : 'Login',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Demo Credentials
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Credentials:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryColor,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Username: demo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Password: demo123',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        TextField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Choose a username',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    final authService = context.read<AuthService>();

    if (_isLogin) {
      authService.login(
        _usernameController.text,
        _passwordController.text,
      );
    } else {
      authService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _firstNameController.text,
        _lastNameController.text,
      );
    }
  }
}
