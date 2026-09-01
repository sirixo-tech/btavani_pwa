part of '../../../main.dart';

class TransparencyPage extends StatefulWidget {
  const TransparencyPage({super.key});

  @override
  State<TransparencyPage> createState() => _TransparencyPageState();
}

class _TransparencyPageState extends State<TransparencyPage> {
  bool _isLoading = true;
  List<dynamic> _blockCollections = [];
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
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _blockCollections = data['blocks'] ?? [];
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
          else if (_error != null)
            Center(
              child: Text(
                'Error loading data. Please try again later.',
                style: TextStyle(color: Colors.red[700]),
              ),
            )
          else if (_blockCollections.isEmpty)
            const Center(
              child: Text(
                'No collections recorded yet.',
                style: TextStyle(color: _muted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _blockCollections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final block = _blockCollections[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: panelDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _surfaceWarm,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.apartment_outlined,
                          color: _maroon,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block['block_name'] ?? 'Unknown Block',
                              style: const TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${block['total_payments'] ?? 0} Contributions',
                              style: const TextStyle(
                                color: _muted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${formatIndianNumber(block['total_amount'] ?? 0)}',
                        style: const TextStyle(
                          color: _leaf,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
