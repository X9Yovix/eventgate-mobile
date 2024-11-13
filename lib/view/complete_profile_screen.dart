import 'package:eventgate_flutter/controller/auth.dart';
import 'package:eventgate_flutter/model/token.dart';
import 'package:eventgate_flutter/model/user.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final AuthController _authController = AuthController();

  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final _completeProfileFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _gender;
  File? _profileImage;

  DateTime _birthDateState =
      DateTime.now().subtract(const Duration(days: 365 * 18));

  String? _selectedCountryCode = '+216';

  @override
  void dispose() {
    _birthDateController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateState,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
        _birthDateState = picked.toLocal();
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _profileImage = File(result.files.single.path!);
      });
    }
  }

  void _skipCompleteProfile(AuthProvider value, context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      debugPrint('he: skin view');
      Token tokens = Token(
        access: value.token!.access,
        refresh: value.token!.refresh,
      );
      await _authController.skipCompleteProfile(tokens);
      debugPrint('he: after skin view');
      AppUtils.showToast(context, _authController.getMessage()!, 'success');
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

  void _completeProfile(context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_completeProfileFormKey.currentState!.validate()) {
        final birthDate = _birthDateController.text;
        final bio = _bioController.text;
        final fullPhoneNumber =
            '$_selectedCountryCode${_phoneNumberController.text}';

        Profile profile = Profile(
            birthDate: birthDate,
            bio: bio,
            phoneNumber: fullPhoneNumber,
            gender: _gender,
            profilePicture: null,
            isProfileComplete: true,
            skipIsProfileComplete: true);
        await _authController.completeProfile(profile, _profileImage);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Complete Profile'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Complete your profile to get started",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset(
                      "assets/images/complete_data.png",
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      semanticLabel: "Complete Profile Image",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _completeProfileFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _birthDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: const InputDecoration(
                            labelText: 'Birthday',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text("Gender:"),
                            Radio<String>(
                              value: 'male',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                            ),
                            const Text("Male"),
                            Radio<String>(
                              value: 'female',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                            ),
                            const Text("female"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        IntlPhoneField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          initialCountryCode: 'TN',
                          onCountryChanged: (country) {
                            // Update selected country code when changed
                            setState(() {
                              _selectedCountryCode = '+${country.dialCode}';
                            });
                          },
                          /* onChanged: (phone) {
                            
                          },
                           */
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _profileImage != null
                                ? Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.account_circle,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image_outlined),
                              label: const Text("Upload Profile Picture"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _completeProfile(context),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_isLoading ? 'Saving...' : 'Save'),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _skipCompleteProfile(value, context),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_isLoading ? 'Skipping...' : 'Skip'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
