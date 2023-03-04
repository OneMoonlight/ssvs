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
  String save_path = "${appDir.path}/ssvs/template_$saveTitle.xlsx";

  var excel = Excel.createExcel();
  excel.rename("Sheet1", "Seminare");
  excel.copy("Seminare", "Voting");

  Sheet votingSheet = excel["Voting"];
  Sheet seminarSheet = excel["Seminare"];

  CellStyle titleStyle = CellStyle(bold: true, fontSize: 16);
  CellStyle metaDataStyle = CellStyle(bold: true, fontSize: 12);
  CellStyle metaDataInputStyle =
      CellStyle(fontSize: 12, fontColorHex: "f16a00");
  CellStyle informationStyle = CellStyle(
      fontSize: 10,
      textWrapping: TextWrapping.WrapText,
      verticalAlign: VerticalAlign.Top,
      horizontalAlign: HorizontalAlign.Left);

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

  votingSheet.merge(
      CellIndex.indexByString("D3"), CellIndex.indexByString("G6"));
  votingSheet.cell(CellIndex.indexByString("D3"))
    ..value = "Beschreibungstext"
    ..cellStyle = informationStyle;

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
    for (Seminar seminar in project.seminarPerDate[date]!) {
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
      group: group, firstName: firstName, lastName: lastName, rank: rank);

  int colIndex = 1;
  List<DateTime> dates = project.seminarPerDate.keys.toList();
  dates.sort();
  for (DateTime date in dates) {
    int rowIndex = 8;
    rowIndex += 1;
    for (Seminar seminar in project.seminarPerDate[date]!) {
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

//void createAssignments(Directory dir, Project project) async { change to this later TODO
void createAssignments(Project project, BuildContext context) async {
  // run through directory recursivly TODO: add
  Directory appDir = await getApplicationDocumentsDirectory();
  Directory dir = Directory("${appDir.path}/ssvs/testData");
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

  for (FilledSheet sheet in filledSheets) {
    Map<DateTime, Map<Seminar, int>> votingsPerDay = {};
    Map<DateTime, bool> attendancePerDay = {};
    for (Seminar seminar in sheet.votings.keys) {
      if (!attendancePerDay.containsKey(seminar.date)) {
        attendancePerDay[seminar.date!] = true;
      }
      votingsPerDay[seminar.date!] = {seminar: sheet.votings[seminar]!};
      if (sheet.votings[seminar] == -1) {
        attendancePerDay[seminar.date!] = false;
      }
    }
    for (DateTime date in attendancePerDay.keys) {
      if (attendancePerDay[date]!) {
        toAssign.add(TuplePersonDate(filledSheet: sheet, date: date));
      } else {
        if (!noAttendance.containsKey(sheet)) {
          noAttendance[sheet] = [];
        }
        noAttendance[sheet]!.add(date);
      }
    }
    //debugPrint("attendance: $attendancePerDay");
    //debugPrint("toAssign: ${toAssign.length}");
  }

  List<int> validScores = [0, 1, 2, 3, 4, 5];
  for (DateTime date in project.seminarPerDate.keys.toList()..sort()) {
    List<Seminar> seminars = project.seminarPerDate[date]!;
    for (int score in validScores.reversed) {
      for (TuplePersonDate tuple
          in toAssign.where((element) => element.date == date)) {
        for (Seminar seminar in seminars
            .where((element) => tuple.filledSheet.votings[element]! == score)) {
          seminar.addVoting(
              tuple.filledSheet, tuple.filledSheet.votings[seminar]!);
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
              debugPrint(
                  "remove ${filledSheet.lastName} from ${otherSeminar.name} at ${otherSeminar.date}");
              otherSeminar.votings.remove(filledSheet);
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
          for (FilledSheet filledSheet in seminar.votings.keys) {
            seminar.votings[filledSheet] = filledSheet.votings[seminar]! +
                filledSheet.additionalInformation.currentDifference;
          }
          List<int> values = seminar.votings.values.toList()..sort();
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
              debugPrint(
                  "remove ${filledSheet.lastName} from ${otherSeminar.name} at ${otherSeminar.date}");
              otherSeminar.votings.remove(filledSheet);
            }
            filledSheet.additionalInformation.currentDifference -=
                (filledSheet.votings[seminar]! - min_value + 1);
            toAssign
                .remove(TuplePersonDate(filledSheet: filledSheet, date: date));
          }
          seminar.votings.clear();
        }
      }
    }
  }

  // generate output excel
  var excel = Excel.createExcel();
  //excel.rename("Sheet1", "Seminare");
  //excel.copy("Seminare", "Voting");

  CellStyle titleStyle = CellStyle(bold: true, fontSize: 16);
  CellStyle listStyle = CellStyle(fontSize: 12);

  for (DateTime date in project.seminarPerDate.keys.toList()..sort()) {
    for (Seminar seminar in project.seminarPerDate[date]!) {
      final String sheetName =
          "${DateFormat("dd.MM.yyyy").format(date)}, ${seminar.name}";
      excel.copy("Sheet1", sheetName);
      Sheet sheet = excel[sheetName];
      sheet.cell(CellIndex.indexByString("A1"))
        ..value = "${seminar.name} am ${DateFormat("dd.MM.yyyy").format(date)}"
        ..cellStyle = titleStyle;
      sheet.cell(CellIndex.indexByString("A3"))
        ..value = "Teilnehmer"
        ..cellStyle = listStyle;
      sheet.cell(CellIndex.indexByString("A4"))
        ..value = "Hörsaal"
        ..cellStyle = listStyle;
      sheet.cell(CellIndex.indexByString("B4"))
        ..value = "Dienstgrad"
        ..cellStyle = listStyle;
      sheet.cell(CellIndex.indexByString("C4"))
        ..value = "Name"
        ..cellStyle = listStyle;
      sheet.cell(CellIndex.indexByString("D4"))
        ..value = "Vorname"
        ..cellStyle = listStyle;
      int row = 4;
      for (FilledSheet filledSheet in seminar.assignments) {
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
    ..cellStyle = listStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("B4"))
    ..value = "Dienstgrad"
    ..cellStyle = listStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("C4"))
    ..value = "Name"
    ..cellStyle = listStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("D4"))
    ..value = "Vorname"
    ..cellStyle = listStyle;
  sheetNoAttendance.cell(CellIndex.indexByString("E4"))
    ..value = "Daten"
    ..cellStyle = listStyle;
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
      stringDates += ";";
    }
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
    ..cellStyle = listStyle;
  sheetInvalids.cell(CellIndex.indexByString("B4"))
    ..value = "Fehlertyp"
    ..cellStyle = listStyle;
  sheetInvalids.cell(CellIndex.indexByString("C4"))
    ..value = "Weitere Informationen"
    ..cellStyle = listStyle;
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

  excel.rename("Sheet1", "Übersicht");
  Sheet mainSheet = excel["Übersicht"];
  mainSheet.cell(CellIndex.indexByString("A1"))
    ..value = project.title
    ..cellStyle = titleStyle;
  mainSheet.cell(CellIndex.indexByString("A2"))
    ..value = project.subtitle
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("A4"))
    ..value = "Anzahl gültiger Teilnehmer"
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("A5"))
    ..value = "Anzahl ungültiger Templates"
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("A6"))
    ..value = "Anzahl Nicht-Teilnahmen"
    ..cellStyle = listStyle;

  mainSheet.cell(CellIndex.indexByString("B4"))
    ..value = filledSheets.length
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("B5"))
    ..value = fails.length
    ..cellStyle = listStyle;
  mainSheet.cell(CellIndex.indexByString("B6"))
    ..value = noAttendance.length
    ..cellStyle = listStyle;

  excel.setDefaultSheet("Übersicht");

  String saveTitle = project.title!.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  String save_path = "${appDir.path}/ssvs/${saveTitle}_Auswertung.xlsx";

  var fileBytes = excel.save();
  File(save_path).createSync(recursive: true);
  File(save_path).writeAsBytesSync(fileBytes!);
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel-Auswertung wurde erstellt")));

  for (DateTime date in project.seminarPerDate.keys) {
    for (Seminar seminar in project.seminarPerDate[date]!) {
      debugPrint(
          "Date: $date, Seminar: ${seminar.name},  ${seminar.assignments}");
    }
  }
  for (FilledSheet filledSheet in filledSheets) {
    debugPrint("sheets ${filledSheet.additionalInformation.assignments}");
  }
}
