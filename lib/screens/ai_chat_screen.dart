import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genui/genui.dart';
import 'package:firebase_ai/firebase_ai.dart' as ai;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/database_item.dart';
import '../models/custom_catalog.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final SurfaceController _surfaceController;
  late final A2uiTransportAdapter _transportAdapter;
  late final Conversation _conversation;
  late final ai.GenerativeModel _model;
  
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    final catalog = CustomCatalog.asCatalog();
    _surfaceController = SurfaceController(catalogs: [catalog]);
    
    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [
        'You are an AI assistant. You use a specific protocol for UI rendering.',
        'RULES:',
        '1. If you want to show a UI component, use the JSON protocol.',
        '2. ALWAYS wrap JSON in ```json ... ``` blocks.',
        '3. NEVER mix text and JSON in the same line.',
        '4. Keep conversation natural but concise.',
        'Catalog items available: Column, TextCard, ImageCard, InteractiveButton, ComparisonTable, StatusIndicator.',
        'CRITICAL: EVERY component in the "components" list MUST have a unique "id" string (e.g., "root", "card_1").',
        'Use the Column component to group multiple components.',
        'catalogId is always "custom_catalog".',
        'Current Database Items:',
        ...mockItems.map((item) => '- ${item.title}: ${item.description} ID: item_${item.id}'),
      ],
    );

    final googleAI = ai.FirebaseAI.googleAI(auth: FirebaseAuth.instance);
    _model = googleAI.generativeModel(
      model: 'gemini-flash-latest',
      systemInstruction: ai.Content.system(promptBuilder.systemPromptJoined()),
    );

    _transportAdapter = A2uiTransportAdapter(onSend: (message) async {});
    _conversation = Conversation(controller: _surfaceController, transport: _transportAdapter);

    _surfaceController.surfaceUpdates.listen((update) {
      if (update is SurfaceAdded) {
        setState(() {
          _messages.add(Message(role: Role.assistant, surfaceId: update.surfaceId));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _surfaceController.dispose();
    _transportAdapter.dispose();
    _conversation.dispose();
    super.dispose();
  }

  String _cleanResponse(String text) {
    String cleaned = text;
    cleaned = cleaned.replaceAll(RegExp(r'```(?:json)?\s*\n[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```(?:json)?[\s\S]*$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\{[\s\S]*?"(?:components|catalogId|updateComponents|version)"[\s\S]*?\}'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\{[\s\S]*?"(?:components|catalogId|updateComponents|version)"[\s\S]*$'), '');
    return cleaned.trim();
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

    try {
      final history = _messages
          .where((m) => m.text != null)
          .map((m) => m.role == Role.user 
              ? ai.Content.text(m.text!) 
              : ai.Content.model([ai.TextPart(m.text!)]))
          .toList();
      
      if (history.isNotEmpty) history.removeLast();

      final chat = _model.startChat(history: history);
      final responseStream = chat.sendMessageStream(ai.Content.text(userMessage));

      String fullResponse = '';
      bool firstTextAdded = false;

      await for (final chunk in responseStream) {
        final chunkText = chunk.text ?? '';
        fullResponse += chunkText;
        
        _transportAdapter.addChunk(chunkText);

        final visibleText = _cleanResponse(fullResponse);
        if (visibleText.isNotEmpty) {
          if (!firstTextAdded) {
            setState(() {
              _messages.add(Message(role: Role.assistant, text: visibleText, rawContent: fullResponse));
              _isLoading = false;
            });
            firstTextAdded = true;
          } else {
            setState(() {
              final lastIdx = _messages.lastIndexWhere((m) => m.role == Role.assistant && m.text != null);
              if (lastIdx != -1) {
                _messages[lastIdx] = Message(role: Role.assistant, text: visibleText, rawContent: fullResponse);
              }
            });
          }
        }
        _scrollToBottom();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(role: Role.assistant, text: 'Error: $e'));
        _isLoading = false;
      });
    }
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
        title: const Text('AI Assistant (GenUI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                
                if (message.surfaceId != null) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 44, bottom: 20, top: 4),
                    child: Surface(surfaceContext: _surfaceController.contextFor(message.surfaceId!)),
                  );
                }
                
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
                hintText: 'Ask the assistant...',
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
  final String? rawContent;
  Message({required this.role, this.text, this.surfaceId, this.rawContent});
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20)),
                    boxShadow: [if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Text(message.text!, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4)),
                ),
                if (!isUser && message.rawContent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.rawContent!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Raw JSON content copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 12),
                      label: const Text('Copy Raw JSON/Text', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
