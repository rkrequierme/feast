import 'package:flutter/material.dart';
import 'date_picker_modal.dart';
import 'file_picker_modal.dart';
import '../core.dart';

enum TrailingAction {
  clear,
  togglePassword,
  dropdown,
  datePicker,
  filePicker,
  none,
}

class LabeledTextFieldConfig {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final TrailingAction trailingAction;
  final VoidCallback? onDropdownTap;

  const LabeledTextFieldConfig({
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.trailingAction = TrailingAction.clear,
    this.onDropdownTap,
  });
}

class LabeledTextField extends StatefulWidget {
  final LabeledTextFieldConfig config;
  const LabeledTextField({super.key, required this.config});

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.config.obscureText;
  }

  void _handleTap() {
    switch (widget.config.trailingAction) {
      case TrailingAction.dropdown:
        widget.config.onDropdownTap?.call();
      case TrailingAction.datePicker:
        DatePickerModal.show(
          context: context,
          controller: widget.config.controller,
        );
      case TrailingAction.filePicker:
        FilePickerModal.show(
          context: context,
          controller: widget.config.controller,
        );
      default:
        break;
    }
  }

  Widget? _buildTrailing() {
    switch (widget.config.trailingAction) {
      case TrailingAction.clear:
        return IconButton(
          icon: const Icon(Icons.close, color: Colors.black54, size: 20),
          onPressed: () => widget.config.controller.clear(),
        );
      case TrailingAction.togglePassword:
        return IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.black54,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        );
      case TrailingAction.dropdown:
        return IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: 22,
          ),
          onPressed: widget.config.onDropdownTap,
        );
      case TrailingAction.datePicker:
        return IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: Colors.black54,
            size: 20,
          ),
          onPressed: () => DatePickerModal.show(
            context: context,
            controller: widget.config.controller,
          ),
        );
      case TrailingAction.filePicker:
        return IconButton(
          icon: const Icon(
            Icons.image_outlined,
            color: Colors.black54,
            size: 20,
          ),
          onPressed: () => FilePickerModal.show(
            context: context,
            controller: widget.config.controller,
          ),
        );
      case TrailingAction.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly =
        widget.config.trailingAction == TrailingAction.dropdown ||
        widget.config.trailingAction == TrailingAction.datePicker ||
        widget.config.trailingAction == TrailingAction.filePicker;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: widget.config.label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.config.controller,
            keyboardType: widget.config.keyboardType,
            obscureText:
                widget.config.trailingAction == TrailingAction.togglePassword
                ? _obscure
                : false,
            readOnly: isReadOnly,
            onTap: isReadOnly ? _handleTap : null,
            style: const TextStyle(fontSize: 14, fontFamily: "Outfit"),
            decoration: InputDecoration(
              hintText: widget.config.hintText,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
              prefixIcon: Icon(widget.config.prefixIcon, color: Colors.black54),
              suffixIcon: _buildTrailing(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
