import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventgate_flutter/controller/auth.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:eventgate_flutter/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = AuthController();
  bool _isLoading = false;
  final String baseUrl = 'http://10.0.2.2:8000';

  void _onLogout(context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      await _authController.logout(context);
      AppUtils.showToast(context, _authController.getMessage()!, 'success');
      /*
      Token tokens = Token(
        access: Provider.of<AuthProvider>(context, listen: false).token!.access,
        refresh:
            Provider.of<AuthProvider>(context, listen: false).token!.refresh,
      );
      */
    } catch (error) {
      AppUtils.showToast(context, _authController.getError()!, 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _authController.setMessage(null);
      _authController.setError(null);
      AppUtils.navigateWithSlideAndClearStack(context, const AuthScreen());
    }
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = const Color.fromARGB(255, 44, 2, 51),
    Color backgroundColor = Colors.white38,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                if (_isLoading && text == 'Logout')
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                      strokeWidth: 2,
                    ),
                  )
                else
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Icon(icon, color: color),
                  ),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, value, child) => SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 44, 2, 51),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: (value.profile!.profilePicture != null &&
                          value.profile!.profilePicture!.isNotEmpty)
                      ? baseUrl + value.profile!.profilePicture!
                      : 'https://placehold.co/200',
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/thumbnail.png',
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${value.user?.firstName ?? ''} ${value.user?.lastName ?? ''}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '@${value.user?.username ?? ''}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.person,
                    text: 'Profile Settings',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.notifications,
                    text: 'Notifications',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.lock,
                    text: 'Security Settings',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.info,
                    text: 'App Information',
                    onTap: () {},
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.logout,
                    text: 'Logout',
                    color: Colors.redAccent,
                    backgroundColor: const Color.fromARGB(255, 255, 204, 204),
                    onTap: () => _onLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
