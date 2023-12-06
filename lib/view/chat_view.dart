import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _openAI = OpenAI.instance.build(
      // token: OPENAI_API_KEY,
      token: dotenv.env["API_KEY"],
      baseOption: HttpSetup(
        sendTimeout: const Duration(seconds: 5),
      ),
      // 実行不能ログの設定
      enableLog: true);

  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "app", lastName: "user");

  final ChatUser _gptChatUser =
      ChatUser(id: "2", firstName: "Chat", lastName: "GPT");

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
          0,
          166,
          126,
          1,
        ),
        title: const Text(
          'GPT Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Color.fromRGBO(
              0,
              166,
              126,
              1,
            ),
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      // 新しいメッセージは、0番目のインデックス(リストの最初の要素)に追加される
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });

    // reversed : gptに送信する順序が、送信される順序と逆であるため
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    final request = ChatCompleteText(
      // 使用するGPT-3モデルを指定
      model: GptTurbo0301ChatModel(),
      // メッセージの送信者（ユーザーまたはアシスタント）とメッセージの内容を含みます
      messages: _messagesHistory,
      // 応答の最大トークン数を指定
      maxToken: 200,
    );

    // * エラー -> [OpenAI] error code: 429, ( リクエストがレート制限を超えた )
    final response = await _openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          // 新しいChatMessageが作成され、_messagesリストの先頭（0番目のインデックス）に挿入されます
          _messages.insert(
            0,
            ChatMessage(
                // メッセージの送信者
                user: _gptChatUser,
                // メッセージが作成された日時
                createdAt: DateTime.now(),
                // メッセージの内容。ここでは、GPT-3モデルが生成したテキスト（element.message!.content）が設定されています
                text: element.message!.content),
          );
        });
      }
    }

    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
