import 'dart:io';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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
    /* votingSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: colIndex, rowIndex: rowIndex))
        .value = DateFormat("dd.MM.yyyy").format(date); */
    rowIndex += 1;
    for (Seminar seminar in project.seminarPerDate[date]!) {
      /* votingSheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex - 1, rowIndex: rowIndex))
        ..value = seminar.name
        ..cellStyle = CellStyle(bold: true); */
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
                "${seminar.name} am ${DateFormat("dd.MM.yyyy").format(seminar.date!)} mit Voting $score, read value: ${votingSheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex)).value.toString()}");
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

//void createAssignments(Directory dir, Project project) async { change to this later TODO
void createAssignments(Project project) async {
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
        debugPrint(filledSheet.toString());
      } on InvalidExcelInputException catch (e) {
        String fileName = entity.uri.pathSegments.last;
        fails.add(FailedLoadings(
            fileName: fileName,
            errorMsg: e.additionalInformation!,
            failType: e.errorMsg));
      }
    }
  }
}
