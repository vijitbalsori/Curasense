import 'dart:io';
import 'package:http/http.dart' as http;

const String API_BASE = "http://localhost:8000";

class ApiService {
  /// Handles lab, prescription, discharge summary uploads
  Future<Map<String, dynamic>> uploadFile({
    required String module,      // "lab", "prescription", "discharge"
    required String patientId,
    required List<File> files,
    required String question,
  }) async {
    try {
      late Uri uri;

      // Correct backend routes
      if (module == "lab") {
        uri = Uri.parse("$API_BASE/lab");
      } else if (module == "prescription") {
        uri = Uri.parse("$API_BASE/prescription");
      } else if (module == "discharge") {
        uri = Uri.parse("$API_BASE/summary");
      } else {
        throw Exception("Unknown module: $module");
      }

      var request = http.MultipartRequest("POST", uri);

      // Add question: backend expects q
      request.fields["q"] = question;

      // Add files
      if (module == "discharge") {
        // multiple files
        for (var f in files) {
          request.files.add(
            await http.MultipartFile.fromPath("files", f.path),
          );
        }
      } else {
        // single file
        request.files.add(
          await http.MultipartFile.fromPath("file", files.first.path),
        );
      }

      // Send request
      var streamed = await request.send();
      var respStr = await streamed.stream.bytesToString();

      return {
        "ok": streamed.statusCode == 200,
        "statusCode": streamed.statusCode,
        "body": respStr,
      };

    } catch (e) {
      return {"ok": false, "error": e.toString()};
    }
  }

  /// General medical Q&A
  Future<Map<String, dynamic>> queryGeneral(String question) async {
    try {
      var uri = Uri.parse("$API_BASE/general?q=$question");
      var resp = await http.get(uri);

      return {
        "ok": resp.statusCode == 200,
        "statusCode": resp.statusCode,
        "body": resp.body,
      };
    } catch (e) {
      return {"ok": false, "error": e.toString()};
    }
  }
}
