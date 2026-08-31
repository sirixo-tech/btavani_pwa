part of '../../../main.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _mobileController = TextEditingController();

  final selected = <String>{};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  final roles = const [
    'Pooja and Rituals',
    'Decoration',
    'Prasadam',
    'Cultural Events',
    'Sound and Lights',
    'Crowd Management',
    'Visarjan',
    'Photography',
    'Collection Support',
    'General Support',
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Volunteer',
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
                  _RegistrationTextField(
                    controller: _nameController,
                    label: 'Volunteer Name *',
                    hint: 'Enter name',
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => (value?.trim().length ?? 0) < 2 ? 'Please enter name' : null,
                  ),
                  _RegistrationTextField(
                    controller: _flatController,
                    label: 'Flat Number *',
                    hint: 'e.g. I-1204',
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => (value?.trim().isEmpty ?? true) ? 'Please enter flat number' : null,
                  ),
                  _RegistrationTextField(
                    controller: _mobileController,
                    label: 'Mobile Number *',
                    hint: 'Enter 10-digit mobile',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) => (value?.trim().length ?? 0) != 10 ? 'Please enter 10 digits' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          const Text(
            'I want to volunteer for',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final role in roles)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: panelDecoration(),
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: selected.contains(role),
                activeColor: _maroon,
                title: Text(
                  role,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onChanged: (value) {
                  setState(() {
                    value == true ? selected.add(role) : selected.remove(role);
                  });
                },
              ),
            ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'SUBMIT',
            isLoading: _isSubmitting,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (!_formKey.currentState!.validate()) return;
              if (selected.isEmpty) {
                _snack(context, 'Please select at least one volunteering area');
                return;
              }

              setState(() => _isSubmitting = true);
              try {
                final api = EventApiService();
                await api.submitVolunteer(
                  name: _nameController.text.trim(),
                  flatNumber: _flatController.text.trim(),
                  mobile: _mobileController.text.trim(),
                  roles: selected.toList(),
                );

                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Volunteer Preferences Saved', style: TextStyle(fontWeight: FontWeight.w900)),
                      content: Text('Thank you for volunteering for ${selected.length} area${selected.length == 1 ? '' : 's'}.', style: const TextStyle(color: _muted, fontWeight: FontWeight.w700)),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: _maroon, foregroundColor: Colors.white),
                          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    );
                  },
                );

                if (!context.mounted) return;
                _formKey.currentState!.reset();
                _nameController.clear();
                _flatController.clear();
                _mobileController.clear();
                setState(() => selected.clear());
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit: $e')),
                );
              } finally {
                if (mounted) setState(() => _isSubmitting = false);
              }
            },
          ),
        ],
      ),
      ),
    );
  }
}
