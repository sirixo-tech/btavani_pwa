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

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
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

    return ScheduleItem(
      time: json['label'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      icon: Icons.access_time, // fallback
      color: parsedColor,
    );
  }
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

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF6C1D45);
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

    return AnnouncementItem(
      label: json['label'] as String? ?? 'Notice',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      date: json['subtitle'] as String? ?? '',
      icon: Icons.notifications, // fallback
      color: parsedColor,
    );
  }
}

class BootstrapData {
  const BootstrapData({
    required this.events,
    required this.schedule,
    required this.announcements,
    required this.gallery,
    required this.blocks,
  });

  final List<EventItem> events;
  final List<ScheduleItem> schedule;
  final List<AnnouncementItem> announcements;
  final List<GalleryPhoto> gallery;
  final List<Block> blocks;
}

class GalleryPhoto {
  const GalleryPhoto({
    this.asset,
    this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  final String? asset;
  final String? imageUrl;
  final String title;
  final String subtitle;

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}

class Block {
  const Block({
    required this.id,
    required this.name,
    required this.upiId,
    required this.qrImageUrl,
    required this.isActive,
  });

  final String id;
  final String name;
  final String upiId;
  final String qrImageUrl;
  final bool isActive;

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      upiId: json['upiId'] as String? ?? '',
      qrImageUrl: json['qrImageUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
