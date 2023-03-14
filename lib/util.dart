import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssvs/main.dart';

import 'project.dart';
import 'seminar.dart';

void generateExcelTemplate(Project project, BuildContext context) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  String saveTitle = project.title!.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  String save_path = "${appDir.path}/ssvs/$saveTitle/template_$saveTitle.xlsx";

  var excel = Excel.createExcel();
  excel.rename("Sheet1", "Seminare");
  excel.copy("Seminare", "Voting");
  excel.copy("Semianre", "Ausfüllhinweise");

  Sheet votingSheet = excel["Voting"];
  Sheet seminarSheet = excel["Seminare"];
  Sheet hintSheet = excel["Ausfüllhinweise"];

  CellStyle titleStyle = CellStyle(bold: true, fontSize: 16);
  CellStyle metaDataStyle = CellStyle(bold: true, fontSize: 12);
  CellStyle metaDataInputStyle =
      CellStyle(fontSize: 12, fontColorHex: "f16a00");
  CellStyle informationStyle = CellStyle(
      fontSize: 10,
      textWrapping: TextWrapping.WrapText,
      verticalAlign: VerticalAlign.Top,
      horizontalAlign: HorizontalAlign.Left);
  CellStyle seminarListStyle = CellStyle(
      textWrapping: TextWrapping.WrapText,
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center);

  votingSheet.cell(CellIndex.indexByString("A1"))
    ..value = "Voting"
    ..cellStyle = titleStyle;
  votingSheet.cell(CellIndex.indexByString("A3"))
    ..value = "Hörsaal:"
    ..cellStyle = metaDataStyle;
  votingSheet.cell(CellIndex.indexByString("A4"))
    ..value = "Dienstgrad:"
    ..cellStyle = metaDataStyle;
  votingSheet.cell(CellIndex.indexByString("A5"))
    ..value = "Name:"
    ..cellStyle = metaDataStyle;
  votingSheet.cell(CellIndex.indexByString("A6"))
    ..value = "Vorname:"
    ..cellStyle = metaDataStyle;

  votingSheet.cell(CellIndex.indexByString("B3"))
    ..value = "Ausfüllen"
    ..cellStyle = metaDataInputStyle;
  votingSheet.cell(CellIndex.indexByString("B4"))
    ..value = "Ausfüllen"
    ..cellStyle = metaDataInputStyle;
  votingSheet.cell(CellIndex.indexByString("B5"))
    ..value = "Ausfüllen"
    ..cellStyle = metaDataInputStyle;
  votingSheet.cell(CellIndex.indexByString("B6"))
    ..value = "Ausfüllen"
    ..cellStyle = metaDataInputStyle;

  hintSheet.cell(CellIndex.indexByString("A1"))
    ..value = "Ausfüllhinweise"
    ..cellStyle = titleStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 3));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
    ..value =
        "1. Alle Felder, die mit \"Ausfüllen\" beschriftet sind, müssen ausgefüllt werden, um als gültige Eingabe erkannt zu werden."
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 4));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
    ..value = "2. Für den Dienstgrad ist die Listenschreibweise zu verwenden."
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 8));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
    ..value =
        "3. Die Seminarbewertung erfolgt über ein Punktesystem. Jedes Seminar kann mit einem Wert zwischen 0 und 5 bewertet werden. "
            "Die Bewertung beschreibt, wie sehr sie dieses Seminar besuchen möchten. Je höher der Wert, desto eher möchten Sie das Seminar besuchen."
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 9),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 10));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 9))
    ..value =
        "4. Sollte ein Seminartag nicht belegt werden (z.B. wegen Urlaub etc.), dann sind die Seminare an diesem Tag mit einer -1 als Bewertung einzutragen."
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 11),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 11));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 11))
    ..value = "5. Alle anderen Werte führen zu einer ungültigen Bewertung."
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 12),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 14));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 12))
    ..value =
        "6. Bennen Sie die Datei folgendermaßen:\nHörsaal_Dienstgrad_Name_Nachname.xlsx\nBeispiel: \"B_L_Mustermann_Max\""
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 15),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 16));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 15))
    ..value = "7. Die gültigen Dienstgradeintragungen umfassen:\n" +
        "${FilledSheet(group: "", firstName: "", lastName: "", rank: "").ranks}"
    ..cellStyle = informationStyle;
  hintSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 17),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 17));
  hintSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 17))
    ..value = "8. Als Hörsaalbezeichnung ist nur der Buchstabe zu verwenden."
    ..cellStyle = informationStyle;

  votingSheet.cell(CellIndex.indexByString("D3"))
    ..value = "Beachten Sie die Ausfüllhinweise!"
    ..cellStyle = metaDataStyle;

  int colIndex = 1;
  List<DateTime> dates = project.seminarPerDate.keys.toList();
  dates.sort();
  for (DateTime date in dates) {
    int rowIndex = 8;
    votingSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: colIndex, rowIndex: rowIndex))
        .value = DateFormat("dd.MM.yyyy").format(date);
    rowIndex += 1;
    for (Seminar seminar in project.seminarPerDate[date]!.toList()
      ..sort((a, b) => a.name!.compareTo(b.name!))) {
      //debugPrint("col: $colIndex, row: $rowIndex, seminar: ${seminar.name}");
      votingSheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex - 1, rowIndex: rowIndex))
        ..value = seminar.name
        ..cellStyle = CellStyle(bold: true);
      votingSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
        ..cellStyle = CellStyle(fontColorHex: "f16a00")
        ..value = "Ausfüllen";
      rowIndex += 1;
    }
    colIndex += 3;
  }

  seminarSheet.cell(CellIndex.indexByString("A1"))
    ..value = "Seminarübersicht"
    ..cellStyle = titleStyle;
  seminarSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
    ..value = "Datum"
    ..cellStyle = metaDataStyle;
  seminarSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
    ..value = "Titel"
    ..cellStyle = metaDataStyle;
  seminarSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2))
    ..value = "Verantwortliche Person"
    ..cellStyle = metaDataStyle;
  seminarSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2))
    ..value = "Max. Teilnehmerzahl"
    ..cellStyle = metaDataStyle;
  seminarSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 2))
    ..value = "Hinweise/ Beschreibung"
    ..cellStyle = metaDataStyle;

  int rowIndex = 3;

  for (DateTime date in project.seminarPerDate.keys.toList()..sort()) {
    for (Seminar seminar in project.seminarPerDate[date]!.toList()
      ..sort((a, b) => a.name!.compareTo(b.name!))) {
      seminarSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = DateFormat("dd.MM.yyyy").format(date)
        ..cellStyle = seminarListStyle;
      seminarSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = seminar.name
        ..cellStyle = seminarListStyle;
      seminarSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = seminar.contact
        ..cellStyle = seminarListStyle;
      seminarSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = seminar.maxPeople
        ..cellStyle = seminarListStyle;
      seminarSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = seminar.description
        ..cellStyle = seminarListStyle;
      rowIndex++;
    }
  }

  debugPrint('Änderung vorgenommen');
  var fileBytes = excel.save();
  File(save_path).createSync(recursive: true);
  File(save_path).writeAsBytesSync(fileBytes!);
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel-Template wurde erstellt")));
}

