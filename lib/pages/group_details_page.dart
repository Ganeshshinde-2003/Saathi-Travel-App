import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDetailPageScreen extends StatefulWidget {
  final String planId;

  const GroupDetailPageScreen({Key? key, required this.planId})
      : super(key: key);

  @override
  State<GroupDetailPageScreen> createState() => _GroupDetailPageScreenState();
}

class _GroupDetailPageScreenState extends State<GroupDetailPageScreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>>? _sharedPlanFuture;
  final appName = "Group Details";

  @override
  void initState() {
    super.initState();
    _sharedPlanFuture = _fetchSharedPlan();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchSharedPlan() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> sharedPlanSnapshot =
          await FirebaseFirestore.instance
              .collection('sharedplans')
              .doc(widget.planId)
              .get();

      return sharedPlanSnapshot;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
        backgroundColor: const Color(0xFFEDEAEA),
        iconTheme: const IconThemeData(
          color: Color(0xFFDFBD43),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFFFDF4),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: FutureBuilder(
          future: _sharedPlanFuture,
          builder: (context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || !snapshot.data!.exists) {
              return const Center(child: Text('Shared plan not found.'));
            } else {
              Map<String, dynamic> sharedPlanData = snapshot.data!.data()!;
              List<dynamic> planMembers = sharedPlanData['planmembers'] ?? [];

              final planDate = (sharedPlanData['date'] as Timestamp).toDate();
              final formattedDate =
                  '${planDate.day.toString().padLeft(2, '0')}-${planDate.month.toString().padLeft(2, '0')}-${planDate.year}';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sharedPlanData['name'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Plan Date: $formattedDate',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Travel Companions',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 105, 105, 105),
                    ),
                  ),
                  const Divider(
                    color: Color(0xFFDFBD43),
                    thickness: 1.0,
                  ),
                  for (var memberId in planMembers) ...[
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberId)
                          .get(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              memberSnapshot) {
                        if (memberSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (memberSnapshot.hasError) {
                          return Text('Error: ${memberSnapshot.error}');
                        } else if (memberSnapshot.data == null ||
                            !memberSnapshot.data!.exists) {
                          return const Text('Member data not found.');
                        } else {
                          Map<String, dynamic> memberData =
                              memberSnapshot.data!.data()!;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFDFBD43),
                                    width: 2.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(
                                    memberData['profilePicUrl'] ??
                                        'https://static.vecteezy.com/system/resources/previews/005/129/844/non_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg',
                                  ),
                                ),
                              ),
                              title: Text(
                                memberData['displayName'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
