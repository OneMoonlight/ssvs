import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'project.dart';
import 'viewProject.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MyHomePageState>(
            create: (context) => MyHomePageState()),
        ChangeNotifierProvider<ViewProjectState>(
            create: (context) => ViewProjectState()),
      ],
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
      ],
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

  void addDate(Project project, String date) {}
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
                          Provider.of<ViewProjectState>(context, listen: false)
                              .setProject(homePageState.projects[index]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => const ViewProjectWidget()),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(Icons.abc),
                          title: Text(homePageState.projects[index].title!),
                          subtitle: homePageState.projects[index].subtitle !=
                                  null
                              ? Text(homePageState.projects[index].subtitle!)
                              : null,
                          trailing: IconButton(
                            /* onPressed: () {
                              homePageState.deleteProjectByIndex(index);
                            }, */
                            onPressed: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                        "Soll das Projekt \"${homePageState.projects[index].title}\" wirklich gelöscht werden?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            homePageState
                                                .deleteProjectByIndex(index);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Ja")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Nein")),
                                    ],
                                  );
                                }),
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
          /* debugPrint(Provider.of<MyHomePageState>(context, listen: false)
              .projects[0]
              .seminarPerDate
              .keys
              .toString()); */
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
