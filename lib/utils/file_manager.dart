import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'utils.dart';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static FileManager? _instance;

  FileManager._internal() {
    _instance = this;
  }

  factory FileManager() => _instance ?? FileManager._internal();

  Future<String> checkDirectory(String map) async {
    Directory? directory = await getExternalStorageDirectory();

    if (directory == null) {
      printY("ERROR_NO_DIRECTORY");
      return "ERROR_NO_DIRECTORY";
    } else {
      Directory? directory1 = Directory("${directory.path}/$map");
      while (directory1 == null) {
        directory1 =
            await Directory("${directory.path}/$map").create(recursive: true);
        log(directory1.path);
      }
      if (!directory1.existsSync()) {
        directory1 =
            await Directory("${directory.path}/$map").create(recursive: true);
      }
      log(directory1.toString());
      return directory1.path;
    }
  }

  Future<String> _directoryPath(String fileName, String map) async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      printY("ERROR_NO_DIRECTORY");
      return "ERROR_NO_DIRECTORY";
    } else {
      return "${directory.path}/$map";
    }
  }

  Future<File> _file(String fileName, String map) async {
    final path = await _directoryPath(fileName, map);
    File file = File("$path/$fileName");

    if (!file.existsSync()) {
      // create the file and save it in external storage
      File('$path/$fileName').create(recursive: true);
    }
    return file;
  }

  Future<Map<dynamic, dynamic>> readJsonFile(
      String fileName, String map) async {
    String fileContent = "ERROR_NO_CONTENT_IN_FILE";
    File file = await _file(fileName, map);
    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
      } catch (e) {
        printY(e.toString());
      }
    }
    return json.decode(fileContent);
  }

  Future<String> writeJsonFile(
      Map<dynamic, dynamic> data, String fileName, String map) async {
    File file = await _file(fileName, map);
    await file.writeAsString(json.encode(data));
    return "";
  }

  Future<String> readTextFile(String fileName, String map) async {
    String fileContent = "lll";
    File file = await _file(fileName, map);
    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
      } catch (e) {
        printY(e.toString());
      }
    }
    return fileContent;
  }

  Future<String> writeTextFile(String text, String fileName, String map) async {
    File file = await _file(fileName, map);
    await file.writeAsString(text);
    return text;
  }
}
