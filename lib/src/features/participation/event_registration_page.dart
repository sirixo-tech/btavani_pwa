part of '../../../main.dart';

class EventRegistrationPage extends StatefulWidget {
  const EventRegistrationPage({this.initialEvent, super.key});

  final String? initialEvent;

  @override
  State<EventRegistrationPage> createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _flatController = TextEditingController();
  final _kidsNameController = TextEditingController();
  final _kidsAgeController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _otherActivityController = TextEditingController();

  String _selectedPersonType = 'Kids';
  String? _selectedActivity;
  bool _isSubmitting = false;

  static const _personTypes = ['Kids', 'Adults'];
  static const _activities = [
    'Dancing(Solo)',
    'Dancing(Group)',
    'Singing',
    'Instrumental',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Default to the first activity if initialEvent matches, otherwise null
    if (widget.initialEvent != null && _activities.contains(widget.initialEvent)) {
      _selectedActivity = widget.initialEvent;
    }
  }

  @override
  void dispose() {
    _flatController.dispose();
    _kidsNameController.dispose();
    _kidsAgeController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _otherActivityController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an activity.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = EventApiService();
      await api.submitRegistration(
        eventTitle: _selectedActivity!,
        participantName: _parentNameController.text.trim(),
        flatNumber: _flatController.text.trim(),
        ageGroup: '', // Deprecated, keeping empty
        mobile: _parentPhoneController.text.trim(),
        personType: _selectedPersonType,
        kidsName: _selectedPersonType == 'Kids' ? _kidsNameController.text.trim() : '',
        kidsAge: _selectedPersonType == 'Kids' ? _kidsAgeController.text.trim() : '',
        parentAdultPhone: _parentPhoneController.text.trim(),
        otherPerformanceDetails: _selectedActivity == 'Other' ? _otherActivityController.text.trim() : '',
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
    final activity = _selectedActivity!;
    final name = _selectedPersonType == 'Kids' ? _kidsNameController.text.trim() : _parentNameController.text.trim();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registration Submitted',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            '$name has been registered for $activity.',
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
    _flatController.clear();
    _kidsNameController.clear();
    _kidsAgeController.clear();
    _parentNameController.clear();
    _parentPhoneController.clear();
    _otherActivityController.clear();
    setState(() {
      _selectedActivity = null;
      _selectedPersonType = 'Kids';
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RegistrationTextField(
                    controller: _flatController,
                    label: 'Block No & Flat No *',
                    hint: 'e.g. A-101',
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Please enter block and flat number.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Select the person *', style: TextStyle(fontWeight: FontWeight.bold, color: _muted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    children: _personTypes.map((type) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: type,
                            groupValue: _selectedPersonType,
                            activeColor: _maroon,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPersonType = value;
                                });
                              }
                            },
                          ),
                          Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Activity *', style: TextStyle(fontWeight: FontWeight.bold, color: _muted)),
                  const SizedBox(height: 8),
                  Column(
                    children: _activities.map((activity) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: activity,
                            groupValue: _selectedActivity,
                            activeColor: _maroon,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedActivity = value;
                                });
                              }
                            },
                          ),
                          Expanded(child: Text(activity, style: const TextStyle(fontWeight: FontWeight.w600))),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedPersonType == 'Kids') ...[
                    _RegistrationTextField(
                      controller: _kidsNameController,
                      label: 'Kids Name *',
                      hint: 'Enter kids name',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (_selectedPersonType == 'Kids' && (value?.trim().isEmpty ?? true)) {
                          return 'Please enter kids name.';
                        }
                        return null;
                      },
                    ),
                    _RegistrationTextField(
                      controller: _kidsAgeController,
                      label: 'Kids Age *',
                      hint: 'Enter kids age',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_selectedPersonType == 'Kids' && (value?.trim().isEmpty ?? true)) {
                          return 'Please enter kids age.';
                        }
                        return null;
                      },
                    ),
                  ],

                  _RegistrationTextField(
                    controller: _parentNameController,
                    label: 'Parent/Adult Name *',
                    hint: 'Enter name',
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Please enter parent/adult name.';
                      }
                      return null;
                    },
                  ),
                  _RegistrationTextField(
                    controller: _parentPhoneController,
                    label: 'Parent/Adult Phone Number *',
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

                  if (_selectedActivity == 'Other') ...[
                    _RegistrationTextField(
                      controller: _otherActivityController,
                      label: 'Other performance (please give details) *',
                      hint: 'Enter details',
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (_selectedActivity == 'Other' && (value?.trim().isEmpty ?? true)) {
                          return 'Please enter performance details.';
                        }
                        return null;
                      },
                    ),
                  ],
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
