import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/api/messages_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({super.key, required this.threadId});

  final int threadId;

  @override
  ConsumerState<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final _text = TextEditingController();
  List<dynamic> _messages = [];
  Map<String, dynamic>? _context;
  bool _loading = true;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final api = ref.read(messagesApiProvider);
    try {
      await api.markRead(widget.threadId);
    } catch (_) {
      /* non-fatal */
    }
    final list = await api.threadMessages(widget.threadId);
    final ctx = await api.threadContext(widget.threadId);
    if (!mounted) return;
    setState(() {
      _messages = list;
      _context = ctx;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    try {
      await ref.read(messagesApiProvider).postMessage(widget.threadId, body);
      _text.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  String _msgText(Map<String, dynamic> m) {
    return '${m['text'] ?? m['body'] ?? m['content'] ?? ''}';
  }

  bool _isMe(Map<String, dynamic> m) => m['me'] == true;

  bool _isSystem(Map<String, dynamic> m) => m['message_kind'] == 'system';

  @override
  Widget build(BuildContext context) {
    final title = _context?['title']?.toString() ?? 'Rental Hub';
    final trust = (_context?['peer'] as Map?)?['trust_score'];

    return PageScaffold(
      title: title,
      body: Column(
        children: [
          if (trust != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  Text('Trust score $trust%', style: AppTextStyles.captionOnDark),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i] as Map<String, dynamic>;
                      if (_isSystem(m)) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _msgText(m),
                              style: AppTextStyles.captionOnDark,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      final me = _isMe(m);
                      return Align(
                        alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: me ? AppColors.accentGreen : AppColors.glassFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: me ? AppColors.accentGreen : AppColors.glassBorder,
                            ),
                          ),
                          child: Text(
                            _msgText(m),
                            style: me
                                ? AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF041208))
                                : AppTextStyles.bodyMediumOnDark,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(hintText: 'Write a message…'),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send_rounded, color: AppColors.accentGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
