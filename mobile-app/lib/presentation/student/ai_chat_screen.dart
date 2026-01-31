import 'package:flutter/material.dart';
import '../../../services/ai_service.dart'; // Make sure this import is here

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // Start with a welcome message
  final List<Map<String, String>> _messages = [
    {"role": "ai", "text": "Hello! I am your AI Tutor. Ask me anything!"},
  ];

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userQuestion = _controller.text;

    setState(() {
      // 1. Show User Message immediately
      _messages.add({"role": "user", "text": userQuestion});

      // 2. Show "Thinking..." placeholder
      _messages.add({"role": "ai", "text": "Thinking..."});
    });

    _controller.clear();

    // 3. Call the Real Python AI
    // (This is the line that was missing or old in your previous version)
    final aiResponse = await AiService.askQuestion(userQuestion);

    if (!mounted) return;

    setState(() {
      // 4. Remove "Thinking..." and add Real Answer
      _messages.removeLast();
      _messages.add({"role": "ai", "text": aiResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Tutor"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(
                            alpha: 0.1,
                          ), // Fixed deprecation warning
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.blue[900] : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask a doubt...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
