import 'package:flutter/material.dart';

class CustomKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback? onEnter;

  const CustomKeyboard({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onEnter,
  });

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool isUpperCase = false;

  void onKeyPressed(String key) {
    final controller = widget.controller;
    final text = controller.text;
    final selection = controller.selection;

    int start = selection.isValid ? selection.start : text.length;

    int end = selection.isValid ? selection.end : text.length;

    if (start < 0) start = text.length;
    if (end < 0) end = text.length;

    if (key == 'ENTER') {
      widget.onEnter?.call();
      return;
    }

    if (key == 'SHIFT') {
      setState(() {
        isUpperCase = !isUpperCase;
      });
      return;
    }

    if (key == 'BACK') {
      if (start == end && start > 0) {
        start--;
      }

      if (start == end) return;

      controller.value = TextEditingValue(
        text: text.replaceRange(start, end, ''),
        selection: TextSelection.collapsed(offset: start),
      );
    } else {
      final value = key == 'SPACE'
          ? ' '
          : isUpperCase
          ? key.toUpperCase()
          : key.toLowerCase();

      controller.value = TextEditingValue(
        text: text.replaceRange(start, end, value),
        selection: TextSelection.collapsed(offset: start + value.length),
      );
    }

    widget.onChanged();
  }

  Widget buildKey(String key, {int flex = 1}) {
    String label = key;

    if (key == 'BACK') label = '⌫';
    if (key == 'SHIFT') label = '⇧';
    if (key == 'SPACE') label = 'Space';

    final isSpecial = ['BACK', 'SHIFT', 'ENTER'].contains(key);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: isSpecial ? const Color(0xffD4D0E3) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onKeyPressed(key),
            child: SizedBox(
              height: 43,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(List<String> keys) {
    return Row(children: keys.map((key) => buildKey(key)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
      color: const Color(0xffE8E6F0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRow('QWERTYUIOP'.split('')),

            buildRow('ASDFGHJKL'.split('')),

            Row(
              children: [
                buildKey('SHIFT'),
                ...'ZXCVBNM'.split('').map((key) => buildKey(key)),
                buildKey('BACK'),
              ],
            ),

            Row(
              children: [
                buildKey(',', flex: 1),
                buildKey('SPACE', flex: 5),
                buildKey('.', flex: 1),
                buildKey('ENTER', flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
