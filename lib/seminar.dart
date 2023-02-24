import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Seminar {
  String? date;
  String? name;
  String? contact;

  Seminar({this.date, this.name});
}

class AddSeminarWidget extends StatefulWidget {
  const AddSeminarWidget({super.key, required this.seminarDay});
  final String seminarDay;

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
            child: Column(
              children: [
                TextFormField(
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
                TextFormField(
                  decoration: const InputDecoration(
                      hintText:
                          "Das Datum, an dem dieses Seminar durchgeführt wird",
                      labelText: "Datum"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Das Datum darf nicht leer sein";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    seminar.date = newValue;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: "Die verantwortliche Person für dieses Seminar",
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
              ],
            )),
      ),
    );
  }
}
