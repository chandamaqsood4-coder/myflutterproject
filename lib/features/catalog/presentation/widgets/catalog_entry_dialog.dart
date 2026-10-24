import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../domain/catalog_entry.dart';
import '../catalog_kind_text.dart';
import '../providers/catalog_providers.dart';

/// Create / edit form for a category or brand.
///
/// Matches the reference website UI:
///   • Title + subtitle + close icon
///   • "Category Name *" text field
///   • "Lifecycle Status" select (Active / Inactive) whose menu opens
///     directly below the field, same width, compact rows, blue highlight
///   • Cancel (text) + Save Changes / Add Category (filled black) buttons
///
/// Pops `true` after saving.
class CatalogEntryDialog extends ConsumerStatefulWidget {
  const CatalogEntryDialog({super.key, required this.kind, this.entry});

  final CatalogKind kind;
  final CatalogEntry? entry;

  @override
  ConsumerState<CatalogEntryDialog> createState() => _CatalogEntryDialogState();
}

class _CatalogEntryDialogState extends ConsumerState<CatalogEntryDialog> {
  static const Color _selectBlue = Color(0xFF1967D2);
  static const String _activeLabel =
      'Active - Available for product assignment';
  static const String _inactiveLabel =
      'Inactive - Temporarily hidden from new products';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late bool _active;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _name = TextEditingController(text: entry?.name ?? '');
    _active = entry?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  // ── Auto-generate slug from name ──────────────────────────────────────
  static String _slugify(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final name = _name.text.trim();
    final draft = CatalogDraft(
      name: name,
      slug: _slugify(name),
      isActive: _active,
      description: widget.entry?.description,
      parentId: widget.entry?.parentId,
      sortOrder: widget.entry?.sortOrder,
    );

    try {
      final repository = ref.read(catalogRepositoryProvider);
      final entry = widget.entry;
      if (entry == null) {
        await repository.create(widget.kind, draft);
      } else {
        await repository.update(widget.kind, entry.id, draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Standard outlined input border matching the reference design.
  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  /// One row of the status menu: compact, blue + white text when selected.
  DropdownMenuEntry<bool> _statusEntry(bool value, String label) {
    final selected = _active == value;
    return DropdownMenuEntry<bool>(
      value: value,
      label: label,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          selected ? _selectBlue : Colors.white,
        ),
        foregroundColor: WidgetStatePropertyAll(
          selected ? Colors.white : AppColors.ink,
        ),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
        visualDensity: VisualDensity.compact,
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final singular = widget.kind.singular; // "Category", "Brand", etc.
    final actionLabel = _editing ? 'Save Changes' : 'Add $singular';

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _editing ? 'Edit $singular' : 'Add $singular',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ── Subtitle ────────────────────────────────────────────
              const Text(
                'Name it and set its lifecycle status. Products can be linked '
                'to it during creation or edit.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // ── Form ────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label: "Category Name *"
                    RichText(
                      text: TextSpan(
                        text: '$singular Name',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Name text field
                    TextFormField(
                      controller: _name,
                      autofocus: true,
                      enabled: !_saving,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: _editing ? null : 'e.g. Industrial Switches',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.hint,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: _border(AppColors.border),
                        enabledBorder: _border(AppColors.border),
                        focusedBorder: _border(AppColors.ink, 1.5),
                        errorBorder: _border(AppColors.error),
                        focusedErrorBorder: _border(AppColors.error, 1.5),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a name'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Label: "Lifecycle Status"
                    const Text(
                      'Lifecycle Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status select — menu opens BELOW the field, same width.
                    DropdownMenu<bool>(
                      initialSelection: _active,
                      enabled: !_saving,
                      expandedInsets: EdgeInsets.zero,
                      requestFocusOnTap: false,
                      enableFilter: false,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                      trailingIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                      selectedTrailingIcon: const Icon(
                        Icons.keyboard_arrow_up,
                        color: AppColors.textSecondary,
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: _border(AppColors.border),
                        enabledBorder: _border(AppColors.border),
                        focusedBorder: _border(AppColors.ink, 2),
                      ),
                      menuStyle: MenuStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          Colors.white,
                        ),
                        surfaceTintColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        elevation: const WidgetStatePropertyAll(2),
                        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      dropdownMenuEntries: [
                        _statusEntry(true, _activeLabel),
                        _statusEntry(false, _inactiveLabel),
                      ],
                      onSelected: (v) {
                        if (v != null) setState(() => _active = v);
                      },
                    ),

                    // Error message
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Actions ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel – plain text button
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Save / Add – filled black button
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.ink.withValues(
                        alpha: 0.6,
                      ),
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            actionLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
