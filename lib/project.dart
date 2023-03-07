import 'dart:convert';
import 'dart:io';
import 'package:io/io.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'seminar.dart';

class Project {
  String? title;
  String? subtitle;
  Map<DateTime, List<Seminar>> seminarPerDate = {};

  Project({this.title, this.subtitle});

  Project.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        subtitle = json["subtitle"],
        seminarPerDate = parseSeminarPerDate(json["seminarPerDate"]);

  static Map<DateTime, List<Seminar>> parseSeminarPerDate(
      Map<String, dynamic> json) {
    Map<String, dynamic> givenMap = json;
    Map<DateTime, List<Seminar>> setMap = {};
    givenMap.forEach((key, value) {
      List<Seminar> seminars = [];

      for (Map<String, dynamic> elem in value) {
        seminars.add(Seminar.fromJson(elem));
      }
      setMap[DateTime.parse(key)] = seminars;
    });
    return setMap;
  }

  Map<String, dynamic> toJson() {
    Map<String, List<Seminar>> newSeminarPerDate = {};
    seminarPerDate.forEach((key, value) {
      newSeminarPerDate[key.toIso8601String()] = value;
    });
    return {
      'title': title,
      'subtitle': subtitle,
      'seminarPerDate': newSeminarPerDate,
    };
  }

  void addSeminar(Seminar seminar) {
    seminarPerDate[seminar.date]!.add(seminar);
  }

  void removeSeminar(Seminar seminar) {
    seminarPerDate[seminar.date]!.remove(seminar);
  }

  void addDate(DateTime date) {
    if (!seminarPerDate.keys.contains(date)) {
      seminarPerDate[date] = <Seminar>[];
    }
  }

  void removeDate(DateTime date) {
    seminarPerDate.remove(date);
  }

  @override
  bool operator ==(Object other) =>
      other is Project &&
      other.runtimeType == runtimeType &&
      other.title == title;

  @override
  int get hashCode => title.hashCode;
}

class AddProjectWidget extends StatefulWidget {
  const AddProjectWidget({super.key});

  @override
  State<AddProjectWidget> createState() => _AddProjectWidgetState();
}

class _AddProjectWidgetState extends State<AddProjectWidget> {
  final _formKeyProject = GlobalKey<FormState>();
  Project project = Project();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neues Projekt anlegen"),
      ),
      body: Form(
        key: _formKeyProject,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    hintText:
                        "Der Titel wird auf der Homepage groß dargestellt und muss eindeutig sein",
                    labelText: "Titel"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Der Titel darf nicht leer sein";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  project.title = newValue;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    hintText:
                        "Der Untertitel wird auf der Homepage unter dem Titel dargestellt",
                    labelText: "Untertitel"),
                validator: (value) {
                  /* if (value != null && value.contains("@")) {
                    return "Der Titel darf kein @ enthalten";
                  } */
                  return null;
                },
                onSaved: (newValue) {
                  project.subtitle = newValue;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKeyProject.currentState!.validate()) {
                      _formKeyProject.currentState!.save();
                      var myHomePageState = context.read<MyHomePageState>();
                      if (myHomePageState.projects.contains(project)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Projekt kann nicht erstellt werden, der Titel existiert bereits.")));
                      } else {
                        myHomePageState.addProject(project);
                        Directory appDir =
                            await getApplicationDocumentsDirectory();
                        String saveTitle = project.title!
                            .replaceAll(RegExp('[^A-Za-z0-9]'), '');
                        String path =
                            "${appDir.path}/ssvs/$saveTitle/filledTemplates";
                        Directory(path).createSync(recursive: true);

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Projekt wurde erstellt")));
                        saveProjects(context);
                        _formKeyProject.currentState!.reset();
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text("Prüfen und erstellen"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EditProjectWidget extends StatefulWidget {
  const EditProjectWidget({super.key, required this.oldProject});
  final Project oldProject;

  @override
  State<EditProjectWidget> createState() => _EditProjectWidgetState();
}

class _EditProjectWidgetState extends State<EditProjectWidget> {
  final _editProjectKey = GlobalKey<FormState>();
  Project project = Project();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projekt \"${widget.oldProject.title}\" ändern"),
      ),
      body: Form(
        key: _editProjectKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    hintText:
                        "Der Titel wird auf der Homepage groß dargestellt und muss eindeutig sein",
                    labelText: "Titel"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Der Titel darf nicht leer sein";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  project.title = newValue;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.oldProject.title,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    hintText:
                        "Der Untertitel wird auf der Homepage unter dem Titel dargestellt",
                    labelText: "Untertitel"),
                validator: (value) {
                  /* if (value != null && value.contains("@")) {
                    return "Der Titel darf kein @ enthalten";
                  } */
                  return null;
                },
                onSaved: (newValue) {
                  project.subtitle = newValue;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.oldProject.subtitle,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_editProjectKey.currentState!.validate()) {
                      _editProjectKey.currentState!.save();
                      var myHomePageState = context.read<MyHomePageState>();
                      if (myHomePageState.projects.contains(project) &&
                          widget.oldProject != project) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Projekt kann nicht erstellt werden, der Titel existiert bereits.")));
                      } else {
                        myHomePageState.deleteProject(widget.oldProject);
                        myHomePageState.addProject(project);
                        Directory appDir =
                            await getApplicationDocumentsDirectory();
                        String saveTitle = project.title!
                            .replaceAll(RegExp('[^A-Za-z0-9]'), '');
                        String oldSaveTitle = widget.oldProject.title!
                            .replaceAll(RegExp('[^A-Za-z0-9]'), '');
                        String path =
                            "${appDir.path}/ssvs/$saveTitle/filledTemplates";
                        String oldPath =
                            "${appDir.path}/ssvs/$oldSaveTitle/filledTemplates";
                        copyPathSync(oldPath, path);
                        if (project.title != widget.oldProject.title) {
                          await ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Projekt wurde geändert. Templates müssen erneut erstellt werden, um up-to-date zu sein. Die alten Dateien müssen manuell kopiert/ gelöscht werden.")));
                        } else {
                          await ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Projekt wurde geändert.")));
                        }
                        saveProjects(context);
                        _editProjectKey.currentState!.reset();
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text("Prüfen und ändern"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
