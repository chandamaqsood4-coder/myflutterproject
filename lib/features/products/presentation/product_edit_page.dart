import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design_system/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../catalog/domain/catalog_entry.dart';
import '../../catalog/presentation/providers/catalog_providers.dart';
import '../domain/product.dart';
import 'providers/product_providers.dart';

/// Full-page product edit view matching the web console design.
class ProductEditPage extends ConsumerStatefulWidget {
  const ProductEditPage({super.key, this.product, required this.onBack});

  final Product? product;
  final VoidCallback onBack;

  @override
  ConsumerState<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends ConsumerState<ProductEditPage> {
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
  Uint8List? _pickedBytes;

  bool get _isEditing => widget.product != null && widget.product!.id != 0;

  static const List<String> _commonUnits = [
    'pc',
    'kg',
    'g',
    'meter',
    'cm',
    'liter',
    'ml',
    'box',
    'pack',
    'dozen',
    'pair',
    'set',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'pc');

    if (p == null) {
      _sellingPrice = TextEditingController();
      _purchaseCost = TextEditingController();
    } else {
      final sellPrice = p.sellingPriceMinor;
      _sellingPrice = TextEditingController(
        text: sellPrice % 100 == 0
            ? (sellPrice ~/ 100).toString()
            : (sellPrice / 100).toStringAsFixed(2),
      );
      final costMinor = p.purchasePriceMinor;
      _purchaseCost = TextEditingController(
        text: costMinor == null || costMinor == 0
            ? ''
            : (costMinor % 100 == 0
                  ? (costMinor ~/ 100).toString()
                  : (costMinor / 100).toStringAsFixed(2)),
      );
    }

    _stock = TextEditingController(text: p?.stockQty?.toString() ?? '0');
    _minThreshold = TextEditingController(
      text: p?.minQuantityThreshold == null
          ? ''
          : p!.minQuantityThreshold.toString(),
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

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
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
      _pickedBytes = bytes;
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
      Product? saved;
      if (_isEditing) {
        saved = await repo.updateProduct(widget.product!.id, draft);
      } else {
        saved = await repo.createProduct(draft);
      }

      ref.invalidate(productsProvider);
      ref.invalidate(productsProvider(''));
      if (widget.product != null && widget.product!.id != 0) {
        ref.invalidate(productDetailProvider(widget.product!.id));
        if (saved != null) {
          ref.read(selectedProductDetailProvider.notifier).state = saved;
        }
      }

      ref.read(editingProductProvider.notifier).clear();
      widget.onBack();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Product updated.' : 'Product created.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save product. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<DropdownMenuItem<int?>> _buildCatalogItems(
    List<CatalogEntry> entries,
    int? selectedId,
    String? fallbackName,
  ) {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('— Select —', style: TextStyle(color: AppColors.hint)),
      ),
      ...entries.map(
        (e) => DropdownMenuItem<int?>(
          value: e.id,
          child: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    ];
    if (selectedId != null && !entries.any((e) => e.id == selectedId)) {
      items.add(
        DropdownMenuItem<int?>(
          value: selectedId,
          child: Text(
            fallbackName ?? '#$selectedId',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return items;
  }

  InputDecoration _inputDec({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.hint),
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(catalogEntriesProvider(CatalogKind.category));
    final brands = ref.watch(catalogEntriesProvider(CatalogKind.brand));
    final catList = categories.value ?? const <CatalogEntry>[];
    final brandList = brands.value ?? const <CatalogEntry>[];
    final product = widget.product;

    final productName = product?.name.trim() ?? '';
    final title = _isEditing ? 'Edit Product' : 'Add Product';
    final subtitle = _isEditing
        ? 'Update details for "$productName". Changes take effect immediately in the POS terminal.'
        : 'Create a new product. Changes take effect immediately in the POS terminal.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header: Title, Subtitle, and Back to Products
                _buildHeader(title, subtitle),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(_error!),
                ],

                const SizedBox(height: 24),

                // Main two-column layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 940;

                    final leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBasicDetailsCard(),
                        const SizedBox(height: 20),
                        _buildCategoryBrandCard(catList, brandList, product),
                        const SizedBox(height: 20),
                        _buildPricingInventoryCard(),
                      ],
                    );

                    final rightColumn = _buildSaveChangesCard();

                    if (!isWide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          leftColumn,
                          const SizedBox(height: 20),
                          rightColumn,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 13, child: leftColumn),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: rightColumn),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        final textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );

        final backButton = TextButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
          label: const Text(
            'Back to Products',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [backButton, const SizedBox(height: 8), textBlock],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: textBlock),
            const SizedBox(width: 16),
            backButton,
          ],
        );
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 1: Basic Details
  // ---------------------------------------------------------------------------
  Widget _buildBasicDetailsCard() {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: AppColors.brand,
              ),
              SizedBox(width: 10),
              Text(
                'Basic Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Product Image section
          _buildFieldLabel('Product Image'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 72x72 Image Thumbnail / Placeholder
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageThumbnail(),
                ),
              ),

              const SizedBox(width: 14),

              // Upload button & URL field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: AppColors.surface,
                      shape: const StadiumBorder(
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: _uploading ? null : _pickAndUpload,
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _uploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.upload_outlined,
                                      size: 18,
                                      color: AppColors.ink,
                                    ),
                              const SizedBox(width: 8),
                              const Text(
                                'Upload Image',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _imageUrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                      decoration: _inputDec(hintText: 'or paste image URL...'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Upload a file from your device, or paste a link to an existing image.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // Product Name
          _buildFieldLabel('Product Name', required: true),
          TextFormField(
            controller: _name,
            decoration: _inputDec(hintText: 'Enter product name'),
            validator: (v) => _validateRequired(v, 'Enter product name'),
          ),

          const SizedBox(height: 18),

          // SKU Code & Barcode
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;

              final skuField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('SKU Code', required: true),
                  TextFormField(
                    controller: _sku,
                    decoration: _inputDec(hintText: 'e.g. Mc'),
                    validator: (v) => _validateRequired(v, 'Enter a SKU code'),
                  ),
                ],
              );

