import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../data/ai_chat_repository.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = ChatMessagesController();
  final _inputCtrl = TextEditingController();
  bool _isLoading = false;

  static const _aiUser = ChatUser(id: 'ai', firstName: 'AI Astrologer');
  static const _humanUser = ChatUser(id: 'user', firstName: 'You');

  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _sendWelcome();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  void _sendWelcome() {
    _controller.addMessage(ChatMessage(
      text: 'Namaste! 🙏 I am your AI Astrologer. Ask me anything about your horoscope, kundli, life questions, or astrological guidance. How can I help you today?',
      user: _aiUser,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _onSend(ChatMessage message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;

    _controller.addMessage(ChatMessage(
      text: text,
      user: _humanUser,
      createdAt: DateTime.now(),
    ));

    _history.add({'role': 'user', 'content': text});

    setState(() => _isLoading = true);

    final buffer = StringBuffer();
    ChatMessage? streamingMsg;

    try {
      final stream = ref.read(aiChatRepositoryProvider).streamChat(messages: _history);

      await for (final delta in stream) {
        buffer.write(delta);
        if (streamingMsg == null) {
          streamingMsg = ChatMessage(
            text: buffer.toString(),
            user: _aiUser,
            createdAt: DateTime.now(),
          );
          _controller.addMessage(streamingMsg);
        } else {
          _controller.updateMessage(
            streamingMsg.copyWith(text: buffer.toString()),
          );
        }
      }

      if (buffer.isNotEmpty) {
        _history.add({'role': 'assistant', 'content': buffer.toString()});
      }
    } catch (e) {
      _controller.addMessage(ChatMessage(
        text: 'Sorry, I encountered an issue. Please try again. 🙏',
        user: _aiUser,
        createdAt: DateTime.now(),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: BackButton(onPressed: () => context.pop()),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🔮', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Astrologer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(
                  'Powered by AI',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.astrologers),
            icon: const Icon(Icons.person_outline, size: 16),
            label: const Text('Human', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textDisabled),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'For entertainment purposes only. Consult a human astrologer for serious matters.',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textDisabled, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AiChatWidget(
              currentUser: _humanUser,
              aiUser: _aiUser,
              controller: _controller,
              onSendMessage: _onSend,
              loadingConfig: LoadingConfig(
                isLoading: _isLoading,
                loadingIndicator: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('AI is thinking...',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              inputOptions: InputOptions(
                textStyle: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask about your stars...',
                  hintStyle:
                      const TextStyle(color: AppColors.textDisabled),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                sendButtonBuilder: (onSend) => IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ),
              messageOptions: const MessageOptions(
                showTime: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
