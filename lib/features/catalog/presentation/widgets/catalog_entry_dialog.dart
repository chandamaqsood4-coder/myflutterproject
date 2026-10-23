import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../domain/catalog_entry.dart';
import '../catalog_kind_text.dart';
import '../providers/catalog_providers.dart';

/// Create / edit form for a category or brand. Pops `true` after saving.
class CatalogEntryDialog extends ConsumerStatefulWidget {
  const CatalogEntryDialog({super.key, required this.kind, this.entry});

  final CatalogKind kind;
  final CatalogEntry? entry;

  @override
  ConsumerState<CatalogEntryDialog> createState() => _CatalogEntryDialogState();
}

class _CatalogEntryDialogState extends ConsumerState<CatalogEntryDialog> {
  static final RegExp _alphaDash = RegExp(r'^[A-Za-z0-9_-]+$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _slug;
  late final TextEditingController _description;
  late bool _active;
  bool _slugTouched = false;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _name = TextEditingController(text: entry?.name ?? '');
    _slug = TextEditingController(text: entry?.slug ?? '');
    _description = TextEditingController(text: entry?.description ?? '');
    _active = entry?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    _description.dispose();
    super.dispose();
  }

  static String _slugify(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  void _onNameChanged(String value) {
    if (!_editing && !_slugTouched) _slug.text = _slugify(value);
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final description = _description.text.trim();
    final draft = CatalogDraft(
      name: _name.text.trim(),
      slug: _slug.text.trim(),
      isActive: _active,
      description: description.isEmpty ? null : description,
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
    }
  }

  InputDecoration _decoration(String label, {String? helper}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      labelText: label,
      helperText: helper,
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.brand, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final singular = widget.kind.singular;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_editing ? 'Edit $singular' : 'Add $singular'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Name'),
                  onChanged: _onNameChanged,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slug,
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'Slug',
                    helper: 'Letters, numbers, dashes and underscores',
                  ),
                  onChanged: (_) => _slugTouched = true,
                  validator: (v) {
                    final slug = v?.trim() ?? '';
                    if (slug.isEmpty) return 'Enter a slug';
                    if (!_alphaDash.hasMatch(slug)) {
                      return 'Use only letters, numbers, - and _';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  enabled: !_saving,
                  minLines: 2,
                  maxLines: 4,
                  decoration: _decoration('Description (optional)'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _active,
                  activeThumbColor: AppColors.brand,
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => _active = v),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
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
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.black),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
