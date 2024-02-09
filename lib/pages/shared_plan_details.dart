// ignore_for_file: library_private_types_in_public_api, prefer_collection_literals, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharedPlanDetailsPage extends StatefulWidget {
  final String planId;

  const SharedPlanDetailsPage({Key? key, required this.planId})
      : super(key: key);

  @override
  _SharedPlanDetailsPageState createState() => _SharedPlanDetailsPageState();
}

class _SharedPlanDetailsPageState extends State<SharedPlanDetailsPage> {
  final TextEditingController _taskNameController = TextEditingController();
  Map<String, dynamic> sharedPlan =
      {}; // Local variable to store shared plan data
  Set<String> checkedTasks = Set();

  @override
  void initState() {
    super.initState();
    // Fetch shared plan data when the widget is initialized
    _fetchSharedPlanData();
  }

  Future<void> _fetchSharedPlanData() async {
    // Fetch the shared plan data from Firebase using the planId
    DocumentSnapshot<Map<String, dynamic>> sharedPlanSnapshot =
        await FirebaseFirestore.instance
            .collection('sharedplans')
            .doc(widget.planId)
            .get();

    // Update the local state with the new shared plan data
    setState(() {
      sharedPlan = sharedPlanSnapshot.data() ?? {};
    });
  }

  Future<void> _createTask() async {
    String taskName = _taskNameController.text.trim();

    if (taskName.isNotEmpty && sharedPlan.isNotEmpty) {
      // Update Firebase with the new task
      await FirebaseFirestore.instance
          .collection('sharedplans')
          .doc(widget.planId)
          .update({
        'uncheckedChecklist': FieldValue.arrayUnion([taskName]),
      });

      _taskNameController.clear();
      _fetchSharedPlanData();
    }
  }

  Future<void> _deleteTask(String taskName) async {
    // Delete the task from Firebase
    await FirebaseFirestore.instance
        .collection('sharedplans')
        .doc(widget.planId)
        .update({
      'uncheckedChecklist': FieldValue.arrayRemove([taskName]),
      'checkedChecklist': FieldValue.arrayRemove([taskName]),
    });

    // Fetch the updated shared plan from Firebase
    _fetchSharedPlanData();
  }

  Future<void> _editTask(String oldTaskName) async {
    TextEditingController _editedTaskController =
        TextEditingController(text: oldTaskName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editedTaskController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Update the task name in Firebase
                  await FirebaseFirestore.instance
                      .collection('sharedplans')
                      .doc(widget.planId)
                      .update({
                    'uncheckedChecklist': FieldValue.arrayRemove([oldTaskName]),
                    'checkedChecklist': FieldValue.arrayRemove([oldTaskName]),
                  });
                  await FirebaseFirestore.instance
                      .collection('sharedplans')
                      .doc(widget.planId)
                      .update({
                    'uncheckedChecklist':
                        FieldValue.arrayUnion([_editedTaskController.text]),
                  });
                  _fetchSharedPlanData();
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sharedPlan['name'].toString().toUpperCase()),
        backgroundColor: const Color(0xFFEDEAEA),
        iconTheme: const IconThemeData(
          color: Color(0xFFDFBD43), // Set color for the backward icon
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Plan's tasks",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: sharedPlan['uncheckedChecklist'] == null ||
                      sharedPlan['uncheckedChecklist'].isEmpty
                  ? const Center(
                      child: Text(
                        "No task created",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 126, 126, 126),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          (sharedPlan['uncheckedChecklist'] as List<dynamic>?)
                                  ?.length ??
                              0,
                      itemBuilder: (context, index) {
                        String taskName =
                            sharedPlan['uncheckedChecklist'][index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: const Color(0xFFD6D6D6),
                              width: 2.0,
                            ),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: checkedTasks.contains(taskName),
                              activeColor: const Color(0xFFDFBD43),
                              onChanged: (bool? value) async {
                                if (value != null) {
                                  setState(() {
                                    if (value) {
                                      checkedTasks.add(taskName);
                                    } else {
                                      checkedTasks.remove(taskName);
                                    }
                                  });
                                  if (value) {
                                    await FirebaseFirestore.instance
                                        .collection('sharedplans')
                                        .doc(widget.planId)
                                        .update({
                                      'uncheckedChecklist':
                                          FieldValue.arrayRemove([taskName]),
                                      'checkedChecklist':
                                          FieldValue.arrayUnion([taskName]),
                                    });
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('sharedplans')
                                        .doc(widget.planId)
                                        .update({
                                      'checkedChecklist':
                                          FieldValue.arrayRemove([taskName]),
                                      'uncheckedChecklist':
                                          FieldValue.arrayUnion([taskName]),
                                    });
                                  }

                                  // Fetch the updated shared plan data
                                  _fetchSharedPlanData();
                                }
                              },
                            ),
                            title: Text(
                              taskName.toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 126, 126, 126),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: Color(0xFFDFBD43),
                                  ),
                                  onPressed: () => _editTask(taskName),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFFDFBD43),
                                  ),
                                  onPressed: () => _deleteTask(taskName),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Finished tasks",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: sharedPlan['checkedChecklist'] == null ||
                      sharedPlan['checkedChecklist'].isEmpty
                  ? const Center(
                      child: Text(
                        "No task completed",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 126, 126, 126),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          (sharedPlan['checkedChecklist'] as List<dynamic>?)
                                  ?.length ??
                              0,
                      itemBuilder: (context, index) {
                        String checkedTaskName =
                            sharedPlan['checkedChecklist'][index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: const Color(0xFFD6D6D6),
                              width: 2.0,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              checkedTaskName.toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 126, 126, 126),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.check_box_outlined,
                              color: Color(0xFFDFBD43),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add a New Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskNameController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _createTask();
                      },
                      child: const Text('Add Task'),
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
    );
  }
}
