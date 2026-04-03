import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_session.dart';

class RealTimeChatScreen extends StatefulWidget {
  final Map<String, dynamic>? tutor;
  const RealTimeChatScreen({super.key, this.tutor});

  @override
  State<RealTimeChatScreen> createState() => _RealTimeChatScreenState();
}

class _RealTimeChatScreenState extends State<RealTimeChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadHistory(); // 1. Load old messages first
    _initSocket();  // 2. Connect for new messages
  }

  Future<void> _loadHistory() async {
    final bookingId = widget.tutor?['bookingId'];
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/chat/history/$bookingId"),
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          _messages = data.map((m) => {
            'text': m['message'],
            'senderId': m['sender'],
            'isMe': m['sender'] == UserSession.currentUser?['_id'],
            'time': DateTime.parse(m['timestamp']),
          }).toList().reversed.toList();
        });
      }
    } catch (e) {
      debugPrint("History error: $e");
    }
  }

  void _initSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      if (mounted) setState(() => _isConnected = true);
      socket.emit('join_chat', widget.tutor?['bookingId']);
    });

    socket.onDisconnect((_) {
      if (mounted) setState(() => _isConnected = false);
    });

    socket.on('receive_message', (data) {
      if (mounted && data != null) {
        final senderId = data['senderId']?.toString() ?? '';
        final text = data['text']?.toString() ?? '';

        if (!_isDuplicateMessage(senderId, text)) {
          setState(() {
            _messages.insert(0, {
              'text': text,
              'senderId': senderId,
              'isMe': senderId == UserSession.currentUser?['_id'],
              'time': DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
            });
          });
        }
      }
    });
  }

  bool _isDuplicateMessage(String senderId, String text) {
    return _messages.any((msg) {
      final msgSender = msg['senderId']?.toString() ?? '';
      final msgText = msg['text']?.toString() ?? '';
      final msgTime = msg['time'] is DateTime ? msg['time'] as DateTime : DateTime.now();
      return msgSender == senderId && msgText == text && DateTime.now().difference(msgTime).inSeconds < 5;
    });
  }

  Future<void> _fallbackSend(Map<String, dynamic> messageData) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unable to send through socket, fallback failed.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send chat message.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _sendMessage() {
    final bookingId = widget.tutor?['bookingId'];
    final senderId = UserSession.currentUser?['_id'];
    final text = _messageController.text.trim();

    if (bookingId == null || senderId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Chat ID or user not found. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    if (text.isEmpty) return;

    final messageData = {
      'bookingId': bookingId,
      'senderId': senderId,
      'text': text,
    };

    _messageController.clear();

    if (!_isDuplicateMessage(senderId, text)) {
      setState(() {
        _messages.insert(0, {
          'text': text,
          'senderId': senderId,
          'isMe': true,
          'time': DateTime.now(),
        });
      });
    }

    if (_isConnected) {
      socket.emit('send_message', messageData);
    } else {
      _fallbackSend(messageData);
    }
  }

  @override
  void dispose() {
    socket.off('receive_message');
    socket.off('connect');
    socket.off('disconnect');
    socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp grey/green background
      appBar: AppBar(
        title: Text(widget.tutor?['name'] ?? "Chat", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF075E54), // WhatsApp Dark Green
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(Icons.circle, color: _isConnected ? Colors.greenAccent : Colors.redAccent, size: 10),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _ChatBubble(
                message: _messages[index]['text'],
                isMe: _messages[index]['isMe'],
                time: _messages[index]['time'],
              ),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                fillColor: Colors.grey[200],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: const Color(0xFF075E54),
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;

  const _ChatBubble({required this.message, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text("${time.hour}:${time.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}