import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({super.key, required this.onCompleted, this.length = 6});

  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nodes[0].requestFocus());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map((c) => c.text).join();

  void _onChanged(int i, String v) {
    final ch = v.replaceAll(RegExp(r'\D'), '');
    if (ch.length > 1) {
      final digits = ch.split('');
      for (var j = 0; j < digits.length && i + j < widget.length; j++) {
        _controllers[i + j].text = digits[j];
      }
      final next = (i + digits.length).clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
    } else if (ch.isNotEmpty) {
      _controllers[i].text = ch;
      if (i < widget.length - 1) _nodes[i + 1].requestFocus();
    }
    if (code.length == widget.length) widget.onCompleted(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: 44,
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTextStyles.displayHero.copyWith(fontSize: 22, letterSpacing: 0),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.glassFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
            ),
            onChanged: (v) => _onChanged(i, v),
            onTap: () => _controllers[i].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[i].text.length,
            ),
          ),
        );
      }),
    );
  }
}
