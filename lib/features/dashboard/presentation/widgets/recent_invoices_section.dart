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
            const SizedBox(width: 8),
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

  /// Below this width the invoice number, amount and status cannot share one
  /// line without clipping, so the amount moves to a line of its own.
  static const double _wideBreakpoint = 520;

  final RecentInvoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.hoverFill,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _wideBreakpoint) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NumberLines(invoice: invoice),
                  const SizedBox(height: 8),
                  _AmountLine(invoice: invoice, compact: true),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _NumberLines(invoice: invoice)),
                const SizedBox(width: 12),
                _AmountLine(invoice: invoice),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Invoice number and customer line.
class _NumberLines extends StatelessWidget {
  const _NumberLines({required this.invoice});

  final RecentInvoice invoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invoice.number,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${invoice.customerName} · ${formatShortDate(invoice.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Amount, status and the open-invoice chevron.
///
/// [compact] lets the amount and the status chip shrink instead of
/// overflowing when the row does not have room for their natural width.
class _AmountLine extends StatelessWidget {
  const _AmountLine({required this.invoice, this.compact = false});

  final RecentInvoice invoice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final amount = Text(
      formatPkr(invoice.totalMinor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
    final status = StatusChip(status: invoice.status);

    return Row(
      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (compact) Flexible(child: amount) else amount,
        const SizedBox(width: 12),
        if (compact) Flexible(child: status) else status,
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_right,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
