import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

class FileDownloader extends StatelessWidget {
/*
class FileDownloader extends StatefulWidget {
  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader> {
  String _output = 'Output will appear here';

  void _createFile() async {
    if (await _requestPermission()) {
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final file = File('${directory.path}/example.txt');
          await file.writeAsString('This is an example file content.');

          setState(() {
            _output = 'File "example.txt" created successfully.';
          });
        } else {
          setState(() {
            _output = 'Error: Unable to access external storage.';
          });
        }
      } catch (e) {
        setState(() {
          _output = 'Error: $e';
        });
      }
    } else {
      setState(() {
        _output = 'Permission not granted. Cannot create file.';
      });
    }
  }

*/

  String extractSS0809String(String fileName) {
    // Split the fileName by hyphens to separate the parts.
    List<String> parts = fileName.split('/');

    // Return the part before the first forward slash.
    if (parts.isNotEmpty) {
      return parts.first;
    }

    // If no forward slash is found, return an empty string or handle the error as needed.
    return '';
  }

  Future<void> renameDirectory(String oldName, String newName) async {
    final directory = Directory(oldName);

    if (await directory.exists()) {
      final newPath = directory.parent.path + Platform.pathSeparator + newName;
      await directory.rename(newPath);
      print('Directory renamed from "$oldName" to "$newName".');
    } else {
      print('Directory "$oldName" not found.');
    }
  }

  void cloner() async {
    String repositoryOwner = 'ss0809';
    String repositoryName = 'test_file_flutter';
    String branchName = 'main';
    String accessToken = '';
    String oldDirectoryName = 'test';
    final url = Uri.parse(
        'https://api.github.com/repos/$repositoryOwner/$repositoryName/zipball/$branchName');

    final headers = {
      'Accept': 'application/vnd.github+json',
      'Authorization': 'Bearer $accessToken',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final zipFilePath = '${directory.path}/$repositoryName.zip';
        final file = File(zipFilePath);
        await file.writeAsBytes(response.bodyBytes);
        print('File downloaded and saved to external storage successfully.');

        // Extract the ZIP file
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);
        for (final file in archive) {
          print(file.name);
          print(extractSS0809String(file.name));
          oldDirectoryName =
              directory.path + '/' + extractSS0809String(file.name) + '/';
          final filename = '${directory.path}/${file.name}';
          if (file.isFile) {
            final outFile = File(filename);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content);
          }
        }
        await renameDirectory(oldDirectoryName, repositoryName);

//TODO
        // Delete all files except the folders
        /*  final folder = Directory('${directory.path}/$repositoryName');
      if (await folder.exists()) {
        await for (final entity in folder.list(recursive: true)) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }*/

        print('ZIP file extracted successfully.');

        // List of folders to move contents from
        List<String> folders = ["folder1", "folder2", "folder3", "folder4"];

        // Get the external storage directory
        Directory? externalStorageDir = await getExternalStorageDirectory();
        if (externalStorageDir == null) {
          print("External storage directory is not accessible.");
          return;
        }

        // Iterate through each folder
        for (String folder in folders) {
          // Check if the folder exists
          final folderPath = path.join(externalStorageDir.path, folder);
          final folderDir = Directory(folderPath);

          if (await folderDir.exists()) {
            // Move contents of the folder to the root directory
            await moveContentsToRoot(folderDir);
          } else {
            print("Folder '$folder' does not exist.");
          }
        }

        // Concatenate all .txt files into randomfile.mp4
        await concatenateTxtFiles(repositoryName + '.mp4');
        print("cool it ended");
      } else {
        print('Error: Unable to access external storage.');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> moveContentsToRoot(Directory folderDir) async {
    // Get the current working directory
    final currentDir = Directory.current;

    // Move contents of the folder to the root directory
    await for (var entity in folderDir.list()) {
      if (entity is File) {
        await entity
            .rename(path.join(currentDir.path, path.basename(entity.path)));
      }
    }

    // Remove the now-empty folder
    await folderDir.delete();
  }

  Future<void> concatenateTxtFiles(String randomfile) async {
    final currentDir = Directory.current;
    final txtFiles = await currentDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.txt'))
        .toList();

    if (txtFiles.isNotEmpty) {
      final outputFile = File(path.join(currentDir.path, randomfile));
      final outputSink = outputFile.openWrite();

      for (var txtFile in txtFiles) {
        if (txtFile is File) {
          final contents = await txtFile.readAsString();
          final encodedContents = utf8.encode(contents);
          outputSink.add(encodedContents); // Write the bytes to the output file
        }
      }

      await outputSink.close();
    }
  }

  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*ElevatedButton(
        onPressed: () {
          // Call the cloner function or any other functionality you want.
          cloner();
        },
        child: Text('Clone and extract'),
      ),*/
          // Add the image here
          Image.asset('assets/asset2.jpeg', width: 450, height: 450),
          SizedBox(
              height: 20), // Add some spacing between the image and the text
          Text(
            'Currently under Development\n----Login option \n----Download option',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
