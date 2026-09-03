part of '../../main.dart';

class EventApiService {
  Future<BootstrapData> fetchBootstrap() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/mobile/bootstrap'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final events = (data['events'] as List<dynamic>?)
            ?.map((json) => EventItem.fromJson(json))
            .toList() ?? [];
            
        final schedule = (data['schedule'] as List<dynamic>?)
            ?.map((json) => ScheduleItem.fromJson(json))
            .toList() ?? [];
            
        final announcements = (data['announcements'] as List<dynamic>?)
            ?.map((json) => AnnouncementItem.fromJson(json))
            .toList() ?? [];
            
        final gallery = (data['gallery'] as List<dynamic>?)
            ?.map((json) => GalleryPhoto.fromJson(json))
            .toList() ?? [];

        final blocks = (data['blocks'] as List<dynamic>?)
            ?.map((json) => Block.fromJson(json))
            .toList() ?? [];
            
        final appSettingsList =
            (data['appSettings'] as List<dynamic>?) ??
            (data['settings'] as List<dynamic>?) ??
            [];
        final Map<String, String> appSettings = {};
        for (var item in appSettingsList) {
          if (item['id'] != null && item['imageUrl'] != null) {
            appSettings[item['id']] = item['imageUrl'];
          }
        }

        return BootstrapData(
          events: events,
          schedule: schedule,
          announcements: announcements,
          gallery: gallery,
          blocks: blocks,
          appSettings: appSettings,
        );
      } else {
        throw Exception('Failed to load bootstrap data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load bootstrap data: $e');
    }
  }

  Future<void> submitRegistration({
    required String eventTitle,
    required String participantName,
    required String flatNumber,
    required String ageGroup,
    required String mobile,
    required String personType,
    required String kidsName,
    required String kidsAge,
    required String parentAdultPhone,
    required String otherPerformanceDetails,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/mobile/registrations');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'eventTitle': eventTitle,
        'participantName': participantName,
        'flatNumber': flatNumber,
        'ageGroup': ageGroup,
        'mobile': mobile,
        'personType': personType,
        'kidsName': kidsName,
        'kidsAge': kidsAge,
        'parentAdultPhone': parentAdultPhone,
        'otherPerformanceDetails': otherPerformanceDetails,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to submit registration');
    }
  }

  Future<void> submitVolunteer({
    required String name,
    required String flatNumber,
    required String mobile,
    required List<String> roles,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/mobile/volunteers');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'flatNumber': flatNumber,
        'mobile': mobile,
        'roles': roles,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to submit volunteer form');
    }
  }

  Future<Map<String, dynamic>> createPaymentRecord({
    required int amount,
    required String blockId,
    required String residentName,
    required String email,
    required String phone,
    required String flatNumber,
    required String gotram,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/mobile/payments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amount,
        'blockId': blockId,
        'residentName': residentName,
        'email': email,
        'phone': phone,
        'flatNumber': flatNumber,
        'gotram': gotram,
        'status': 'created',
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create payment record');
    }
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updatePaymentRecord({
    required String paymentId,
    required String utr,
    List<int>? screenshotBytes,
    String? screenshotName,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/mobile/payments/$paymentId');
    
    if (screenshotBytes != null) {
      final request = http.MultipartRequest('PUT', url)
        ..fields['provider'] = 'upi_qr'
        ..fields['status'] = 'pending'
        ..fields['referenceId'] = utr;

      request.files.add(
        http.MultipartFile.fromBytes(
          'screenshot',
          screenshotBytes,
          filename: screenshotName ?? 'screenshot.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update payment. Status code: ${response.statusCode}');
      }
      return json.decode(response.body);
    } else {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'provider': 'upi_qr',
          'status': 'pending',
          'referenceId': utr,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update payment');
      }
      return json.decode(response.body);
    }
  }

  Future<void> submitBid({
    required int amount,
    required String bidderName,
    required String flatNumber,
    required String mobile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/mobile/bids');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amount,
        'bidderName': bidderName,
        'flatNumber': flatNumber,
        'mobile': mobile,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to submit bid');
    }
  }
}
