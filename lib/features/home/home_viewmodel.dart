import 'dart:async';

import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/exhibit/viewmodel/exhibit_viewmodel.dart';
import 'package:arttrip/features/home/home_repository.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  HomeViewModel({required this.exhibitVM, required this.homeRepository});
  final ExhibitViewModel exhibitVM;
  final HomeRepository homeRepository;

  AsyncState<List<String>> overseasCountries = const AsyncState.loading();
  AsyncState<List<String>> domesticRegions = const AsyncState.loading();
  AsyncState<List<ExhibitModel>> todayExhibitRecommendations =
      const AsyncState.loading();
  AsyncState<List<String>> genres = const AsyncState.loading();
  AsyncState<List<ExhibitModel>> exhibitsByGenre = const AsyncState.loading();
  Map<String, AsyncState<List<ExhibitModel>>> personalizedExhibits = {
    LocationType.overseas.name: const AsyncState.loading(),
    LocationType.domestic.name: const AsyncState.loading(),
  };
  Map<String, AsyncState<List<ExhibitModel>>> weeklyExhibitsBySelectedDate = {
    DateTime.now().day.toString(): const AsyncState.loading(),
  };
  AsyncState<List<DateTime>> weeklyCalendar = const AsyncState.loading();

  List<String>? _overseasCountriesCache;
  List<String>? _domesticRegionsCache;
  final Map<String, List<ExhibitModel>> _todayExhibitRecommendationsCache = {};
  final Map<String, List<ExhibitModel>> _personalizedExhibitsCache = {};
  List<DateTime>? _weeklyCalendarCache;
  final Map<String, List<ExhibitModel>> _weeklyExhibitsBySelectedDateCache = {};
  List<String>? _genresCache;
  final Map<String, List<ExhibitModel>> _exhibitsByGenreCache = {};

  final DateTime _today = DateTime.now();
  bool _isDomestic = false;
  late String _selectedLocation;
  late String _selectedGenre;
  DateTime _selectedDateInWeek = DateTime.now();

  bool get isDomestic => _isDomestic;
  String get selectedLocation => _selectedLocation;
  String get selectedGenre => _selectedGenre;
  DateTime get selectedDateInWeek => _selectedDateInWeek;

  set isDomestic(bool value) {
    _isDomestic = value;
    notifyListeners();
  }

  set selectedLocation(String region) {
    _selectedLocation = region;
    notifyListeners();
  }

  set selectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  set selectedDateInWeek(DateTime date) {
    _selectedDateInWeek = date;
    notifyListeners();
  }

  void _resetToLoading({bool resetLocations = true}) {
    if (resetLocations) overseasCountries = const AsyncState.loading();
    todayExhibitRecommendations = const AsyncState.loading();
    genres = const AsyncState.loading();
    exhibitsByGenre = const AsyncState.loading();
    personalizedExhibits = {
      LocationType.overseas.name: const AsyncState.loading(),
      LocationType.domestic.name: const AsyncState.loading(),
    };
    weeklyExhibitsBySelectedDate[_today.day.toString()] =
        const AsyncState.loading();
    weeklyCalendar = const AsyncState.loading();
    notifyListeners();
  }

  Future<void> load(BuildContext context, {bool refresh = false}) async {
    if (refresh) _resetToLoading();
    await (_isDomestic
        ? fetchDomesticRegions()
        : fetchOverseasCountries(context));

    unawaited(fetchTodayExhibitRecommendations());
    unawaited(fetchGenres());
    unawaited(fetchPersonalizedExhibits());
    unawaited(fetchWeeklyExhibitsBySelectedDate(_today, isInitialLoad: true));
    unawaited(getWeeklyCalendar());
  }

  void updateSelectedLocation(String location) {
    _selectedLocation = location;
    // _resetToLoading(resetLocations: false);
    fetchTodayExhibitRecommendations();
    fetchGenres();
    fetchPersonalizedExhibits();
    fetchWeeklyExhibitsBySelectedDate(_today, isInitialLoad: true);
    getWeeklyCalendar();
  }

  void updateSelectedDateInWeek(DateTime date) {
    selectedDateInWeek = date;
    fetchWeeklyExhibitsBySelectedDate(date);
  }

  Future<void> fetchOverseasCountries(BuildContext context) async {
    if (_overseasCountriesCache != null) {
      _selectedLocation = context.l10n.allItems;
      overseasCountries = AsyncState.success(_overseasCountriesCache!);
      notifyListeners();
      return;
    }

    overseasCountries = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchOverseasCountries();
    if (result == null || context.mounted == false) {
      overseasCountries = const AsyncState.error();
    } else {
      result = [context.l10n.allItems, ...result];
      _selectedLocation = context.l10n.allItems;
      overseasCountries = AsyncState.success(result);
      _overseasCountriesCache = result;
    }
    notifyListeners();
  }

  Future<void> fetchDomesticRegions() async {
    if (_domesticRegionsCache != null) {
      domesticRegions = AsyncState.success(_domesticRegionsCache!);
      notifyListeners();
      return;
    }

    domesticRegions = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchDomesticRegions();
    if (result == null) {
      domesticRegions = const AsyncState.error();
    } else {
      domesticRegions = AsyncState.success(result);
      _domesticRegionsCache = result;
    }
    notifyListeners();
  }

  Future<void> fetchTodayExhibitRecommendations() async {
    var key = _isDomestic ? LocationType.domestic.name : _selectedLocation;
    if (_todayExhibitRecommendationsCache[key] != null) {
      todayExhibitRecommendations = AsyncState.success(
        _todayExhibitRecommendationsCache[_selectedLocation]!,
      );
      notifyListeners();
      return;
    }

    todayExhibitRecommendations = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchTodayExhibitRecommendations(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? '전체' : null,
    );
    if (result == null) {
      todayExhibitRecommendations = const AsyncState.error();
    } else {
      exhibitVM.initializeFromExhibits(result);
      todayExhibitRecommendations = AsyncState.success(result);
      _todayExhibitRecommendationsCache[key] = result;
    }
    notifyListeners();
  }

  Future<void> fetchGenres() async {
    if (_genresCache != null) {
      _selectedGenre = _genresCache!.first;
      genres = AsyncState.success(_genresCache!);
      notifyListeners();
      return;
    }
    genres = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchGenres();
    if (result == null) {
      genres = const AsyncState.error();
    } else {
      genres = AsyncState.success(result);
      _selectedGenre = result.first;
      _genresCache = result;
    }
    notifyListeners();
    await fetchExhibitsByGenre();
  }

  Future<void> fetchExhibitsByGenre() async {
    if (_exhibitsByGenreCache[_selectedGenre] != null) {
      exhibitsByGenre = AsyncState.success(
        _exhibitsByGenreCache[_selectedGenre]!,
      );
      notifyListeners();
      return;
    }
    exhibitsByGenre = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchExhibitsByGenre(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
      genre: _selectedGenre,
    );
    if (result == null) {
      exhibitsByGenre = const AsyncState.error();
    } else {
      exhibitsByGenre = AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
      _exhibitsByGenreCache[_selectedGenre] = result;
    }
    notifyListeners();
  }

  Future<void> fetchPersonalizedExhibits() async {
    var location = _isDomestic ? LocationType.domestic : LocationType.overseas;
    var cached = _personalizedExhibitsCache[location.name];
    if (cached != null) {
      personalizedExhibits[location.name] = AsyncState.success(cached);
      notifyListeners();
      return;
    }

    personalizedExhibits[location.name] = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchPersonalizedExhibits(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
    );
    if (result == null) {
      personalizedExhibits[location.name] = const AsyncState.error();
    } else {
      personalizedExhibits[location.name] = AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
      _personalizedExhibitsCache[location.name] = result;
    }
    notifyListeners();
  }

  Future<void> fetchWeeklyExhibitsBySelectedDate(
    DateTime date, {
    bool isInitialLoad = false,
  }) async {
    if (isInitialLoad) _selectedDateInWeek = _today;
    var selectedDateDay = _selectedDateInWeek.day.toString();

    if (_weeklyExhibitsBySelectedDateCache[selectedDateDay] != null) {
      weeklyExhibitsBySelectedDate[selectedDateDay] = AsyncState.success(
        _weeklyExhibitsBySelectedDateCache[selectedDateDay]!,
      );
      notifyListeners();
      return;
    }

    weeklyExhibitsBySelectedDate[selectedDateDay] = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchWeeklyExhibitsBySelectedDate(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
      date: AppUtil.formatDateYMD(date),
    );
    if (result == null) {
      weeklyExhibitsBySelectedDate[selectedDateDay] = const AsyncState.error();
    } else {
      weeklyExhibitsBySelectedDate[selectedDateDay] = AsyncState.success(
        result,
      );
      exhibitVM.initializeFromExhibits(result);
      _weeklyExhibitsBySelectedDateCache[selectedDateDay] = result;
    }
    notifyListeners();
  }

  Future<void> getWeeklyCalendar() async {
    if (_weeklyCalendarCache != null) {
      weeklyCalendar = AsyncState.success(_weeklyCalendarCache!);
      notifyListeners();
      return;
    }
    weeklyCalendar = const AsyncState.loading();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    var result = AppUtil.getCurrentWeek(_today);

    weeklyCalendar = AsyncState.success(result);
    _weeklyCalendarCache = result;
    notifyListeners();
  }
}