class FilledSheet {
  String group;
  String lastName;
  String firstName;
  String rank;

  List<String> ranks = [
    "FJ",
    "SU(OA)",
    "FR",
    "OF(OA)",
    "OFR",
    "SF(OA)",
    "OSF(OA)",
    "L",
    "OL",
    "H",
    "SH",
    "M",
    "OTL",
    "O"
  ].reversed.toList();

  Map<Seminar, int> votings = {};
  AdditionalInformation additionalInformation = AdditionalInformation();

  FilledSheet(
      {required this.group,
      required this.firstName,
      required this.lastName,
      required this.rank});

  void addVoting(Seminar seminar, int score) {
    votings[seminar] = score;
  }

  int compareTo(FilledSheet other) {
    //debugPrint(
    //    "comparing: ${rank}, ${lastName}, ${firstName} with ${other.rank}, ${other.lastName}, ${other.firstName}");
    if (other.group != group) {
      //debugPrint("different group");
      return group.compareTo(other.group);
    }
    if (rank != other.rank) {
      //debugPrint("different rank");
      if (!ranks.contains(rank)) {
        //debugPrint(
        //    "ranks does not contain rank of ${lastName}, ${firstName}: $rank");
        return -1;
      }
      if (!ranks.contains(other.rank)) {
        //debugPrint(
        //    "ranks does not contain rank of ${other.lastName}, ${other.firstName}: ${other.rank}");
        return 1;
      }
      if (ranks.indexOf(rank) > ranks.indexOf(other.rank)) {
        //debugPrint(
        //    "$rank > ${other.rank}: ${ranks.indexOf(rank)} > ${ranks.indexOf(other.rank)}");
        return 1;
      } else {
        //debugPrint(
        //    "$rank < ${other.rank}: ${ranks.indexOf(rank)} < ${ranks.indexOf(other.rank)}");
        return -1;
      }
    }
    if (lastName != other.lastName) {
      //debugPrint("different lastName");
      return lastName.compareTo(other.lastName);
    }
    if (firstName != other.firstName) {
      //debugPrint("different firstName");
      return firstName.compareTo(other.firstName);
    }
    //debugPrint("same...");
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      other is FilledSheet &&
      other.runtimeType == runtimeType &&
      other.group == group &&
      other.lastName == lastName &&
      other.firstName == firstName &&
      other.rank == rank;

  @override
  int get hashCode => ("$group$lastName$firstName$rank").hashCode;

  @override
  String toString() =>
      "Group: $group,\nRank: $rank\nLastName: $lastName\nFirstName: $firstName\n votings: $votings";
}

FilledSheet readExcelTemplate(Project project, Excel excel) {
  var votingSheet = excel["Voting"];
  String group =
      votingSheet.cell(CellIndex.indexByString("B3")).value.toString();
  String rank =
      votingSheet.cell(CellIndex.indexByString("B4")).value.toString();
  String lastName =
      votingSheet.cell(CellIndex.indexByString("B5")).value.toString();
  String firstName =
      votingSheet.cell(CellIndex.indexByString("B6")).value.toString();

  if (group.isEmpty ||
      rank.isEmpty ||
      lastName.isEmpty ||
      firstName.isEmpty ||
      group == "Ausfüllen" ||
      rank == "Ausfüllen" ||
      lastName == "Ausfüllen" ||
      firstName == "Ausfüllen") {
    throw InvalidExcelInputException(
        errorMsg: InvalidExcelInput.invalidMetaData);
  }

  FilledSheet filledSheet = FilledSheet(
      group: group,
      firstName: firstName,
      lastName: lastName,
      rank: rank.replaceAll(" ", ""));

  int colIndex = 1;
  List<DateTime> dates = project.seminarPerDate.keys.toList();
  dates.sort();
  for (DateTime date in dates) {
    int rowIndex = 8;
    rowIndex += 1;
    for (Seminar seminar in project.seminarPerDate[date]!.toList()
      ..sort((a, b) => a.name!.compareTo(b.name!))) {
      double? readScore = double.tryParse(votingSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, rowIndex: rowIndex))
          .value
          .toString());
      if (readScore == null) {
        throw InvalidExcelInputException(
            errorMsg: InvalidExcelInput.invalidVoting,
            additionalInformation:
                "${seminar.name} am ${DateFormat("dd.MM.yyyy").format(seminar.date!)} mit Voting $readScore, read value: ${votingSheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex)).value.toString()}");
      }
      int score = readScore.toInt();
      if (score < -1 || score > 5) {
        throw InvalidExcelInputException(
            errorMsg: InvalidExcelInput.invalidVoting,
            additionalInformation:
                "${seminar.name} am ${DateFormat("dd.MM.yyyy").format(seminar.date!)} mit Voting $score");
      } else {
        filledSheet.addVoting(seminar, score);
      }
      rowIndex += 1;
    }
    colIndex += 3;
  }
  return filledSheet;
}

