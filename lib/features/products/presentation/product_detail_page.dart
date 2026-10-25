import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design_system/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/product.dart';
import 'providers/product_providers.dart';

/// Full-page product detail view matching the web console design.
class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onBack,
  });

  final Product product;
  final VoidCallback onBack;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  ProductDraft _createDraft(
    Product p, {
    String? imageUrl,
    ProductStatus? status,
  }) {
    return ProductDraft(
      name: p.name,
      sku: p.sku,
      sellingPriceMinor: p.sellingPriceMinor,
      purchasePriceMinor: p.purchasePriceMinor ?? 0,
      barcode: p.barcode,
      categoryId: p.categoryId,
      brandId: p.brandId,
      unit: p.unit,
      status: status ?? p.status,
      stockQty: p.stockQty,
      minQuantityThreshold: p.minQuantityThreshold,
      description: p.description,
      imageUrl: imageUrl ?? p.imageUrl,
    );
  }

  Future<void> _pickAndUploadImage(Product current) async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();

      setState(() => _isUploadingImage = true);

      final url = await ref
          .read(productRepositoryProvider)
          .uploadImage(bytes: bytes, filename: file.name);

      await _applyImageUrl(current, url);
    } on ApiException catch (e) {
      _showFeedback(e.message);
    } catch (_) {
      _showFeedback('Could not upload image.');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _applyImageUrl(Product current, String? url) async {
    try {
      final draft = _createDraft(current, imageUrl: url);
      final updated = await ref
          .read(productRepositoryProvider)
          .updateProduct(current.id, draft);

      ref.invalidate(productsProvider);
      ref.invalidate(productsProvider(''));
      ref.invalidate(productDetailProvider(current.id));

      if (updated != null && mounted) {
        ref.read(selectedProductDetailProvider.notifier).state = updated;
      }
      _showFeedback('Product image updated.');
    } on ApiException catch (e) {
      _showFeedback(e.message);
    }
  }

  Future<void> _handlePasteUrl(Product current) async {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isUploadingImage = true);
    try {
      await _applyImageUrl(current, text);
      _urlController.clear();
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _toggleArchive(Product current) async {
    final newStatus = current.status == ProductStatus.paused
        ? ProductStatus.active
        : ProductStatus.paused;

    try {
      final draft = _createDraft(current, status: newStatus);
      final updated = await ref
          .read(productRepositoryProvider)
          .updateProduct(current.id, draft);

      ref.invalidate(productsProvider);
      ref.invalidate(productsProvider(''));
      ref.invalidate(productDetailProvider(current.id));

      if (updated != null && mounted) {
        ref.read(selectedProductDetailProvider.notifier).state = updated;
      }
      _showFeedback(
        newStatus == ProductStatus.paused
            ? 'Product archived.'
            : 'Product unarchived.',
      );
    } on ApiException catch (e) {
      _showFeedback(e.message);
    }
  }

  void _openEdit(Product current) {
    ref.read(editingProductProvider.notifier).edit(current);
  }

  Future<void> _delete(Product current) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete this product?',
      message:
          'This permanently removes the product from the catalog. '
          'Historical invoices and quotations will still show its name, but '
          'the product can no longer be sold. This cannot be undone.',
      confirmLabel: 'Delete Product',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(productRepositoryProvider).deleteProduct(current.id);
      ref.invalidate(productsProvider);
      ref.invalidate(productsProvider(''));
      ref.invalidate(productDetailProvider(current.id));
      if (!mounted) return;
      ref.read(selectedProductDetailProvider.notifier).state = null;
      widget.onBack();
      _showFeedback('Deleted ${current.name}.');
    } on ApiException catch (e) {
      _showFeedback(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.product.id));
    final product = detailAsync.value ?? widget.product;

    final permissions = ref.watch(currentPermissionsProvider);
    final canEdit = permissions.contains('products.update');
    final canDelete = permissions.contains('products.delete');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Back button, Title, Status, SKU, and Action buttons
              _HeaderSection(
                product: product,
                onBack: widget.onBack,
                onArchive: () => _toggleArchive(product),
                onEdit: () => _openEdit(product),
                onDelete: () => _delete(product),
                canEdit: canEdit,
                canDelete: canDelete,
              ),

              const SizedBox(height: 24),

              // Two-column layout
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 940;

                  final leftColumn = _ImagesCard(
                    product: product,
                    isUploading: _isUploadingImage,
                    urlController: _urlController,
                    onUpload: () => _pickAndUploadImage(product),
                    onSubmitUrl: () => _handlePasteUrl(product),
                  );

                  final rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProductInformationCard(product: product),
                      const SizedBox(height: 20),
                      _PricingProfitabilityCard(product: product),
                      const SizedBox(height: 20),
                      _StockInventoryCard(product: product),
                      const SizedBox(height: 20),
                      const _SalesInformationCard(),
                    ],
                  );

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
                      Expanded(flex: 8, child: leftColumn),
                      const SizedBox(width: 24),
                      Expanded(flex: 12, child: rightColumn),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Section
