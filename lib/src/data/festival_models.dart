part of '../../main.dart';

class EventItem {
  const EventItem({
    required this.title,
    required this.date,
    required this.venue,
    required this.icon,
    required this.color,
    required this.description,
    this.imageAsset,
    this.imageUrl,
  });

  final String title;
  final String date;
  final String venue;
  final IconData icon;
  final Color color;
  final String description;
  final String? imageAsset;
  final String? imageUrl;

  factory EventItem.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF6C1D45); // _maroon fallback
    if (json['color'] != null) {
      final colorStr = json['color'].toString();
      if (colorStr.startsWith('#')) {
        final hex = colorStr.replaceAll('#', '');
        if (hex.length == 6) {
          parsedColor = Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          parsedColor = Color(int.parse(hex, radix: 16));
        }
      }
    }

    return EventItem(
      title: json['title'] as String? ?? 'Unknown Event',
      date: json['startsAt'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      icon: Icons.event, // Default icon since API doesn't provide one
      color: parsedColor,
      description: json['body'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class ScheduleItem {
  const ScheduleItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class AnnouncementItem {
  const AnnouncementItem({
    required this.label,
    required this.title,
    required this.body,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String label;
  final String title;
  final String body;
  final String date;
  final IconData icon;
  final Color color;
}

class GalleryPhoto {
  const GalleryPhoto({
    required this.asset,
    required this.title,
    required this.subtitle,
  });

  final String asset;
  final String title;
  final String subtitle;
}
