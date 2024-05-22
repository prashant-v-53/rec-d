import 'package:http/http.dart' as http;

class BookRepo {
  Future fetchBook({String id}) async {
    try {
      String url = "https://www.googleapis.com/books/v1/volumes/$id";

      final response = await http.get(url);
      return response;
    } catch (e) {
      return null;
    }
  }
}
