import 'package:arttrip/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GNB ShellRoute용 Shell 위젯
///
/// 하단 네비게이션 바를 포함하고, 탭 전환 시 각 탭의 상태를 유지

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<BottomNavBarState> _bottomNavigationKey =
      GlobalKey<BottomNavBarState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: widget.navigationShell),
      bottomNavigationBar: BottomNavBar(
        key: _bottomNavigationKey,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => _onTap(index),
      ),
    );
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
