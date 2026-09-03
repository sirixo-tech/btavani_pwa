part of '../../../main.dart';

class ContributePage extends StatefulWidget {
  const ContributePage({this.onBackToHome, super.key});

  final VoidCallback? onBackToHome;

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {

  List<Block> _blocks = [];
  bool _isLoadingBlocks = true;
  String? _appLogoUrl;

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
    ContributionAmountOption(2116),
    ContributionAmountOption(5116),
    ContributionAmountOption(10116),
    ContributionAmountOption(null),
  ];

  int _currentStep = 0;
  int _selectedAmountIndex = 0;
  Block? _selectedBlock;
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
        _appLogoUrl = bootstrap.appSettings['app_logo'];
        _isLoadingBlocks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _blocks = fallbackBlocks;
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

  String get _upiUri {
    final amount = _selectedAmount ?? amounts.first.amount!;
    final tn = 'Ganesh Utsav 2026 - ${_selectedBlock?.name ?? ''}-${_flatController.text.trim()}';

    return 'upi://pay?pa=$_selectedUpiId&pn=BT%20AVANI%20Ganesh%20Utsav%20Committee&mc=0000&am=${amount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(tn)}';
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

    if (_currentStep == 3) {
      setState(() => _isSubmitting = true);
      try {
        final api = EventApiService();
        final response = await api.submitPayment(
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
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedCheckmark(),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;
        Navigator.pop(context); // close dialog

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ThankYouScreen(
              paymentData: response,
              onBackToHome: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const FestivalShell()),
                (route) => false,
              ),
              onViewTracker: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const FestivalShell()),
                  (route) => false,
                );
                // Also push transparency
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TransparencyPage()));
              },
            ),
          ),
        );
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
        if (amount == null || amount <= 0) {
          _showSnack('Please enter an amount greater than 0.');
          return false;
        }
        return true;
      case 1:
        return _detailsFormKey.currentState?.validate() ?? false;
      case 2:
        return _addressFormKey.currentState?.validate() ?? false;
      case 3:
        if (_screenshotFile == null) {
          _showSnack('Please upload the payment screenshot.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _editStep(int step) {
    setState(() {
      _currentStep = step;
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
    if (_appLogoUrl != null && _appLogoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _appLogoUrl!,
        width: 150,
        height: 54,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/btavani.png',
          width: 150,
          height: 54,
          fit: BoxFit.contain,
        ),
      );
    }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
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
            const SizedBox(height: 5),
            const Text(
              'Your contribution makes this celebration special!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.w900,
                fontSize: 14,
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
                  _ => _PaymentStep(
                    amount: amount,
                    block: _selectedBlock?.name ?? '',
                    name: _nameController.text,
                    phone: _phoneController.text,
                    flatNumber: _flatController.text,
                    upiId: _selectedUpiId,
                    qrImageUrl: _selectedQrImageUrl,
                    upiPayload: _upiUri.toString(),
                    utrController: _utrController,
                    screenshotFileName: _screenshotFile?.name,
                    onEdit: _editStep,
                    onPickScreenshot: () async {
                      final source = await showModalBottomSheet<ImageSource>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Camera'),
                                onTap: () => Navigator.pop(ctx, ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Gallery'),
                                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (source != null) {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(source: source);
                        if (file != null) {
                          setState(() => _screenshotFile = file);
                        }
                      }
                    },
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SizedBox(
              height: 54,
              child: PrimaryButton(
                label: switch (_currentStep) {
                  3 => 'SUBMIT',
                  _ => 'CONTINUE',
                },
                isLoading: _isSubmitting,
                onPressed: _continue,
              ),
            ),
          ),
        ],
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
                    color: index < currentStep
                        ? Colors.green[700]
                        : (index == currentStep ? _maroon : _line),
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
              color: index < currentStep ? Colors.green[700] : _line,
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
        const SizedBox(height: 8),
        const Text(
          'Select Amount',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          itemCount: amounts.length,
          itemBuilder: (context, index) {
            final option = amounts[index];
            return AmountButton(
              amount: option.amount,
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
  final String? selectedBlock;
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
            value: selectedBlock,
            items: [
              for (final block in blocks)
                DropdownMenuItem(value: block, child: Text(block)),
            ],
            onChanged: (value) {
              if (value != null) onBlockChanged(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your block.';
              }
              return null;
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

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.amount,
    required this.block,
    required this.name,
    required this.phone,
    required this.flatNumber,
    required this.upiId,
    required this.qrImageUrl,
    required this.upiPayload,
    required this.utrController,
    this.screenshotFileName,
    required this.onEdit,
    required this.onPickScreenshot,
  });

  final int amount;
  final String block;
  final String name;
  final String phone;
  final String flatNumber;
  final String upiId;
  final String qrImageUrl;
  final String upiPayload;
  final TextEditingController utrController;
  final String? screenshotFileName;
  final ValueChanged<int> onEdit;
  final VoidCallback onPickScreenshot;

  Widget _buildUpiAppIcon(String name, String? assetPath, String urlScheme) {
    String url = upiPayload;
    if (urlScheme.isNotEmpty) {
      url = url.replaceFirst('upi://pay', urlScheme);
    }
    final uri = Uri.parse(url);

    return Expanded(
      child: Link(
        uri: uri,
        target: LinkTarget.self,
        builder: (context, followLink) => GestureDetector(
          onTap: () {
            print('LAUNCHING UPI URI: $uri');
            if (followLink != null) {
              followLink();
            } else {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: name == 'PhonePe'
                    ? Colors.purple.shade200
                    : (name == 'Google Pay' ? Colors.blue.shade200 : Colors.lightBlue.shade200),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (assetPath != null)
                  Image.asset(assetPath, width: 46, height: 46, fit: BoxFit.contain)
                else
                  const Icon(Icons.account_balance, size: 46),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ink)),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tap to Pay', style: TextStyle(fontSize: 10, color: _muted)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 12, color: _maroon),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Step 4 of 4',
                style: TextStyle(color: Color(0xFF9B1B30), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a payment option',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose any option below to complete your payment',
            style: TextStyle(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.phone_android, size: 20, color: _maroon),
              const SizedBox(width: 8),
              const Text('Pay using UPI App', style: TextStyle(fontWeight: FontWeight.bold, color: _ink)),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: _line.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildUpiAppIcon('PhonePe', 'assets/images/payment/phonepe.png', 'phonepe://pay'),
              const SizedBox(width: 12),
              _buildUpiAppIcon('Google Pay', 'assets/images/payment/google_pay.png', 'tez://upi/pay'),
              const SizedBox(width: 12),
              _buildUpiAppIcon('Paytm', 'assets/images/payment/paytm.jpg', 'paytmmp://pay'),
            ],
          ),
          const SizedBox(height: 24),
          const _FieldLabel('Upload Payment Proof *'),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickScreenshot,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _paper,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    screenshotFileName != null ? Icons.image : Icons.add_a_photo_outlined,
                    color: _maroon,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      screenshotFileName ?? 'Upload Screenshot',
                      style: TextStyle(
                        color: screenshotFileName != null ? _ink : _muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (screenshotFileName != null)
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: _line.withOpacity(0.5))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider(color: _line.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.qr_code_scanner, size: 20, color: _maroon),
              const SizedBox(width: 8),
              const Text('Scan QR Code to Pay', style: TextStyle(fontWeight: FontWeight.bold, color: _ink)),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: _line.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _line.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.all(8),
                child: qrImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        key: ValueKey(qrImageUrl),
                        imageUrl: qrImageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => QrImageView(
                          data: upiPayload,
                          version: QrVersions.auto,
                          gapless: false,
                        ),
                      )
                    : QrImageView(
                        data: upiPayload,
                        version: QrVersions.auto,
                        gapless: false,
                      ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan & Pay',
                style: TextStyle(
                  color: _maroon,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use any UPI App to scan this QR code and make payment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: upiId));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ID copied to clipboard')));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _paper,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy, size: 14, color: _maroon),
                      const SizedBox(width: 8),
                      Text('Copy UPI ID: $upiId', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ink)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFECB3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: _maroon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Once payment is complete in your UPI App, please ',
                    style: TextStyle(color: _ink, fontSize: 13, height: 1.4),
                    children: [
                      TextSpan(
                        text: 'come back to this screen',
                        style: TextStyle(color: _maroon, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' and upload the payment proof for verification.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, color: Colors.green, size: 16),
            SizedBox(width: 6),
            Text('Your payment is 100% secure', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        const ContributionNotice(
          icon: Icons.shield_outlined,
          text: 'Please upload the screenshot after making the payment.',
        ),
        const SizedBox(height: 24),
        ContributionTextField(
          label: 'UTR / Transaction ID (Optional)',
          hint: 'e.g. 123456789012',
          icon: Icons.tag,
          controller: utrController,
        ),
      ],
    ),
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
    this.readOnly = false,
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
  final bool readOnly;

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
            readOnly: readOnly,
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
    required this.amount,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final int? amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOther = amount == null;
    final bgColor = isOther
        ? const Color(0xFFFFF8E1)
        : (selected ? const Color(0xFFFFF0ED) : Colors.white);
    final borderColor = selected ? _maroon : const Color(0xFFE8E8E8);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!selected && !isOther)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: isOther
              ? _buildOtherContent()
              : _buildPresetContent(amount!),
        ),
      ),
    );
  }

  Widget _buildPresetContent(int value) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${formatIndianNumber(value)}',
            style: const TextStyle(
              color: _maroon,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Suggested',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _maroon.withValues(alpha: 0.4),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(Icons.edit, color: _maroon, size: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter Any\nAmount',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _maroon,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
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

class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({super.key});
  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CheckmarkPainter(_scaleAnimation.value, _checkAnimation.value),
          size: const Size(120, 120),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double scale;
  final double checkProgress;
  _CheckmarkPainter(this.scale, this.checkProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * scale;

    if (scale > 0) {
      final bgPaint = Paint()
        ..color = const Color(0xFF2E7D32)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, radius, bgPaint);
    }

    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final startPoint = Offset(center.dx - radius * 0.4, center.dy + radius * 0.1);
      final midPoint = Offset(center.dx - radius * 0.1, center.dy + radius * 0.4);
      final endPoint = Offset(center.dx + radius * 0.4, center.dy - radius * 0.3);

      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(midPoint.dx, midPoint.dy);
      path.lineTo(endPoint.dx, endPoint.dy);

      final pathMetrics = path.computeMetrics().first;
      final extractPath = pathMetrics.extractPath(0, pathMetrics.length * checkProgress);
      canvas.drawPath(extractPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => true;
}
