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
  });

  final String title;
  final String date;
  final String venue;
  final IconData icon;
  final Color color;
  final String description;
  final String? imageAsset;
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