              final barcodeField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Barcode (EAN/UPC)'),
                  TextFormField(
                    controller: _barcode,
                    decoration: _inputDec(hintText: 'e.g. 8901234567890'),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  children: [
                    skuField,
                    const SizedBox(height: 18),
                    barcodeField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: skuField),
                  const SizedBox(width: 16),
                  Expanded(child: barcodeField),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          // Description
          _buildFieldLabel('Description'),
          TextFormField(
            controller: _description,
            minLines: 3,
            maxLines: 5,
            decoration: _inputDec(hintText: 'Optional product description...'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail() {
    if (_pickedBytes != null) {
      return Image.memory(_pickedBytes!, fit: BoxFit.cover);
    }
    final url = _imageUrl.text.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.local_offer_outlined,
            size: 26,
            color: Color(0xFF94A3B8),
          ),
        ),
      );
    }
    return const Center(
      child: Icon(
        Icons.local_offer_outlined,
        size: 26,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 2: Category & Brand
  // ---------------------------------------------------------------------------
  Widget _buildCategoryBrandCard(
    List<CatalogEntry> catList,
    List<CatalogEntry> brandList,
    Product? product,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Category & Brand',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;

              final categoryField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Category', required: true),
                  DropdownButtonFormField<int?>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: _inputDec(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                    items: _buildCatalogItems(
                      catList,
                      _categoryId,
                      product?.categoryName,
                    ),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Select a category' : null,
                  ),
                ],
              );

              final brandField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Brand', required: true),
                  DropdownButtonFormField<int?>(
                    initialValue: _brandId,
                    isExpanded: true,
                    decoration: _inputDec(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                    items: _buildCatalogItems(
                      brandList,
                      _brandId,
                      product?.brandName,
                    ),
                    onChanged: (v) => setState(() => _brandId = v),
                    validator: (v) => v == null ? 'Select a brand' : null,
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  children: [
                    categoryField,
                    const SizedBox(height: 18),
                    brandField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: categoryField),
                  const SizedBox(width: 16),
                  Expanded(child: brandField),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 3: Pricing & Inventory
  // ---------------------------------------------------------------------------
  Widget _buildPricingInventoryCard() {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pricing & Inventory',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),

          const SizedBox(height: 20),

          // Row 1: Selling Price & Purchase Cost
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;

              final sellField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Selling Price (PKR)', required: true),
                  TextFormField(
                    controller: _sellingPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDec(hintText: 'e.g. 1999'),
                    validator: _validatePrice,
                  ),
                ],
              );

              final costField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Purchase Cost (PKR)'),
                  TextFormField(
                    controller: _purchaseCost,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDec(hintText: 'e.g. 1500'),
                    validator: (v) => _validatePrice(v, required: false),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  children: [sellField, const SizedBox(height: 18), costField],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: sellField),
                  const SizedBox(width: 16),
                  Expanded(child: costField),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          // Row 2: Current Stock & Low-Stock Threshold
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;

              final stockField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Current Stock'),
                  TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: _inputDec(hintText: 'e.g. 10'),
                    validator: _validateStock,
                  ),
                ],
              );

              final thresholdField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Low-Stock Threshold'),
                  TextFormField(
                    controller: _minThreshold,
                    keyboardType: TextInputType.number,
                    decoration: _inputDec(hintText: 'e.g. 5'),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  children: [
                    stockField,
                    const SizedBox(height: 18),
                    thresholdField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: stockField),
                  const SizedBox(width: 16),
                  Expanded(child: thresholdField),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          // Row 3: Unit of Sale & Status
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;

              final unitField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Unit of Sale'),
                  DropdownButtonFormField<String>(
                    initialValue: _commonUnits.contains(_unit.text.trim())
                        ? _unit.text.trim()
                        : (_unit.text.trim().isEmpty
                              ? 'pc'
                              : _unit.text.trim()),
                    isExpanded: true,
                    decoration: _inputDec(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                    items: [
                      if (!_commonUnits.contains(_unit.text.trim()) &&
                          _unit.text.trim().isNotEmpty)
                        DropdownMenuItem(
                          value: _unit.text.trim(),
                          child: Text(_unit.text.trim()),
                        ),
                      ..._commonUnits.map(
                        (u) => DropdownMenuItem(value: u, child: Text(u)),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _unit.text = v);
                    },
                  ),
                ],
              );

              final statusField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Status'),
                  DropdownButtonFormField<ProductStatus>(
                    initialValue: _status,
                    isExpanded: true,
                    decoration: _inputDec(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
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
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  children: [
                    unitField,
                    const SizedBox(height: 18),
                    statusField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: unitField),
                  const SizedBox(width: 16),
                  Expanded(child: statusField),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 4: Save Changes (Right Column)
  // ---------------------------------------------------------------------------
  Widget _buildSaveChangesCard() {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Save Changes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Review the details above. The updated information will be reflected immediately in the POS terminal.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Black stadium button: Save Changes
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Cancel button
          Center(
            child: TextButton(
              onPressed: widget.onBack,
              style: TextButton.styleFrom(foregroundColor: AppColors.ink),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
