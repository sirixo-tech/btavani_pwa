part of '../../../main.dart';

class AuctionPage extends StatelessWidget {
  const AuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Laddoo Auction',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_paper, _surfaceWarm],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _maroonDark.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LabelPill(label: 'LIVE AUCTION', color: _gold),
                ),
                const SizedBox(height: 18),
                const Text(
                  'LADDOO AUCTION',
                  style: TextStyle(
                    color: _maroonDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Current Highest Bid',
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Rs 11,501',
                  style: TextStyle(
                    color: _maroon,
                    fontWeight: FontWeight.w900,
                    fontSize: 38,
                  ),
                ),
                const Text(
                  'by I-1204',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ends in',
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const TimerRow(),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'PLACE YOUR BID',
                  onPressed: () =>
                      _snack(context, 'Bidding flow ready for integration'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextButton(onPressed: () {}, child: const Text('View All Bids')),
        ],
      ),
    );
  }
}

class TimerRow extends StatelessWidget {
  const TimerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimeChunk(value: '02', label: 'HOURS'),
          Text(
            ' : ',
            style: TextStyle(
              color: _maroon,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          TimeChunk(value: '35', label: 'MINS'),
          Text(
            ' : ',
            style: TextStyle(
              color: _maroon,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          TimeChunk(value: '18', label: 'SECS'),
        ],
      ),
    );
  }
}

class TimeChunk extends StatelessWidget {
  const TimeChunk({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _paper,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: _maroon,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontWeight: FontWeight.w800,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
