import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = "https://gw.apiflow.online/api/1358f420ae2e4df794a4b4b49f53d042";
  static const String _token = "Bearer ODAxMDdlMTQ1YTJlYmFhNjZjOGZiMjQ1MDRmNmY0MGQ6YTE3NjFiOTRjODM3NmE3ODNiZjVhNWU4NDlhZjlmZmQ=";

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/$endpoint"),
        headers: {
          "Authorization": _token,
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 204) return null;
      if (response.statusCode != 200) {
        throw Exception("Erro na API (${response.statusCode}): ${response.body}");
      }
      
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } catch (e) {
      print('Erro na requisição POST: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final uri = Uri.parse("$_baseUrl/$endpoint").replace(
        queryParameters: params?.map((k, v) => MapEntry(k, v.toString())),
      );

      final response = await http.get(
        uri, 
        headers: {"Authorization": _token}
      );
      
      if (response.statusCode != 200) {
        throw Exception("Erro na API (${response.statusCode}): ${response.body}");
      }
      
      if (response.body.isEmpty) return [];
      return jsonDecode(response.body);
    } catch (e) {
      print('Erro na requisição GET: $e');
      rethrow;
    }
  }
}