class InvalidExcelInputException implements Exception {
  InvalidExcelInput errorMsg;
  String? additionalInformation = "";

  InvalidExcelInputException(
      {required this.errorMsg, this.additionalInformation});
}

enum InvalidExcelInput {
  invalidMetaData,
  invalidVoting,
}

class FailedLoadings {
  String fileName;
  InvalidExcelInput failType;
  String errorMsg;

  FailedLoadings(
      {required this.fileName, required this.errorMsg, required this.failType});

  @override
  String toString() =>
      "fileName: $fileName, failType: $failType, errorMsg: $errorMsg";
}

class TuplePersonDate {
  FilledSheet filledSheet;
  DateTime date;

  TuplePersonDate({required this.filledSheet, required this.date});

  @override
  bool operator ==(Object other) =>
      other is TuplePersonDate &&
      other.runtimeType == runtimeType &&
      other.filledSheet == filledSheet &&
      other.date == date;

  @override
  int get hashCode =>
      ("${filledSheet.rank}${filledSheet.lastName}${filledSheet.firstName}${filledSheet.group}${date.toString()}")
          .hashCode;

  @override
  String toString() => "Person data: $filledSheet, date: $date";
}

class AdditionalInformation {
  int currentDifference = 0;
  Map<DateTime, Seminar> assignments = {};

