part of '../../../main.dart';

class TransparencyPage extends StatefulWidget {
  const TransparencyPage({super.key});

  @override
  State<TransparencyPage> createState() => _TransparencyPageState();
}

class _TransparencyPageState extends State<TransparencyPage> {
  bool _isLoading = true;
  TransparencySummary _summary = TransparencySummary.empty();
  List<TransparencyBlockCollection> _blockCollections = [];
  List<TransparencyPayment> _payments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransparencyData();
  }

  Future<void> _fetchTransparencyData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/mobile/transparency'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};
        final blocks = (data['blocks'] as List<dynamic>?)
                ?.whereType<Map>()
                .map((json) => TransparencyBlockCollection.fromJson(json))
                .toList() ??
            _fallbackCollections();
            
        final paymentsList = (data['payments'] as List<dynamic>?)
                ?.whereType<Map>()
                .map((json) => TransparencyPayment.fromJson(json))
                .toList() ??
            [];

        if (mounted) {
          setState(() {
            _summary = TransparencySummary.fromJson(data, blocks);
            _blockCollections = blocks;
            _payments = paymentsList;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load transparency data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _summary = TransparencySummary.empty();
          _blockCollections = _fallbackCollections();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Transparency',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Block-wise Collection',
            style: TextStyle(
              color: _ink,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A transparent view of collections across all blocks.',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: _maroon))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  const _TransparencyNotice(
                    icon: Icons.cloud_off_outlined,
                    message:
                        'Live collection data could not be loaded. Showing a safe empty fallback.',
                  ),
                  const SizedBox(height: 14),
                ],
                _TransparencySummaryCard(summary: _summary),
                const SizedBox(height: 14),
                _BlockCollectionsCard(
                  blocks: _blockCollections,
                  payments: _payments,
                  totalAmount: _summary.totalAmount,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class TransparencySummary {
  const TransparencySummary({
    required this.totalAmount,
    required this.totalPayments,
    required this.totalExpenses,
    required this.balanceAvailable,
    required this.lastUpdated,
  });

  final int totalAmount;
  final int totalPayments;
  final int totalExpenses;
  final int balanceAvailable;
  final String lastUpdated;

  factory TransparencySummary.empty() {
    return const TransparencySummary(
      totalAmount: 0,
      totalPayments: 0,
      totalExpenses: 0,
      balanceAvailable: 0,
      lastUpdated: '',
    );
  }

  factory TransparencySummary.fromJson(
    Map<String, dynamic> json,
    List<TransparencyBlockCollection> blocks,
  ) {
    final totals = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : <String, dynamic>{};
    final amount = _readInt(
      totals['verifiedCollection'] ??
          json['totalVerifiedCollection'] ??
          json['total_verified_collection'],
    );
    final expenses = _readInt(
      totals['totalExpenses'] ??
          json['totalExpenses'] ??
          json['total_expenses'],
    );
    final payments = _readInt(
      totals['totalPayments'] ?? json['totalPayments'] ?? json['total_payments'],
    );

    return TransparencySummary(
      totalAmount: amount == 0
          ? blocks.fold(0, (sum, block) => sum + block.totalAmount)
          : amount,
      totalPayments: payments == 0
          ? blocks.fold(0, (sum, block) => sum + block.totalPayments)
          : payments,
      totalExpenses: expenses,
      balanceAvailable: _readInt(
        totals['balanceAvailable'] ??
            json['balanceAvailable'] ??
            json['balance_available'],
      ),
      lastUpdated: _readString(json['lastUpdated'] ?? json['last_updated']),
    );
  }
}

class TransparencyBlockCollection {
  const TransparencyBlockCollection({
    required this.blockId,
    required this.blockName,
    required this.totalPayments,
    required this.totalAmount,
  });

  final String blockId;
  final String blockName;
  final int totalPayments;
  final int totalAmount;

  factory TransparencyBlockCollection.fromJson(Map<dynamic, dynamic> json) {
    return TransparencyBlockCollection(
      blockId: _readString(json['blockId'] ?? json['block_id']),
      blockName: _readString(json['blockName'] ?? json['block_name']).isEmpty
          ? 'Unknown Block'
          : _readString(json['blockName'] ?? json['block_name']),
      totalPayments: _readInt(json['totalPayments'] ?? json['total_payments']),
      totalAmount: _readInt(json['totalAmount'] ?? json['total_amount']),
    );
  }
}

List<TransparencyBlockCollection> _fallbackCollections() {
  return fallbackBlocks
      .map(
        (block) => TransparencyBlockCollection(
          blockId: block.id,
          blockName: block.name,
          totalPayments: 0,
          totalAmount: 0,
        ),
      )
      .toList();
}

class TransparencyPayment {
  const TransparencyPayment({
    required this.residentName,
    required this.amount,
    required this.blockId,
  });

  final String residentName;
  final int amount;
  final String blockId;

  factory TransparencyPayment.fromJson(Map<dynamic, dynamic> json) {
    return TransparencyPayment(
      residentName: _readString(json['residentName'] ?? json['resident_name']),
      amount: _readInt(json['amount']),
      blockId: _readString(json['blockId'] ?? json['block_id']),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse((value ?? '').toString().replaceAll(RegExp(r'[^0-9-]'), '')) ??
      0;
}

String _readString(dynamic value) => (value ?? '').toString().trim();

String _formatUpdatedAt(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return 'Awaiting verified payments';

  final local = date.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year}, ${local.hour}:$minute';
}

class _TransparencySummaryCard extends StatelessWidget {
  const _TransparencySummaryCard({required this.summary});

  final TransparencySummary summary;

  @override
  Widget build(BuildContext context) {
    final balance = summary.balanceAvailable == 0
        ? summary.totalAmount - summary.totalExpenses
        : summary.balanceAvailable;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [_maroon, _maroonDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Verified Collection',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${formatIndianNumber(summary.totalAmount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Contributions',
                  value: '${summary.totalPayments}',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Expenses',
                  value: '₹${formatIndianNumber(summary.totalExpenses)}',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Balance',
                  value: '₹${formatIndianNumber(balance)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Last updated: ${_formatUpdatedAt(summary.lastUpdated)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _BlockCollectionsCard extends StatelessWidget {
  const _BlockCollectionsCard({
    required this.blocks,
    required this.payments,
    required this.totalAmount,
  });

  final List<TransparencyBlockCollection> blocks;
  final List<TransparencyPayment> payments;
  final int totalAmount;

  @override
  Widget build(BuildContext context) {
    final maxAmount = blocks.fold<int>(
      1,
      (max, block) => block.totalAmount > max ? block.totalAmount : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Block-wise Collection',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          ...blocks.map(
            (block) {
              final blockPayments = payments
                  .where((p) => p.blockId == block.blockId)
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _BlockCollectionRow(
                  block: block,
                  payments: blockPayments,
                  progress: block.totalAmount / maxAmount,
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _line)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'TOTAL',
                    style: TextStyle(
                      color: _maroonDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '₹${formatIndianNumber(totalAmount)}',
                  style: const TextStyle(
                    color: _maroonDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockCollectionRow extends StatelessWidget {
  const _BlockCollectionRow({
    required this.block,
    required this.payments,
    required this.progress,
  });

  final TransparencyBlockCollection block;
  final List<TransparencyPayment> payments;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _surfaceWarm,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.apartment_outlined, color: _maroon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      block.blockName,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '₹${formatIndianNumber(block.totalAmount)}',
                    style: const TextStyle(
                      color: _leaf,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: _line,
                  valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${block.totalPayments} verified contributions',
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              _PaymentsList(payments: payments),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransparencyNotice extends StatelessWidget {
  const _TransparencyNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: panelDecoration(color: _surfaceWarm, radius: 14),
      child: Row(
        children: [
          Icon(icon, color: _maroon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({required this.payments});

  final List<TransparencyPayment> payments;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3DE).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: payments.map((payment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      payment.residentName,
                      style: const TextStyle(
                        color: Color(0xFF17120F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    "₹${formatIndianNumber(payment.amount)}",
                    style: const TextStyle(
                      color: Color(0xFF3F7E4A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

