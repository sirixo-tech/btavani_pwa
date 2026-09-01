part of '../../../main.dart';

class ContributePage extends StatefulWidget {
  const ContributePage({this.onBackToHome, super.key});

  final VoidCallback? onBackToHome;

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  static const int minimumContributionAmount = 2000;
  static const int maximumContributionAmount = 99000;
  List<Block> _blocks = [];
  Map<String, String>? _appSettings;
  bool _isLoadingBlocks = true;

  final _detailsFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _customAmountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _flatController = TextEditingController();
  final _gotramController = TextEditingController();
  final _utrController = TextEditingController();
  XFile? _screenshotFile;

  final List<ContributionAmountOption> amounts = const [
    ContributionAmountOption(2001),
    ContributionAmountOption(5001),
    ContributionAmountOption(10001),
    ContributionAmountOption(25001),
    ContributionAmountOption(50001),
    ContributionAmountOption(null),
  ];

  int _currentStep = 0;
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
        _blocks = bootstrap.blocks.isEmpty ? fallbackBlocks : bootstrap.blocks;
        _appSettings = bootstrap.appSettings;
        if (_blocks.isNotEmpty) {
          _selectedBlock = _blocks.first;
        }
        _isLoadingBlocks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _blocks = fallbackBlocks;
        _selectedBlock = fallbackBlocks.first;
        _isLoadingBlocks = false;
      });
    }
  }

  int? get _selectedAmount {
    final preset = amounts[_selectedAmountIndex].amount;
    if (preset != null) return preset;

    return int.tryParse(
      _customAmountController.text.replaceAll(',', '').trim(),
    );
  }

  String get _selectedUpiId => _selectedBlock?.upiId ?? '';
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
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _flatController.dispose();
    _gotramController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!_validateStep(_currentStep)) return;

    if (_currentStep == 5) {
      setState(() => _isSubmitting = true);
      try {
        final api = EventApiService();
        await api.submitPayment(
          amount: _selectedAmount ?? amounts.first.amount!,
          blockId: _selectedBlock?.id ?? '',
          residentName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          flatNumber: _flatController.text.trim(),
          gotram: _gotramController.text.trim(),
          utr: _utrController.text.trim(),
          screenshotBytes: _screenshotFile != null
              ? await _screenshotFile!.readAsBytes()
              : null,
          screenshotName: _screenshotFile?.name,
        );
        if (!mounted) return;
        _showSnack('Payment marked complete. Thank you for contributing.');

        // Navigate to home page
        if (widget.onBackToHome != null) {
          widget.onBackToHome?.call();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        _showSnack('Failed to record payment: $e');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }

    setState(() => _currentStep += 1);
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    widget.onBackToHome?.call();
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        final amount = _selectedAmount;
        if (amount == null ||
            amount < minimumContributionAmount ||
            amount > maximumContributionAmount) {
          _showSnack('Please enter an amount between Rs 2,000 and Rs 99,000.');
          return false;
        }
        return true;
      case 1:
        return _detailsFormKey.currentState?.validate() ?? false;
      case 2:
        return _addressFormKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  void _editStep(int step) {
    setState(() {
      _currentStep = step;
      _paymentMarkedComplete = false;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _requiredValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $field.';
    }
    return '';
  }

  String? _validateRequired(String? value, String field) {
    final message = _requiredValidator(value, field);
    return message.isEmpty ? null : message;
  }

  String? _validateEmail(String? value) {
    final requiredMessage = _requiredValidator(value, 'email');
    if (requiredMessage.isNotEmpty) return requiredMessage;

    final text = value!.trim();
    if (!text.contains('@') || !text.contains('.')) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final requiredMessage = _requiredValidator(value, 'phone number');
    if (requiredMessage.isNotEmpty) return requiredMessage;

    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Please enter a 10 digit phone number.';
    }
    return null;
  }

  Widget _buildHeaderLogo() {
    final logoUrl = _appSettings?['app_logo'];
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        width: 150,
        height: 54,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackHeaderLogo(),
      );
    }

    return _buildFallbackHeaderLogo();
  }

  Widget _buildFallbackHeaderLogo() {
    return Image.asset(
      'assets/images/btavani.png',
      width: 150,
      height: 54,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _selectedAmount ?? amounts.first.amount!;

    if (_isLoadingBlocks) {
      return const Center(child: CircularProgressIndicator(color: _maroon));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 104),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                Expanded(child: Center(child: _buildHeaderLogo())),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    tooltip: 'Announcements',
                    onPressed: () => _push(context, const AnnouncementsPage()),
                    icon: const Icon(Icons.notifications_none),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/btavani.png',
                height: 60,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your contribution makes this celebration special!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ContributionStepper(currentStep: _currentStep),
            const SizedBox(height: 22),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: switch (_currentStep) {
                  0 => _AmountStep(
                    amounts: amounts,
                    selectedAmountIndex: _selectedAmountIndex,
                    customAmountController: _customAmountController,
                    onSelected: (index) {
                      setState(() => _selectedAmountIndex = index);
                    },
                  ),
                  1 => _DetailsStep(
                    formKey: _detailsFormKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    validateRequired: _validateRequired,
                    validateEmail: _validateEmail,
                    validatePhone: _validatePhone,
                  ),
                  2 => _AddressStep(
                    formKey: _addressFormKey,
                    blocks: _blocks.map((b) => b.name).toList(),
                    selectedBlock: _selectedBlock?.name ?? '',
                    flatController: _flatController,
                    gotramController: _gotramController,
                    onBlockChanged: (block) {
                      setState(
                        () => _selectedBlock = _blocks.firstWhere(
                          (b) => b.name == block,
                        ),
                      );
                    },
                    validateRequired: _validateRequired,
                  ),
                  3 => _BlockStep(
                    blocks: _blocks.map((b) => b.name).toList(),
                    selectedBlock: _selectedBlock?.name ?? '',
                    onSelected: (block) {
                      setState(
                        () => _selectedBlock = _blocks.firstWhere(
                          (b) => b.name == block,
                        ),
                      );
                    },
                  ),
                  4 => _ReviewStep(
                    amount: amount,
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    block: _selectedBlock?.name ?? '',
                    flatNumber: _flatController.text,
                    gotram: _gotramController.text,
                    onEdit: _editStep,
                  ),
                  _ => _PaymentStep(
                    amount: amount,
                    block: _selectedBlock?.name ?? '',
                    upiId: _selectedUpiId,
                    qrImageUrl: _selectedQrImageUrl,
                    upiPayload: _upiUri.toString(),
                    paymentMarkedComplete: _paymentMarkedComplete,
                    utrController: _utrController,
                    screenshotFileName: _screenshotFile?.name,
                    onPickScreenshot: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null) {
                        setState(() => _screenshotFile = file);
                      }
                    },
                  ),
                },
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: PrimaryButton(
                label: switch (_currentStep) {
                  4 => 'PROCEED TO PAYMENT',
                  5 =>
                    _paymentMarkedComplete
                        ? 'PAYMENT COMPLETED'
                        : 'I HAVE COMPLETED THE PAYMENT',
                  _ => 'CONTINUE',
                },
                isLoading: _isSubmitting,
                onPressed: _continue,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ContributionAmountOption {
  const ContributionAmountOption(this.amount);

  final int? amount;

  String get label {
    if (amount == null) return 'Other';
    return '₹${formatIndianNumber(amount!)}';
  }
}

class ContributionStepper extends StatelessWidget {
  const ContributionStepper({required this.currentStep, super.key});

  final int currentStep;

  static const _labels = [
    'Amount',
    'Details',
    'Address',
    'Block',
    'Review',
    'Payment',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index <= currentStep ? _maroon : _line,
                    shape: BoxShape.circle,
                  ),
                  child: index < currentStep
                      ? const Icon(Icons.check, color: Colors.white, size: 15)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= currentStep ? Colors.white : _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _labels[index],
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (index != _labels.length - 1)
            Container(
              width: 10,
              height: 1.4,
              margin: const EdgeInsets.only(bottom: 21),
              color: index < currentStep ? _maroon : _line,
            ),
        ],
      ],
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({
    required this.amounts,
    required this.selectedAmountIndex,
    required this.customAmountController,
    required this.onSelected,
  });

  final List<ContributionAmountOption> amounts;
  final int selectedAmountIndex;
  final TextEditingController customAmountController;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final otherSelected = amounts[selectedAmountIndex].amount == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle(
          title: 'Choose Contribution Amount',
          subtitle:
              'Please enter your contribution amount between ₹2,000 and ₹99,000.',
        ),
        const SizedBox(height: 22),
        const Text(
          'Select Amount',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.72,
          ),
          itemCount: amounts.length,
          itemBuilder: (context, index) {
            return AmountButton(
              label: amounts[index].label,
              selected: selectedAmountIndex == index,
              onTap: () => onSelected(index),
            );
          },
        ),
        if (otherSelected) ...[
          const SizedBox(height: 14),
          ContributionTextField(
            label: 'Other Amount *',
            hint: 'Enter amount',
            controller: customAmountController,
            keyboardType: TextInputType.number,
            prefixText: '₹ ',
          ),
        ],
        const SizedBox(height: 18),
        const ContributionNotice(
          icon: Icons.shield_outlined,
          text:
              'Every contribution, big or small, makes a big difference.\nThank you.',
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.validateRequired,
    required this.validateEmail,
    required this.validatePhone,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? Function(String?, String) validateRequired;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePhone;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Enter Details',
            subtitle:
                'Please provide your details for a smoother contribution experience.',
          ),
          const SizedBox(height: 22),
          ContributionTextField(
            label: 'Resident / Devotee Full Name *',
            hint: 'Enter Full Name',
            icon: Icons.person_outline,
            controller: nameController,
            validator: (value) => validateRequired(value, 'full name'),
          ),
          ContributionTextField(
            label: 'Email *',
            hint: 'Enter Email',
            icon: Icons.mail_outline,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          ContributionTextField(
            label: 'Phone Number *',
            hint: 'Enter Phone Number',
            icon: Icons.phone_outlined,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            prefixText: '+91 ',
            validator: validatePhone,
          ),
        ],
      ),
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.formKey,
    required this.blocks,
    required this.selectedBlock,
    required this.flatController,
    required this.gotramController,
    required this.onBlockChanged,
    required this.validateRequired,
  });

  final GlobalKey<FormState> formKey;
  final List<String> blocks;
  final String selectedBlock;
  final TextEditingController flatController;
  final TextEditingController gotramController;
  final ValueChanged<String> onBlockChanged;
  final String? Function(String?, String) validateRequired;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Address Details',
            subtitle: 'Please provide your address details.',
          ),
          const SizedBox(height: 22),
          const _FieldLabel('Block *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedBlock,
            items: [
              for (final block in blocks)
                DropdownMenuItem(value: block, child: Text(block)),
            ],
            onChanged: (value) {
              if (value != null) onBlockChanged(value);
            },
            decoration: contributionInputDecoration(hint: 'Select Block'),
          ),
          const SizedBox(height: 16),
          ContributionTextField(
            label: 'Flat Number *',
            hint: 'Enter Flat Number',
            icon: Icons.apartment_outlined,
            controller: flatController,
            textCapitalization: TextCapitalization.characters,
            validator: (value) => validateRequired(value, 'flat number'),
          ),
          ContributionTextField(
            label: 'Gotram (Optional)',
            hint: 'Enter Gotram',
            icon: Icons.temple_hindu_outlined,
            controller: gotramController,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }
}