  void addAssignment(DateTime date, Seminar seminar) {
    assignments[date] = seminar;
  }
}

void createAssignments(Project project, BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel-Auswertung wird erstellt...")));
  Directory appDir = await getApplicationDocumentsDirectory();
  String saveTitle = project.title!.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  // debugPrint(saveTitle);
  Directory dir = Directory("${appDir.path}/ssvs/$saveTitle/filledTemplates");
  List<FileSystemEntity> entities =
      await dir.list(recursive: true, followLinks: false).toList();
  List<FilledSheet> filledSheets = [];
  List<FailedLoadings> fails = [];
  for (var entity in entities) {
    if (FileSystemEntity.isFileSync(entity.path) &&
        entity.path.endsWith(".xlsx")) {
      var fileBytes = File(entity.path).readAsBytesSync();
      try {
        FilledSheet filledSheet =
            readExcelTemplate(project, Excel.decodeBytes(fileBytes));
        filledSheets.add(filledSheet);
      } on InvalidExcelInputException catch (e) {
        String fileName = entity.uri.pathSegments.last;
        fails.add(FailedLoadings(
            fileName: fileName,
            errorMsg: e.additionalInformation!,
            failType: e.errorMsg));
      }
    }
  }
  // retrieve base data for assigning
  Map<FilledSheet, List<DateTime>> noAttendance = {};
  List<TuplePersonDate> toAssign = [];
  List<TuplePersonDate> putAnywhere = [];

  for (FilledSheet sheet in filledSheets) {
    debugPrint("evaluating sheet for ${sheet.lastName}");
    Map<DateTime, Map<Seminar, int>> votingsPerDay = {};
    Map<DateTime, bool> attendancePerDay = {};
    for (Seminar seminar in sheet.votings.keys) {
      if (!attendancePerDay.containsKey(seminar.date)) {
        attendancePerDay[seminar.date!] = true;
      }
      if (!votingsPerDay.containsKey(seminar.date)) {
        votingsPerDay[seminar.date!] = {};
      }
      votingsPerDay[seminar.date!]![seminar] = sheet.votings[seminar]!;
      if (sheet.votings[seminar] == -1) {
        attendancePerDay[seminar.date!] = false;
      }
    }
    for (DateTime date in attendancePerDay.keys) {
      if (attendancePerDay[date]!) {
        bool eq = true;
        int current =
            votingsPerDay[date]![votingsPerDay[date]!.keys.toList()[0]]!;
        debugPrint("current: $current");
        for (Seminar seminar in votingsPerDay[date]!.keys) {
          if (eq) {
            eq = current == votingsPerDay[date]![seminar];
            debugPrint(
                "new eq for ${sheet.lastName}: $eq; because current=$current and voting=${votingsPerDay[date]![seminar]}");
          }
        }
        debugPrint("final eq for ${sheet.lastName}: $eq");
        if (eq) {
          putAnywhere.add(TuplePersonDate(filledSheet: sheet, date: date));
        } else {
          toAssign.add(TuplePersonDate(filledSheet: sheet, date: date));
        }
      } else {
        if (!noAttendance.containsKey(sheet)) {
          noAttendance[sheet] = [];
        }
        noAttendance[sheet]!.add(date);
      }
    }
  }

  List<int> validScores = [0, 1, 2, 3, 4, 5];
  for (DateTime date in project.seminarPerDate.keys.toList()..sort()) {
    List<Seminar> seminars = project.seminarPerDate[date]!.toList()
      ..sort((a, b) => a.name!.compareTo(b.name!));
    for (int score in validScores.reversed) {
      for (TuplePersonDate tuple
          in toAssign.where((element) => element.date == date)) {
        List<String> currentAssignmentNames = [];
        for (Seminar seminar
            in tuple.filledSheet.additionalInformation.assignments.values) {
          currentAssignmentNames.add(seminar.name!);
        }
        for (Seminar seminar in seminars
            .where((element) => tuple.filledSheet.votings[element]! == score)) {
          if (!currentAssignmentNames.contains(seminar.name)) {
            seminar.addVoting(
                tuple.filledSheet, tuple.filledSheet.votings[seminar]!);
          } else {
            debugPrint(
                "cant vote for seminar ${seminar.name} anymore as this seminar is already in ${tuple.filledSheet.lastName}'s assignments");
          }
        }
      }
      for (Seminar seminar in seminars) {
        if (seminar.assignments.length == seminar.maxPeople!) {
          seminar.votings.clear();
        } else if (seminar.votings.length + seminar.assignments.length <=
            seminar.maxPeople!) {
          for (FilledSheet filledSheet in seminar.votings.keys) {
            for (Seminar otherSeminar
                in seminars.where((element) => element != seminar)) {
              otherSeminar.votings.remove(filledSheet);
              /* debugPrint(
                  "removing ${filledSheet.lastName} from ${otherSeminar.name}"); */
            }
            seminar.addAssignment(filledSheet);
            filledSheet.additionalInformation.addAssignment(date, seminar);
            toAssign
                .remove(TuplePersonDate(filledSheet: filledSheet, date: date));
            int max_vote = 0;
            for (var elem in filledSheet.votings.entries
                .where((element) => element.key.date == date)) {
              max_vote = max(elem.value, max_vote);
            }
            filledSheet.additionalInformation.currentDifference +=
                (max_vote - filledSheet.votings[seminar]!);
          }
          seminar.votings.clear();
        } else {
          debugPrint(
              "CONFLICT seminar: ${seminar.name}::${seminar.date}, max: ${seminar.maxPeople}, assignments: ${seminar.assignments.length}, votings: ${seminar.votings.length}");
          for (FilledSheet filledSheet in seminar.votings.keys) {
            seminar.votings[filledSheet] = filledSheet.votings[seminar]! +
                filledSheet.additionalInformation.currentDifference;
            debugPrint(
                "new currentDifference evaluation for ${filledSheet.lastName} with value ${filledSheet.additionalInformation.currentDifference}");
          }

          List<int> values = seminar.votings.values.toList()..sort();
          values = values.reversed.toList();
          int min_value =
              values[seminar.maxPeople! - seminar.assignments.length];
          List<FilledSheet> assigned = [];
          for (FilledSheet filledSheet in seminar.votings.keys) {
            if (seminar.votings[filledSheet]! > min_value) {
              seminar.addAssignment(filledSheet);
              assigned.add(filledSheet);
              filledSheet.additionalInformation.addAssignment(date, seminar);
            }
          }
          int amountLeftToAssign =
              seminar.maxPeople! - seminar.assignments.length;
          List<FilledSheet> leftToAssign = seminar.votings.keys
              .where((element) =>
                  !assigned.contains(element) &&
                  seminar.votings[element] == min_value)
              .toList();
          for (int i = 0; i < amountLeftToAssign; i++) {
            FilledSheet randChoice =
                leftToAssign[Random().nextInt(leftToAssign.length)];
            seminar.addAssignment(randChoice);
            assigned.add(randChoice);
            randChoice.additionalInformation.addAssignment(date, seminar);
            leftToAssign.remove(randChoice);
          }
          for (FilledSheet filledSheet in assigned) {
            for (Seminar otherSeminar
                in seminars.where((element) => element != seminar)) {
              /* debugPrint(
                  "removing ${filledSheet.lastName} from ${otherSeminar.name}"); */
              otherSeminar.votings.remove(filledSheet);
            }
            filledSheet.additionalInformation.currentDifference = max(
                0,
                filledSheet.additionalInformation.currentDifference -
                    (filledSheet.votings[seminar]! - min_value + 1));
            toAssign
                .remove(TuplePersonDate(filledSheet: filledSheet, date: date));
          }
          seminar.votings.clear();
        }
      }
    }
    debugPrint("PutAnywhere List: $putAnywhere");
    for (Seminar seminar in seminars) {
      List<TuplePersonDate> assigned = [];
      for (TuplePersonDate tuple
          in putAnywhere.where((element) => element.date == date)) {
        List<String> currentAssignmentNames = [];
        for (Seminar seminar
            in tuple.filledSheet.additionalInformation.assignments.values) {
          currentAssignmentNames.add(seminar.name!);
        }
        if (seminar.maxPeople! > seminar.assignments.length &&
            !currentAssignmentNames.contains(seminar.name)) {
          seminar.addAssignment(tuple.filledSheet);
          tuple.filledSheet.additionalInformation.addAssignment(date, seminar);
          assigned.add(tuple);
          debugPrint(
              "added ${tuple.filledSheet.lastName} to ${seminar.name} because equality");
        }
      }
      for (TuplePersonDate tuple in assigned) {
        putAnywhere.remove(tuple);
        debugPrint(
            "removed ${tuple.filledSheet.lastName} from list because equality");
      }
    }
  }

  // generate output excel
  var excel = Excel.createExcel();
  //excel.rename("Sheet1", "Seminare");
  //excel.copy("Seminare", "Voting");

  CellStyle titleStyle = CellStyle(bold: true, fontSize: 16);
  CellStyle listStyle = CellStyle(fontSize: 12);
  CellStyle listTitleStyle = CellStyle(bold: true, fontSize: 12);
  CellStyle listTitleStyleBigger = CellStyle(bold: true, fontSize: 14);

  for (DateTime date in project.seminarPerDate.keys.toList()..sort()) {
    for (Seminar seminar in project.seminarPerDate[date]!.toList()
      ..sort((a, b) => a.name!.compareTo(b.name!))) {
      final String sheetName =
          "${DateFormat("dd.MM.yyyy").format(date)}, ${seminar.name}";
      excel.copy("Sheet1", sheetName);
      Sheet sheet = excel[sheetName];
      sheet.cell(CellIndex.indexByString("A1"))
        ..value = "${seminar.name} am ${DateFormat("dd.MM.yyyy").format(date)}"
        ..cellStyle = titleStyle;
      sheet.cell(CellIndex.indexByString("A3"))
        ..value = "Teilnehmer"
        ..cellStyle = listTitleStyleBigger;
      sheet.cell(CellIndex.indexByString("A4"))
        ..value = "Hörsaal"
        ..cellStyle = listTitleStyle;
      sheet.cell(CellIndex.indexByString("B4"))
        ..value = "Dienstgrad"
        ..cellStyle = listTitleStyle;
      sheet.cell(CellIndex.indexByString("C4"))
        ..value = "Name"
        ..cellStyle = listTitleStyle;
      sheet.cell(CellIndex.indexByString("D4"))
        ..value = "Vorname"
        ..cellStyle = listTitleStyle;
      int row = 4;
      List<FilledSheet> sheets = seminar.assignments
        ..sort((a, b) => a.compareTo(b));
      for (FilledSheet filledSheet in sheets) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          ..value = filledSheet.group
          ..cellStyle = listStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          ..value = filledSheet.rank
          ..cellStyle = listStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          ..value = filledSheet.lastName
          ..cellStyle = listStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          ..value = filledSheet.firstName
          ..cellStyle = listStyle;
        row++;
      }
    }
  }

  excel.copy("Sheet1", "Keine Teilnahme");
  Sheet sheetNoAttendance = excel["Keine Teilnahme"];
  sheetNoAttendance.cell(CellIndex.indexByString("A1"))
    ..value = "Keine Teilnehmer"
    ..cellStyle = titleStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("A2"))
    ..value =
        "Liste aller Teilnehmer, die an mindestens einem Tag nicht teilnehmen"
    ..cellStyle = listStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("A4"))
    ..value = "Hörsaal"
    ..cellStyle = listTitleStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("B4"))
    ..value = "Dienstgrad"
    ..cellStyle = listTitleStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("C4"))
    ..value = "Name"
    ..cellStyle = listTitleStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("D4"))
    ..value = "Vorname"
    ..cellStyle = listTitleStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("E4"))
    ..value = "Daten"
    ..cellStyle = listTitleStyle;
  int row = 4;
  noAttendance.forEach((filledSheet, dates) {
    sheetNoAttendance
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = filledSheet.group
      ..cellStyle = listStyle;
    sheetNoAttendance
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = filledSheet.rank
      ..cellStyle = listStyle;
    sheetNoAttendance
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
      ..value = filledSheet.lastName
      ..cellStyle = listStyle;
    sheetNoAttendance
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
      ..value = filledSheet.firstName
      ..cellStyle = listStyle;
    String stringDates = "";
    for (DateTime date in dates) {
      stringDates += DateFormat("dd.MM.yyyy").format(date);
      stringDates += "; ";
    }
    stringDates = stringDates.trim();
    if (stringDates.isNotEmpty) {
      stringDates = stringDates.substring(0, stringDates.length - 1);
    }
    sheetNoAttendance
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
      ..value = stringDates
      ..cellStyle = listStyle;
    row++;
  });
  excel.copy("Sheet1", "Ungültige");
  Sheet sheetInvalids = excel["Ungültige"];
  sheetInvalids.cell(CellIndex.indexByString("A1"))
    ..value = "Ungültige Templates"
    ..cellStyle = titleStyle;
  sheetInvalids.cell(CellIndex.indexByString("A2"))
    ..value = "Liste aller Excel-Tabellen, die ungültig sind"
    ..cellStyle = listStyle;
  sheetInvalids.cell(CellIndex.indexByString("A4"))
    ..value = "Dateiname"
    ..cellStyle = listTitleStyle;
  sheetInvalids.cell(CellIndex.indexByString("B4"))
    ..value = "Fehlertyp"
    ..cellStyle = listTitleStyle;
  sheetInvalids.cell(CellIndex.indexByString("C4"))
    ..value = "Weitere Informationen"
    ..cellStyle = listTitleStyle;
  row = 4;
  for (FailedLoadings failedLoadings in fails) {
    sheetInvalids
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = failedLoadings.fileName
      ..cellStyle = listStyle;
    sheetInvalids
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = failedLoadings.failType == InvalidExcelInput.invalidMetaData
          ? "Ungültige persönliche Daten"
          : "Ungültiges Wahlfeld"
      ..cellStyle = listStyle;
    sheetInvalids
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
      ..value = failedLoadings.errorMsg
      ..cellStyle = listStyle;
    row++;
  }

  Map<String, List<FilledSheet>> groups = {};

  for (FilledSheet filledSheet in filledSheets) {
    if (!groups.containsKey(filledSheet.group)) {
      groups[filledSheet.group] = [];
    }
    groups[filledSheet.group]!.add(filledSheet);
  }

  for (String group in groups.keys) {
    excel.copy("Sheet1", "Hörsaal $group");
    Sheet currentSheet = excel["Hörsaal $group"];
    currentSheet.cell(CellIndex.indexByString("A1"))
      ..value = "Hörsaalliste $group"
      ..cellStyle = titleStyle;
    int colIndex = 3;
    Map<DateTime, int> dateIndexMap = {};
    currentSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 2))
      ..value = "Seminare"
      ..cellStyle = listTitleStyleBigger;
    for (DateTime date in project.seminarPerDate.keys.toList()..sort()) {
      dateIndexMap[date] = colIndex;
      currentSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 3))
        ..value = DateFormat("dd.MM.yyyy").format(date)
        ..cellStyle = listTitleStyle;
      colIndex++;
    }
    currentSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
      ..value = "Teilnehmer"
      ..cellStyle = listTitleStyleBigger;
    currentSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
      ..value = "Dienstgrad"
      ..cellStyle = listTitleStyle;
    currentSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
      ..value = "Nachname"
      ..cellStyle = listTitleStyle;
    currentSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3))
      ..value = "Vorname"
      ..cellStyle = listTitleStyle;

    int rowIndex = 4;
    List<FilledSheet> sortedGroup = groups[group]!.toList()
      ..sort(
        (a, b) => a.compareTo(b),
      );
    for (FilledSheet filledSheet in sortedGroup) {
      currentSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = filledSheet.rank
        ..cellStyle = listStyle;
      currentSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = filledSheet.lastName
        ..cellStyle = listStyle;
      currentSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = filledSheet.firstName
        ..cellStyle = listStyle;
      for (DateTime date
          in filledSheet.additionalInformation.assignments.keys) {
        currentSheet.cell(CellIndex.indexByColumnRow(
            columnIndex: dateIndexMap[date], rowIndex: rowIndex))
          ..value = filledSheet.additionalInformation.assignments[date]!.name
          ..cellStyle = listStyle;
      }
      rowIndex++;
    }
  }

  excel.rename("Sheet1", "Übersicht");
  Sheet mainSheet = excel["Übersicht"];
  mainSheet.cell(CellIndex.indexByString("A1"))
    ..value = project.title
    ..cellStyle = titleStyle;
  mainSheet.cell(CellIndex.indexByString("A2"))
    ..value = project.subtitle
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("A4"))
    ..value = "Gesamt"
    ..cellStyle = listTitleStyleBigger;
  mainSheet.cell(CellIndex.indexByString("A5"))
    ..value = "Anzahl gültiger Teilnehmer"
    ..cellStyle = listTitleStyle;
  mainSheet.cell(CellIndex.indexByString("A6"))
    ..value = "Anzahl ungültiger Templates"
    ..cellStyle = listTitleStyle;
  mainSheet.cell(CellIndex.indexByString("A7"))
    ..value = "Anzahl Nicht-Teilnahmen"
    ..cellStyle = listTitleStyle;

  mainSheet.cell(CellIndex.indexByString("B5"))
    ..value = filledSheets.length
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("B6"))
    ..value = fails.length
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("B7"))
    ..value = noAttendance.length
    ..cellStyle = listStyle;

  mainSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 8))
    ..value = "Je Hörsaal"
    ..cellStyle = listTitleStyleBigger;

  int rowIndex = 9;
  int colIndex = 0;
  for (String group in groups.keys.toList()..sort()) {
    mainSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
      ..value = "Hörsaal $group"
      ..cellStyle = listTitleStyle;
    mainSheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex, rowIndex: rowIndex + 1))
      ..value = "Anzahl gültiger Teilnehmer"
      ..cellStyle = listTitleStyle;
    mainSheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex, rowIndex: rowIndex + 2))
      ..value = "Anzahl Nicht-Teilnahmen"
      ..cellStyle = listTitleStyle;
    mainSheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex + 1, rowIndex: rowIndex + 1))
      ..value = groups[group]!.length
      ..cellStyle = listStyle;
    mainSheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex + 1, rowIndex: rowIndex + 2))
      ..value =
          noAttendance.keys.where((element) => element.group == group).length
      ..cellStyle = listStyle;
    colIndex += 3;
  }

  excel.setDefaultSheet("Übersicht");

  String save_path =
      "${appDir.path}/ssvs/$saveTitle/${saveTitle}_Auswertung.xlsx";

  var fileBytes = excel.save();
  File(save_path).createSync(recursive: true);
  File(save_path).writeAsBytesSync(fileBytes!);

  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel-Auswertung wurde erstellt")));

/*   for (DateTime date in project.seminarPerDate.keys) {
    for (Seminar seminar in project.seminarPerDate[date]!) {
      debugPrint(
          "Date: $date, Seminar: ${seminar.name},  ${seminar.assignments}");
    }
  }
  for (FilledSheet filledSheet in filledSheets) {
    debugPrint(
        "Name: ${filledSheet.lastName}, sheets: ${filledSheet.additionalInformation.assignments}");
  } */
}
