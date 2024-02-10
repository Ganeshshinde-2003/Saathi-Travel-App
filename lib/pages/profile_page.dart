import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/components/snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ignore: prefer_final_fields
  late Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String _name = '';
  late String _email = '';
  late String _profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      Map<String, dynamic> userCredentialJson =
          json.decode(prefs.getString('userCredential') ?? '{}');
      _name = userCredentialJson['user']['displayName'] ?? 'Default Name';
      _email = userCredentialJson['user']['email'] ?? 'Default Email';
      _profilePicUrl = userCredentialJson['user']['profilePicUrl'] ??
          'Default Profile Pic URL';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFFDF4),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDFBD43),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePicUrl.isNotEmpty
                        ? NetworkImage(_profilePicUrl)
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Name: $_name',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  'Email: $_email',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),
                const Text(
                  'About Developer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDFBD43)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDFBD43),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/mypic.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'I am Ganesh Shinde, a dedicated Computer Science and Engineering student with a passion for mobile development. I possess comprehensive skills in React Native and Flutter, acquired through hands-on experiences in various internships. My proficiency includes designing and developing robust mobile applications, contributing to the success of projects in my previous internships. With a strong foundation in HTML, CSS, and JavaScript, coupled with my commitment to staying updated with the latest technologies and also I have the experience in deploying app in Playstore and Applestore, I am eager to leverage my expertise as a React Native and Flutter developer to deliver innovative and impactful solutions.',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _copyToClipboard('https://www.shindeganesh.tech/');
                        },
                        child: const Text('Portfolio URL'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackBar(
      context: context,
      content: "Successfully Copied",
    );
  }
}
