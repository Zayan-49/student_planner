import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/features/ai/models/message_model.dart';
import 'package:student_planner/features/ai/services/ai_service.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';
import 'package:student_planner/theme/widgets/gradient_background.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();

  final List<Message> _messages = <Message>[];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _messageController
      ..removeListener(_onInputChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _canSend => _messageController.text.trim().isNotEmpty && !_isTyping;

  void _onInputChanged() {
    setState(() {});
  }

  Future<void> _sendMessage() async {
    if (!_canSend) {
      return;
    }

    final input = _messageController.text.trim();

    setState(() {
      _messages.add(Message(text: input, isUser: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final responseText = await _aiService.generateResponse(input);

    if (!mounted) {
      return;
    }

    setState(() {
      _messages.add(Message(text: responseText, isUser: false));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('AI Study Assistant'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? const _EmptyChatState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isTyping && index == _messages.length) {
                            return const _TypingBubble();
                          }

                          final message = _messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
              ),
              _ChatInputBar(
                controller: _messageController,
                onSend: _sendMessage,
                canSend: _canSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.canSend,
  });

  final TextEditingController controller;
  final Future<void> Function() onSend;
  final bool canSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask anything about your studies...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canSend ? () => onSend() : null,
              style: IconButton.styleFrom(
                backgroundColor: canSend
                    ? AppColors.primary
                    : const Color.fromRGBO(255, 255, 255, 0.12),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.12),
              ),
              icon: const Icon(Icons.send_rounded),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            backgroundColor: isUser
                ? const Color.fromRGBO(16, 185, 129, 0.20)
                : const Color.fromRGBO(15, 23, 42, 0.46),
            borderColor: isUser
                ? const Color.fromRGBO(52, 211, 153, 0.30)
                : const Color.fromRGBO(255, 255, 255, 0.12),
            blurSigma: 14,
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: _BubbleFrame(
          child: Text(
            'AI is typing...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleFrame extends StatelessWidget {
  const _BubbleFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: const Color.fromRGBO(15, 23, 42, 0.46),
      borderColor: const Color.fromRGBO(255, 255, 255, 0.12),
      child: child,
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          backgroundColor: const Color.fromRGBO(15, 23, 42, 0.34),
          borderColor: const Color.fromRGBO(255, 255, 255, 0.12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(16, 185, 129, 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Ask me anything',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get simple explanations, study tips, and quick help for your subjects.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
