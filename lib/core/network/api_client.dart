import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Future<String?> Function()? tokenProvider;
  ApiClient({required this.baseUrl, this.tokenProvider});

  Future<Map<String, String>> _headers() async {
    final h = {'Content-Type': 'application/json'};
    final t = await tokenProvider?.call();
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    return h;
  }

  Future<dynamic> get(String path) async {
    final r = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (r.statusCode >= 400) throw Exception('GET $path => ${r.statusCode}: ${r.body}');
    return json.decode(r.body.isEmpty ? 'null' : r.body);
  }

  Future<dynamic> post(String path, Map body) async {
    final r = await http.post(Uri.parse('$baseUrl$path'),
        headers: await _headers(), body: json.encode(body));
    if (r.statusCode >= 400) throw Exception('POST $path => ${r.statusCode}: ${r.body}');
    return json.decode(r.body.isEmpty ? 'null' : r.body);
  }

  Future<dynamic> put(String path, Map body) async {
    final r = await http.put(Uri.parse('$baseUrl$path'),
        headers: await _headers(), body: json.encode(body));
    if (r.statusCode >= 400) throw Exception('PUT $path => ${r.statusCode}: ${r.body}');
    return json.decode(r.body.isEmpty ? 'null' : r.body);
  }

  Future<void> delete(String path) async {
    final r = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (r.statusCode >= 400) throw Exception('DELETE $path => ${r.statusCode}: ${r.body}');
  }
}
