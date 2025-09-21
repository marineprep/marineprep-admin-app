import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';

class RichTextEditor extends StatefulWidget {
  final QuillController controller;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool readOnly;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.maxLines = 3,
    this.readOnly = false,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });

    // Listen to text changes
    widget.controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(widget.controller.document.toPlainText());
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          RichText(
            text: TextSpan(
              text: widget.labelText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
              children: widget.isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasFocus ? AppColors.primary : AppColors.gray300,
              width: _hasFocus ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Toolbar
              if (!widget.readOnly)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    border: Border(
                      bottom: BorderSide(color: AppColors.gray200),
                    ),
                  ),
                  child: _buildToolbar(),
                ),

              // Editor
              Container(
                constraints: BoxConstraints(
                  minHeight: widget.maxLines * 24.0,
                  maxHeight: widget.maxLines * 28.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: widget.readOnly
                      ? BorderRadius.circular(11)
                      : const BorderRadius.only(
                          bottomLeft: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                ),
                child: QuillEditor.basic(
                  controller: widget.controller,
                  focusNode: _focusNode,
                ),
              ),
            ],
          ),
        ),

        // Validation message
        if (widget.validator != null) ...[
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final plainText = widget.controller.document.toPlainText();
              final error = widget.validator!(
                plainText.trim().isEmpty ? null : plainText,
              );
              if (error != null) {
                return Text(
                  error,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarButton(
          icon: Icons.format_bold,
          onPressed: () => _toggleFormat(Attribute.bold),
          isActive: _isFormatActive(Attribute.bold),
        ),
        _ToolbarButton(
          icon: Icons.format_italic,
          onPressed: () => _toggleFormat(Attribute.italic),
          isActive: _isFormatActive(Attribute.italic),
        ),
        _ToolbarButton(
          icon: Icons.format_underlined,
          onPressed: () => _toggleFormat(Attribute.underline),
          isActive: _isFormatActive(Attribute.underline),
        ),
        _ToolbarButton(
          icon: Icons.format_list_bulleted,
          onPressed: () => _toggleFormat(Attribute.ul),
          isActive: _isFormatActive(Attribute.ul),
        ),
        _ToolbarButton(
          icon: Icons.format_list_numbered,
          onPressed: () => _toggleFormat(Attribute.ol),
          isActive: _isFormatActive(Attribute.ol),
        ),
      ],
    );
  }

  void _toggleFormat(Attribute attribute) {
    final isActive = _isFormatActive(attribute);
    if (isActive) {
      widget.controller.formatText(
        widget.controller.selection.start,
        widget.controller.selection.end - widget.controller.selection.start,
        Attribute.clone(attribute, null),
      );
    } else {
      widget.controller.formatText(
        widget.controller.selection.start,
        widget.controller.selection.end - widget.controller.selection.start,
        attribute,
      );
    }
  }

  bool _isFormatActive(Attribute attribute) {
    return widget.controller.getSelectionStyle().attributes.containsKey(
      attribute.key,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _ToolbarButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primary : AppColors.gray600,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class CompactRichTextEditor extends StatefulWidget {
  final QuillController controller;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;

  const CompactRichTextEditor({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  State<CompactRichTextEditor> createState() => _CompactRichTextEditorState();
}

class _CompactRichTextEditorState extends State<CompactRichTextEditor> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
        if (_hasFocus) {
          _showToolbar = true;
        }
      });
    });

    // Listen to text changes
    widget.controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(widget.controller.document.toPlainText());
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          RichText(
            text: TextSpan(
              text: widget.labelText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
              children: widget.isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
        ],

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hasFocus ? AppColors.primary : AppColors.gray300,
              width: _hasFocus ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Compact Toolbar (shown when focused or text selected)
              if (!widget.readOnly && _showToolbar)
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                    border: Border(
                      bottom: BorderSide(color: AppColors.gray200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildCompactToolbar()),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showToolbar = false;
                          });
                          _focusNode.unfocus();
                        },
                        icon: Icon(Iconsax.arrow_up_2, size: 16),
                        iconSize: 16,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

              // Editor
              Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 80),
                decoration: BoxDecoration(
                  borderRadius: _showToolbar && !widget.readOnly
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        )
                      : BorderRadius.circular(7),
                ),
                child: QuillEditor.basic(
                  controller: widget.controller,
                  focusNode: _focusNode,
                ),
              ),
            ],
          ),
        ),

        // Show/Hide toolbar button when not focused
        if (!widget.readOnly && !_showToolbar && !_hasFocus)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showToolbar = true;
                });
                _focusNode.requestFocus();
              },
              icon: Icon(Iconsax.edit_2, size: 12),
              label: const Text('Format text', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gray600,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

        // Validation message
        if (widget.validator != null) ...[
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final plainText = widget.controller.document.toPlainText();
              final error = widget.validator!(
                plainText.trim().isEmpty ? null : plainText,
              );
              if (error != null) {
                return Text(
                  error,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCompactToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CompactToolbarButton(
          icon: Icons.format_bold,
          onPressed: () => _toggleFormat(Attribute.bold),
          isActive: _isFormatActive(Attribute.bold),
        ),
        _CompactToolbarButton(
          icon: Icons.format_italic,
          onPressed: () => _toggleFormat(Attribute.italic),
          isActive: _isFormatActive(Attribute.italic),
        ),
        _CompactToolbarButton(
          icon: Icons.format_underlined,
          onPressed: () => _toggleFormat(Attribute.underline),
          isActive: _isFormatActive(Attribute.underline),
        ),
      ],
    );
  }

  void _toggleFormat(Attribute attribute) {
    final isActive = _isFormatActive(attribute);
    if (isActive) {
      widget.controller.formatText(
        widget.controller.selection.start,
        widget.controller.selection.end - widget.controller.selection.start,
        Attribute.clone(attribute, null),
      );
    } else {
      widget.controller.formatText(
        widget.controller.selection.start,
        widget.controller.selection.end - widget.controller.selection.start,
        attribute,
      );
    }
  }

  bool _isFormatActive(Attribute attribute) {
    return widget.controller.getSelectionStyle().attributes.containsKey(
      attribute.key,
    );
  }
}

class _CompactToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _CompactToolbarButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 14,
          color: isActive ? AppColors.primary : AppColors.gray600,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Read-only rich text viewer
class RichTextViewer extends StatelessWidget {
  final dynamic content; // Delta from flutter_quill
  final TextStyle? style;

  const RichTextViewer({super.key, required this.content, this.style});

  @override
  Widget build(BuildContext context) {
    final controller = QuillController(
      document: Document.fromDelta(content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    return QuillEditor.basic(controller: controller);
  }
}
