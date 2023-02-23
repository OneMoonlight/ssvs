import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'project.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyHomePageState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green, brightness: Brightness.light)),
      /* home: ChangeNotifierProvider(
        create: (context) => MyHomePageState(),
        child: const MyHomePage(),
      ), */
      home: const MyHomePage(),
    );
  }
}

class MyHomePageState extends ChangeNotifier {
  List<Project> projects = [
    Project(
        title: "Seminarwoche DG 02/23", subtitle: "Vom 15.03.23 bis 20.03.23")
  ];

  void addProject(Project project) {
    projects.add(project);
    notifyListeners();
  }

  void deleteProject(Project project) {
    projects.remove(project);
    notifyListeners();
  }

  void deleteProjectByIndex(int index) {
    projects.removeAt(index);
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Seminar Voting System'),
      ),
      body: Center(
        child: ListView(
          children: [
            Consumer<MyHomePageState>(
              builder: (context, homePageState, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: homePageState.projects.length,
                  itemBuilder: (context, int index) {
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          debugPrint("i got tapped");
                        },
                        child: ListTile(
                          leading: const Icon(Icons.abc),
                          title: Text(homePageState.projects[index].title!),
                          subtitle: homePageState.projects[index].subtitle !=
                                  null
                              ? Text(homePageState.projects[index].subtitle!)
                              : null,
                          trailing: IconButton(
                            onPressed: () {
                              homePageState.deleteProjectByIndex(index);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => const AddProjectWidget()),
            ),
          );
        },
        tooltip: "Projekt anlegen",
        child: const Icon(Icons.add),
      ),
    );
  }
}
