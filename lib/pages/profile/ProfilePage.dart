import 'package:ezbuy/pages/product_page/changepassword.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'purchase_history_page.dart';
import '../../auth/auth_services.dart';
import '../../core/app/wrapper.dart';
import '../../core/theme/colors.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await File(image.path).readAsBytes();
      final base64String = base64Encode(bytes);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'photo': base64String});

      if (mounted) {
        setState(() {
          userData!['photo'] = base64String;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo updated successfully!')),
        );
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              userData = doc.data() as Map<String, dynamic>;
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return const Center(child: Text('No user data found.'));
    }

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              _buildProfileAvatar(isDark),
              const SizedBox(height: 20),
              _buildProfileCard(isDark, userData!),
              const SizedBox(height: 20),
              _buildPurchaseHistoryButton(isDark),
              const SizedBox(height: 20),
              _buildChangePasswordButton(isDark),
              const SizedBox(height: 30),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileAvatar(bool isDark) {
    final avatarColor = isDark ? AppColors.lightTextSecondary : AppColors.lightPrimary;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: avatarColor,
                backgroundImage: userData!['photo'] != null
                    ? MemoryImage(base64Decode(userData!['photo']))
                    : null,
                child: userData!['photo'] == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.lightSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: isDark ? Colors.black : Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userData!['fullName'] ?? 'User Name',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            userData!['email'] ?? 'N/A',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            Icons.phone,
            'Phone Number',
            data['phone'] ?? 'N/A',
            isDark,
          ),
        ],
      ),
    );
  }
  Widget _buildDetailRow(
      IconData icon,
      String label,
      String value,
      bool isDark,
      ) {
    final accentColor = AppColors.lightSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildPurchaseHistoryButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PurchaseHistoryPage(),
            ),
          );
        },
        icon: const Icon(Icons.history, color: Colors.white),
        label: Text(
          'Purchase History',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.teal.shade600 : Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
      ),
    );
  }


  Widget _buildChangePasswordButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            ),
          );
        },
        icon: const Icon(Icons.lock_reset, color: Colors.white),
        label: Text(
          'Change Password',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.orange.shade600 : Colors.blue.shade600, 
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
      ),
    );
  }
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await authServiceNotifier.value.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Wrapper()),
            );
          }
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: Text(
          'Logout',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}