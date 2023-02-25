import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'project.dart';
import 'seminar.dart';
import 'editSeminar.dart';

class ViewProjectWidget extends StatefulWidget {
  const ViewProjectWidget({super.key});

  @override
  State<ViewProjectWidget> createState() => _ViewProjectWidgetState();
}

class _ViewProjectWidgetState extends State<ViewProjectWidget> {
  final _formKeyAddSeminarDay = GlobalKey<FormState>();

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
          body: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: getColumns(viewProjectState, context),
              ),
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
                            content: Form(
                              key: _formKeyAddSeminarDay,
                              /* child: TextField(
                                decoration: const InputDecoration(
                                    labelText: "Seminartag"),
                                onChanged: (value) {
                                  viewProjectState.setSeminarDay(value);
                                },
                              ), */
                              child: InputDatePickerFormField(
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 3560),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 3560),
                                ),
                                errorFormatText: "Ungültiges Format",
                                errorInvalidText: "Ungültiges Datum",
                                onDateSaved: (value) {
                                  viewProjectState.setSeminarDay(value);
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    /* if (viewProjectState
                                        .seminarDay.isNotEmpty) {
                                      viewProjectState
                                          .addDate(viewProjectState.seminarDay); 
                                      Navigator.of(context).pop();
                                    } */
                                    if (_formKeyAddSeminarDay.currentState!
                                        .validate()) {
                                      _formKeyAddSeminarDay.currentState!
                                          .save();
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
                IconButton(
                    onPressed: () {
                      debugPrint(
                          viewProjectState.project.seminarPerDate.toString());
                    },
                    icon: const Icon(Icons.deck))
              ],
            ),
          ),
        );
      },
    );
  }

  List<Padding> getColumns(
      ViewProjectState viewProjectState, BuildContext context) {
    List<DateTime> base = viewProjectState.project.seminarPerDate.keys.toList();
    base.sort();
    List<Padding> columns = base
        .map((date) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                        getDateWidget(viewProjectState, date, context)
                      ] +
                      viewProjectState.project.seminarPerDate[date]!
                          .map((seminar) => getSeminarWidget(
                              viewProjectState, seminar, context))
                          .toList()),
            ))
        .toList();
    if (viewProjectState.showAddSeminarButton) {
      columns = base
          .map((date) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                        getDateWidget(viewProjectState, date, context)
                      ] +
                      viewProjectState.project.seminarPerDate[date]!
                          .map((seminar) => getSeminarWidget(
                              viewProjectState, seminar, context))
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
                ),
              ))
          .toList();
    }
    return columns;
  }

  Widget getDateWidget(
      ViewProjectState viewProjectState, DateTime date, BuildContext context) {
    double _scale = 0.7;
    DateFormat formatter = DateFormat("dd.MM.yyyy");
    if (viewProjectState.showEditButton && viewProjectState.showDeleteButton) {
      return Row(
        children: [
          Text(formatter.format(date)),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                editDate(date, viewProjectState, context);
              },
              icon: const Icon(Icons.edit),
            ),
          ),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                deleteDate(date, viewProjectState, context);
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
          Text(formatter.format(date)),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                editDate(date, viewProjectState, context);
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
          Text(formatter.format(date)),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                deleteDate(date, viewProjectState, context);
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      );
    }
    return Text(formatter.format(date));
  }

  Widget getSeminarWidget(ViewProjectState viewProjectState, Seminar seminar,
      BuildContext context) {
    double _scale = 0.7;
    if (viewProjectState.showEditButton && viewProjectState.showDeleteButton) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(seminar.name!),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                editSeminar(seminar, viewProjectState, context);
              },
              icon: const Icon(Icons.edit),
            ),
          ),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                deleteSeminar(context, viewProjectState, seminar);
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      );
    }
    if (viewProjectState.showEditButton && !viewProjectState.showDeleteButton) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(seminar.name!),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                editSeminar(seminar, viewProjectState, context);
              },
              icon: const Icon(Icons.edit),
            ),
          ),
        ],
      );
    }
    if (!viewProjectState.showEditButton && viewProjectState.showDeleteButton) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(seminar.name!),
          Transform.scale(
            scale: _scale,
            child: IconButton(
              onPressed: () {
                deleteSeminar(context, viewProjectState, seminar);
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

void deleteSeminar(
    BuildContext context, ViewProjectState viewProjectState, Seminar seminar) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "Soll das Seminar ${seminar.name} wirklich gelöscht werden?"),
          actions: [
            TextButton(
                onPressed: () {
                  viewProjectState.removeSeminar(seminar);
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
      });
}

void editSeminar(
    Seminar seminar, ViewProjectState viewProjectState, BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditSeminarWidget(oldSeminar: seminar)));
}

void deleteDate(
    DateTime date, ViewProjectState viewProjectState, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "Soll das Datum ${DateFormat("dd.MM.yyyy").format(date)} wirklich gelöscht werden? Damit werden auch alle Seminare an diesem Tag gelöscht."),
          actions: [
            TextButton(
                onPressed: () {
                  viewProjectState.removeDate(date);
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
      });
}

void editDate(
    DateTime date, ViewProjectState viewProjectState, BuildContext context) {
  final _formKeyEditDate = GlobalKey<FormState>();
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seminartag ändern"),
          content: Form(
            key: _formKeyEditDate,
            child: InputDatePickerFormField(
              firstDate: DateTime.now().subtract(
                const Duration(days: 3560),
              ),
              lastDate: DateTime.now().add(
                const Duration(days: 3560),
              ),
              errorFormatText: "Ungültiges Format",
              errorInvalidText: "Ungültiges Datum",
              onDateSaved: (value) {
                viewProjectState.setSeminarDay(value);
              },
              initialDate: date,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Abbrechen")),
            TextButton(
                onPressed: () {
                  if (_formKeyEditDate.currentState!.validate()) {
                    _formKeyEditDate.currentState!.save();
                    if (viewProjectState.seminarDay != date) {
                      if (viewProjectState.project.seminarPerDate.keys
                          .contains(viewProjectState.seminarDay)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Das Datum ${DateFormat("dd.MM.yyyy").format(date)} existiert bereits. Änderung konnte nicht vorgenommen werden.")));
                      } else {
                        viewProjectState.addDate(viewProjectState.seminarDay);
                        for (Seminar toChangeSeminar
                            in viewProjectState.project.seminarPerDate[date]!) {
                          viewProjectState.addSeminar(toChangeSeminar
                              .copyWithOtherDate(viewProjectState.seminarDay));
                        }
                        viewProjectState.removeDate(date);
                      }
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Änderung vornehmen")),
          ],
        );
      });
}

class ViewProjectState extends ChangeNotifier {
  Project project = Project();
  late DateTime seminarDay;

  bool showEditButton = true;
  bool showDeleteButton = false;
  bool showAddSeminarButton = true;

  void setProject(Project newProject) {
    project = newProject;
  }

  void addDate(DateTime date) {
    project.addDate(date);
    notifyListeners();
  }

  void removeDate(DateTime date) {
    project.removeDate(date);
    notifyListeners();
  }

  void setSeminarDay(DateTime newDay) {
    seminarDay = newDay;
  }

  void addSeminar(Seminar seminar) {
    project.addSeminar(seminar);
    notifyListeners();
  }

  void removeSeminar(Seminar seminar) {
    project.removeSeminar(seminar);
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
