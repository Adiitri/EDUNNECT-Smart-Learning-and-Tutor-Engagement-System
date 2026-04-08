import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../services/user_session.dart';

// Web-only imports
import 'dart:html' as html show window;

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
  final ImagePicker _imagePicker = ImagePicker();

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
            'type': m['fileType'] ?? 'text',
            'fileUrl': m['fileUrl'],
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
              'type': data['fileType'] ?? 'text',
              'fileUrl': data['fileUrl'],
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
          'type': 'text',
        });
      });
    }

    if (_isConnected) {
      socket.emit('send_message', messageData);
    } else {
      _fallbackSend(messageData);
    }
  }

  // File Upload Methods
  Future<void> _showUploadOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pick Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Pick Document/File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          await _uploadAndSendFileWeb(bytes, pickedFile.name, 'image');
        } else {
          await _uploadAndSendFile(File(pickedFile.path), 'image');
        }
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  Future<void> _captureImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          await _uploadAndSendFileWeb(bytes, pickedFile.name, 'image');
        } else {
          await _uploadAndSendFile(File(pickedFile.path), 'image');
        }
      }
    } catch (e) {
      debugPrint("Camera capture error: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;
        await _uploadAndSendFileWeb(bytes, fileName, 'file');
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  Future<void> _uploadAndSendFileWeb(Uint8List bytes, String fileName, String fileType) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading file...'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      final bookingId = widget.tutor?['bookingId'];
      final senderId = UserSession.currentUser?['_id'];

      if (bookingId == null || senderId == null) return;

      // Create multipart request for web
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/chat/upload'),
      );

      request.fields['bookingId'] = bookingId;
      request.fields['senderId'] = senderId;
      request.fields['fileType'] = fileType;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        final fileUrl = data['fileUrl'];

        final messageData = {
          'bookingId': bookingId,
          'senderId': senderId,
          'text': fileName,
          'fileUrl': fileUrl,
          'fileType': fileType,
        };

        if (mounted) {
          setState(() {
            _messages.insert(0, {
              'text': fileName,
              'senderId': senderId,
              'isMe': true,
              'time': DateTime.now(),
              'type': fileType,
              'fileUrl': fileUrl,
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (_isConnected) {
          socket.emit('send_message', messageData);
        } else {
          _fallbackSend(messageData);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("File upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAndSendFile(File file, String fileType) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading file...'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      final bookingId = widget.tutor?['bookingId'];
      final senderId = UserSession.currentUser?['_id'];

      if (bookingId == null || senderId == null) return;

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/chat/upload'),
      );

      request.fields['bookingId'] = bookingId;
      request.fields['senderId'] = senderId;
      request.fields['fileType'] = fileType;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        final fileUrl = data['fileUrl'];
        final fileName = data['fileName'];

        final messageData = {
          'bookingId': bookingId,
          'senderId': senderId,
          'text': fileName,
          'fileUrl': fileUrl,
          'fileType': fileType,
        };

        if (mounted) {
          setState(() {
            _messages.insert(0, {
              'text': fileName,
              'senderId': senderId,
              'isMe': true,
              'time': DateTime.now(),
              'type': fileType,
              'fileUrl': fileUrl,
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (_isConnected) {
          socket.emit('send_message', messageData);
        } else {
          _fallbackSend(messageData);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("File upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                messageType: _messages[index]['type'] ?? 'text',
                fileUrl: _messages[index]['fileUrl'],
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
          // Add '+' button on the left
          CircleAvatar(
            backgroundColor: const Color(0xFF075E54),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _showUploadOptions,
            ),
          ),
          const SizedBox(width: 8),
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
  final String? messageType;
  final String? fileUrl;
  final BuildContext? chatContext;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.time,
    this.messageType = 'text',
    this.fileUrl,
    this.chatContext,
  });

  void _openFile(BuildContext context) {
    if (fileUrl == null || fileUrl!.isEmpty) return;

    if (messageType == 'image') {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: InteractiveViewer(
            child: Image.network(fileUrl!, fit: BoxFit.contain),
          ),
        ),
      );
    } else {
      // For files, launch URL to download/open
      if (kIsWeb) {
        // On web, open in new tab
        html.window.open(fileUrl!, '_blank');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: $message'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
            // Display different content based on message type
            if (messageType == 'image' && fileUrl != null)
              GestureDetector(
                onTap: () => _openFile(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fileUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Text('Image not found'),
                  ),
                ),
              )
            else if (messageType == 'file' && fileUrl != null)
              GestureDetector(
                onTap: () => _openFile(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_file, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 14, decoration: TextDecoration.underline, color: Colors.blue),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}