// ---------------------------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.product,
    required this.onBack,
    required this.onArchive,
    required this.onEdit,
    required this.onDelete,
    required this.canEdit,
    required this.canDelete,
  });

  final Product product;
  final VoidCallback onBack;
  final VoidCallback onArchive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 740;

        final titleAndStatus = Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            _StatusBadge(status: product.status),
          ],
        );

        final skuSubtitle = Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 13),
            children: [
              const TextSpan(
                text: 'SKU: ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: product.sku.isNotEmpty ? product.sku : '—',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        );

        final actionButtons = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _OutlinedPillButton(
              icon: Icons.archive_outlined,
              label: product.status == ProductStatus.paused
                  ? 'Unarchive'
                  : 'Archive',
              onTap: onArchive,
            ),
            if (canEdit)
              _SolidPillButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onTap: onEdit,
              ),
            if (canDelete)
              _SolidPillButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                onTap: onDelete,
              ),
          ],
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Back Button
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.border),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompact) ...[
                    titleAndStatus,
                    const SizedBox(height: 4),
                    skuSubtitle,
                    const SizedBox(height: 12),
                    actionButtons,
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleAndStatus,
                              const SizedBox(height: 4),
                              skuSubtitle,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        actionButtons,
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ProductStatus.active => (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
        'Active',
      ),
      ProductStatus.paused => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
        'Inactive',
      ),
      ProductStatus.deleted => (
        const Color(0xFFFEE2E2),
        const Color(0xFFB91C1C),
        'Archived',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _OutlinedPillButton extends StatelessWidget {
  const _OutlinedPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolidPillButton extends StatelessWidget {
  const _SolidPillButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Product Images (Left Column)
// ---------------------------------------------------------------------------
class _ImagesCard extends StatelessWidget {
  const _ImagesCard({
    required this.product,
    required this.isUploading,
    required this.urlController,
    required this.onUpload,
    required this.onSubmitUrl,
  });

  final Product product;
  final bool isUploading;
  final TextEditingController urlController;
  final VoidCallback onUpload;
  final VoidCallback onSubmitUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        product.imageUrl != null && product.imageUrl!.trim().isNotEmpty;
    final initialLetter = product.name.trim().isNotEmpty
        ? product.name.trim()[0].toUpperCase()
        : 'P';

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                size: 20,
                color: AppColors.ink,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Product Images',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasImage ? '1 image' : '0 images',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main image container with initial placeholder or loaded image
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : (hasImage
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (_, _, _) =>
                                _PlaceholderInitial(letter: initialLetter),
                          )
                        : _PlaceholderInitial(letter: initialLetter)),
            ),
          ),

          const SizedBox(height: 18),

          // Action row: Upload Image button + Paste URL field (wrapped for narrow layouts)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 440;

              final uploadButton = Material(
                color: AppColors.surface,
                shape: const StadiumBorder(
                  side: BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: isUploading ? null : onUpload,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_outlined,
                          size: 18,
                          color: AppColors.ink,
                        ),
                        SizedBox(width: 8),
                        Text(
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
              );

              final pasteField = Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlController,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Paste image URL...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.hint,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => onSubmitUrl(),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Apply URL',
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.brand,
                      ),
                      splashRadius: 18,
                      onPressed: isUploading ? null : onSubmitUrl,
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    uploadButton,
                    const SizedBox(height: 10),
                    pasteField,
                  ],
                );
              }

              return Row(
                children: [
                  uploadButton,
                  const SizedBox(width: 10),
                  Expanded(child: pasteField),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          const Text(
            'The first image is used as the main product picture across POS and catalog.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderInitial extends StatelessWidget {
  const _PlaceholderInitial({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 88,
          fontWeight: FontWeight.w700,
          color: Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Product Information (Right Column)
// ---------------------------------------------------------------------------
class _ProductInformationCard extends StatelessWidget {
  const _ProductInformationCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 20, color: AppColors.ink),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Product Information',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              final col1 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoField(
                    label: 'CATEGORY',
                    value: product.categoryName ?? '—',
                    subtext: product.categoryName?.toLowerCase(),
                  ),
                  const SizedBox(height: 20),
                  _InfoField(label: 'UNIT OF SALE', value: product.unit),
                  const SizedBox(height: 20),
                  _InfoField(
                    label: 'STATUS',
                    value: switch (product.status) {
                      ProductStatus.active => 'Active',
                      ProductStatus.paused => 'Inactive',
                      ProductStatus.deleted => 'Archived',
                    },
                  ),
                ],
              );

              final col2 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoField(
                    label: 'BRAND',
                    value: product.brandName ?? '—',
                    subtext: product.brandName?.toLowerCase(),
                  ),
                  const SizedBox(height: 20),
                  _InfoField(
                    label: 'BARCODE',
                    value: product.barcode?.isNotEmpty == true
                        ? product.barcode!
                        : '—',
                  ),
                  const SizedBox(height: 20),
                  _InfoField(
                    label: 'LOW-STOCK THRESHOLD',
                    value: '${product.minQuantityThreshold ?? 0}',
                    subtext: 'POS alerts when stock falls to or below this',
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [col1, const SizedBox(height: 20), col2],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 24),
                  Expanded(child: col2),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, this.subtext});

  final String label;
  final String value;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        if (subtext != null && subtext!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtext!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Pricing & Profitability (Right Column)
// ---------------------------------------------------------------------------
class _PricingProfitabilityCard extends StatelessWidget {
  const _PricingProfitabilityCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cost = product.purchasePriceMinor;
    final profit = cost == null ? null : product.sellingPriceMinor - cost;
    final margin = (cost == null || cost <= 0) ? null : (profit! / cost) * 100;
    final stockValue = cost == null ? null : cost * (product.stockQty ?? 0);

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: 20,
                color: AppColors.ink,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pricing & Profitability',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 580;
              final isTiny = constraints.maxWidth < 360;

              final items = [
                _StatItem(
                  label: 'SELLING PRICE',
                  value: formatPkr(product.sellingPriceMinor),
                  valueColor: AppColors.ink,
                ),
                _StatItem(
                  label: 'PURCHASE COST',
                  value: cost == null ? 'PKR 0.00' : formatPkr(cost),
                  valueColor: AppColors.ink,
                ),
                _StatItem(
                  label: 'PROFIT / UNIT',
                  value: profit == null ? '—' : formatPkr(profit),
                  valueColor: const Color(0xFF0B8F4D),
                  subtext: margin == null
                      ? null
                      : '${margin.toStringAsFixed(1)}%',
                ),
                _StatItem(
                  label: 'STOCK VALUE',
                  value: stockValue == null
                      ? 'PKR 0.00'
                      : formatPkr(stockValue),
                  valueColor: const Color(0xFF0B8F4D),
                ),
              ];

              if (isTiny) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      items[i],
                    ],
                  ],
                );
              }

              if (isSmall) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: item,
                      ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(child: items[i]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.subtext,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        if (subtext != null && subtext!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtext!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Stock & Inventory (Right Column)
// ---------------------------------------------------------------------------
class _StockInventoryCard extends StatelessWidget {
  const _StockInventoryCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final stock = product.stockQty ?? 0;
    final threshold = product.minQuantityThreshold ?? 0;

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.ink),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Stock & Inventory',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 640;

              final currentStockCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT STOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$stock',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _StockHealthBadge(stock: stock, threshold: threshold),
                ],
              );

              final thresholdCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LOW-STOCK THRESHOLD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$threshold',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Alerts when stock falls at or below this level',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              final statusCol = const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STOCK STATUS ON POS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Auto-synced',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sold quantities decrement automatically after each sale',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    currentStockCol,
                    const SizedBox(height: 18),
                    thresholdCol,
                    const SizedBox(height: 18),
                    statusCol,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: currentStockCol),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: thresholdCol),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: statusCol),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StockHealthBadge extends StatelessWidget {
  const _StockHealthBadge({required this.stock, required this.threshold});

  final int stock;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = stock <= 0
        ? (const Color(0xFFFEE2E2), const Color(0xFFB91C1C), 'Out of stock')
        : (stock <= threshold
              ? (const Color(0xFFFEF3C7), const Color(0xFF92400E), 'Low stock')
              : (const Color(0xFFDCFCE7), const Color(0xFF15803D), 'Healthy'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Sales Information (Right Column)
// ---------------------------------------------------------------------------
class _SalesInformationCard extends StatelessWidget {
  const _SalesInformationCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: AppColors.ink),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sales Information',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 580;
              final isTiny = constraints.maxWidth < 360;

              final items = [
                const _StatItem(
                  label: 'UNITS SOLD',
                  value: '0',
                  valueColor: AppColors.ink,
                ),
                const _StatItem(
                  label: 'TOTAL REVENUE',
                  value: 'PKR 0.00',
                  valueColor: Color(0xFF0B8F4D),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DOCUMENTS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: const [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '0 ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              TextSpan(
                                text: 'invoices',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '0 ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              TextSpan(
                                text: 'quotations',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAST SALE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '—',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No sales recorded yet',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ];

              if (isTiny) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      items[i],
                    ],
                  ],
                );
              }

              if (isSmall) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: item,
                      ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final item in items) Expanded(child: item)],
              );
            },
          ),

          const SizedBox(height: 24),

          // Sub-section: SALES HISTORY
          const Row(
            children: [
              Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sales History',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Empty state box with rounded inbox icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 24,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
