import 'dart:async';

import 'package:arttrip/features/map/data/models/map_cluster_item.dart';
import 'package:arttrip/features/map/data/models/map_marker_model.dart';
import 'package:arttrip/features/map/viewmodels/map_viewmodel.dart';
import 'package:arttrip/features/map/widgets/map_bottom_sheet.dart';
import 'package:arttrip/features/map/widgets/map_category_bar.dart';
import 'package:arttrip/features/map/widgets/map_cluster_renderer.dart';
import 'package:arttrip/features/map/widgets/map_location_button.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide Cluster, ClusterManager;
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // ── 멤버 변수 ──
  GoogleMapController? _mapController;
  late ClusterManager<MapClusterItem> _clusterManager;
  Set<Marker> _markers = {};
  final _sheetController = DraggableScrollableController();
  bool _hasRequestedAllExhibits = false;

  // 캐시된 BitmapDescriptor
  BitmapDescriptor? _cachedPinBitmap;

  @override
  void initState() {
    super.initState();
    _clusterManager = ClusterManager<MapClusterItem>(
      [],
      _updateMarkers,
      markerBuilder: _markerBuilder,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () => context.read<MapViewModel>().init(),
      child: Scaffold(
        body: Selector<MapViewModel, AsyncState<List<MapMarkerModel>>>(
          selector: (_, vm) => vm.markersState,
          builder: (context, markersState, _) {
            return AsyncView<List<MapMarkerModel>>(
              state: markersState,
              onLoading: () => _buildMapStack(context),
              onData: (markers) {
                _updateClusterItems(markers);
                return _buildMapStack(context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapStack(BuildContext context) {
    final vm = context.read<MapViewModel>();
    return Stack(
      children: [
        // 1. 전체화면 GoogleMap
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: vm.currentCenter,
            zoom: vm.currentZoom,
          ),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            _clusterManager.setMapId(controller.mapId);

            // 사용자 위치가 있으면 이동
            if (vm.userLocation != null) {
              unawaited(
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(vm.userLocation!, 10),
                ),
              );
            }
          },
          onCameraMove: (position) {
            _clusterManager.onCameraMove(position);
            vm.updateMapPosition(position.target, position.zoom);
          },
          onCameraIdle: () {
            _clusterManager.updateMap();
          },
          onTap: (_) {
            vm.closeDropdown();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // 2. 현재 위치 버튼 (바텀시트에 가려짐)
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.07 + 16.h,
          right: 24.w,
          child: MapLocationButton(
            onTap: () async {
              await vm.requestUserLocation();
              if (vm.userLocation != null) {
                await _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(vm.userLocation!, 13),
                );
              }
            },
          ),
        ),

        // 3. 바텀시트
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: MapBottomSheet(
            sheetController: _sheetController,
            onDragUp: _onBottomSheetDragUp,
          ),
        ),

        // 4. 상단 카테고리 바 + 드롭다운 (최상위 레이어)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 24.w,
          right: 24.w,
          child: MapCategoryBar(
            onCountrySelected: (location) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  location.position,
                  location.zoom,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ClusterManager에 아이템 업데이트
  void _updateClusterItems(List<MapMarkerModel> markers) {
    final items = markers.map((m) => MapClusterItem(m)).toList();
    _clusterManager.setItems(items);
  }

  /// ClusterManager 콜백: 마커 세트 업데이트
  void _updateMarkers(Set<Marker> markers) {
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  /// ClusterManager 마커 빌더
  Future<Marker> _markerBuilder(Cluster<MapClusterItem> cluster) async {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final BitmapDescriptor icon;
    if (cluster.isMultiple) {
      icon = await MapClusterRenderer.buildClusterBitmap(
        cluster.count,
        devicePixelRatio: devicePixelRatio,
      );
    } else {
      _cachedPinBitmap ??= await MapClusterRenderer.buildPinBitmap(
        devicePixelRatio: devicePixelRatio,
      );
      icon = _cachedPinBitmap!;
    }

    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      icon: icon,
      onTap: () => _onMarkerTap(cluster),
    );
  }

  /// 마커/클러스터 탭 핸들러
  void _onMarkerTap(Cluster<MapClusterItem> cluster) {
    final vm = context.read<MapViewModel>();
    final ids = cluster.items.map((item) => item.marker.id).toList();

    if (cluster.isMultiple) {
      // 클러스터: 포함된 마커들이 모두 보이는 범위로 줌인
      final bounds = _boundsFromCluster(cluster);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } else {
      // 개별 마커: 거리 수준 줌
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.location, 15.0),
      );
    }

    // 마커 탭에 의한 요청임을 표시 (드래그와 중복 방지)
    _hasRequestedAllExhibits = true;

    // 전시 리스트 조회 + 바텀시트 펼침
    vm.fetchClusterExhibits(ids);
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 클러스터 내 마커들의 LatLngBounds 계산
  LatLngBounds _boundsFromCluster(Cluster<MapClusterItem> cluster) {
    var minLat = 90.0;
    var maxLat = -90.0;
    var minLng = 180.0;
    var maxLng = -180.0;
    for (final item in cluster.items) {
      final loc = item.location;
      if (loc.latitude < minLat) minLat = loc.latitude;
      if (loc.latitude > maxLat) maxLat = loc.latitude;
      if (loc.longitude < minLng) minLng = loc.longitude;
      if (loc.longitude > maxLng) maxLng = loc.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// 바텀시트 드래그 시 전체 전시 로드
  void _onBottomSheetDragUp() {
    if (_hasRequestedAllExhibits) return;
    _hasRequestedAllExhibits = true;

    final vm = context.read<MapViewModel>();
    final allIds = vm.allMarkers.map((m) => m.id).toList();
    if (allIds.isNotEmpty) {
      vm.fetchClusterExhibits(allIds);
    }
  }
}
