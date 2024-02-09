import 'dart:convert';

import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFFFFDF4),
          height: 850,
          padding: const EdgeInsets.symmetric(vertical: 25),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  initialValue:
                      "I am Ganesh Shinde, a dedicated Computer Science and Engineering student with a passion for mobile development. Currently in my 6th semester at Dayananda Sagar University, I possess comprehensive skills in React Native and Flutter, acquired through hands-on experiences in various internships also delpoying in playstore and applestore. My proficiency includes designing and developing robust mobile applications, contributing to the success of projects at previous internships. I am eager to leverage my expertise as a React Native and Flutter developer to deliver innovative and impactful solutions.",
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
