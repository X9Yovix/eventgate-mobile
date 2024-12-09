import 'package:eventgate_flutter/controller/auth.dart';
import 'package:eventgate_flutter/model/user.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:eventgate_flutter/view/main_screen.dart';
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

  void _skipCompleteProfile(context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _authController.skipCompleteProfile(context);
      AppUtils.showToast(context, _authController.getMessage()!, 'success');
      AppUtils.navigateWithSlideAndClearStack(context, const MainScreen());
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

  void _completeProfile(context, value) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_birthDateController.text.isEmpty &&
          _phoneNumberController.text.isEmpty &&
          _bioController.text.isEmpty &&
          _gender == null &&
          _profileImage == null) {
        AppUtils.showToast(context, 'No data to save, skipping...', 'info');
        await _authController.skipCompleteProfile(context);
        AppUtils.navigateWithSlideAndClearStack(context, const MainScreen());
        return;
      }

      Profile profile = Profile(
        birthDate: null,
        bio: null,
        phoneNumber: null,
        gender: null,
        profilePicture: null,
        isProfileComplete: true,
        skipIsProfileComplete: false,
      );

      if (_birthDateController.text.isNotEmpty) {
        profile.birthDate = _birthDateController.text;
      }

      if (_bioController.text.isNotEmpty) {
        profile.bio = _bioController.text;
      }

      if (_phoneNumberController.text.isNotEmpty) {
        profile.phoneNumber =
            '$_selectedCountryCode${_phoneNumberController.text}';
      }

      if (_gender != null) {
        profile.gender = _gender;
      }

      if (_completeProfileFormKey.currentState!.validate()) {
        await _authController.completeProfile(context, profile, _profileImage);
        AppUtils.showToast(context, _authController.getMessage()!, 'success');
        AppUtils.navigateWithFade(context, const MainScreen());
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
                    borderRadius: BorderRadius.circular(15),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                        IntlPhoneField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          initialCountryCode: 'TN',
                          onCountryChanged: (country) {
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _completeProfile(context, value),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 44, 2, 51),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _skipCompleteProfile(context),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.skip_next_outlined),
                              label: Text(_isLoading ? 'Skipping...' : 'Skip'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(179, 44, 2, 51),
                                foregroundColor: Colors.white70,
                              ),
                            ),
                          ],
                        )
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
