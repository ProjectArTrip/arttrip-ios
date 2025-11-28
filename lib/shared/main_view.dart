import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';
import '../features/home/view/home_view.dart';
import '../features/map/view/map_view.dart';
import '../features/stamp/view/stamp_view.dart';
import '../features/storage/view/storage_view.dart';
import '../features/my/view/my_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    MapView(),
    StampView(),
    StorageView(),
    MyView(),
  ];

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
