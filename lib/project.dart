import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class Project {
  String? title;
  String? subtitle;

  Project({this.title, this.subtitle});

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
  final _formKey = GlobalKey<FormState>();
  Project project = Project();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neues Projekt anlegen"),
      ),
      body: Form(
        key: _formKey,
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
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
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
                      }
                    }
                  },
                  child: const Text("Prüfen und erstellen"),
                ),
              )
            ],
          ),
        ),
        /* child: Center(
          child: ElevatedButton(
            child: const Text("add me"),
            onPressed: () {
              var myHomePageState = context.read<MyHomePageState>();
              myHomePageState.addProject(Project("new title", "new subtitle"));
            },
          ),
        ), */
      ),
    );
  }
}
