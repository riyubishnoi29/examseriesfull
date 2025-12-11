import 'dart:convert';

import 'package:examtrack/core/app.theme.dart';

import 'package:examtrack/profile/profile_screen.dart';
import 'package:examtrack/score/score_screen.dart';
import 'package:examtrack/tests/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAppUpdate(context);
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }

  List<Widget> get _pages {
    return [
      TestScreen(),
      userId != null
          ? ScoreScreen()
          : const Center(child: CircularProgressIndicator()),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          top: false,
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: "TEST",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.score), label: "SCORE"),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "MY PROFILE",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkAppUpdate(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version; // 1.0.0

    final response = await http.get(
      Uri.parse(
        'https://rankyard.in/check_update?current_version=$currentVersion',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final latestVersion = data['latest_version'];
      final updateType = data['update_type']; // force / normal / none
      final updateUrl = data['update_url'];

      if (updateType == 'force') {
        _showForceUpdateDialog(context, updateUrl);
      } else if (updateType == 'normal') {
        _showNormalUpdateDialog(context, updateUrl);
      }
    }
  }

  void _showForceUpdateDialog(BuildContext context, String url) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Update Required'),
            content: Text(
              'A new version of the app is available. Please update to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse(url)),
                child: Text('Update Now'),
              ),
            ],
          ),
    );
  }

  void _showNormalUpdateDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Update Available'),
            content: Text(
              'A new version is available. Would you like to update?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Later'),
              ),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(url)),
                child: Text('Update Now'),
              ),
            ],
          ),
    );
  }
}
