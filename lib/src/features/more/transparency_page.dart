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
      title: 'Collections',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Collection Transparency',
            style: TextStyle(
              color: _ink,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A simple block-wise view of verified contributions, pending entries, expenses and available balance.',
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
                        'Live data could not be refreshed. Showing available collection blocks until the connection is back.',
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
    required this.status,
  });

  final String residentName;
  final int amount;
  final String blockId;
  final String status;

  factory TransparencyPayment.fromJson(Map<dynamic, dynamic> json) {
    return TransparencyPayment(
      residentName: _readString(json['residentName'] ?? json['resident_name']),
      amount: _readInt(json['amount']),
      blockId: _readString(json['blockId'] ?? json['block_id']),
      status: _readString(json['status'], fallback: 'paid'),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse((value ?? '').toString().replaceAll(RegExp(r'[^0-9-]'), '')) ??
      0;
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString().trim();
}

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

class _BlockCollectionsCard extends StatefulWidget {
  const _BlockCollectionsCard({
    required this.blocks,
    required this.payments,
    required this.totalAmount,
  });

  final List<TransparencyBlockCollection> blocks;
  final List<TransparencyPayment> payments;
  final int totalAmount;

  @override
  State<_BlockCollectionsCard> createState() => _BlockCollectionsCardState();
}

class _BlockCollectionsCardState extends State<_BlockCollectionsCard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final maxAmount = widget.blocks.fold<int>(
      1,
      (max, block) => block.totalAmount > max ? block.totalAmount : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Collections',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 36,
              child: SegmentedPill(
                  labels: const ['Blocks', 'Users'],
                  selectedIndex: _tab,
                  onChanged: (val) {
                    setState(() {
                      _tab = val;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_tab == 0)
            ...widget.blocks.map(
              (block) {
                final blockPayments = widget.payments
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
            )
          else
            _UserWiseList(payments: widget.payments),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: panelDecoration(elevated: true),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL VERIFIED',
                  style: TextStyle(
                    color: _maroonDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '₹${formatIndianNumber(widget.totalAmount)}',
                style: const TextStyle(
                  color: _maroonDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserWiseList extends StatelessWidget {
  const _UserWiseList({required this.payments});

  final List<TransparencyPayment> payments;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No resident contributions to show yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: payments.map((payment) {
          final initial = payment.residentName.trim().isNotEmpty
              ? payment.residentName.trim().substring(0, 1).toUpperCase()
              : '?';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: panelDecoration(elevated: true),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_gold, _maroon],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.residentName,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (payment.status == 'pending')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            'Verification Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Paid Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '₹${formatIndianNumber(payment.amount)}',
                  style: const TextStyle(
                    color: _leaf,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: panelDecoration(elevated: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_maroon, _maroonDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _maroon.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.apartment_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        block.blockName,
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '₹${formatIndianNumber(block.totalAmount)}',
                      style: const TextStyle(
                        color: _leaf,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: _line,
                    valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  block.totalPayments == 1
                      ? '1 verified contribution'
                      : '${block.totalPayments} verified contributions',
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                if (payments.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _PaymentsList(payments: payments),
                ],
              ],
            ),
          ),
        ],
      ),
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
          color: const Color(0xFFFFF3DE).withValues(alpha: 0.5),
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
