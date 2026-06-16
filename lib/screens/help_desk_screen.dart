import 'package:flutter/material.dart';
// TODO 1: Import GenUI and Generative AI packages
// import 'package:genui/genui.dart';
// import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import '../models/product.dart';
import '../firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HelpDeskScreen extends StatefulWidget {
  const HelpDeskScreen({super.key});

  @override
  State<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends State<HelpDeskScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // TODO 2: Declare SurfaceController, A2uiTransportAdapter, Conversation, and GenerativeModel
  
  final List<Message> _messages = [];
  bool _isLoading = false;

  static String get _envApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  String get _apiKey => _envApiKey.isNotEmpty 
      ? _envApiKey 
      : DefaultFirebaseOptions.currentPlatform.apiKey;

  @override
  void initState() {
    super.initState();
    
    // TODO 3: Initialize GenUI SurfaceController and Conversation
    // TODO 4: Initialize GenerativeModel (gemini-2.5-flash) with system instructions for GenUI protocol rules
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // TODO 5: Dispose controllers and adapters to prevent memory leaks
    super.dispose();
  }

  // TODO 6: Implement JSON cleaning/filtering logic for streaming responses so JSON isn't rendered as a text bubble
  String _cleanResponse(String text) {
    return text.trim();
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(Message(role: Role.user, text: userMessage));
      _isLoading = true;
    });

    _scrollToBottom();

    // TODO 7: Start chat session and handle streaming response.
    // Send message to Gemini, clean JSON block from response for text bubbles,
    // and feed the stream to the transport adapter so GenUI can render components.
    
    // Placeholder echo response:
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _messages.add(Message(role: Role.assistant, text: 'You said: "$userMessage". Configure GenUI and Gemini to enable generative widgets!'));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('AI Help Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () => setState(() => _messages.clear()), 
            icon: const Icon(Icons.refresh, size: 20)
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                
                // TODO 8: Render GenUI Surface widgets if message contains surfaceId
                // if (message.surfaceId != null) {
                //   return Padding(
                //     padding: const EdgeInsets.only(left: 44, bottom: 20, top: 4),
                //     child: Surface(surfaceContext: _surfaceController.contextFor(message.surfaceId!)),
                //   );
                // }
                
                return _MessageBubble(message: message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(width: 40, height: 4, child: LinearProgressIndicator(backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(Colors.blue))),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF1F3F6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class Role {
  static const String user = 'user';
  static const String assistant = 'assistant';
}

class Message {
  final String role;
  final String? text;
  final String? surfaceId;
  Message({required this.role, this.text, this.surfaceId});
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    if (message.text == null || message.text!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, right: 8),
              child: CircleAvatar(radius: 16, backgroundColor: Colors.blue.shade50, child: const Icon(Icons.support_agent, color: Colors.blue, size: 16)),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20)),
                boxShadow: [if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Text(message.text!, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
