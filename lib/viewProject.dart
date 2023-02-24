import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project.dart';
import 'seminar.dart';

class ViewProjectWidget extends StatelessWidget {
  const ViewProjectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewProjectState>(
      builder: (context, viewProjectState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("${viewProjectState.project.title}"),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Seminartag hinzufügen"),
                            content: TextField(
                              decoration: const InputDecoration(
                                  labelText: "Seminartag"),
                              onChanged: (value) {
                                viewProjectState.setSeminarDay(value);
                              },
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    if (viewProjectState
                                        .seminarDay.isNotEmpty) {
                                      viewProjectState
                                          .addDate(viewProjectState.seminarDay);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text("Hinzufügen"))
                            ],
                          );
                        }),
                    tooltip: "Seminartag hinzufügen",
                    icon: const Icon(Icons.post_add)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: getColumns(viewProjectState, context),
            ),
          ),
        );
      },
    );
  }

  List<Column> getColumns(
      ViewProjectState viewProjectState, BuildContext context) {
    List<String> base = viewProjectState.project.seminarPerDate.keys.toList();
    base.sort();
    return base
        .map((date) => Column(
              children: [
                Text(date),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              AddSeminarWidget(seminarDay: date)));
                    },
                    child: const Text("Seminar hinzufügen"))
              ],
            ))
        .toList();
  }
}

class ViewProjectState extends ChangeNotifier {
  Project project = Project();
  late String seminarDay;

  void setProject(Project newProject) {
    project = newProject;
  }

  void addDate(String date) {
    project.addDate(date);
    notifyListeners();
  }

  void setSeminarDay(String newDay) {
    seminarDay = newDay;
  }

  void addSeminar(Seminar seminar) {
    project.addSeminar(seminar);
    notifyListeners();
  }
}
