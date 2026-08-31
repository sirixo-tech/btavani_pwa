part of '../../main.dart';

class EventApiService {
  Future<List<EventItem>> fetchEvents() async {
    try {
      // Need to import ApiConfig. Since main doesn't have it, we should import it in main or use the full URL.
      // Wait, let's use the URL directly, or add import to main.dart.
      // Since ApiConfig is in src/core/confi/api_config.dart, let's import it in main.dart first, or here.
      // Actually, since it's a part file, we can't have imports here.
      // Let's modify main.dart to include ApiConfig.
      // For now, I will write the code assuming ApiConfig is available in main.dart.
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/mobile/bootstrap'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson.map((json) => EventItem.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }
}
