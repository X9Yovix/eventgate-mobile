import 'package:eventgate_flutter/model/user.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventgate_flutter/controller/auth.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final AuthController _authController = AuthController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _registerFormKey = GlobalKey<FormState>();
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _register(context) async {
    if (_registerFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = User(
        id: 0,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );
      final password = _passwordController.text.trim();

      try {
        await _authController.register(user, password);
        if (_authController.getMessage() != null) {
          AppUtils.showToast(context, _authController.getMessage()!, 'success');
          _clearForm();
          AppUtils.navigateWithFade(context, const AuthScreen());
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

  void _clearForm() {
    _registerFormKey.currentState!.reset();
    _usernameController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Form(
          key: _registerFormKey,
          child: Column(
            children: [
              Image.asset(
                'assets/images/register.png',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: 300,
                  child: TextFormField(
                    enabled: !_isLoading,
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a first name';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 20),
              SizedBox(
                  width: 300,
                  child: TextFormField(
                    enabled: !_isLoading,
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a last name';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 20),
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
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: 300,
                  child: TextFormField(
                    enabled: !_isLoading,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || !emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
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
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _register(context),
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
                    : const Icon(Icons.how_to_reg_outlined),
                label: Text(_isLoading ? 'Registering...' : 'Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 44, 2, 51),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
