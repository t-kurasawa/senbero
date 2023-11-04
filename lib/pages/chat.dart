import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _chatgptuser = const types.User(id: 'chatgpt4');

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    _addMessage(textMessage);

    // デモ用にコマンドで処理を決める
    switch (message.text) {
      case 'flight':
        // 本当は画像をチャットで送信したらChatGPTに食わせたいが機能がまだ開放されてない。
        await sleep(Duration(seconds: 1));
        final ticketMessage = types.TextMessage(
          author: _chatgptuser,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: randomString(),
          text: '''
Airline: The airline is Air Company, but this appears to be a placeholder name that is often used in sample images.
Passenger Name: DOE / JOHN
Flight Number: AY0007
Date of Flight: 12 NOV 2015
Departure City (From): MOSCOW / DME (which stands for Domodedovo Moscow Airport)
Arrival City (To): LARNACA / LCA (which stands for Larnaca International Airport)
Seat Number: 24A
Boarding Time: 11:30
Gate Number: 47
Class: ECONOMY
Ticket Number (ETKT): 5552125239450
Other Notes: GATE CLOSES 40 MINUTES BEFORE DEPARTURE and HAVE A NICE TRIP!
''',
        );
        _addMessage(ticketMessage);
        break;
      case 'senbero':
        // Google Map で店検索する
        final content = await fetchMapChoices(message.text);
        final mapmessages = types.TextMessage(
          author: _chatgptuser,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: randomString(),
          text: content,
        );
        _addMessage(mapmessages);

        break;
      default:
        // ChatGPTに質問するAPIをリクエストする
        final content = await fetchChat(message.text);

        final chatgptmessage = types.TextMessage(
          author: _chatgptuser,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: randomString(),
          text: content,
        );
        _addMessage(chatgptmessage);
    }
  }


  void _loadMessages() async {
    const response = [
      {
        "author": {
          "id": "chatgpt4"
        },
        "createdAt": 1677649421032,
        "id": "message_id_2",
        "text": "ChatGPT に質問してください"
      },
    ];
    final messages = (response as List)
        .map((e) => types.TextMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }  

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }


  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Chat(
      user: _user,
      messages: _messages,
      onAttachmentPressed: _handleAttachmentPressed,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
    ),
  );
}

Future fetchChat(question) async {
  final response = await http.post(
    Uri.parse('https://26dnl0rgtj.execute-api.ap-northeast-1.amazonaws.com/prod/chat'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "prompt": question,
      "model": "gpt-4"
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    String jsonString = response.body; // ここに提供されたJSONデータを入力してください

    // JSONデータをデコード
    Map<String, dynamic> decodedData = jsonDecode(jsonString);

    // 必要なデータを取得
    Map<String, dynamic> messageData = decodedData['message'];
    Map<String, dynamic> innerMessageData = messageData['message'];
    String content = innerMessageData['content'];
    final decodedContent = utf8.decode(content.runes.toList());
    // データを表示
    print('decoded content: $decodedContent');

    return decodedContent;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to API');
  }
}


Future fetchMapChoices(bordingTime) async {
  final response = await http.post(
    Uri.parse('https://26dnl0rgtj.execute-api.ap-northeast-1.amazonaws.com/prod/map/choices'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "bordingTime": "11:30"
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

    // JSON文字列をMapに変換
    Map<String, dynamic> jsonData = json.decode(response.body);

    // データへのアクセス例
    String status = jsonData['status'];
    List<dynamic> messages = jsonData['message'];

    print('Status: $status');
    String content = '';

    for (var message in messages) {
      String formattedAddress = message['formattedAddress'];
      String displayName = message['displayName']['text'];
      content = displayName + ' : ' + formattedAddress;

      print('Formatted Address: $formattedAddress');
      print('Display Name: $displayName');
      print('---');
    }
    return content;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to API');
  }
}



// デモ用
Future<void> sleep(Duration duration) {
  return Future.delayed(duration, () => {});
}