class _BlockStep extends StatelessWidget {
  const _BlockStep({
    required this.blocks,
    required this.selectedBlock,
    required this.onSelected,
  });

  final List<String> blocks;
  final String selectedBlock;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle(
          title: 'Select Your Block',
          subtitle: 'Please select your residential block.',
        ),
        const SizedBox(height: 22),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.65,
          ),
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index];
            final selected = block == selectedBlock;
            return BlockButton(
              label: block,
              selected: selected,
              onTap: () => onSelected(block),
            );
          },
        ),
        const SizedBox(height: 22),
        const ContributionNotice(
          icon: Icons.shield_outlined,
          text:
              'Your contribution will be sent to your respective Block Organizer.',
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.amount,
    required this.name,
    required this.email,
    required this.phone,
    required this.block,
    required this.flatNumber,
    required this.gotram,
    required this.onEdit,
  });

  final int amount;
  final String name;
  final String email;
  final String phone;
  final String block;
  final String flatNumber;
  final String gotram;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ReviewRowData(
        icon: Icons.currency_rupee,
        label: 'Amount',
        value: '₹${formatIndianNumber(amount)}',
        step: 0,
      ),
      ReviewRowData(
        icon: Icons.person_outline,
        label: 'Name',
        value: name,
        step: 1,
      ),
      ReviewRowData(
        icon: Icons.mail_outline,
        label: 'Email',
        value: email,
        step: 1,
      ),
      ReviewRowData(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: '+91 $phone',
        step: 1,
      ),
      ReviewRowData(
        icon: Icons.apartment_outlined,
        label: 'Block',
        value: block,
        step: 3,
      ),
      ReviewRowData(
        icon: Icons.meeting_room_outlined,
        label: 'Flat Number',
        value: flatNumber.toUpperCase(),
        step: 2,
      ),
      ReviewRowData(
        icon: Icons.temple_hindu_outlined,
        label: 'Gotram',
        value: gotram.trim().isEmpty ? 'Not provided' : gotram,
        step: 2,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle(
          title: 'Review & Confirm',
          subtitle: 'Please review your details before proceeding to payment.',
        ),
        const SizedBox(height: 16),
        Container(
          decoration: panelDecoration(radius: 7, elevated: false),
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                ReviewRow(data: rows[index], onEdit: onEdit),
                if (index != rows.length - 1)
                  Divider(height: 1, color: _line.withValues(alpha: 0.75)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.amount,
    required this.block,
    required this.upiId,
    required this.qrImageUrl,
    required this.upiPayload,
    required this.paymentMarkedComplete,
    required this.utrController,
    this.screenshotFileName,
    required this.onPickScreenshot,
  });

  final int amount;
  final String block;
  final String upiId;
  final String qrImageUrl;
  final String upiPayload;
  final bool paymentMarkedComplete;
  final TextEditingController utrController;
  final String? screenshotFileName;
  final VoidCallback onPickScreenshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_maroon, _maroonDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You are contributing to',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      block,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${formatIndianNumber(amount)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: panelDecoration(radius: 7, elevated: false),
          child: Column(
            children: [
              const Text(
                'Scan & Pay using any UPI App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                '(Google Pay / PhonePe / Paytm / any UPI)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _StepTitle(
          title: 'Have you completed the payment?',
          subtitle: 'Please submit payment details for verification.',
        ),
        const SizedBox(height: 16),
        ContributionTextField(
          label: 'UTR / Transaction ID *',
          hint: 'e.g. 123456789012',
          icon: Icons.tag,
          controller: utrController,
        ),
        const SizedBox(height: 4),
        const _FieldLabel('Screenshot (Optional)'),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickScreenshot,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _paper,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: _maroon, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    screenshotFileName ?? 'Upload screenshot for reference',
                    style: TextStyle(
                      color: screenshotFileName != null ? _ink : _muted,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (screenshotFileName != null)
                  const Icon(Icons.check_circle, color: Colors.green, size: 19),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const ContributionNotice(
          icon: Icons.shield_outlined,
          text: 'Your payment will be verified by your block volunteer.',
        ),
        if (paymentMarkedComplete) ...[
          const SizedBox(height: 12),
          const ContributionNotice(
            icon: Icons.check_circle_outline,
            text:
                'Thank you. Your payment completion has been noted on this device.',
          ),
        ],
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _ink,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

InputDecoration contributionInputDecoration({
  required String hint,
  IconData? icon,
  String? prefixText,
}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefixText,
    prefixIcon: icon == null ? null : Icon(icon, color: _maroon, size: 19),
    filled: true,
    fillColor: _paper,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: _line.withValues(alpha: 0.9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: _maroon, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: _maroon, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: _maroon, width: 1.5),
    ),
  );
}

class ContributionTextField extends StatelessWidget {
  const ContributionTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.prefixText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator,
            decoration: contributionInputDecoration(
              hint: hint,
              icon: icon,
              prefixText: prefixText,
            ),
          ),
        ],
      ),
    );
  }
}

