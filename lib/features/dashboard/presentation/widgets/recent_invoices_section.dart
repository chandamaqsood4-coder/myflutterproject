import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/dashboard_summary.dart';
import 'status_chip.dart';

class RecentInvoicesSection extends StatelessWidget {
  const RecentInvoicesSection({
    super.key,
    required this.invoices,
    required this.onViewAll,
    required this.onOpenInvoice,
  });

  final List<RecentInvoice> invoices;
  final VoidCallback onViewAll;
  final ValueChanged<RecentInvoice> onOpenInvoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.description_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Recent Invoices',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All'),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < invoices.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.border),
                _InvoiceRow(
                  invoice: invoices[i],
                  onTap: () => onOpenInvoice(invoices[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice, required this.onTap});

  final RecentInvoice invoice;
  final VoidCallback onTap;

  /// Below this width the single-line layout no longer fits and the row
  /// switches to a stacked one.
  static const double _wideLayoutBreakpoint = 400;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.hoverFill,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _wideLayoutBreakpoint) {
              return _stacked(context);
            }
            return _singleLine(context);
          },
        ),
      ),
    );
  }

  Widget _singleLine(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _description()),
        const SizedBox(width: 12),
        _amount(),
        const SizedBox(width: 12),
        StatusChip(status: invoice.status),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_right,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _stacked(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _number()),
            const SizedBox(width: 12),
            StatusChip(status: invoice.status),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _customer()),
            const SizedBox(width: 12),
            _amount(),
          ],
        ),
      ],
    );
  }

  Widget _description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_number(), const SizedBox(height: 2), _customer()],
    );
  }

  Widget _number() {
    return Text(
      invoice.number,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }

  Widget _customer() {
    return Text(
      '${invoice.customerName} · ${formatShortDate(invoice.date)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
    );
  }

  /// The amount keeps its natural width and scales down rather than
  /// overflowing, so a price is never truncated.
  Widget _amount() {
    return Flexible(
      flex: 0,
      fit: FlexFit.loose,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          formatPkr(invoice.totalMinor),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
