import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ssvs/viewProject.dart';

import 'seminar.dart';

class EditSeminarWidget extends StatefulWidget {
  const EditSeminarWidget({super.key, required this.oldSeminar});
  final Seminar oldSeminar;

  @override
  State<EditSeminarWidget> createState() => _EditSeminarWidgetState();
}

class _EditSeminarWidgetState extends State<EditSeminarWidget> {
  final _fromKeyEditSeminar = GlobalKey<FormState>();
  Seminar newSeminar = Seminar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seminar hinzufügen"),
      ),
      body: Form(
        key: _fromKeyEditSeminar,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          hintText:
                              "Der Titel des Seminars muss innerhalb eines Seminartages eindeutig sein",
                          labelText: "Titel"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Der Titel darf nicht leer sein";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        newSeminar.name = newValue;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: widget.oldSeminar.name,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          hintText:
                              "Die verantwortliche Person für dieses Seminar",
                          labelText: "Verantwortliche Person"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Die verantwortliche Person darf nicht leer sein";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        newSeminar.contact = newValue;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: widget.oldSeminar.contact,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                        newSeminar.date = value;
                      },
                      initialDate: widget.oldSeminar.date,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          hintText:
                              "Die maximale Anzahl an Personen, die an diesem Seminar teilnehmen kann",
                          labelText: "Max. Anzahl Personen"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Die maximale Anzahl an Personen darf nicht leer sein";
                        }
                        try {
                          int i = int.parse(value);
                        } catch (e) {
                          return "Die maximale Anzahl an Personen muss eine ganze Zahl sein";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        newSeminar.maxPeople = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: widget.oldSeminar.maxPeople.toString(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          hintText:
                              "Eine kurze Beschreibung des Seminars und ggf. zusätzliche relevante Hinweise",
                          labelText: "Beschreibung/ Hinweise"),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (newValue) {
                        newSeminar.description = newValue;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: widget.oldSeminar.description,
                      maxLines: null,
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Abbrechen"),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: const Text(
                                "Prüfen und ändern",
                              ),
                              onPressed: () {
                                if (_fromKeyEditSeminar.currentState!
                                    .validate()) {
                                  _fromKeyEditSeminar.currentState!.save();
                                  List<SeminarDifference> difference = widget
                                      .oldSeminar
                                      .getDifference(newSeminar);
                                  var viewProjectState =
                                      context.read<ViewProjectState>();
                                  if (difference.isEmpty) {
                                    Navigator.of(context).pop();
                                  } else {
                                    if (difference
                                        .contains(SeminarDifference.date)) {
                                      // Datum ist noch nicht vorhanden
                                      if (!viewProjectState
                                          .project.seminarPerDate
                                          .containsKey(newSeminar.date)) {
                                        viewProjectState
                                            .addDate(newSeminar.date!);
                                        viewProjectState.addSeminar(newSeminar);
                                        viewProjectState
                                            .removeSeminar(widget.oldSeminar);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Seminar wurde erfolgreich geändert"),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                        _fromKeyEditSeminar.currentState!
                                            .reset();
                                        return;
                                      } else {
                                        // Neues Datum bereits vorhanden
                                        if (viewProjectState.project
                                            .seminarPerDate[newSeminar.date]!
                                            .contains(newSeminar)) {
                                          // Neues Datum hat bereits Seminar mit gleichem Titel
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Seminar konnte nicht erstellt werden. Am ${DateFormat("dd.MM.yyyy").format(newSeminar.date!)} existiert bereits ein Seminar mit dem Titel \"${newSeminar.name}\""),
                                            ),
                                          );
                                          return;
                                        } else {
                                          // Neues Datum hat noch KEIN Seminar mit dem gleichen Titel
                                          viewProjectState
                                              .addDate(newSeminar.date!);
                                          viewProjectState
                                              .addSeminar(newSeminar);
                                          viewProjectState
                                              .removeSeminar(widget.oldSeminar);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Seminar wurde erfolgreich geändert"),
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                          _fromKeyEditSeminar.currentState!
                                              .reset();
                                          return;
                                        }
                                      }
                                    }
                                    if (difference
                                        .contains(SeminarDifference.name)) {
                                      // Unterschiedlicher Name, gleiches Datum
                                      if (viewProjectState.project
                                          .seminarPerDate[newSeminar.date]!
                                          .contains(newSeminar)) {
                                        // Gleiches Datum hat bereits Seminar mit gleichem Titel
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Seminar konnte nicht erstellt werden. Am ${DateFormat("dd.MM.yyyy").format(newSeminar.date!)} existiert bereits ein Seminar mit dem Titel \"${newSeminar.name}\""),
                                          ),
                                        );
                                        return;
                                      } else {
                                        // Gleiches Datum hat noch KEIN Seminar mit dem gleichen Titel
                                        viewProjectState
                                            .addDate(newSeminar.date!);
                                        viewProjectState.addSeminar(newSeminar);
                                        viewProjectState
                                            .removeSeminar(widget.oldSeminar);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Seminar wurde erfolgreich geändert"),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                        _fromKeyEditSeminar.currentState!
                                            .reset();
                                        return;
                                      }
                                    }
                                    if (difference.contains(
                                            SeminarDifference.contact) ||
                                        difference.contains(
                                            SeminarDifference.maxPeople) ||
                                        difference.contains(
                                            SeminarDifference.description)) {
                                      // Kontaktänderung hat keinen Einfluss
                                      viewProjectState
                                          .addDate(newSeminar.date!);
                                      viewProjectState.addSeminar(newSeminar);
                                      viewProjectState
                                          .removeSeminar(widget.oldSeminar);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Seminar wurde erfolgreich geändert"),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                      _fromKeyEditSeminar.currentState!.reset();
                                      return;
                                    }
                                  }
                                }
                              },
                            )),
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
