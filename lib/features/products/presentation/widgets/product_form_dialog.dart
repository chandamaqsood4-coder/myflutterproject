import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../../catalog/domain/catalog_entry.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/product.dart';
import '../providers/product_providers.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _barcode;
  late final TextEditingController _unit;
  late final TextEditingController _sellingPrice;
  late final TextEditingController _purchaseCost;
  late final TextEditingController _stock;
  late final TextEditingController _minThreshold;
  late final TextEditingController _description;
  late final TextEditingController _imageUrl;

  ProductStatus _status = ProductStatus.active;
  int? _categoryId;
  int? _brandId;
  bool _saving = false;
  bool _uploading = false;
  String? _error;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'pc');
    _sellingPrice = TextEditingController(
      text: p == null ? '' : (p.sellingPriceMinor / 100).toStringAsFixed(2),
    );
    final costMinor = p?.purchasePriceMinor;
    _purchaseCost = TextEditingController(
      text: costMinor == null ? '0.00' : (costMinor / 100).toStringAsFixed(2),
    );
    _stock = TextEditingController(text: p?.stockQty?.toString() ?? '0');
    _minThreshold = TextEditingController(
      text: p?.minQuantityThreshold?.toString() ?? '',
    );
    _description = TextEditingController(text: p?.description ?? '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
    _status = p?.status ?? ProductStatus.active;
    _categoryId = p?.categoryId;
    _brandId = p?.brandId;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _barcode.dispose();
    _unit.dispose();
    _sellingPrice.dispose();
    _purchaseCost.dispose();
    _stock.dispose();
    _minThreshold.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  int _parseMinor(String text) => parseMinorUnits(text) ?? 0;

  int? _parseInt(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  String? _validatePrice(String? value, {bool required = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Enter a price' : null;
    if (parseMinorUnits(text) == null) return 'Enter a valid amount';
    return null;
  }

  String? _validateStock(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a quantity';
    if (int.tryParse(text) == null) return 'Enter a whole number';
    return null;
  }

  Future<void> _pickAndUpload() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();

    setState(() {
      _uploading = true;
      _error = null;
      _pickedImageBytes = bytes;
      _pickedImageName = file.name;
    });

    try {
      final url = await ref
          .read(productRepositoryProvider)
          .uploadImage(bytes: bytes, filename: file.name);
      if (mounted) {
        setState(() {
          _imageUrl.text = url;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not upload image.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final draft = ProductDraft(
      name: _name.text.trim(),
      sku: _sku.text.trim(),
      sellingPriceMinor: _parseMinor(_sellingPrice.text),
      purchasePriceMinor: _parseMinor(_purchaseCost.text),
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      categoryId: _categoryId,
      brandId: _brandId,
      unit: _unit.text.trim().isEmpty ? 'pc' : _unit.text.trim(),
      status: _status,
      stockQty: _parseInt(_stock.text) ?? 0,
      minQuantityThreshold: _parseInt(_minThreshold.text),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
    );

    try {
      final repo = ref.read(productRepositoryProvider);
      if (_editing) {
        await repo.updateProduct(widget.product!.id, draft);
      } else {
        await repo.createProduct(draft);
      }
      if (mounted) {
        ref.invalidate(productsProvider);
        ref.invalidate(productsProvider(''));
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save product.';
        });
      }
    }
  }

  InputDecoration _dec(String label) {
    OutlineInputBorder border(Color color, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: w),
        );
    return InputDecoration(
      labelText: label,
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.brand, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  List<DropdownMenuItem<int?>> _catalogItems(
    List<CatalogEntry> entries,
    int? selectedId,
    String? selectedName,
  ) {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('—')),
      ...entries.map(
        (e) => DropdownMenuItem<int?>(
          value: e.id,
          child: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    ];
    // Keep the current selection visible while the list loads, or when the
    // linked entry is no longer returned by the API.
    if (selectedId != null && !entries.any((e) => e.id == selectedId)) {
      items.add(
        DropdownMenuItem<int?>(
          value: selectedId,
          child: Text(
            selectedName ?? '#$selectedId',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(catalogEntriesProvider(CatalogKind.category));
    final brands = ref.watch(catalogEntriesProvider(CatalogKind.brand));
    final catList = categories.value ?? const <CatalogEntry>[];
    final brandList = brands.value ?? const <CatalogEntry>[];
    final product = widget.product;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_editing ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _name,
                        decoration: _dec('Product Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter a name'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sku,
                        decoration: _dec('SKU'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter a SKU'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _barcode,
                        decoration: _dec('Barcode (optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unit,
                        decoration: _dec('Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: _dec('Category'),
                        items: _catalogItems(
                          catList,
                          _categoryId,
                          product?.categoryName,
                        ),
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _brandId,
                        isExpanded: true,
                        decoration: _dec('Brand'),
                        items: _catalogItems(
                          brandList,
                          _brandId,
                          product?.brandName,
                        ),
                        onChanged: (v) => setState(() => _brandId = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPrice,
                        decoration: _dec('Selling Price (PKR)'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: _validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _purchaseCost,
                        decoration: _dec('Purchase Cost (PKR)'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) => _validatePrice(v, required: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stock,
                        decoration: _dec('Stock Quantity'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'-?[0-9]')),
                        ],
                        validator: _validateStock,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minThreshold,
                        decoration: _dec('Min Threshold (optional)'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductStatus>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: _dec('Status'),
                  items: const [
                    DropdownMenuItem(
                      value: ProductStatus.active,
                      child: Text('Active (Available for sale)'),
                    ),
                    DropdownMenuItem(
                      value: ProductStatus.paused,
                      child: Text('Inactive (Hidden from POS)'),
                    ),
                    DropdownMenuItem(
                      value: ProductStatus.deleted,
                      child: Text('Archived'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _status = v ?? ProductStatus.active),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: _dec('Description (optional)'),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _imageUrl,
                        decoration: _dec('Product Image URL (optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _saving || _uploading ? null : _pickAndUpload,
                      icon: _uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(_uploading ? 'Uploading...' : 'Upload Image'),
                    ),
                  ],
                ),
                if (_pickedImageBytes != null && _pickedImageName != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected: $_pickedImageName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
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
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
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
              : Text(_editing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
