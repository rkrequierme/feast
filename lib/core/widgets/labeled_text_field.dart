// lib/core/widgets/labeled_text_field.dart
//
// A single, self-contained form-field widget used across the entire app.
// It replaces all the private _buildField / _buildDropdown / _buildDateField /
// _buildPasswordField helpers that used to live in register_screen.dart.
//
// Supported field types (set via the [type] parameter)
// ─────────────────────────────────────────────────────
//  LabeledFieldType.text          – plain text input with a clear (×) button
//  LabeledFieldType.password      – obscured input with a visibility toggle
//  LabeledFieldType.dropdown      – DropdownButtonFormField driven by [items]
//  LabeledFieldType.datePicker    – read-only field that opens DatePickerModal
//  LabeledFieldType.filePicker    – read-only field that opens FilePickerModal
//
// Quick usage examples
// ────────────────────
//  // Plain text
//  LabeledTextField(
//    label: 'First Name', hintText: 'Juan',
//    prefixIcon: Icons.person_outline,
//    controller: _firstNameController,
//    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
//  )
//
//  // Password with live strength feedback
//  LabeledTextField(
//    label: 'Password', hintText: '••••••••',
//    prefixIcon: Icons.lock_outline,
//    controller: _passwordController,
//    type: LabeledFieldType.password,
//    onChanged: (v) => setState(() => _passwordErrors = AuthService.checkPasswordStrength(v)),
//    validator: (v) { ... },
//  )
//
//  // Dropdown
//  LabeledTextField(
//    label: 'Gender', hintText: '-- Select --',
//    prefixIcon: Icons.favorite_border,
//    controller: _genderController,   // updated automatically on selection
//    type: LabeledFieldType.dropdown,
//    items: const ['Male', 'Female', 'Other'],
//    onDropdownChanged: (v) => setState(() => _selectedGender = v),
//  )
//
//  // Date picker
//  LabeledTextField(
//    label: 'Date of Birth', hintText: 'MM/DD/YYYY',
//    prefixIcon: Icons.calendar_today_outlined,
//    controller: _dobController,
//    type: LabeledFieldType.datePicker,
//    validator: (v) => v!.isEmpty ? 'Required' : null,
//  )
//
//  // File / image picker
//  LabeledTextField(
//    label: 'Legal ID', hintText: 'Select image…',
//    prefixIcon: Icons.image_outlined,
//    controller: _idController,
//    type: LabeledFieldType.filePicker,
//    filePickerMode: FilePickerMode.imagesOnly,
//    onFilesPicked: (files) => _handleFiles(files),
//  )

import 'dart:io';
import 'package:flutter/material.dart';
import '../core.dart'; // gives us FieldLabel, feastGreen, DatePickerModal, FilePickerModal, FilePickerMode

// ── Field type enum ───────────────────────────────────────────────────────────

enum LabeledFieldType { text, password, dropdown, datePicker, filePicker }

// ── Widget ────────────────────────────────────────────────────────────────────

class LabeledTextField extends StatefulWidget {
  // ── Required for all types ─────────────────────────────────────────────
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;

  // ── Field behaviour ────────────────────────────────────────────────────
  final LabeledFieldType type;
  final TextInputType keyboardType;

  // ── Validation & change callbacks ─────────────────────────────────────
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  // ── Dropdown-specific ──────────────────────────────────────────────────
  /// Required when [type] is [LabeledFieldType.dropdown].
  final List<String>? items;

  /// Called when the user picks a dropdown value.
  /// The chosen value is also written into [controller.text] automatically.
  final ValueChanged<String?>? onDropdownChanged;

  // ── File-picker-specific ───────────────────────────────────────────────
  /// Defaults to [FilePickerMode.imagesOnly]. Pass [FilePickerMode.allFiles]
  /// for chat attachments.
  final FilePickerMode filePickerMode;

  /// Called with the confirmed [List<File>] after the user taps Confirm in
  /// the FilePickerModal.
  final void Function(List<File> files)? onFilesPicked;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.type = LabeledFieldType.text,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.items,
    this.onDropdownChanged,
    this.filePickerMode = FilePickerMode.imagesOnly,
    this.onFilesPicked,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  final FocusNode _focusNode = FocusNode();

  // Password visibility — only meaningful when type == password.
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // ── Tap handler for read-only fields ─────────────────────────────────────

