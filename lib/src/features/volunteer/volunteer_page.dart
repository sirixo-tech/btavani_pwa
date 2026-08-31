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
            onPressed: () => _snack(context, 'Volunteer preferences saved'),
          ),
        ],
      ),
    );
  }
}
