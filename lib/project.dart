import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'seminar.dart';

class Project {
  String? title;
  String? subtitle;
  Map<String, List<Seminar>> seminarPerDate = {};

  Project({this.title, this.subtitle});

  void addSeminar(Seminar seminar) {
    seminarPerDate[seminar.date]!.add(seminar);
  }

  void addDate(String date) {
    if (!seminarPerDate.keys.contains(date)) {
      seminarPerDate[date] = <Seminar>[];
    }
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
                        "Der Titel wird auf der Homepage unter dem Titel dargestellt",
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
                  onPressed: () {
                    if (_formKeyProject.currentState!.validate()) {
                      _formKeyProject.currentState!.save();
                      var myHomePageState = context.read<MyHomePageState>();
                      if (myHomePageState.projects.contains(project)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Projekt kann nicht erstellt werden, der Titel existiert bereits.")));
                      } else {
                        myHomePageState.addProject(project);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Projekt wurde erstellt")));
                        _formKeyProject.currentState!.reset();
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
