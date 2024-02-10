// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/snack_bar.dart';
import 'package:myapp/pages/shared_plan_details.dart';

class GroupListingPage extends StatefulWidget {
  const GroupListingPage({Key? key}) : super(key: key);

  @override
  State<GroupListingPage> createState() => _GroupListingPageState();
}

class _GroupListingPageState extends State<GroupListingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFFFDF4),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shared Plans",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _buildSharedPlansList(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            _showGroupOptions(context);
          },
          backgroundColor: const Color(0xFFDFBD43),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSharedPlansList() {
    return FutureBuilder(
      future: _fetchUserSharedPlans(),
      builder: (context, AsyncSnapshot<List<String>> userPlansSnapshot) {
        if (userPlansSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (userPlansSnapshot.hasError) {
          return Text('Error: ${userPlansSnapshot.error}');
        } else {
          List<String> userSharedPlans = userPlansSnapshot.data ?? [];

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('sharedplans')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Widget> planWidgets = [];

                for (var document in snapshot.data!.docs) {
                  String planId = document.id;
                  String planName = document['name'];
                  DateTime planDate = (document['date'] as Timestamp).toDate();

                  String formattedDate =
                      "${planDate.day.toString().padLeft(2, '0')}-${planDate.month.toString().padLeft(2, '0')}-${planDate.year}";

                  if (userSharedPlans.contains(planId)) {
                    planWidgets.add(
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SharedPlanDetailsPage(planId: planId),
                            ),
                          ),
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
                              planName.toString().toUpperCase(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 126, 126, 126),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text('Date: $formattedDate'),
                            trailing: const Icon(
                              Icons.indeterminate_check_box,
                              color: Color(0xFFDFBD43),
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }

                return planWidgets.isEmpty
                    ? Container(
                        margin: const EdgeInsets.only(top: 150),
                        child: Image.asset(
                          'assets/images/shared.png',
                          width: 500,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Column(children: planWidgets);
              }
            },
          );
        }
      },
    );
  }

  Future<List<String>> _fetchUserSharedPlans() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();

        List<dynamic> userSharedPlans = userSnapshot['sharedPlans'] ?? [];
        return List<String>.from(userSharedPlans);
      }

      return [];
    } catch (e) {
      print('Error fetching user shared plans: $e');
      return [];
    }
  }

  void _showGroupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create Plan'),
              onTap: () {
                Navigator.pop(context);
                _createPlan(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Join Plan'),
              onTap: () {
                Navigator.pop(context);
                _joinPlan(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _createPlan(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String planName = '';
        DateTime? selectedDate;

        return AlertDialog(
          title: const Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  planName = value;
                },
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  setState(() {
                    selectedDate = pickedDate ?? DateTime.now();
                  });
                },
                child: const Text('Pick Date'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (planName.isNotEmpty && selectedDate != null) {
                    _savePlan(planName, selectedDate!);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Plan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _joinPlan(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: _fetchSharedPlans(),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Widget> sharedPlansWidgets = [];
                    List<DocumentSnapshot> sharedPlans = snapshot.data!;

                    for (var document in sharedPlans) {
                      String planName = document['name'];
                      DateTime planDate =
                          (document['date'] as Timestamp).toDate();

                      String formattedDate =
                          "${planDate.day.toString().padLeft(2, '0')}-${planDate.month.toString().padLeft(2, '0')}-${planDate.year}";

                      sharedPlansWidgets.add(
                        ListTile(
                          title: Text(planName),
                          subtitle: Text('Date: $formattedDate'),
                          onTap: () {
                            Navigator.pop(context);
                            _joinSelectedPlan(document.id);
                          },
                        ),
                      );
                    }

                    return Column(children: sharedPlansWidgets);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchSharedPlans() async {
    try {
      QuerySnapshot sharedPlansSnapshot =
          await FirebaseFirestore.instance.collection('sharedplans').get();
      return sharedPlansSnapshot.docs;
    } catch (e) {
      print('Error fetching shared plans: $e');
      return [];
    }
  }

  void _joinSelectedPlan(String sharedPlanId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'sharedPlans': FieldValue.arrayUnion([sharedPlanId]),
        });

        await FirebaseFirestore.instance
            .collection('sharedplans')
            .doc(sharedPlanId)
            .update({
          'planmembers': FieldValue.arrayUnion([currentUser.uid]),
        });

        showSnackBar(
          context: context,
          content: "Plan joined successfully!",
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  void _savePlan(String planName, DateTime selectedDate) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentReference sharedPlanRef =
            await FirebaseFirestore.instance.collection('sharedplans').add({
          'name': planName,
          'date': selectedDate,
          'checkedChecklist': [],
          'uncheckedChecklist': [],
          'planmembers': [currentUser.uid],
        });

        String sharedPlanId = sharedPlanRef.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'sharedPlans': FieldValue.arrayUnion([sharedPlanId]),
        });
        showSnackBar(
          context: context,
          content: "Plan saved successfully!",
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }
}
