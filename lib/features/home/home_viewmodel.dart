import 'package:arttrip/core/app_utils.dart';
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

  AsyncState<List<String>> locations = const AsyncState.loading();
  AsyncState<List<ExhibitModel>> todayExhibitRecommendations =
      const AsyncState.loading();
  AsyncState<List<String>> genres = const AsyncState.loading();
  AsyncState<List<ExhibitModel>> exhibitsByGenre = const AsyncState.loading();
  AsyncState<List<ExhibitModel>> personalizedExhibits =
      const AsyncState.loading();
  AsyncState<List<ExhibitModel>> weeklyExhibitsBySelectedDate =
      const AsyncState.loading();
  AsyncState<List<DateTime>> weeklyCalendar = const AsyncState.loading();

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
    if (resetLocations) locations = const AsyncState.loading();
    todayExhibitRecommendations = const AsyncState.loading();
    genres = const AsyncState.loading();
    exhibitsByGenre = const AsyncState.loading();
    personalizedExhibits = const AsyncState.loading();
    weeklyExhibitsBySelectedDate = const AsyncState.loading();
    weeklyCalendar = const AsyncState.loading();
    notifyListeners();
  }

  void load(BuildContext context) {
    _resetToLoading();
    (_isDomestic ? fetchDomesticRegions() : fetchOverseasCountries(context))
        .then((_) {
          fetchTodayExhibitRecommendations();
          fetchGenres();
          fetchPersonalizedExhibits();
          fetchWeeklyExhibitsBySelectedDate(_today, isInitialLoad: true);
          getWeeklyCalendar();
        });
  }

  void updateSelectedLocation(String location) {
    _selectedLocation = location;
    _resetToLoading(resetLocations: false);
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
    locations = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchOverseasCountries();
    if (result == null || context.mounted == false) {
      locations = const AsyncState.error();
    } else {
      result = [context.l10n.allItems, ...result];
      _selectedLocation = context.l10n.allItems;
      locations = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchDomesticRegions() async {
    locations = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchDomesticRegions();
    if (result == null) {
      locations = const AsyncState.error();
    } else {
      if (result.isNotEmpty) _selectedLocation = result[0];
      locations = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchTodayExhibitRecommendations() async {
    todayExhibitRecommendations = const AsyncState.loading();
    notifyListeners();
    var result = await homeRepository.fetchTodayExhibitRecommendations(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
    );
    if (result == null) {
      todayExhibitRecommendations = const AsyncState.error();
    } else {
      exhibitVM.initializeFromExhibits(result);
      todayExhibitRecommendations = AsyncState.success(result);
    }
    notifyListeners();
  }

  Future<void> fetchGenres() async {
    genres = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchGenres();
    if (result == null) {
      genres = const AsyncState.error();
    } else {
      genres = AsyncState.success(result);
      _selectedGenre = result.first;
    }
    notifyListeners();
    await fetchExhibitsByGenre();
  }

  Future<void> fetchExhibitsByGenre() async {
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
    }
    notifyListeners();
  }

  Future<void> fetchPersonalizedExhibits() async {
    personalizedExhibits = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchPersonalizedExhibits(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
    );
    if (result == null) {
      personalizedExhibits = const AsyncState.error();
    } else {
      personalizedExhibits = AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    }
    notifyListeners();
  }

  Future<void> fetchWeeklyExhibitsBySelectedDate(
    DateTime date, {
    bool isInitialLoad = false,
  }) async {
    if (isInitialLoad) _selectedDateInWeek = _today;
    weeklyExhibitsBySelectedDate = const AsyncState.loading();
    notifyListeners();

    var result = await homeRepository.fetchWeeklyExhibitsBySelectedDate(
      isDomestic: _isDomestic,
      country: _isDomestic ? null : _selectedLocation,
      region: _isDomestic ? _selectedLocation : null,
      date: AppUtil.formatDateYMD(date),
    );
    if (result == null) {
      weeklyExhibitsBySelectedDate = const AsyncState.error();
    } else {
      weeklyExhibitsBySelectedDate = AsyncState.success(result);
      exhibitVM.initializeFromExhibits(result);
    }
    notifyListeners();
  }

  Future<void> getWeeklyCalendar() async {
    weeklyCalendar = const AsyncState.loading();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    var result = AppUtil.getCurrentWeek(_today);

    weeklyCalendar = AsyncState.success(result);
    notifyListeners();
  }
}
