// ignore_for_file: use_build_context_synchronously, prefer_collection_literals, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanDetailsPage extends StatefulWidget {
  final String planId;

  const PlanDetailsPage({Key? key, required this.planId}) : super(key: key);

  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  final TextEditingController _taskNameController = TextEditingController();
  Map<String, dynamic> plan = {};
  Set<String> checkedTasks = Set();

  @override
  void initState() {
    super.initState();
    _fetchPlanData();
  }

  Future<void> _fetchPlanData() async {
    DocumentSnapshot<Map<String, dynamic>> planSnapshot =
        await FirebaseFirestore.instance
            .collection('plans')
            .doc(widget.planId)
            .get();

    setState(() {
      plan = planSnapshot.data() ?? {};
    });
  }

  Future<void> _createTask() async {
    String taskName = _taskNameController.text.trim();

    if (taskName.isNotEmpty && plan.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('plans')
          .doc(widget.planId)
          .update({
        'uncheckedCheckpoints': FieldValue.arrayUnion([taskName]),
      });

      _taskNameController.clear();
      _fetchPlanData();
    }
  }

  Future<void> _deleteTask(String taskName) async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc(widget.planId)
        .update({
      'uncheckedCheckpoints': FieldValue.arrayRemove([taskName]),
    });

    _fetchPlanData();
  }

  Future<void> _editTask(String oldTaskName) async {
    // ignore: no_leading_underscores_for_local_identifiers
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
                  await FirebaseFirestore.instance
                      .collection('plans')
                      .doc(widget.planId)
                      .update({
                    'uncheckedCheckpoints':
                        FieldValue.arrayRemove([oldTaskName]),
                  });
                  await FirebaseFirestore.instance
                      .collection('plans')
                      .doc(widget.planId)
                      .update({
                    'uncheckedCheckpoints':
                        FieldValue.arrayUnion([_editedTaskController.text]),
                  });
                  _fetchPlanData();
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

  Future<void> _deletePlan() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Plan'),
          content: const Text('Are you sure you want to delete this plan?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance
          .collection('plans')
          .doc(widget.planId)
          .delete();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan['name'].toString().toUpperCase()),
        backgroundColor: const Color(0xFFEDEAEA),
        iconTheme: const IconThemeData(color: Color(0xFFDFBD43)),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: () => _deletePlan(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFFFFDF4),
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
              child: plan['uncheckedCheckpoints'] == null ||
                      plan['uncheckedCheckpoints'].isEmpty
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
                          (plan['uncheckedCheckpoints'] as List<dynamic>?)
                                  ?.length ??
                              0,
                      itemBuilder: (context, index) {
                        String taskName = plan['uncheckedCheckpoints'][index];
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
                                  await FirebaseFirestore.instance
                                      .collection('plans')
                                      .doc(widget.planId)
                                      .update({
                                    'uncheckedCheckpoints':
                                        FieldValue.arrayRemove([taskName]),
                                    'checkedCheckpoints':
                                        FieldValue.arrayUnion([taskName]),
                                  });

                                  _fetchPlanData();
                                }
                              },
                            ),
                            title: Text(
                              taskName.toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15,
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
              child: plan['checkedCheckpoints'] == null ||
                      plan['checkedCheckpoints'].isEmpty
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
                      itemCount: (plan['checkedCheckpoints'] as List<dynamic>?)
                              ?.length ??
                          0,
                      itemBuilder: (context, index) {
                        String checkedTaskName =
                            plan['checkedCheckpoints'][index];
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
                                fontSize: 15,
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
