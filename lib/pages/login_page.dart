// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/components/bottom_nav.dart';
import 'package:myapp/components/snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        saveUserCredential(userCredential);
        saveUserToFirestore(userCredential.user);

        _navigateToHomePageIfReady();
      }
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  Map<String, dynamic> userCredentialToJson(UserCredential userCredential) {
    Map<String, dynamic>? profile = userCredential.additionalUserInfo?.profile;
    String? profilePicUrl = profile?['picture'];

    Map<String, dynamic> jsonMap = {
      'additionalUserInfo': {
        'isNewUser': userCredential.additionalUserInfo?.isNewUser,
        'profile': profile,
        'providerId': userCredential.additionalUserInfo?.providerId,
        'username': userCredential.additionalUserInfo?.username,
        'authorizationCode':
            userCredential.additionalUserInfo?.authorizationCode,
      },
      'credential': {
        'providerId': userCredential.credential?.providerId,
        'signInMethod': userCredential.credential?.signInMethod,
        'token': userCredential.credential?.token,
        'accessToken': userCredential.credential?.accessToken,
      },
      'user': {
        'displayName': userCredential.user?.displayName,
        'email': userCredential.user?.email,
        'isEmailVerified': userCredential.user?.emailVerified,
        'isAnonymous': userCredential.user?.isAnonymous,
        'metadata': {
          'creationTime':
              userCredential.user?.metadata.creationTime?.toIso8601String(),
        },
        'profilePicUrl': profilePicUrl,
      },
    };

    return jsonMap;
  }

  void saveUserCredential(UserCredential userCredential) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userCredentialJson =
        userCredentialToJson(userCredential);
    prefs.setString('userCredential', json.encode(userCredentialJson));
  }

  void saveUserToFirestore(User? user) {
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'profilePicUrl': user.photoURL,
        'sharedPlans': [],
      }).catchError((error) {
        showSnackBar(
          context: context,
          content: error.toString(),
        );
      });
    }
  }

  void _navigateToHomePageIfReady() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasUserCredential = prefs.containsKey('userCredential');

    if (hasUserCredential) {
      // Check if Firestore has user data
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      bool hasFirestoreData = userDoc.exists;

      if (hasFirestoreData) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigation(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Hop on the Hype Train!",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 59, 58, 58),
                ),
              ),
              const SizedBox(height: 180),
              Image.asset(
                'assets/images/logo@2x.png',
                width: 200,
                fit: BoxFit.contain,
              ),
              Image.asset(
                'assets/images/illu.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFFFFFDF4),
                  border: Border.all(
                    color: const Color(0xFFDFBD43),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Center(
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 36, 36, 36),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _signInWithGoogle,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFFFFFDF4),
                    border: Border.all(
                      color: const Color(0xFFDFBD43),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        width: 40,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Color.fromARGB(255, 36, 36, 36),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ],
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
