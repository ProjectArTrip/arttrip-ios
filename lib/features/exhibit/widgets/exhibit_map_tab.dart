import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 전시 지도 탭 콘텐츠
class ExhibitMapTabContent extends StatelessWidget {
  const ExhibitMapTabContent({super.key, required this.exhibit});

  final ExhibitDetailModel exhibit;

  @override
  Widget build(BuildContext context) {
    // 좌표가 없는 경우
    if (exhibit.hallLatitude == null || exhibit.hallLongitude == null) {
      return _buildNoMapPlaceholder(context);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildMapContainer(context)],
      ),
    );
  }

  Widget _buildNoMapPlaceholder(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Center(
        child: ArtTripText.pretendard()
            .body01Regular()
            .color(AppColors.textTertiary)
            .build()
            .text(context.l10n.noMapInfo),
      ),
    );
  }

  Widget _buildMapContainer(BuildContext context) {
    var lat = exhibit.hallLatitude!;
    var lng = exhibit.hallLongitude!;
    var position = LatLng(lat, lng);

    return GestureDetector(
      onTap: () => _openGoogleMaps(lat, lng),
      child: Container(
        width: double.infinity,
        height: 220.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.gray100, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: position, zoom: 15),
            markers: {
              Marker(
                markerId: const MarkerId('exhibit_location'),
                position: position,
                infoWindow: InfoWindow(title: exhibit.hallName),
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            onTap: (_) => _openGoogleMaps(lat, lng),
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    // Google Maps 앱 URL 스킴 (iOS)
    var appUrl = Uri.parse(
      'comgooglemaps://?daddr=$lat,$lng&directionsmode=transit',
    );

    // 앱이 설치되어 있으면 앱으로, 아니면 웹으로
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      var webUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
