import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/features/screens/auth/welcome_screen.dart';
import 'package:loyalty/features/screens/user/profile/edit_profile.dart';
import 'package:provider/provider.dart';
import '../../../../core/ui.dart';
import '../../../providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
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
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: getWidth(context),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 100,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: dividerColors),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Active Offers",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              "10",
                              style: TextStyle(
                                fontSize: 40,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: SvgPicture.asset("assets/profile/user.svg"),
                        label: 'My Profile',
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => EditProfile(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: dividerColors),
                      _buildInfoRow(
                        icon: SvgPicture.asset("assets/profile/bar-chart.svg"),
                        label: 'User Statistics',
                        onPress: () {},
                      ),
                      const Divider(color: dividerColors),
                      _buildInfoRow(
                        icon: SvgPicture.asset("assets/profile/settings.svg"),
                        label: 'Settings',
                        onPress: () {},
                      ),
                      const Divider(color: dividerColors),
                      _buildInfoRow(
                        icon: SvgPicture.asset("assets/profile/clipboard.svg"),
                        label: 'Support',
                        onPress: () {},
                      ),
                      const Divider(color: dividerColors),
                      _buildInfoRow(
                        icon: SvgPicture.asset("assets/profile/log-out.svg"),
                        label: 'Logout',
                        onPress: () async {
                          await userProvider.logout();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WelcomeScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required Widget icon,
    required onPress,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
