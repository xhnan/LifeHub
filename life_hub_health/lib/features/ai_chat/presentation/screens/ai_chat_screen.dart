import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/models/chat_message.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/services/sse_service.dart';

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  final sseService = ref.read(sseServiceProvider);
  return ChatMessagesNotifier(sseService);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final SseService _sseService;
  bool _isStreaming = false;
  int _streamingIndex = -1;

  ChatMessagesNotifier(this._sseService) : super([]);

  bool get isStreaming => _isStreaming;

  Future<void> sendMessage(String content) async {
    if (_isStreaming) return;

    state = [...state, ChatMessage(role: 'user', content: content)];
    state = [...state, ChatMessage(role: 'assistant', content: '', isStreaming: true)];

    _isStreaming = true;
    _streamingIndex = state.length - 1;

    try {
      final stream = await _sseService.streamChat(message: content);

      await for (final event in stream) {
        if (!_isStreaming || _streamingIndex >= state.length || !state[_streamingIndex].isStreaming) break;

        if (event.data != null) {
          final data = jsonDecode(event.data!);
          final eventType = data['type'] as String?;

          if (eventType == 'delta') {
            final chunk = data['content'] as String? ?? '';
            final current = state[_streamingIndex];
            state = [...state.sublist(0, _streamingIndex), current.copyWith(content: current.content + chunk), ...state.sublist(_streamingIndex + 1)];
          } else if (eventType == 'complete') {
            final current = state[_streamingIndex];
            state = [...state.sublist(0, _streamingIndex), current.copyWith(isStreaming: false), ...state.sublist(_streamingIndex + 1)];
            break;
          }
        }
      }
    } catch (e) {
      if (_streamingIndex < state.length && state[_streamingIndex].isStreaming) {
        final current = state[_streamingIndex];
        state = [...state.sublist(0, _streamingIndex), current.copyWith(content: '抱歉，发生了错误：${e.toString()}', isStreaming: false), ...state.sublist(_streamingIndex + 1)];
      }
    } finally {
      _isStreaming = false;
      _streamingIndex = -1;
    }
  }

  void clearMessages() {
    _isStreaming = false;
    _streamingIndex = -1;
    state = [];
  }
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    if (ref.read(chatMessagesProvider.notifier).isStreaming) return;

    _messageController.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI 助手'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(messages),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'AI 健康助手',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '有什么健康问题可以问我',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: message.role == 'user' ? 64 : 0,
          right: message.role == 'user' ? 0 : 64,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.role == 'user' ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: message.isStreaming && message.content.isEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '思考中...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : Text(
                message.content + (message.isStreaming ? '▎' : ''),
                style: TextStyle(
                  color: message.role == 'user' ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入您的问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
