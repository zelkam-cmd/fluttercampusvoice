import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'student_dashboard.dart';
import 'survey_list_screen.dart';
import 'announcements_screen.dart';
import 'student_profile_screen.dart';

class StudentMainNav extends StatefulWidget {
  const StudentMainNav({super.key});

  @override
  State<StudentMainNav> createState() => _StudentMainNavState();
}

class _StudentMainNavState extends State<StudentMainNav> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      StudentDashboard(onNavigateTab: _onTabTapped),
      const SurveyListScreen(),
      const AnnouncementsScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primaryTealLight,
            elevation: 0,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.primaryTeal),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: const Icon(Icons.assignment_outlined),
                selectedIcon: const Icon(Icons.assignment_rounded, color: AppColors.primaryTeal),
                label: 'Surveys',
              ),
              NavigationDestination(
                icon: const Icon(Icons.notifications_none_rounded),
                selectedIcon: const Icon(Icons.notifications_rounded, color: AppColors.primaryTeal),
                label: 'Notices',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primaryTeal),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
