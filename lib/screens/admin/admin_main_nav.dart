import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard.dart';
import 'admin_surveys_screen.dart';
import 'survey_results_screen.dart';
import 'student_directory_screen.dart';
import '../../services/firebase_service.dart';
import '../../models/survey.dart';

class AdminMainNav extends StatefulWidget {
  const AdminMainNav({super.key});

  @override
  State<AdminMainNav> createState() => _AdminMainNavState();
}

class _AdminMainNavState extends State<AdminMainNav> {
  int _currentIndex = 0;
  Survey? _featuredSurvey;

  @override
  void initState() {
    super.initState();
    _loadFirstSurvey();
  }

  Future<void> _loadFirstSurvey() async {
    final list = await FirebaseService().getSurveys();
    if (list.isNotEmpty && mounted) {
      setState(() {
        _featuredSurvey = list.first;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultSurvey = _featuredSurvey ??
        Survey(
          id: 'srv_midterm_2026',
          title: 'Campus Overview Analytics',
          description: 'University feedback metrics across colleges',
          startDate: '2026-09-01',
          endDate: '2026-10-30',
        );

    final List<Widget> pages = [
      AdminDashboard(onNavigateTab: _onTabTapped),
      const AdminSurveysScreen(),
      SurveyResultsScreen(survey: defaultSurvey),
      const StudentDirectoryScreen(),
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
            indicatorColor: const Color(0xFFDBEAFE),
            elevation: 0,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.royalBlue),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.royalBlue),
                label: 'Surveys',
              ),
              const NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded, color: AppColors.royalBlue),
                label: 'Analytics',
              ),
              const NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded, color: AppColors.royalBlue),
                label: 'Students',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