  void _handleReadOnlyTap() {
    switch (widget.type) {
      case LabeledFieldType.datePicker:
        // Opens the shared DatePickerModal and writes the result into controller.
        DatePickerModal.show(
          context: context,
          controller: widget.controller,
        );

      case LabeledFieldType.filePicker:
        // Opens the FilePickerModal in the requested mode.
        showDialog(
          context: context,
          builder: (_) => FilePickerModal(
            mode: widget.filePickerMode,
            onConfirm: (files) {
              if (files.isNotEmpty) {
                // Show the first filename in the text field as a preview.
                widget.controller.text = files.first.path.split('/').last;
              }
              widget.onFilesPicked?.call(files);
            },
          ),
        );

      default:
        break;
    }
  }

  // ── Suffix icon ───────────────────────────────────────────────────────────

  Widget? _buildSuffixIcon(bool isFocused) {
    final activeColor = isFocused ? feastGreen : Colors.black54;

    switch (widget.type) {
      case LabeledFieldType.text:
        return IconButton(
          icon: Icon(Icons.close, color: activeColor, size: 20),
          onPressed: widget.controller.clear,
        );

      case LabeledFieldType.password:
        return IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: activeColor,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        );

      case LabeledFieldType.dropdown:
        // The dropdown arrow is provided by DropdownButtonFormField itself.
        return null;

      case LabeledFieldType.datePicker:
        return IconButton(
          icon: const Icon(
            Icons.calendar_month_outlined,
            color: Colors.black54,
            size: 20,
          ),
          onPressed: () => DatePickerModal.show(
            context: context,
            controller: widget.controller,
          ),
        );

      case LabeledFieldType.filePicker:
        return IconButton(
          icon: const Icon(
            Icons.image_outlined,
            color: Colors.black54,
            size: 20,
          ),
          onPressed: _handleReadOnlyTap,
        );
    }
  }

  // ── Shared input decoration ───────────────────────────────────────────────

  InputDecoration _decoration(bool isFocused, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontFamily: 'Outfit',
      ),
      prefixIcon: Icon(
        widget.prefixIcon,
        color: isFocused ? feastGreen : Colors.black54,
      ),
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      errorStyle: const TextStyle(height: 0.8),
    );
  }

  // ── Animated container that wraps the field ───────────────────────────────

  Widget _wrapInContainer({required bool isFocused, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFocused ? feastGreen : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? feastGreen.withOpacity(0.25)
                : Colors.black.withOpacity(0.15),
            blurRadius: isFocused ? 15 : 12,
            spreadRadius: isFocused ? 2 : 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: widget.label),
        const SizedBox(height: 4),

        // ── Dropdown — uses DropdownButtonFormField, not TextFormField ────
        if (widget.type == LabeledFieldType.dropdown)
          _wrapInContainer(
            isFocused: isFocused,
            child: DropdownButtonFormField<String>(
              focusNode: _focusNode,
              // Reflect the controller value as the current selection.
              value: widget.controller.text.isEmpty
                  ? null
                  : widget.controller.text,
              isExpanded: true,
              decoration: _decoration(isFocused),
              items: widget.items
                  ?.map((i) => DropdownMenuItem(value: i, child: Text(i,
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 14))))
                  .toList(),
              onChanged: (v) {
                // Keep controller in sync so the parent can read it.
                widget.controller.text = v ?? '';
                widget.onDropdownChanged?.call(v);
              },
              validator: widget.validator,
            ),
          )

        // ── All other types — use TextFormField ───────────────────────────
        else
          _wrapInContainer(
            isFocused: isFocused,
            child: TextFormField(
              focusNode: _focusNode,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              // Password fields are obscured until the eye icon is tapped.
              obscureText:
                  widget.type == LabeledFieldType.password && _obscureText,
              // Date/file fields are read-only; tapping opens their modals.
              readOnly: widget.type == LabeledFieldType.datePicker ||
                  widget.type == LabeledFieldType.filePicker,
              onTap: (widget.type == LabeledFieldType.datePicker ||
                      widget.type == LabeledFieldType.filePicker)
                  ? _handleReadOnlyTap
                  : null,
              onChanged: widget.onChanged,
              validator: widget.validator,
              cursorColor: feastGreen,
              style: const TextStyle(fontSize: 14, fontFamily: 'Outfit'),
              decoration: _decoration(
                isFocused,
                suffixIcon: _buildSuffixIcon(isFocused),
              ),
            ),
          ),
      ],
    );
  }
}
