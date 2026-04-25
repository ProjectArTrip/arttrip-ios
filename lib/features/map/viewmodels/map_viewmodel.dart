import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/map/data/map_repository.dart';
import 'package:arttrip/features/map/data/models/country_location.dart';
import 'package:arttrip/features/map/data/models/map_marker_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel with ChangeNotifier {
  MapViewModel({
    required ExhibitViewModel exhibitVM,
    required MapRepository mapRepository,
  }) : _exhibitVM = exhibitVM,
       _mapRepository = mapRepository;

  final ExhibitViewModel _exhibitVM;
  final MapRepository _mapRepository;

  // 마커 데이터
  AsyncState<List<MapMarkerModel>> _markersState = const AsyncState.loading();
  List<MapMarkerModel> _allMarkers = [];

  // 전시 리스트 (바텀시트)
  AsyncState<List<ExhibitModel>> _exhibitsState = const AsyncState.success([]);
  List<ExhibitModel> _currentExhibits = [];
  int _exhibitTotalCount = 0;
  int? _nextCursor;
  bool _hasNext = false;
  bool _isLoadingMore = false;
  List<int> _currentIds = [];

  // 카테고리 드롭다운
  AsyncState<List<String>> _countriesState = const AsyncState.loading();
  List<String> _countries = [];
  String? _selectedCountry;
  bool _isDropdownOpen = false;

  // 지도 상태
  LatLng? _userLocation;
  LatLng _currentCenter = CountryLocation.defaultLocation.position;
  double _currentZoom = CountryLocation.defaultLocation.zoom;

  AsyncState<List<MapMarkerModel>> get markersState => _markersState;
  List<MapMarkerModel> get allMarkers => _allMarkers;
  AsyncState<List<ExhibitModel>> get exhibitsState => _exhibitsState;
  List<ExhibitModel> get currentExhibits => _currentExhibits;
  int get exhibitTotalCount => _exhibitTotalCount;
  bool get hasNext => _hasNext;
  bool get isLoadingMore => _isLoadingMore;
  AsyncState<List<String>> get countriesState => _countriesState;
  List<String> get countries => _countries;
  String? get selectedCountry => _selectedCountry;
  bool get isDropdownOpen => _isDropdownOpen;
  LatLng? get userLocation => _userLocation;
  LatLng get currentCenter => _currentCenter;
  double get currentZoom => _currentZoom;

  /// 초기화
  Future<void> init() async {
    await Future.wait([
      fetchCountries(),
      fetchMarkers(),
      requestUserLocation(),
    ]);
  }

  /// 전체 마커 좌표 일괄 조회
  Future<void> fetchMarkers() async {
    try {
      _markersState = const AsyncState.loading();
      notifyListeners();

      final response = await _mapRepository.fetchMarkers();
      if (response != null) {
        _allMarkers = response.markers;
        _markersState = AsyncState.success(response.markers);
      } else {
        _markersState = AsyncState.success(_allMarkers);
      }
    } catch (e) {
      AppUtil.debugLog('fetchMarkers: $e');
      _markersState = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 클러스터/마커 탭 시 전시 리스트 조회
  Future<void> fetchClusterExhibits(List<int> ids) async {
    if (ids.isEmpty) return;

    try {
      _currentIds = ids;
      _exhibitsState = const AsyncState.loading();
      _currentExhibits = [];
      notifyListeners();

      final expectedCount = ids.length;
      final response = await _mapRepository.fetchClusterExhibits(
        ids: ids,
        size: 20,
      );
      if (response != null && response.exhibits.isNotEmpty) {
        _currentExhibits = response.exhibits;
        _exhibitTotalCount = expectedCount;
        _nextCursor = response.nextCursor;
        _hasNext = response.hasNext;
        _exhibitsState = AsyncState.success(response.exhibits);
        _exhibitVM.initializeFromExhibits(response.exhibits);
      } else {
        _currentExhibits = [];
        _exhibitTotalCount = 0;
        _exhibitsState = const AsyncState.success([]);
      }
    } catch (e) {
      AppUtil.debugLog('fetchClusterExhibits: $e');
      _exhibitsState = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 페이지네이션 (다음 페이지 로드)
  Future<void> fetchMoreExhibits() async {
    if (!_hasNext || _isLoadingMore) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      final response = await _mapRepository.fetchClusterExhibits(
        ids: _currentIds,
        cursor: _nextCursor,
        size: 20,
      );
      if (response != null) {
        _currentExhibits = [..._currentExhibits, ...response.exhibits];
        _nextCursor = response.nextCursor;
        _hasNext = response.hasNext;
        _exhibitsState = AsyncState.success(_currentExhibits);
        _exhibitVM.initializeFromExhibits(response.exhibits);
      }
    } catch (e) {
      AppUtil.debugLog('fetchMoreExhibits: $e');
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  /// 국가 리스트 조회
  Future<void> fetchCountries() async {
    try {
      _countriesState = const AsyncState.loading();
      notifyListeners();

      _countries = await _mapRepository.fetchCountries();
      _countriesState = AsyncState.success(_countries);
    } catch (e) {
      AppUtil.debugLog('fetchCountries: $e');
      _countriesState = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 국가 선택 → 좌표 반환 (View에서 카메라 이동)
  CountryLocationData? selectCountry(String country) {
    _selectedCountry = country;
    _isDropdownOpen = false;
    notifyListeners();
    return CountryLocation.getLocation(country);
  }

  /// 현재 위치 요청
  Future<void> requestUserLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _userLocation = LatLng(position.latitude, position.longitude);
      _currentCenter = _userLocation!;
      notifyListeners();
    } catch (e) {
      AppUtil.debugLog('requestUserLocation: $e');
    }
  }

  /// 지도 상태 업데이트
  void updateMapPosition(LatLng center, double zoom) {
    _currentCenter = center;
    _currentZoom = zoom;
  }

  /// 드롭다운 토글
  void toggleDropdown() {
    _isDropdownOpen = !_isDropdownOpen;
    notifyListeners();
  }

  /// 드롭다운 닫기
  void closeDropdown() {
    if (_isDropdownOpen) {
      _isDropdownOpen = false;
      notifyListeners();
    }
  }

  /// 상태 초기화
  void reset() {
    _markersState = const AsyncState.loading();
    _allMarkers = [];
    _exhibitsState = const AsyncState.success([]);
    _currentExhibits = [];
    _exhibitTotalCount = 0;
    _nextCursor = null;
    _hasNext = false;
    _isLoadingMore = false;
    _currentIds = [];
    _countriesState = const AsyncState.loading();
    _countries = [];
    _selectedCountry = null;
    _isDropdownOpen = false;
    _userLocation = null;
    _currentCenter = CountryLocation.defaultLocation.position;
    _currentZoom = CountryLocation.defaultLocation.zoom;
    notifyListeners();
  }
}
