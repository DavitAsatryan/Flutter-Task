import 'package:flutter/material.dart';
import 'package:flutter_task/Model/task_model.dart';
import 'package:flutter_task/Store/db_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  int? selectedId;
  bool completed = false;
  bool active = false;

  void dialog([bool? header]) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => Container(
        child: AlertDialog(
          title: Column(
            children: [
              header == true ? const Text("Update") : const Text("Create"),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) => Container(
              height: 150,
              child: Center(
                child: Column(
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(hintText: "Description"),
                      minLines: 2,
                      maxLines: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              value: completed,
                              onChanged: (bool? value) {
                                setState(() {
                                  completed = value!;
                                  if (completed == true) {
                                    active = false;
                                  }
                                });
                              },
                            ),
                            const Text("Completed"),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              value: active,
                              onChanged: (bool? value) {
                                setState(() {
                                  active = value!;
                                  if (active == true) {
                                    completed = false;
                                  }
                                });
                              },
                            ),
                            const Text("Active"),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (header == true) {
                  selectedId != null
                      ? update(selectedId!, titleController.text,
                          descriptionController.text, completed, active)
                      : null;
                  setState(() {
                    titleController.clear();
                    descriptionController.clear();
                    selectedId = null;
                  });
                } else {
                  selectedId != null
                      ? null
                      : add(
                          titleController.text,
                          descriptionController.text,
                          completed,
                          active,
                        );
                  setState(() {
                    selectedId = null;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Task"),
      ),
      body: Center(
        child: FutureBuilder<List<TaskModel>>(
            future: DatabaseHelper.instance.getTaskModel(),
            builder: (BuildContext context,
                AsyncSnapshot<List<TaskModel>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text(
                    'Loading...',
                  ),
                );
              }
              return snapshot.data!.isEmpty
                  ? const Center(
                      child: Text('No Tasks list'),
                    )
                  : ListView(
                      children: snapshot.data!.map((taskModel) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16, left: 16),
                          child: Center(
                            child: Card(
                              color: taskModel.completed == "true"
                                  ? Colors.white70
                                  : taskModel.active == "true"
                                      ? const Color.fromARGB(179, 159, 153, 153)
                                      : Colors.white,
                              child: ListTile(
                                title: Text(taskModel.title),
                                subtitle: Text(taskModel.description),
                                trailing: IconButton(
                                    onPressed: () async {
                                      selectedId = taskModel.id;
                                      selectedId != null
                                          ? remove(selectedId!)
                                          : null;
                                      setState(() {
                                        titleController.clear();
                                        selectedId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete)),
                                onTap: () {
                                  selectedId = taskModel.id;
                                  titleController.text = taskModel.title;
                                  descriptionController.text =
                                      taskModel.description;
                                  dialog(true);
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          descriptionController.clear();
          completed = false;
          active = false;
          dialog(false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> add(
    String title, String description, bool completed, bool active) async {
  if (title == '') {
    null;
  } else {
    await DatabaseHelper.instance.add(TaskModel(
        title: title,
        description: description,
        completed: "$completed",
        active: "$active"));
  }
}

Future<void> remove(int? id) async {
  DatabaseHelper.instance.remove(id!);
}

Future<void> update(int id, String title, String description, bool completed,
    bool active) async {
  await DatabaseHelper.instance.update(TaskModel(
      id: id,
      title: title,
      description: description,
      completed: "$completed",
      active: "$active"));
}
