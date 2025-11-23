import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/chat_provider.dart';
import '../widgets/glass_card.dart';

/// Chat Tab: Real-time Grok 3 conversations with TTS
/// Now with REAL API integration using grok-4-1-fast-non-reasoning!
class ChatScreenV2 extends StatefulWidget {
  const ChatScreenV2({super.key});

  @override
  State<ChatScreenV2> createState() => _ChatScreenV2State();
}

class _ChatScreenV2State extends State<ChatScreenV2> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _apiKeyController = TextEditingController();

  // Speech-to-text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatProvider chatProvider) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    chatProvider.sendMessage(text);

    // Scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoiceInput(ChatProvider chatProvider) async {
    if (_isListening) {
      // Stop listening
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      // Start listening
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice input error: $error')),
          );
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _voiceText = result.recognizedWords;
              _messageController.text = _voiceText;
            });

            // If user pauses, send the message
            if (result.finalResult) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_messageController.text.isNotEmpty) {
                  _sendMessage(chatProvider);
                }
              });
            }
          },
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input not available on this device'),
          ),
        );
      }
    }
  }

  void _showApiKeyDialog(BuildContext context, ChatProvider chatProvider) {
    _apiKeyController.text = chatProvider.hasApiKey ? '••••••••••••' : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('xAI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your xAI API key to chat with Grok:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                hintText: 'xai-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Get your key at: https://console.x.ai',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = _apiKeyController.text.trim();
              if (key.isNotEmpty && key != '••••••••••••') {
                await chatProvider.saveApiKey(key);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key saved! Ready to chat with Grok!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Auto-scroll when messages change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients &&
              chatProvider.messages.isNotEmpty) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chat with Grok'),
                Text(
                  chatProvider.hasApiKey
                      ? 'Powered by grok-4-1-fast-non-reasoning'
                      : 'API key required',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            actions: [
              // TTS toggle
              IconButton(
                icon: Icon(
                  chatProvider.isTTSEnabled
                      ? Icons.volume_up
                      : Icons.volume_off,
                ),
                onPressed: () {
                  chatProvider.toggleTTS();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        chatProvider.isTTSEnabled
                            ? '🔊 Voice enabled - Grok will speak!'
                            : '🔇 Voice disabled',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: chatProvider.isTTSEnabled
                    ? 'Disable voice'
                    : 'Enable voice',
              ),
              // API Key
              IconButton(
                icon: Icon(
                  chatProvider.hasApiKey ? Icons.key : Icons.key_off,
                  color: chatProvider.hasApiKey
                      ? const Color(0xFF4CAF50)
                      : Colors.grey,
                ),
                onPressed: () => _showApiKeyDialog(context, chatProvider),
                tooltip: 'API Key',
              ),
              // Clear chat
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  chatProvider.clearMessages();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat cleared')),
                  );
                },
                tooltip: 'Clear chat',
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState(chatProvider)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(
                            chatProvider.messages[index],
                            index,
                            chatProvider,
                          );
                        },
                      ),
              ),

              // Loading indicator
              if (chatProvider.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Grok is thinking...',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      if (chatProvider.isTTSEnabled) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.volume_up,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                      ],
                    ],
                  ),
                ),

              // Error display
              if (chatProvider.error != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          chatProvider.error!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled:
                            chatProvider.hasApiKey && !chatProvider.isLoading,
                        decoration: InputDecoration(
                          hintText: chatProvider.hasApiKey
                              ? 'Ask Grok... (e.g., "arm day?")'
                              : 'Set API key first',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(chatProvider),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Microphone button
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: _isListening
                          ? const Color(0xFFF44336)
                          : const Color(0xFF00D4FF),
                      onPressed: chatProvider.hasApiKey
                          ? () => _toggleVoiceInput(chatProvider)
                          : null,
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    FloatingActionButton(
                      mini: true,
                      onPressed: chatProvider.hasApiKey &&
                              !chatProvider.isLoading
                          ? () => _sendMessage(chatProvider)
                          : null,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ChatProvider chatProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!chatProvider.hasApiKey) ...[
              Icon(
                Icons.key_off,
                size: 80,
                color: Colors.grey.shade700,
              ),
              const SizedBox(height: 24),
              const Text(
                'API Key Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the key icon above to set your xAI API key\nand start chatting with Grok!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey.shade700,
              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms),
              const SizedBox(height: 24),
              const Text(
                'Chat with Grok',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ask for workout plans, nutrition advice,\nor just chat about fitness!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _quickPromptChip(context, chatProvider, 'arm day?'),
                  _quickPromptChip(context, chatProvider, 'leg day?'),
                  _quickPromptChip(context, chatProvider, 'cardio tips'),
                  _quickPromptChip(
                      context, chatProvider, 'nutrition advice'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _quickPromptChip(
      BuildContext context, ChatProvider chatProvider, String prompt) {
    return ActionChip(
      label: Text(prompt),
      onPressed: () {
        _messageController.text = prompt;
        _sendMessage(chatProvider);
      },
      backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
      side: BorderSide(
        color: const Color(0xFF2196F3).withOpacity(0.3),
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    int index,
    ChatProvider chatProvider,
  ) {
    final isUser = message.isUser;
    final isError = message.isError;

    final bubbleColor = isError
        ? Colors.red.withOpacity(0.2)
        : (isUser
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : const Color(0xFF2196F3).withOpacity(0.2)); // Blue for Grok

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2196F3),
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: isUser
                  ? null
                  : () {
                      // Re-read message aloud
                      chatProvider.readMessageAloud(message);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔊 Reading message...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isError
                            ? Colors.red
                            : (isUser
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFF2196F3)))
                        .withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (!isUser && !isError) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.volume_up,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(
                    begin: isUser ? 0.2 : -0.2,
                    duration: 300.ms,
                  ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
