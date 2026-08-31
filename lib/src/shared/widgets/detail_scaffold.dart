part of '../../../main.dart';

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    required this.title,
    required this.child,
    this.trailing,
    this.useScroll = true,
    this.maxWidth = 430,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool useScroll;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: child,
    );

    return AppFrame(
      maxWidth: maxWidth,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              PageTopBar(
                title: title,
                compact: true,
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                trailing: trailing,
              ),
              Expanded(
                child: useScroll
                    ? SingleChildScrollView(child: content)
                    : content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
