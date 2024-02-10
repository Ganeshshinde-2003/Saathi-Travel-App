// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/snack_bar.dart';
import 'package:myapp/pages/group_page.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Screens = [
    const HomePageScreen(),
    const GroupListingPage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home_outlined, size: 30),
      const Icon(Icons.group_add_outlined, size: 30),
      const Icon(Icons.search, size: 30),
      const Icon(Icons.person_outline, size: 30),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo@2x.png',
          width: 200,
          fit: BoxFit.contain,
        ),
        backgroundColor: const Color(0xFFEDEAEA),
        iconTheme: const IconThemeData(
          color: Color(0xFFDFBD43),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              size: 25,
            ),
            onPressed: () => _showLogoutConfirmationDialog(context),
          ),
        ],
      ),
      extendBody: true,
      body: Screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        child: CurvedNavigationBar(
          key: navigationKey,
          color: const Color(0xFFEDEAEA),
          buttonBackgroundColor: const Color(0xFFEDEAEA),
          backgroundColor: Colors.transparent,
          items: items,
          height: 60,
          index: index,
          onTap: (index) => setState(() => this.index = index),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Do you really want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _logoutAndNavigateToLogin();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _logoutAndNavigateToLogin() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userCredential', "");
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }
}
