import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:eventgate_flutter/view/complete_profile_screen.dart';
import 'package:eventgate_flutter/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventgate_flutter/controller/auth.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthController _authController = AuthController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _login(context) async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final username = _usernameController.text;
      final password = _passwordController.text;
      try {
        await _authController.login(username, password);
        if (_authController.getMessage() != null) {
          AppUtils.showToast(context, _authController.getMessage()!, 'success');

          await Provider.of<AuthProvider>(context, listen: false).login(
              _authController.getUser(),
              _authController.getProfile(),
              _authController.getToken());

          debugPrint(
              '_authController.getProfile()!.isProfileComplete ${_authController.getProfile()!.isProfileComplete}');
          debugPrint(
              '_authController.getProfile()!.skipIsProfileComplete ${_authController.getProfile()!.skipIsProfileComplete}');
          if (_authController.getProfile()!.isProfileComplete == false &&
              _authController.getProfile()!.skipIsProfileComplete == false) {
            AppUtils.navigateWithSlideAndClearStack(
                context, const CompleteProfileScreen());
          } else {
            AppUtils.navigateWithSlideAndClearStack(
                context, const MainScreen());
          }
        }
        if (_authController.getError() != null) {
          AppUtils.showToast(context, _authController.getError()!, 'error');
        }
      } catch (error) {
        AppUtils.showToast(context, _authController.getError()!, 'error');
      } finally {
        setState(() {
          _isLoading = false;
        });
        _authController.setMessage(null);
        _authController.setError(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _loginFormKey,
        child: Column(
          children: [
            SizedBox(
                width: 300,
                child: TextFormField(
                  enabled: !_isLoading,
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.perm_identity_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                )),
            const SizedBox(height: 20),
            SizedBox(
                width: 300,
                child: TextFormField(
                  enabled: !_isLoading,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.password_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: _isPasswordVisible ? false : true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                )),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _login(context),
              iconAlignment: IconAlignment.start,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.login_outlined),
              label: Text(_isLoading ? 'Logging in...' : 'Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 44, 2, 51),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ));
  }
}
