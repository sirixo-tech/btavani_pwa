import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'src/core/confi/api_config.dart';

part 'src/core/theme/app_colors.dart';
part 'src/core/utils/ui_helpers.dart';
part 'src/shared/styles/panel_decoration.dart';
part 'src/data/festival_models.dart';
part 'src/data/festival_data.dart';
part 'src/data/event_api_service.dart';
part 'src/app/tulasi_vanam_app.dart';
part 'src/app/festival_shell.dart';
part 'src/shared/widgets/app_frame.dart';
part 'src/shared/widgets/page_top_bar.dart';
part 'src/shared/widgets/segmented_pill.dart';
part 'src/shared/widgets/detail_scaffold.dart';
part 'src/shared/widgets/forms.dart';
part 'src/shared/widgets/buttons.dart';
part 'src/shared/widgets/info_section.dart';
part 'src/features/home/home_page.dart';
part 'src/features/events/events_page.dart';
part 'src/features/contribute/contribute_page.dart';
part 'src/features/more/more_page.dart';
part 'src/features/more/transparency_page.dart';
part 'src/features/participation/event_registration_page.dart';
part 'src/features/volunteer/volunteer_page.dart';
part 'src/features/schedule/schedule_page.dart';
part 'src/features/announcements/announcements_page.dart';
part 'src/features/gallery/gallery_page.dart';
part 'src/features/auction/auction_page.dart';

void main() {
  runApp(const TulasiVanamApp());
}
