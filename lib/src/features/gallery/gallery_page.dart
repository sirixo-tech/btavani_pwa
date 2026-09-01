part of '../../../main.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int _tab = 0;
  int _selectedPhoto = 0;
  List<GalleryPhoto>? _gallery;
  String? _error;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    try {
      setState(() {
        _error = null;
        _gallery = null;
      });
      final bootstrap = await EventApiService().fetchBootstrap();
      setState(() {
        _gallery = bootstrap.gallery;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load gallery.';
          _gallery = galleryPhotos; // fallback
        });
      }
    }
  }

  void _handleTabChanged(int value) {
    if (_tab != value) {
      setState(() {
        _tab = value;
      });
    }
  }

  void _handleTileTap(int index, BuildContext context) {
    setState(() {
      _selectedPhoto = index;
    });

    // Ensure context is still valid before showing dialog
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final currentGallery = _gallery ?? galleryPhotos;
        return GalleryPreviewDialog(photo: currentGallery[index]);
      },
    );
  }

  Future<void> _handleUploadPressed(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/mobile/gallery'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: file.name,
        ),
      );

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded! Pending admin approval.'),
            backgroundColor: Color(0xFF4CAF50), // Fallback green or just remove _green
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Failed to upload');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: Color(0xFFF44336), // Fallback red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Utsav Gallery',
      maxWidth: 1040,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = GalleryLayoutMetrics.fromWidth(constraints.maxWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GalleryControlWidth(
                width: metrics.controlWidth,
                child: SegmentedPill(
                  labels: const ['Photos', 'Videos'],
                  selectedIndex: _tab,
                  onChanged: _handleTabChanged,
                ),
              ),
              SizedBox(height: metrics.sectionGap),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_tab == 0)
                _gallery == null && _error == null
                    ? const Center(child: CircularProgressIndicator())
                    : GalleryPhotosView(
                        gallery: _gallery ?? galleryPhotos,
                        selectedPhoto: _selectedPhoto,
                        metrics: metrics,
                        onTileTap: (index) => _handleTileTap(index, context),
                      )
              else
                GalleryControlWidth(
                  width: metrics.emptyStateWidth,
                  child: const GalleryEmptyState(),
                ),
              SizedBox(height: metrics.sectionGap),
              GalleryControlWidth(
                width: metrics.buttonWidth,
                child: PrimaryButton(
                  label: _isUploading ? 'UPLOADING...' : 'UPLOAD PHOTO',
                  onPressed: _isUploading ? null : () => _handleUploadPressed(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GalleryLayoutMetrics {
  const GalleryLayoutMetrics({
    required this.isWide,
    required this.gridColumns,
    required this.gridSpacing,
    required this.sectionGap,
    required this.featureAspectRatio,
    required this.gridAspectRatio,
    required this.controlWidth,
    required this.buttonWidth,
    required this.emptyStateWidth,
  });

  final bool isWide;
  final int gridColumns;
  final double gridSpacing;
  final double sectionGap;
  final double featureAspectRatio;
  final double gridAspectRatio;
  final double? controlWidth;
  final double? buttonWidth;
  final double? emptyStateWidth;

  factory GalleryLayoutMetrics.fromWidth(double width) {
    final isWide = width >= 760;

    if (isWide) {
      return const GalleryLayoutMetrics(
        isWide: true,
        gridColumns: 2,
        gridSpacing: 12,
        sectionGap: 18,
        featureAspectRatio: 1.24,
        gridAspectRatio: 1.04,
        controlWidth: 360,
        buttonWidth: 280,
        emptyStateWidth: 520,
      );
    }

    return GalleryLayoutMetrics(
      isWide: false,
      gridColumns: width >= 600 ? 3 : 2,
      gridSpacing: width >= 600 ? 12 : 10,
      sectionGap: 14,
      featureAspectRatio: width >= 600 ? 1.82 : 1.62,
      gridAspectRatio: 1.04,
      controlWidth: null,
      buttonWidth: null,
      emptyStateWidth: null,
    );
  }
}

class GalleryControlWidth extends StatelessWidget {
  const GalleryControlWidth({required this.child, this.width, super.key});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (width == null) {
      return child;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: width, child: child),
    );
  }
}

class GalleryPhotosView extends StatelessWidget {
  const GalleryPhotosView({
    required this.gallery,
    required this.selectedPhoto,
    required this.metrics,
    required this.onTileTap,
    super.key,
  });

  final List<GalleryPhoto> gallery;
  final int selectedPhoto;
  final GalleryLayoutMetrics metrics;
  final ValueChanged<int> onTileTap;

  @override
  Widget build(BuildContext context) {
    if (gallery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No photos available'),
        ),
      );
    }

    final selectedIndex = selectedPhoto.clamp(0, gallery.length - 1);
    final feature = GalleryFeaturePhoto(
      photo: gallery[selectedIndex],
      aspectRatio: metrics.featureAspectRatio,
      largeTitle: metrics.isWide,
    );
    final grid = GalleryPhotoGrid(
      gallery: gallery,
      selectedPhoto: selectedIndex,
      metrics: metrics,
      onTileTap: onTileTap,
    );

    if (!metrics.isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          feature,
          SizedBox(height: metrics.sectionGap),
          GallerySectionHeader(count: gallery.length),
          const SizedBox(height: 10),
          grid,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: feature),
        const SizedBox(width: 18),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GallerySectionHeader(count: gallery.length),
              const SizedBox(height: 10),
              grid,
            ],
          ),
        ),
      ],
    );
  }
}

