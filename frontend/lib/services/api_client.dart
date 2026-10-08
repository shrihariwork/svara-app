import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  // Use 10.0.2.2 for Android emulator testing, or change to your local IP for physical devices
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  static Future<String?> calibrate(File audioFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/calibrate'));
      request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['reference_id'];
      }
    } catch (e) {
      print("Calibration Error: $e");
    }
    return null;
  }
  
  static Future<String?> synthesize(String shlokaId, String referenceId, String downloadPath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/synthesize'));
      request.fields['shloka_id'] = shlokaId;
      request.fields['reference_id'] = referenceId;
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        final file = File(downloadPath);
        var bytes = await response.stream.toBytes();
        await file.writeAsBytes(bytes);
        return downloadPath;
      }
    } catch (e) {
      print("Synthesis Error: $e");
    }
    return null;
  }
}
