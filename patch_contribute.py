import re

with open('lib/src/features/contribute/contribute_page.dart', 'r') as f:
    content = f.read()

# 1. Replace static lists
content = re.sub(
    r"  static const List<String> _blocks = \[.*?\];\n  static const Map<String, String> _upiIds = \{.*?\};\n",
    "  List<Block> _blocks = [];\n  bool _isLoadingBlocks = true;\n",
    content,
    flags=re.DOTALL
)

# 2. Update state variables and add initState
content = re.sub(
    r"  int _currentStep = 0;\n  int _selectedAmountIndex = 0;\n  String _selectedBlock = _blocks\.first;\n  bool _paymentMarkedComplete = false;\n  bool _isSubmitting = false;\n",
    """  int _currentStep = 0;
  int _selectedAmountIndex = 0;
  Block? _selectedBlock;
  bool _paymentMarkedComplete = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    try {
      final bootstrap = await EventApiService().fetchBootstrap();
      if (!mounted) return;
      setState(() {
        _blocks = bootstrap.blocks;
        if (_blocks.isNotEmpty) {
           _selectedBlock = _blocks.first;
        }
        _isLoadingBlocks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBlocks = false;
      });
    }
  }
""",
    content
)

# 3. Update getters
content = re.sub(
    r"  String get _selectedUpiId => _upiIds\[_selectedBlock\] \?\? _upiIds\.values\.first;\n\n  Uri get _upiUri \{\n    final amount = _selectedAmount \?\? amounts\.first\.amount!;\n\n    return Uri\(\n      scheme: 'upi',\n      host: 'pay',\n      queryParameters: \{\n        'pa': _selectedUpiId,\n        'pn': 'BT AVANI Ganesh Utsav Committee',\n        'am': amount\.toString\(\),\n        'cu': 'INR',\n        'tn': 'Avani Ganesh Utsav 2026 - \$_selectedBlock',\n      \},\n    \);\n  \}",
    """  String get _selectedUpiId => _selectedBlock?.upiId ?? '';
  String get _selectedQrImageUrl => _selectedBlock?.qrImageUrl ?? '';

  Uri get _upiUri {
    final amount = _selectedAmount ?? amounts.first.amount!;

    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': _selectedUpiId,
        'pn': 'BT AVANI Ganesh Utsav Committee',
        'am': amount.toString(),
        'cu': 'INR',
        'tn': 'Avani Ganesh Utsav 2026 - ${_selectedBlock?.name ?? ''}',
      },
    );
  }""",
    content,
    flags=re.DOTALL
)

# 4. Update submitPayment
content = content.replace(
    "blockId: _selectedBlock.toLowerCase().replaceAll(' ', ''),",
    "blockId: _selectedBlock?.id ?? '',"
)

# 5. Fix _AddressStep, _BlockStep, _ReviewStep, _PaymentStep instantiations
content = content.replace("selectedBlock: _selectedBlock,", "selectedBlock: _selectedBlock?.name ?? '',")
content = content.replace("block: _selectedBlock,", "block: _selectedBlock?.name ?? '',")
content = content.replace("blocks: _blocks,", "blocks: _blocks.map((b) => b.name).toList(),")

# 6. Pass qrImageUrl to _PaymentStep
content = content.replace(
    """                  _ => _PaymentStep(
                    amount: amount,
                    block: _selectedBlock?.name ?? '',
                    upiId: _selectedUpiId,
                    upiPayload: _upiUri.toString(),
                    paymentMarkedComplete: _paymentMarkedComplete,
                  ),""",
    """                  _ => _PaymentStep(
                    amount: amount,
                    block: _selectedBlock?.name ?? '',
                    upiId: _selectedUpiId,
                    qrImageUrl: _selectedQrImageUrl,
                    upiPayload: _upiUri.toString(),
                    paymentMarkedComplete: _paymentMarkedComplete,
                  ),"""
)

# 7. Update _PaymentStep class to accept qrImageUrl
content = content.replace(
    """  const _PaymentStep({
    required this.amount,
    required this.block,
    required this.upiId,
    required this.upiPayload,
    required this.paymentMarkedComplete,
  });

  final int amount;
  final String block;
  final String upiId;
  final String upiPayload;
  final bool paymentMarkedComplete;""",
    """  const _PaymentStep({
    required this.amount,
    required this.block,
    required this.upiId,
    required this.qrImageUrl,
    required this.upiPayload,
    required this.paymentMarkedComplete,
  });

  final int amount;
  final String block;
  final String upiId;
  final String qrImageUrl;
  final String upiPayload;
  final bool paymentMarkedComplete;"""
)

# 8. Update QR generation UI to use qrImageUrl if available
content = content.replace(
    """              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: QrImageView(
                  data: upiPayload,
                  version: QrVersions.auto,
                  size: 220,
                  gapless: false,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'UPI ID: $upiId',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),""",
    """              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: qrImageUrl.isNotEmpty
                    ? Image.network(
                        qrImageUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      )
                    : QrImageView(
                        data: upiPayload,
                        version: QrVersions.auto,
                        size: 220,
                        gapless: false,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              if (upiId.isNotEmpty)
                Text(
                  'UPI ID: $upiId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),"""
)

# 9. Handle isLoading in build
content = content.replace(
    "final amount = _selectedAmount ?? amounts.first.amount!;",
    """final amount = _selectedAmount ?? amounts.first.amount!;

    if (_isLoadingBlocks) {
      return const Center(
        child: CircularProgressIndicator(color: _maroon),
      );
    }"""
)


with open('lib/src/features/contribute/contribute_page.dart', 'w') as f:
    f.write(content)
