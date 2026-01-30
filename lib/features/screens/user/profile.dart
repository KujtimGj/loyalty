import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/features/screens/auth/welcome_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/ui.dart';
import '../../providers/user_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('No user data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Avatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(user.email!, style: TextStyle(fontSize: 18)),
                        Text("Edit profile", style: TextStyle(fontSize: 14,color: primaryColor)),

                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // User Info Card
                Column(
                  children: [
                    _buildInfoRow(
                      label: 'Phone',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      label: 'User ID',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    await userProvider.logout();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WelcomeScreen()),
                    );
                  },
                  child: Container(
                    height: 55,
                    width: getWidth(context),
                    decoration: BoxDecoration(
                      color: warningColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text("Log Out", style: TextStyle(color: Colors.white),)
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(Icons.arrow_forward_ios_outlined),
      ],
    );
  }
}
