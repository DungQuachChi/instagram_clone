import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';
import 'dart:typed_data';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showPasswordRequirements = false;

  // Password validation states
  late Map<String, bool> _passwordValidation = {
    'hasMinLength': false,
    'hasUppercase': false,
    'hasLowercase': false,
    'hasNumbers': false,
    'hasSpecialChar': false,
  };

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
      });
    }
  }

  void _updatePasswordValidation(String password) {
    setState(() {
      _passwordValidation = AuthMethods.validatePassword(password);
    });
  }

  void signUpUser() async {
    if (_emailController.text.isEmpty) {
      showSnackBar('Email is required', context);
      return;
    }
    if (_passwordController.text.isEmpty) {
      showSnackBar('Password is required', context);
      return;
    }
    if (_usernameController.text.isEmpty) {
      showSnackBar('Username is required', context);
      return;
    }

    if (!AuthMethods.isPasswordStrong(_passwordController.text)) {
      showSnackBar('Password is not strong enough', context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
        (route) => false,
      );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    SvgPicture.asset(
                      'assets/ic_instagram.svg',
                      color: primaryColor,
                      height: 64,
                    ),
                    const SizedBox(height: 30),

                    // Avatar
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!),
                              )
                            : CircleAvatar(
                                radius: 64,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person, size: 50, color: Colors.grey),
                              ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo),
                            style: IconButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile Picture (Optional)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // USERNAME
                    TextFieldInput(
                      hintText: "Enter your username",
                      textInputType: TextInputType.text,
                      textEditingController: _usernameController,
                      prefixIcon: const Icon(Icons.person),
                      onChanged: (_) => setState(() {}), // refresh validity row
                    ),
                    const SizedBox(height: 8),
                    _buildFieldStatus(
                      isValid: _usernameController.text.isNotEmpty &&
                          AuthMethods.isValidUsername(_usernameController.text),
                      label: 'Username must be 3-30 characters',
                    ),
                    const SizedBox(height: 16),

                    // EMAIL
                    TextFieldInput(
                      hintText: "Enter your email",
                      textInputType: TextInputType.emailAddress,
                      textEditingController: _emailController,
                      prefixIcon: const Icon(Icons.email),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    _buildFieldStatus(
                      isValid: _emailController.text.isNotEmpty &&
                          AuthMethods.isValidEmail(_emailController.text),
                      label: 'Valid email required',
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: mobileSearchColor,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (v) {
                        _updatePasswordValidation(v);
                        setState(() {}); // update checklist ticks
                      },
                    ),
                    const SizedBox(height: 16),

                    // Show the password requirements only when user starts typing
                    if (_passwordController.text.isNotEmpty) ...[
                      _buildPasswordRequirements(),
                      const SizedBox(height: 16),
                    ],

                    // BIO (optional)
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        hintText: "Add a bio (optional)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.info),
                        filled: true,
                        fillColor: mobileSearchColor,
                      ),
                      maxLines: 3,
                      maxLength: 150,
                    ),
                    const SizedBox(height: 24),

                    // SIGN UP BUTTON
                    InkWell(
                      onTap: _isLoading ? null : signUpUser,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: ShapeDecoration(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          color: _isLoading ? Colors.grey : const Color.fromARGB(255, 118, 104, 104),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text("Already have an account?"),
                        ),
                        GestureDetector(
                          onTap: navigateToLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              " Log in.",
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  // HELPER WIDGET: Field Status Indicator
  Widget _buildFieldStatus({required bool isValid, required String label}) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.info,
          size: 16,
          color: isValid ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  // HELPER WIDGET: Password Requirements Checklist
  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            'At least 8 characters',
            _passwordValidation['hasMinLength'] ?? false,
          ),
          _buildRequirementRow(
            'Uppercase letter (A-Z)',
            _passwordValidation['hasUppercase'] ?? false,
          ),
          _buildRequirementRow(
            'Lowercase letter (a-z)',
            _passwordValidation['hasLowercase'] ?? false,
          ),
          _buildRequirementRow(
            'Number (0-9)',
            _passwordValidation['hasNumbers'] ?? false,
          ),
          _buildRequirementRow(
            'Special character (!@#\$%^&*)',
            _passwordValidation['hasSpecialChar'] ?? false,
          ),
        ],
      ),
    );
  }

  // HELPER WIDGET: Individual Requirement Row
  Widget _buildRequirementRow(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey[600],
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
