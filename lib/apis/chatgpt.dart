import 'package:http/http.dart' as http;

Future<ChatGPT> callChatGPT(String title) async {
  final response = await http.post(
    Uri.parse('https://26dnl0rgtj.execute-api.ap-northeast-1.amazonaws.com/prod/chat'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "prompt": "こんにちは。あなたは誰？",
      "model": "gpt-4"
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update album.');
  }
}