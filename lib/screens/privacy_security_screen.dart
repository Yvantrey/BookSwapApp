import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'change_password_screen.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Manage your account security and privacy settings',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          
          // Password Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          
          const Divider(),
          
          // Privacy Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Profile Visibility'),
            subtitle: Text('Your profile is visible to other users'),
            trailing: Icon(Icons.info_outline),
          ),
          const ListTile(
            leading: Icon(Icons.chat),
            title: Text('Message Privacy'),
            subtitle: Text('Only you and the recipient can see messages'),
            trailing: Icon(Icons.info_outline),
          ),
          
          const Divider(),
          
          // Security Information
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Security Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Your data is encrypted and secure'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.block, color: Colors.green),
                    SizedBox(width: 8),
                    Text('We never share your data with third parties'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.green),
                    SizedBox(width: 8),
                    Text('You can delete your account anytime'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.green),
                    SizedBox(width: 8),
                    Text('All communications are private'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}