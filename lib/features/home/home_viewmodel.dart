import 'dart:async';

import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/models/region_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.exhibitVM, required this.homeRepository});
  final ExhibitViewModel exhibitVM;
  final HomeRepository homeRepository;

  final DateTime _today = DateTime.now();
  late String _selectedGenre;
  DateTime _selectedDateInWeek = DateTime.now();
  LocationType _locationType = LocationType.overseas;
  String? _area;
  AsyncState<List<String>> _overseasCountries = const AsyncState.loading();
  AsyncState<List<RegionModel>> _domesticRegions = const AsyncState.loading();
  AsyncState<List<DateTime>> _weeklyCalendar = const AsyncState.loading();

  final Map<LocationType, Map<String, AsyncState<List<ExhibitModel>>>>
  _todayExhibitRecommendations = {};

  /// 해외/국내별, 국가/지역의 일자별로 저장
  final Map<
    LocationType,
    Map<String, Map<String, AsyncState<List<ExhibitModel>>>>
  >
  _weeklyExhibitsBySelectedDate = {};

  final Map<LocationType, AsyncState<List<ExhibitModel>>>
  _personalizedExhibits = {};
  final Map<
    LocationType,
    Map<String, Map<String, AsyncState<List<ExhibitModel>>>>
  >
  _exhibitsByGenre = {};
  AsyncState<List<String>> _genres = const AsyncState.loading();

  String get selectedGenre => _selectedGenre;
  DateTime get selectedDateInWeek => _selectedDateInWeek;
  LocationType get locationType => _locationType;
  String? get area => _area;
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
  AsyncState<List<String>> get genres => _genres;
  Map<LocationType, Map<String, Map<String, AsyncState<List<ExhibitModel>>>>>
  get exhibitsByGenre => _exhibitsByGenre;

  set setLocationType(LocationType locationType) {
    _locationType = locationType;
    notifyListeners();
  }

  set setArea(String area) {
    _area = area;
    notifyListeners();
  }

  set setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  set setSelectedDateInWeek(DateTime date) {
    _selectedDateInWeek = date;
    notifyListeners();
  }

  Future<void> load(BuildContext context) async {
    await (isDomestic
        ? getDomesticRegions(context)
        : getOverseasCountries(context));

    unawaited(getTodayExhibitRecommendations());
    unawaited(getGenres());
    unawaited(getPersonalizedExhibits());
    unawaited(getWeeklyExhibitsBySelectedDate(_today));
    unawaited(getWeeklyCalendar());
  }

  /// 해외/국내별 국가/지역 업데이트
  void updateSelectedLocation(String area) {
    _area = area;
    getTodayExhibitRecommendations();
    getGenres();
    getPersonalizedExhibits();
    getWeeklyExhibitsBySelectedDate(_today);
    getWeeklyCalendar();
  }

  /// 이번주 선택한 날짜 업데이트
  void updateSelectedDateInWeek(DateTime date) {
    setSelectedDateInWeek = date;
    getWeeklyExhibitsBySelectedDate(date);
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
      var result = await homeRepository.fetchOverseasCountries();
      if (!context.mounted) {
        /// context가 보장되지 않으면 '전체' 항목은 보여주지 않음
        _overseasCountries = AsyncState.success(result);
        _area = result.first;
      } else {
        result = [context.l10n.allItems, ...result];
        _area = context.l10n.allItems;
        _overseasCountries = AsyncState.success(result);
      }
    } catch (e) {
      AppUtil.debugLog('getOverseasCountries error: $e');
      _overseasCountries = const AsyncState.error();
      _area = context.mounted ? context.l10n.allItems : '';
    }

    notifyListeners();
  }

  /// 국내 지역 리스트 조회
  Future<void> getDomesticRegions(BuildContext context) async {
    if (_domesticRegions.status == AsyncStatus.success) {
      _locationType = LocationType.domestic;
      notifyListeners();
      return;
    }

    _domesticRegions = const AsyncState.loading();
    notifyListeners();
    try {
      final result = await homeRepository.fetchDomesticRegions();
      _domesticRegions = AsyncState.success(result);
      _area =
          result.isNotEmpty
              ? result.first.region
              : context.mounted
              ? context.l10n.allItems
              : '';
    } catch (e) {
      AppUtil.debugLog('getDomesticRegions error: $e');
      _domesticRegions = const AsyncState.error();
      _area = context.mounted ? context.l10n.allItems : '';
    }
    notifyListeners();
  }

  /// 오늘의 랜덤 전시 추천
  Future<void> getTodayExhibitRecommendations() async {
    /// 캐싱 처리 (기존 데이터가 있으면 로딩 상태로 변경하지 않고 그대로 보여줌)
    if (_todayExhibitRecommendations[_locationType]?[_area]?.status ==
        AsyncStatus.success) {
      final oldState = _todayExhibitRecommendations[_locationType]![_area!]!;

      _todayExhibitRecommendations[_locationType]![_area!] = AsyncState.success(
        List.from(oldState.data!),
      );

      notifyListeners();
      return;
    }
    _area ??= '전체';
    _todayExhibitRecommendations[_locationType] ??= {};
    _todayExhibitRecommendations[_locationType]![_area!] =
        const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchTodayExhibitRecommendations(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area,
        region: isDomestic ? _area : null,
      );

      exhibitVM.initializeFromExhibits(result);
      _todayExhibitRecommendations[_locationType]![_area!] = AsyncState.success(
        result,
      );
    } catch (e) {
      AppUtil.debugLog('getTodayExhibitRecommendations error: $e');
      _todayExhibitRecommendations[_locationType]![_area!] =
          const AsyncState.error();
    }
    notifyListeners();
  }

  /// 장르 리스트 조회
  Future<void> getGenres() async {
    if (_genres.status == AsyncStatus.success) {
      /// 장르는 해외/국내 공통이므로 locationType 구분 없이 캐싱 처리
      await getExhibitsByGenre();
      return;
    }

    _genres = const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchGenres();

      _genres = AsyncState.success(result);
      _selectedGenre = result.first;
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
    if (_exhibitsByGenre[_locationType]?[_area!]?[_selectedGenre]?.status ==
        AsyncStatus.success) {
      final oldState =
          _exhibitsByGenre[_locationType]![_area!]?[_selectedGenre];
      _exhibitsByGenre[_locationType]![_area!]?[_selectedGenre] =
          AsyncState.success(List.from(oldState!.data!));

      notifyListeners();
      return;
    }

    _exhibitsByGenre[_locationType] ??= {};
    _exhibitsByGenre[_locationType]![_area!] ??= {};
    _exhibitsByGenre[_locationType]![_area]![_selectedGenre] =
        const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchExhibitsByGenre(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area,
        region: isDomestic ? _area : null,
        genre: _selectedGenre,
      );

      _exhibitsByGenre[_locationType]![_area]![_selectedGenre] =
          AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    } catch (e) {
      AppUtil.debugLog('getExhibitsByGenre error: $e');
      _exhibitsByGenre[_locationType]![_area]![_selectedGenre] =
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
        country: isDomestic ? null : _area,
        region: isDomestic ? _area : null,
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
    final selectedDateDay = _selectedDateInWeek.day.toString();
    if (_weeklyExhibitsBySelectedDate[_locationType]?[_area]?[selectedDateDay]
            ?.status ==
        AsyncStatus.success) {
      final oldState =
          _weeklyExhibitsBySelectedDate[_locationType]![_area]![selectedDateDay]!;

      _weeklyExhibitsBySelectedDate[_locationType]![_area]![selectedDateDay] =
          AsyncState.success(List.from(oldState.data!));

      notifyListeners();
      return;
    }
    _weeklyExhibitsBySelectedDate[_locationType] ??= {};
    _weeklyExhibitsBySelectedDate[_locationType]![_area!] ??= {};
    _weeklyExhibitsBySelectedDate[_locationType]![_area]![selectedDateDay] =
        const AsyncState.loading();
    notifyListeners();

    try {
      final result = await homeRepository.fetchWeeklyExhibitsBySelectedDate(
        isDomestic: isDomestic,
        country: isDomestic ? null : _area,
        region: isDomestic ? _area : null,
        date: AppUtil.formatDateYMD(date),
      );

      _weeklyExhibitsBySelectedDate[_locationType]![_area]![selectedDateDay] =
          AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    } catch (e) {
      AppUtil.debugLog('getWeeklyExhibitsBySelectedDate error: $e');
      _weeklyExhibitsBySelectedDate[_locationType]![_area]![selectedDateDay] =
          const AsyncState.error();
    }

    notifyListeners();
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
      await Future.delayed(const Duration(milliseconds: 500));
      final result = AppUtil.getCurrentWeek(_today);

      _weeklyCalendar = AsyncState.success(result);
    } catch (e) {
      AppUtil.debugLog('getWeeklyCalendar error: $e');
      _weeklyCalendar = const AsyncState.error();
    }
    notifyListeners();
  }
}
