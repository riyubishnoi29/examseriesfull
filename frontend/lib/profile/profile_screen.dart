import 'dart:io';
import 'package:examtrack/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // Load user profile from API
  void loadProfile() async {
    final profile = await ApiService.getProfile();
    setState(() => user = profile);
  }

  // Pick image and upload
  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploading = true;
      });

      final result = await ApiService.uploadProfilePicture(_selectedImage!);

      if (result != null && result['success'] == true) {
        setState(() {
          user!['profile_picture'] = result['imageUrl'];
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture uploaded successfully'),
          ),
        );
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Upload failed')));
      }
    } catch (e) {
      setState(() => _isUploading = false);
      print('Error uploading image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Please login to view your profile",
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.redAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundImage:
                                _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : NetworkImage(
                                          user!['profile_picture'] != null &&
                                                  user!['profile_picture'] != ''
                                              ? user!['profile_picture']
                                              : 'https://www.gravatar.com/avatar/placeholder',
                                        )
                                        as ImageProvider,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            onPressed: _pickAndUploadImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (_isUploading)
                    const Text(
                      'Uploading...',
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _infoCard(
                      icon: Icons.person,
                      label: "Name",
                      value: user!['name'],
                    ),
                    const SizedBox(height: 15),
                    _infoCard(
                      icon: Icons.email,
                      label: "Email",
                      value: user!['email'],
                    ),
                    const SizedBox(height: 15),
                    _infoCard(
                      icon: Icons.calendar_today,
                      label: "Joined",
                      value: user!['created_at'],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.redAccent,
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () async {
                          await ApiService.logout();
                          setState(() => user = null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.redAccent, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
