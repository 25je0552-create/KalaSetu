import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StudioApiService {
  /// Default server URL.
  /// For Android Emulator: "http://10.0.2.2:8000"
  /// For iOS Simulator / Web: "http://127.0.0.1:8000"
  /// For Localtunnel / Ngrok: Replace with your public tunnel URL e.g. "https://kalasetu-studio.loca.lt"
  static String baseUrl = kIsWeb
      ? "http://127.0.0.1:8000"
      : (Platform.isAndroid ? "http://10.0.2.2:8000" : "http://127.0.0.1:8000");

  /// Sends raw image file to FastAPI (united.py Module 1 pipeline)
  /// and returns processed Uint8List image bytes.
  ///
  /// Wrapped in error handling & timeout so that any network or ML failure
  /// gracefully returns null and falls back to the original photo.
  static Future<Uint8List?> transformStudioImage(File imageFile, {Duration timeout = const Duration(seconds: 20)}) async {
    try {
      if (!imageFile.existsSync()) {
        debugPrint('[StudioApiService] File does not exist: ${imageFile.path}');
        return null;
      }

      final uri = Uri.parse("$baseUrl/api/v1/studio-transform");
      debugPrint('[StudioApiService] Sending craft photo to ML pipeline: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add image file to multipart request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Bypasses Localtunnel reminder splash page if active
      request.headers['Bypass-Tunnel-Remainder'] = 'true';

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint('[StudioApiService] ML transformation successful (${response.bodyBytes.length} bytes)');
        return response.bodyBytes;
      } else {
        debugPrint('[StudioApiService] Studio API Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } on TimeoutException catch (te) {
      debugPrint('[StudioApiService] Request timed out after $timeout: $te');
      return null;
    } on SocketException catch (se) {
      debugPrint('[StudioApiService] Network connection failed (server offline): $se');
      return null;
    } catch (e, stack) {
      debugPrint('[StudioApiService] Unexpected error in transformStudioImage: $e\n$stack');
      return null;
    }
  }
}
