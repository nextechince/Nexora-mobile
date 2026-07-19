import 'package:flutter/material.dart';

class PinCodeField extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final Function(String) onCompleted;
  const PinCodeField({super.key, required this.controller, required this.length, required this.onCompleted});
  @override
  State<PinCodeField> createState() => _PinCodeFieldState();
}

class _PinCodeFieldState extends State<PinCodeField> {
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      _focusNodes.add(FocusNode());
      _controllers.add(TextEditingController());
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < widget.length - 1) _focusNodes[i + 1].requestFocus();
        _updateParent();
      });
    }
  }

  void _updateParent() {
    final code = _controllers.map((c) => c.text).join();
    widget.controller.text = code;
    if (code.length == widget.length) widget.onCompleted(code);
  }

  @override
  void dispose() { for (var n in _focusNodes) n.dispose(); for (var c in _controllers) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(widget.length, (index) => SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(counterText: '', filled: true, fillColor: Colors.grey.shade800, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2))),
        style: const TextStyle(color: Colors.white, fontSize: 24),
        onChanged: (value) { if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus(); },
      ),
    )));
  }
}