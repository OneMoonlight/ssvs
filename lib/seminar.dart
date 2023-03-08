import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ssvs/viewProject.dart';
import 'util.dart';

class Seminar {
  DateTime? date;
  String? name;
  String? contact;
  int? maxPeople;
  String? description;
  Map<FilledSheet, int> votings = {};
  List<FilledSheet> assignments = [];

  Seminar({this.date, this.name, this.contact, this.maxPeople});

  @override
  bool operator ==(Object other) =>
      other is Seminar &&
      other.runtimeType == runtimeType &&
      other.name == name &&
      other.date == date;

  @override
  int get hashCode => (name! + date.toString()).hashCode;

  @override
  String toString() {
    return "Titel: $name, Datum: ${DateFormat("dd.MM.yyyy").format(date!)}";
  }

  void addVoting(FilledSheet filledSheet, int value) {
    votings[filledSheet] = value;
  }

  void addAssignment(FilledSheet filledSheet) {
    assignments.add(filledSheet);
  }

  Seminar copyWithOtherDate(DateTime newDate) {
    return Seminar(
        date: newDate, name: name, contact: contact, maxPeople: maxPeople);
  }

  List<SeminarDifference> getDifference(Seminar seminar) {
    List<SeminarDifference> difference = <SeminarDifference>[];
    if (seminar.name != name) {
      difference.add(SeminarDifference.name);
    }
    if (seminar.date != date) {
      difference.add(SeminarDifference.date);
    }
    if (seminar.contact != contact) {
      difference.add(SeminarDifference.contact);
    }
    if (seminar.maxPeople != maxPeople) {
      difference.add(SeminarDifference.maxPeople);
    }
    if (seminar.description != description) {
      difference.add(SeminarDifference.description);
    }
    return difference;
  }

  Seminar.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        date = DateTime.parse(json["date"]),
        contact = json["contact"],
        maxPeople = json["maxPeople"],
        description = json["description"];

  Map<String, dynamic> toJson() => {
        'name': name,
        'contact': contact,
        'date': date!.toIso8601String(),
        'maxPeople': maxPeople,
        'description': description
      };
}

enum SeminarDifference {
  date,
  name,
  contact,
  maxPeople,
  description,
}

class AddSeminarWidget extends StatefulWidget {
  const AddSeminarWidget({super.key, required this.seminarDay});
  final DateTime seminarDay;

  @override
  State<AddSeminarWidget> createState() => _AddSeminarWidgetState();
}

class _AddSeminarWidgetState extends State<AddSeminarWidget> {
  final _fromKeySeminar = GlobalKey<FormState>();
  Seminar seminar = Seminar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seminar hinzufügen"),
      ),
      body: Form(
        key: _fromKeySeminar,
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
                        seminar.name = newValue;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        seminar.contact = newValue;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        seminar.date = value;
                      },
                      initialDate: widget.seminarDay,
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
                        seminar.maxPeople = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        seminar.description = newValue;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: null,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: const Text(
                          "Prüfen und erstellen",
                        ),
                        onPressed: () {
                          if (_fromKeySeminar.currentState!.validate()) {
                            _fromKeySeminar.currentState!.save();
                            var myViewProjectState =
                                context.read<ViewProjectState>();
                            if (!myViewProjectState.project.seminarPerDate
                                .containsKey(seminar.date)) {
                              myViewProjectState.addDate(seminar.date!);
                            }
                            if (myViewProjectState
                                .project.seminarPerDate[seminar.date]!
                                .contains(seminar)) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Seminar konnte nicht erstellt werden. Der Titel existiert bereits am ${DateFormat("dd.MM.yyyy").format(seminar.date!)}")));
                            } else {
                              myViewProjectState.addSeminar(seminar);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Seminar wurde erstellt")));
                              _fromKeySeminar.currentState!.reset();
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ))
                ],
              ),
            )),
      ),
    );
  }
}
