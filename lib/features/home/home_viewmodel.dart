import 'dart:async';

import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/data/models/curation_model.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/region_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.exhibitVM, required this.homeRepository});
  final ExhibitViewModel exhibitVM;
  final HomeRepository homeRepository;

  final Map<LocationType, double> _scrollOffset = {};
  final DateTime _today = DateTime.now();

  // locationType -> area -> genre
  final Map<LocationType, Map<String, String>> _selectedGenre = {};
  // locationType -> area -> selected date in week
  final Map<LocationType, Map<String, DateTime>> _selectedDateInWeek = {};
  LocationType _locationType = LocationType.overseas;
  final Map<LocationType, String?> _area = {};
  AsyncState<List<String>> _overseasCountries = const AsyncState.loading();
  AsyncState<List<RegionModel>> _domesticRegions = const AsyncState.loading();
  AsyncState<List<DateTime>> _weeklyCalendar = const AsyncState.loading();

  final Map<LocationType, Map<String, AsyncState<List<ExhibitModel>>>>
  _todayExhibitRecommendations = {};

  /// 주간 전시 해외/국내별, 국가/지역의 일자별로 저장
  final Map<
    LocationType,
    Map<String, Map<String, AsyncState<List<ExhibitModel>>>>
  >
  _weeklyExhibitsBySelectedDate = {};

  /// 개인 맞춤 추천 전시
  final Map<LocationType, AsyncState<List<ExhibitModel>>>
  _personalizedExhibits = {};

  /// 큐레이션 전시
  final Map<LocationType, Map<String, AsyncState<CurationModel>>> _curations =
      {};

  final Map<
    LocationType,
    Map<String, Map<String, AsyncState<List<ExhibitModel>>>>
  >
  _exhibitsByGenre = {};
  AsyncState<List<String>> _genres = const AsyncState.loading();

  Map<LocationType, double> get scrollOffset => _scrollOffset;

  /// locationType -> area -> genre
  Map<LocationType, dynamic> get selectedGenre => _selectedGenre;
  Map<LocationType, dynamic> get selectedDateInWeek => _selectedDateInWeek;
  LocationType get locationType => _locationType;
  Map<LocationType, String?> get area => _area;
  bool get isDomestic => _locationType == LocationType.domestic;
  AsyncState<List<DateTime>> get weeklyCalendar => _weeklyCalendar;
  AsyncState<List<String>> get overseasCountries => _overseasCountries;
  AsyncState<List<RegionModel>> get domesticRegions => _domesticRegions;

  Map<LocationType, Map<String, AsyncState<List<ExhibitModel>>>>
  get todayExhibitRecommendations => _todayExhibitRecommendations;

  Map<LocationType, AsyncState<List<ExhibitModel>>> get personalizedExhibits =>
      _personalizedExhibits;
  Map<LocationType, Map<String, Map<String, AsyncState<List<ExhibitModel>>>>>
  get weeklyExhibitsBySelectedDate => _weeklyExhibitsBySelectedDate;

  /// 큐레이션 전시 (국내/해외 -> 국가/지역)
  Map<LocationType, Map<String, AsyncState<CurationModel>>> get curations =>
      _curations;
  AsyncState<List<String>> get genres => _genres;
  Map<LocationType, Map<String, Map<String, AsyncState<List<ExhibitModel>>>>>
  get exhibitsByGenre => _exhibitsByGenre;

  set setLocationType(LocationType locationType) {
    _locationType = locationType;
    notifyListeners();
  }

  set setSelectedGenre(String genre) {
    _selectedGenre[_locationType]![_area[_locationType]!] = genre;
    notifyListeners();
  }

  set setSelectedDateInWeek(DateTime date) {
    _selectedDateInWeek[_locationType] ??= {};
    _selectedDateInWeek[_locationType]![_area[_locationType]!] = date;
    notifyListeners();
  }

  set setScrollOffset(double offset) {
    _scrollOffset[_locationType] = offset;
    notifyListeners();
  }

  Future<void> load(BuildContext context) async {
    _area[_locationType] = context.l10n.allItems;
    await (isDomestic
        ? getDomesticRegions(context)
        : getOverseasCountries(context));

    unawaited(getTodayExhibitRecommendations());
    unawaited(getGenres());
    unawaited(getPersonalizedExhibits());
    unawaited(
      updateSelectedDateInWeek(
        _selectedDateInWeek[_locationType]?[_area[_locationType]] ?? _today,
      ),
    );
    unawaited(getWeeklyCalendar());
    unawaited(getCurations());
  }

  /// 해외/국내별 국가/지역 업데이트
  void updateSelectedLocation(String area) {
    _area[_locationType] = area;
    getTodayExhibitRecommendations();
    getGenres();
    getPersonalizedExhibits();
    updateSelectedDateInWeek(
      _selectedDateInWeek[_locationType]?[_area[_locationType]] ?? _today,
    );
    getWeeklyCalendar();
    getCurations();
  }

  /// 이번주 선택한 날짜 업데이트
  Future<void> updateSelectedDateInWeek(DateTime date) async {
    setSelectedDateInWeek = date;
    unawaited(getWeeklyExhibitsBySelectedDate(date));
  }

  /// 해외 국가 리스트 조회
  Future<void> getOverseasCountries(BuildContext context) async {
    if (_overseasCountries.status == AsyncStatus.success) {
      _locationType = LocationType.overseas;
      notifyListeners();
      return;
    }
    _overseasCountries = const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchOverseasCountries();
      _overseasCountries = AsyncState.success(result);
      if (result.isNotEmpty) {
        _area[LocationType.overseas] = result.first;
      } else {
        if (context.mounted) {
          _area[LocationType.overseas] = context.l10n.allItems;
        }
      }
    } catch (e) {
      AppUtil.debugLog('getOverseasCountries error: $e');
      _overseasCountries = const AsyncState.error();
      _area[LocationType.overseas] = context.mounted
          ? context.l10n.allItems
          : '';
    }

    notifyListeners();
  }

  /// 국내 지역 리스트 조회
  Future<void> getDomesticRegions(BuildContext context) async {
    if (_domesticRegions.status == AsyncStatus.success) {
      _locationType = LocationType.domestic;
      _area[LocationType.domestic] = context.l10n.allItems;
      notifyListeners();
      return;
    }

    _domesticRegions = const AsyncState.loading();
    notifyListeners();
    try {
      _area[LocationType.domestic] = context.mounted
          ? context.l10n.allItems
          : '';
      final result = await homeRepository.fetchDomesticRegions();
      _domesticRegions = AsyncState.success(result);
    } catch (e) {
      AppUtil.debugLog('getDomesticRegions error: $e');
      _domesticRegions = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 오늘의 랜덤 전시 추천
  Future<void> getTodayExhibitRecommendations() async {
    /// 캐싱 처리 (기존 데이터가 있으면 로딩 상태로 변경하지 않고 그대로 보여줌)
    if (_todayExhibitRecommendations[_locationType]?[_area[_locationType]]
            ?.status ==
        AsyncStatus.success) {
      final oldState =
          _todayExhibitRecommendations[_locationType]![_area[_locationType]]!;

      _todayExhibitRecommendations[_locationType]![_area[_locationType]!] =
          AsyncState.success(
            List.from(oldState.data!),
          );

      notifyListeners();
      return;
    }
    // _area[_locationType] ??= context.l10n.allItems;
    _todayExhibitRecommendations[_locationType] ??= {};
    _todayExhibitRecommendations[_locationType]![_area[_locationType]!] =
        const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchTodayExhibitRecommendations(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area[_locationType],
        region: isDomestic ? _area[_locationType] : null,
      );

      exhibitVM.initializeFromExhibits(result);
      _todayExhibitRecommendations[_locationType]![_area[_locationType]!] =
          AsyncState.success(
            result,
          );
    } catch (e) {
      AppUtil.debugLog('getTodayExhibitRecommendations error: $e');
      _todayExhibitRecommendations[_locationType]![_area[_locationType]!] =
          const AsyncState.error();
    }
    notifyListeners();
  }

  /// 장르 리스트 조회
  Future<void> getGenres() async {
    if (_genres.status == AsyncStatus.success) {
      await getExhibitsByGenre();
      return;
    }

    _genres = const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchGenres();

      _genres = AsyncState.success(result);
      _selectedGenre[_locationType] ??= {};
      _selectedGenre[_locationType]![_area[_locationType]!] = result.first;

      notifyListeners();

      await getExhibitsByGenre();
    } catch (e) {
      AppUtil.debugLog('getGenres error: $e');
      _genres = const AsyncState.error();
      notifyListeners();
    }
  }

  /// 장르별 전시 리스트 조회
  Future<void> getExhibitsByGenre() async {
    if (_exhibitsByGenre[_locationType]?[_area[_locationType]]?[_selectedGenre[_locationType]![_area[_locationType]]]
            ?.status ==
        AsyncStatus.success) {
      final oldState =
          _exhibitsByGenre[_locationType]![_area[_locationType]]![_selectedGenre[_locationType]![_area[_locationType]]];
      _exhibitsByGenre[_locationType]![_area[_locationType]]![_selectedGenre[_locationType]![_area[_locationType]]!] =
          AsyncState.success(List.from(oldState!.data!));

      notifyListeners();
      return;
    }

    _exhibitsByGenre[_locationType] ??= {};
    _exhibitsByGenre[_locationType]![_area[_locationType]!] ??= {};
    _selectedGenre[_locationType] ??= {};
    _selectedGenre[_locationType]![_area[_locationType]!] ??=
        _genres.data!.first;
    _exhibitsByGenre[_locationType]![_area[_locationType]]![_selectedGenre[_locationType]![_area[_locationType]]!] =
        const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchExhibitsByGenre(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area[_locationType],
        region: isDomestic ? _area[_locationType] : null,
        genre: _selectedGenre[_locationType]![_area[_locationType]]!,
      );

      _exhibitsByGenre[_locationType]![_area[_locationType]]![_selectedGenre[_locationType]![_area[_locationType]]!] =
          AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    } catch (e) {
      AppUtil.debugLog('getExhibitsByGenre error: $e');
      _exhibitsByGenre[_locationType]![_area[_locationType]]![_selectedGenre[_locationType]![_area[_locationType]]!] =
          const AsyncState.error();
    }
    notifyListeners();
  }

  /// 사용자 맞춤 전시 리스트 조회
  Future<void> getPersonalizedExhibits() async {
    /// 캐싱 처리
    if (_personalizedExhibits[_locationType]?.status == AsyncStatus.success) {
      final oldState = _personalizedExhibits[_locationType]!;
      _personalizedExhibits[_locationType] = AsyncState.success(
        List.from(oldState.data!),
      );
      notifyListeners();
      return;
    }

    _personalizedExhibits[_locationType] = const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchPersonalizedExhibits(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area[_locationType],
        region: isDomestic ? _area[_locationType] : null,
      );

      _personalizedExhibits[_locationType] = AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    } catch (e) {
      AppUtil.debugLog('getPersonalizedExhibits error: $e');
      _personalizedExhibits[_locationType] = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 이번주 선택한 날짜 기준 전시 리스트 조회
  Future<void> getWeeklyExhibitsBySelectedDate(DateTime date) async {
    final selectedDateDay = date.day.toString();
    if (_weeklyExhibitsBySelectedDate[_locationType]?[_area[_locationType]]?[selectedDateDay]
            ?.status ==
        AsyncStatus.success) {
      final oldState =
          _weeklyExhibitsBySelectedDate[_locationType]![_area[_locationType]]![selectedDateDay]!;

      _weeklyExhibitsBySelectedDate[_locationType]![_area[_locationType]]![selectedDateDay] =
          AsyncState.success(List.from(oldState.data!));

      notifyListeners();
      return;
    }
    _weeklyExhibitsBySelectedDate[_locationType] ??= {};
    _weeklyExhibitsBySelectedDate[_locationType]![_area[_locationType]!] ??= {};
    _weeklyExhibitsBySelectedDate[_locationType]![_area[_locationType]]![selectedDateDay] =
        const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchWeeklyExhibitsBySelectedDate(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area[_locationType],
        region: isDomestic ? _area[_locationType] : null,
        date: AppUtil.formatDateYMD(date),
      );
      _weeklyExhibitsBySelectedDate[_locationType]![_area[_locationType]]![selectedDateDay] =
          AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    } catch (e) {
      AppUtil.debugLog('getWeeklyExhibitsBySelectedDate error: $e');
      _weeklyExhibitsBySelectedDate[_locationType]![_area[_locationType]]![selectedDateDay] =
          const AsyncState.error();
    }

    notifyListeners();
  }

  /// 큐레이션 조회
  Future<void> getCurations() async {
    try {
      if (_curations[_locationType]?[_area[_locationType]]?.status ==
          AsyncStatus.success) {
        final oldState = _curations[_locationType]![_area[_locationType]]!;

        _curations[_locationType]![_area[_locationType]!] = AsyncState.success(
          oldState.data!,
        );

        notifyListeners();
        return;
      }

      _curations[_locationType] ??= {};
      _curations[_locationType]![_area[_locationType]!] =
          const AsyncState.loading();

      final result = await homeRepository.fetchCurations(
        isDomestic: isDomestic,
        country: _area[_locationType],
      );
      _curations[_locationType]![_area[_locationType]!] = AsyncState.success(
        result,
      );
    } catch (e) {
      AppUtil.debugLog('getCurations error: $e');
    }
  }

  /// 이번주 캘린더 조회
  Future<void> getWeeklyCalendar() async {
    if (_weeklyCalendar.status == AsyncStatus.success) {
      _weeklyCalendar = AsyncState.success(_weeklyCalendar.data!);
      notifyListeners();
      return;
    }

    _weeklyCalendar = const AsyncState.loading();
    notifyListeners();

    try {
      final result = AppUtil.getCurrentWeek(_today);

      _weeklyCalendar = AsyncState.success(result);
    } catch (e) {
      AppUtil.debugLog('getWeeklyCalendar error: $e');
      _weeklyCalendar = const AsyncState.error();
    }
    notifyListeners();
  }

  /// 큐레이션 전체 조회
  ///
  /// 로딩 처리는 각 화면에서 로딩 변수로 처리합니다.
  ///
  /// null: API 호출 실패
  Future<ExhibitFilterModel?> getCurationDetail({
    required String curationId,
    required int cursor,
    required int size,
  }) async {
    try {
      final response = await homeRepository.fetchCurationDetail(
        curationId: curationId,
        cursor: cursor,
        size: size,
      );
      return response;
    } catch (e) {
      AppUtil.debugLog('getCurationDetail error: $e');
      return null;
    }
  }
}
