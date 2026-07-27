import 'package:google_maps_flutter/google_maps_flutter.dart';

class CountryLocationData {
  const CountryLocationData({
    required this.position,
    required this.zoom,
  });

  final LatLng position;
  final double zoom;
}

class CountryLocation {
  const CountryLocation._();

  static const Map<String, CountryLocationData> countries = {
    '국내': CountryLocationData(
      position: LatLng(37.5665, 126.9780),
      zoom: 7.0,
    ),
    '프랑스': CountryLocationData(
      position: LatLng(48.8566, 2.3522),
      zoom: 6.0,
    ),
    '독일': CountryLocationData(
      position: LatLng(52.5200, 13.4050),
      zoom: 6.0,
    ),
    '일본': CountryLocationData(
      position: LatLng(35.6762, 139.6503),
      zoom: 6.0,
    ),
    '이탈리아': CountryLocationData(
      position: LatLng(41.9028, 12.4964),
      zoom: 6.0,
    ),
    '미국': CountryLocationData(
      position: LatLng(40.7128, -74.0060),
      zoom: 4.0,
    ),
    '오스트리아': CountryLocationData(
      position: LatLng(48.2082, 16.3738),
      zoom: 7.0,
    ),
    '영국': CountryLocationData(
      position: LatLng(51.5074, -0.1278),
      zoom: 6.0,
    ),
    '스페인': CountryLocationData(
      position: LatLng(40.4168, -3.7038),
      zoom: 6.0,
    ),
    '중국': CountryLocationData(
      position: LatLng(39.9042, 116.4074),
      zoom: 5.0,
    ),
    '네덜란드': CountryLocationData(
      position: LatLng(52.3676, 4.9041),
      zoom: 7.0,
    ),
    '스위스': CountryLocationData(
      position: LatLng(46.9480, 7.4474),
      zoom: 7.0,
    ),
  };

  static CountryLocationData? getLocation(String countryName) {
    return countries[countryName];
  }

  static const CountryLocationData defaultLocation = CountryLocationData(
    position: LatLng(37.5665, 126.9780),
    zoom: 7.0,
  );
}
