import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final model.User user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
      });
    }
  }

  void updateProfile() async {
    if (_usernameController.text.isEmpty) {
      showSnackBar('Username cannot be empty', context);
      return;
    }

    if (!AuthMethods.isValidUsername(_usernameController.text)) {
      showSnackBar('Invalid username format', context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String photoUrl = widget.user.photoUrl;

      // Upload new image if selected
      if (_image != null) {
        photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          _image!,
          false,
        );
      }

      // Update user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'username': _usernameController.text.toLowerCase(),
        'bio': _bioController.text,
        'photoUrl': photoUrl,
      });

      setState(() {
        _isLoading = false;
      });

      showSnackBar('Profile updated successfully', context);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar('Error updating profile: $e', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(widget.user.photoUrl),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: mobileSearchColor,
                ),
              ),
              const SizedBox(height: 16),

              // Bio Field
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.info),
                  filled: true,
                  fillColor: mobileSearchColor,
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              const SizedBox(height: 32),

              // Save Button
              InkWell(
                onTap: _isLoading ? null : updateProfile,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: _isLoading ? Colors.grey : primaryColor,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}