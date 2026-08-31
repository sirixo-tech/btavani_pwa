part of '../../../main.dart';

class EventRegistrationPage extends StatefulWidget {
  const EventRegistrationPage({this.initialEvent, super.key});

  final String? initialEvent;

  @override
  State<EventRegistrationPage> createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _mobileController = TextEditingController();

  late String? _selectedEvent;
  String? _selectedAgeGroup;
  bool _isSubmitting = false;

  static const _ageGroups = [
    'Below 6 years',
    '6 - 10 years',
    '11 - 15 years',
    '16 - 21 years',
    'Adult',
  ];

  @override
  void initState() {
    super.initState();
    _selectedEvent = _initialSelectedEvent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  String? get _initialSelectedEvent {
    final initialEvent = widget.initialEvent;
    return fallbackEventItems.any((event) => event.title == initialEvent)
        ? initialEvent
        : null;
  }

  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = EventApiService();
      await api.submitRegistration(
        eventTitle: _selectedEvent!,
        participantName: _nameController.text.trim(),
        flatNumber: _flatController.text.trim(),
        ageGroup: _selectedAgeGroup!,
        mobile: _mobileController.text.trim(),
      );
      if (!mounted) return;
      await _showRegistrationConfirmation();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showRegistrationConfirmation() async {
    final event = _selectedEvent!;
    final name = _nameController.text.trim();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registration Submitted',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            '$name has been registered for $event.',
            style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroon,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    _formKey.currentState!.reset();
    _nameController.clear();
    _flatController.clear();
    _mobileController.clear();
    setState(() {
      _selectedEvent = _initialSelectedEvent;
      _selectedAgeGroup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Event Registration',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: panelDecoration(),
              child: Column(
                children: [
                  _RegistrationDropdown(
                    label: 'Select Event',
                    value: _selectedEvent,
                    hint: 'Select event',
                    items: fallbackEventItems.map((event) => event.title).toList(),
                    validator: (value) =>
                        value == null ? 'Please select an event.' : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedEvent = value;
                      });
                    },
                  ),
                  _RegistrationTextField(
                    controller: _nameController,
                    label: 'Participant Name',
                    hint: 'Enter name',
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 2) {
                        return 'Please enter the participant name.';
                      }
                      return null;
                    },
                  ),
                  _RegistrationTextField(
                    controller: _flatController,
                    label: 'Flat Number',
                    hint: 'e.g. I-1204',
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Please enter the flat number.';
                      }
                      return null;
                    },
                  ),
                  _RegistrationDropdown(
                    label: 'Age Group',
                    value: _selectedAgeGroup,
                    hint: 'Select age group',
                    items: _ageGroups,
                    validator: (value) =>
                        value == null ? 'Please select an age group.' : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgeGroup = value;
                      });
                    },
                  ),
                  _RegistrationTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    hint: 'Enter mobile number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length != 10) {
                        return 'Please enter a valid 10-digit mobile number.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'REGISTER',
              onPressed: _submitRegistration,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationTextField extends StatelessWidget {
  const _RegistrationTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: _registrationInputDecoration(label, hint),
      ),
    );
  }
}

class _RegistrationDropdown extends StatelessWidget {
  const _RegistrationDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.validator,
  });

  final String label;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: _registrationInputDecoration(label, hint),
        validator: validator,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

InputDecoration _registrationInputDecoration(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: _paper,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _line.withValues(alpha: 0.9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _maroon, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _maroon),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _maroon, width: 1.6),
    ),
  );
}
