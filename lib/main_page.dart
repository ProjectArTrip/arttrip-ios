import 'package:arttrip/features/home/home_page.dart';
import 'package:arttrip/features/map/view/map_view.dart';
import 'package:arttrip/features/my/view/my_view.dart';
import 'package:arttrip/features/stamp/view/stamp_view.dart';
import 'package:arttrip/features/storage/view/storage_view.dart';
import 'package:arttrip/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MapView(),
    StampView(),
    StorageView(),
    MyView(),
  ];

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
