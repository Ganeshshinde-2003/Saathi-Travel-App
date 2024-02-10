// ignore_for_file: non_constant_identifier_names

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/group_page.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/search_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;

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
      const Icon(Icons.person_2_outlined, size: 30),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo@2x.png',
          width: 200,
          fit: BoxFit.contain,
        ),
        backgroundColor: const Color(0xFFEDEAEA),
      ),
      extendBody: true,
      body: Screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: Colors.black)),
        child: CurvedNavigationBar(
          key: navigationKey,
          color: const Color(0xFFEDEAEA),
          buttonBackgroundColor: const Color(0xFFEDEAEA),
          backgroundColor: Colors.transparent,
          items: items,
          height: 60,
          index: index,
          onTap: (index) => setState(
            () {
              this.index = index;
            },
          ),
        ),
      ),
    );
  }
}