class ContributionNotice extends StatelessWidget {
  const ContributionNotice({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_goldLight.withValues(alpha: 0.34), _surfaceWarm],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _gold.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Icon(icon, color: _gold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _maroonDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewRowData {
  const ReviewRowData({
    required this.icon,
    required this.label,
    required this.value,
    required this.step,
  });

  final IconData icon;
  final String label;
  final String value;
  final int step;
}

class ReviewRow extends StatelessWidget {
  const ReviewRow({required this.data, required this.onEdit, super.key});

  final ReviewRowData data;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(data.icon, color: _maroon, size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit ${data.label}',
            onPressed: () => onEdit(data.step),
            icon: const Icon(Icons.edit_outlined, color: _ink, size: 19),
          ),
        ],
      ),
    );
  }
}

class AmountButton extends StatelessWidget {
  const AmountButton({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [_maroon, _maroonDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : _paper,
            border: Border.all(
              color: selected ? _maroon : _line.withValues(alpha: 0.9),
            ),
            borderRadius: BorderRadius.circular(7),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _maroon.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlockButton extends StatelessWidget {
  const BlockButton({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [_maroon, _maroonDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : _paper,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected ? _maroon : _line.withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.apartment_outlined,
                color: selected ? Colors.white : _maroon,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : _ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatIndianNumber(int value) {
  final text = value.toString();
  if (text.length <= 3) return text;

  final lastThree = text.substring(text.length - 3);
  final leading = text.substring(0, text.length - 3);
  final parts = <String>[];

  for (var end = leading.length; end > 0; end -= 2) {
    final start = end - 2 < 0 ? 0 : end - 2;
    parts.insert(0, leading.substring(start, end));
  }

  return '${parts.join(',')},$lastThree';
}