class GallerySectionHeader extends StatelessWidget {
  const GallerySectionHeader({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Festival Moments',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          '$count photos',
          style: const TextStyle(color: _muted, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class GalleryPhotoGrid extends StatelessWidget {
  const GalleryPhotoGrid({
    required this.gallery,
    required this.selectedPhoto,
    required this.metrics,
    required this.onTileTap,
    super.key,
  });

  final List<GalleryPhoto> gallery;
  final int selectedPhoto;
  final GalleryLayoutMetrics metrics;
  final ValueChanged<int> onTileTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: metrics.gridColumns,
        crossAxisSpacing: metrics.gridSpacing,
        mainAxisSpacing: metrics.gridSpacing,
        childAspectRatio: metrics.gridAspectRatio,
      ),
      itemCount: gallery.length,
      itemBuilder: (context, index) => RepaintBoundary(
        child: GalleryTile(
          photo: gallery[index],
          selected: selectedPhoto == index,
          onTap: () => onTileTap(index),
        ),
      ),
    );
  }
}

class GalleryFeaturePhoto extends StatelessWidget {
  const GalleryFeaturePhoto({
    required this.photo,
    this.aspectRatio = 1.62,
    this.largeTitle = false,
    super.key,
  });

  final GalleryPhoto photo;
  final double aspectRatio;
  final bool largeTitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo.imageUrl != null)
              Image.network(
                photo.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              )
            else if (photo.asset != null)
              Image.asset(
                photo.asset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(color: Colors.grey.shade300),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.56),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: largeTitle ? 16 : 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: largeTitle ? 22 : 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    photo.subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: largeTitle ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryTile extends StatelessWidget {
  const GalleryTile({
    required this.photo,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final GalleryPhoto photo;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? _maroon : Colors.white.withValues(alpha: 0.88),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photo.imageUrl != null)
                  Image.network(
                    photo.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else if (photo.asset != null)
                  Image.asset(
                    photo.asset!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Container(color: Colors.grey.shade200),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.54),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      child: Text(
                        photo.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryPreviewDialog extends StatelessWidget {
  const GalleryPreviewDialog({required this.photo, super.key});

  final GalleryPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: photo.imageUrl != null
                  ? Image.network(
                      photo.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : photo.asset != null
                      ? Image.asset(
                          photo.asset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(color: Colors.grey.shade300),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photo.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          photo.subtitle,
                          style: const TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryEmptyState extends StatelessWidget {
  const GalleryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      decoration: panelDecoration(color: _paper.withValues(alpha: 0.94)),
      child: const Column(
        children: [
          Icon(Icons.video_library_outlined, color: _maroon, size: 42),
          SizedBox(height: 10),
          Text(
            'Videos will appear here soon',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 4),
          Text(
            'Festival clips can be added after the event.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class FestivalTilePainter extends CustomPainter {
  FestivalTilePainter({
    required this.base,
    required this.accent,
    required this.seed,
  });

  final Color base;
  final Color accent;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        colors: [base, accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final glow = Paint()..color = Colors.white.withValues(alpha: 0.16);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.22),
      size.width * 0.24,
      glow,
    );

    final lamp = Paint()..color = const Color(0xFFFFCC64);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.68),
        width: size.width * 0.42,
        height: size.height * 0.12,
      ),
      lamp,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.54),
          width: size.width * 0.18,
          height: size.height * 0.36,
        ),
        const Radius.circular(20),
      ),
      lamp,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.32),
      size.width * 0.09,
      Paint()..color = Colors.white,
    );
    final flame = Path()
      ..moveTo(size.width * 0.5, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.30,
        size.width * 0.5,
        size.height * 0.39,
      )
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.30,
        size.width * 0.5,
        size.height * 0.16,
      );
    canvas.drawPath(flame, Paint()..color = const Color(0xFFFFF0A2));

    final dot = Paint()..color = Colors.white.withValues(alpha: 0.42);
    for (var i = 0; i < 11; i++) {
      final x = ((i * 23 + seed * 17) % 100) / 100 * size.width;
      final y = ((i * 37 + seed * 11) % 100) / 100 * size.height;
      canvas.drawCircle(Offset(x, y), 1.4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant FestivalTilePainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.base != base ||
      oldDelegate.accent != accent;
}
