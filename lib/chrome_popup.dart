import 'dart:js_util';

import 'package:atomsbox/atomsbox.dart';
import 'package:flutter/material.dart';

import '../chrome_api.dart';
import 'summary_api_client.dart';

class ChatMessage {
  ChatMessage(this.content, this.isUserMessage);

  final String content;
  final bool isUserMessage;
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.content,
    required this.isUserMessage,
    super.key,
  });

  final String content;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUserMessage
            ? Color(0xF5A5D6A7)
            : Color(0xF590CAF9),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isUserMessage ? 'You' : 'IntelliQAi',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(content),
          ],
        ),
      ),
    );
  }
}

class MessageComposer extends StatelessWidget {
  MessageComposer({
    required this.onSubmitted,
    required this.awaitingResponse,
    super.key,
  });

  final TextEditingController _messageController = TextEditingController();

  final void Function(String) onSubmitted;
  final bool awaitingResponse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.05),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: !awaitingResponse
                  ? TextField(
                      controller: _messageController,
                      onSubmitted: onSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Fetching response...'),
                        ),
                      ],
                    ),
            ),
            IconButton(
              onPressed: !awaitingResponse
                  ? () => onSubmitted(_messageController.text)
                  : null,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class ChromePopup extends StatefulWidget {
  const ChromePopup({super.key});

  @override
  State<ChromePopup> createState() => _ChromePopupState();
}

class _ChromePopupState extends State<ChromePopup> {
  late bool isLoading;
  late SummaryApiClient summaryApiClient;
  final _messages = <ChatMessage>[
    ChatMessage('Hello, how can I help?', false),
  ];
  var _awaitingResponse = false;
  bool _needsScroll = false;
  final ScrollController _scrollController = ScrollController();
  String? _summary;

  _scrollToEnd() async {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut
    );
  }

  @override
  void initState() {
    isLoading = false;
    summaryApiClient = SummaryApiClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToEnd());
      _needsScroll = false;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        title: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 84, maxWidth: 200),
          child: Image.asset(
            'assets/images/intelliqai_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: AppConstants.sm),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  ..._messages.map(
                    (msg) => MessageBubble(
                      content: msg.content,
                      isUserMessage: msg.isUserMessage,
                    ),
                  ),
                  MessageComposer(
                    onSubmitted: _onSubmitted,
                    awaitingResponse: _awaitingResponse,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmitted(String message) async {
    setState(() {
      _messages.add(ChatMessage(message, true));
      _awaitingResponse = true;
      _needsScroll = true;
    });
    final response = await getSummary(message);
    setState(() {
      _messages.add(ChatMessage(response, false));
      _awaitingResponse = false;
      _needsScroll = true;
    });
  }

  Future<String> selectUrl() async {
    List tab = await promiseToFuture(
      query(ParameterQueryTabs(active: true, lastFocusedWindow: true)),
    );
    return tab[0].url;
  }

  Future<String> getSummary(String message) async {
    String url = await selectUrl();
    return summaryApiClient.getSummary(url, message);
  }
}
