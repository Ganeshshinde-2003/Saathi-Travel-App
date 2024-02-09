// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/components/snack_bar.dart';
import 'package:myapp/pages/plan_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final TextEditingController _planNameController = TextEditingController();
  Map<String, dynamic>? userData;
  late String greeting = '';
  List<Map<String, dynamic>> plans = [];

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _fetchUserData();
    _fetchPlansFromFirestore();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userCredentialString = prefs.getString('userCredential') ?? '';

    if (userCredentialString.isNotEmpty) {
      // Decode the stored JSON string
      Map<String, dynamic> userCredentialJson =
          json.decode(userCredentialString);

      setState(() {
        userData = userCredentialJson;
      });
    }
  }

  void _setGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      setState(() {
        greeting = 'Good morning';
      });
    } else if (hour < 17) {
      setState(() {
        greeting = 'Good afternoon';
      });
    } else {
      setState(() {
        greeting = 'Good evening';
      });
    }
  }

  Future<void> _createPlan() async {
    String planName = _planNameController.text.trim();
    DateTime? selectedDate;

    if (planName.isNotEmpty) {
      selectedDate = await _selectDate(context);

      if (selectedDate != null) {
        await FirebaseFirestore.instance.collection('plans').add({
          'name': planName,
          'planDate': selectedDate,
          'checkedCheckpoints': [],
          'uncheckedCheckpoints': [],
        });

        _planNameController.clear();

        // Fetch updated plans
        await _fetchPlansFromFirestore();

        showSnackBar(
          context: context,
          content: "Plan created successfully!",
        );
      }
    }
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime? selectedDate;

    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFDFBD43),
            colorScheme: const ColorScheme.light(primary: Color(0xFFDFBD43)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        selectedDate = value;
      }
    });

    return selectedDate;
  }

  Future<void> _fetchPlansFromFirestore() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('plans').get();

    List<Map<String, dynamic>> fetchedPlans = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      plans = fetchedPlans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFFFDF4),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDFBD43),
                  width: 2.0,
                ),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.network(
                    userData?['user']?['profilePicUrl'] ??
                        'https://static.vecteezy.com/system/resources/previews/005/129/844/non_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4.0),
              color: const Color(0xFFF5F2E8),
              child: Text(
                '$greeting, ${userData?['user']?['displayName'] ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(
              color: Color.fromARGB(255, 171, 171, 171),
              thickness: 1.0,
            ),
            const SizedBox(height: 20),
            const Text(
              'Explore Your Plans',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...plans.map((plan) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PlanDetailsPage(planId: plan['id'])),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFFD6D6D6),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text(
                      plan['name'].toString().toUpperCase(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 126, 126, 126),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text('Date: ${_formatDate(plan['planDate'])}'),
                    trailing: const Icon(
                      Icons.indeterminate_check_box,
                      color: Color(0xFFDFBD43),
                      size: 35,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Create a New Plan'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _planNameController,
                        decoration:
                            const InputDecoration(labelText: 'Plan Name'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _createPlan();
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          backgroundColor: const Color(0xFFDFBD43),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? date) {
    if (date != null) {
      return _formatTimestamp(date);
    }
    return '';
  }

  String _formatTimestamp(Timestamp timestamp) {
    var dateTime = timestamp.toDate();
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }
}
