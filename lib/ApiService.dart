import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  ApiService();

  Future<dynamic> fetchBlogs() async {
    const String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    const String adminSecret = '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      if (response.statusCode == 200) {
        // Request successful, handle the response data here
        print('Response data: ${response.body}');
        return json.decode(response.body)['blogs'];
      } else {
        // Request failed
        print('Request failed with status code: ${response.statusCode}');
        print('Response data: ${response.body}');
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      print('Error: $e');
    }
  }
}
class BlogItem {
  final String id;
  final String imageUrl;
  final String title;

  BlogItem({
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
    };
  }

}
