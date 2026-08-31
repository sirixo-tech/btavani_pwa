part of '../../../main.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final selected = <String>{};
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            onPressed: () {
              if (selected.isEmpty) {
                _snack(context, 'Please select at least one volunteering area');
                return;
              }

              showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Volunteer Preferences Saved',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    content: Text(
                      'Thank you for volunteering for ${selected.length} area${selected.length == 1 ? '' : 's'}.',
                      style: const TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w700,
                      ),
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
            },
          ),
        ],
      ),
    );
  }
}
