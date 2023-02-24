import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:context_menus/context_menus.dart';
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
            /* actions: [
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
            ], */
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: getColumns(viewProjectState, context),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    viewProjectState
                        .setShowEditButton(!viewProjectState.showEditButton);
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: "Editierbutton umschalten",
                ),
                IconButton(
                  onPressed: () {
                    viewProjectState.setShowDeleteButton(
                        !viewProjectState.showDeleteButton);
                  },
                  icon: const Icon(Icons.delete),
                  tooltip: "Löschbutton umschalten",
                ),
                IconButton(
                  onPressed: () {
                    viewProjectState.setShowAddSeminarButton(
                        !viewProjectState.showAddSeminarButton);
                  },
                  tooltip: "Seminarbutton umschalten",
                  icon: const Icon(Icons.add),
                ),
                IconButton(
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
                    icon: const Icon(Icons.post_add))
              ],
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
    List<Column> columns = base
        .map((date) => Column(
            children: <Widget>[Text(date)] +
                viewProjectState.project.seminarPerDate[date]!
                    .map(
                        /* (seminar) => RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            text: seminar.name!,
                            recognizer: TapGestureRecognizer()
                              ..onSecondaryTap = () {
                                debugPrint(seminar.name);
                              },
                          ),
                        ), */
                        /*(seminar) => Row(
                          children: [
                            Text(seminar.name!),
                            Transform.scale(
                              scale: 0.7,
                              child: IconButton(
                                onPressed: () {
                                  debugPrint(seminar.name);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ],
                        ), */
                        (seminar) =>
                            getSeminarWidget(viewProjectState, seminar))
                    .toList() /*  +
                  <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  AddSeminarWidget(seminarDay: date)));
                        },
                        child: const Text("Seminar hinzufügen"))
                  ], */
            ))
        .toList();
    if (viewProjectState.showAddSeminarButton) {
      columns = base
          .map((date) => Column(
                children: <Widget>[Text(date)] +
                    viewProjectState.project.seminarPerDate[date]!
                        .map((seminar) =>
                            getSeminarWidget(viewProjectState, seminar))
                        .toList() +
                    <Widget>[
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
    return columns;
  }

  Widget getSeminarWidget(ViewProjectState viewProjectState, Seminar seminar) {
    double _scale = 0.7;
    if (viewProjectState.showEditButton && viewProjectState.showDeleteButton) {
      return Row(
        children: [
          Text(seminar.name!),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                debugPrint("edit ${seminar.name}");
              },
              icon: const Icon(Icons.edit),
            ),
          ),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                debugPrint("delete ${seminar.name}");
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      );
    }
    if (viewProjectState.showEditButton && !viewProjectState.showDeleteButton) {
      return Row(
        children: [
          Text(seminar.name!),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                debugPrint("edit ${seminar.name}");
              },
              icon: const Icon(Icons.edit),
            ),
          ),
        ],
      );
    }
    if (!viewProjectState.showEditButton && viewProjectState.showDeleteButton) {
      return Row(
        children: [
          Text(seminar.name!),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                debugPrint("delete ${seminar.name}");
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      );
    }
    return Text(seminar.name!);
  }
}

class ViewProjectState extends ChangeNotifier {
  Project project = Project();
  late String seminarDay;

  bool showEditButton = true;
  bool showDeleteButton = false;
  bool showAddSeminarButton = true;

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

  void setShowEditButton(bool newValue) {
    showEditButton = newValue;
    notifyListeners();
  }

  void setShowDeleteButton(bool newValue) {
    showDeleteButton = newValue;
    notifyListeners();
  }

  void setShowAddSeminarButton(bool newValue) {
    showAddSeminarButton = newValue;
    notifyListeners();
  }
}
