import 'package:examtrack/core/app.theme.dart';
import 'package:examtrack/features/screens/home_screen.dart';
import 'package:examtrack/profile/profile_screen.dart';
import 'package:examtrack/score/score_screen.dart';
import 'package:examtrack/tests/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
  int? userId; // ✅ shared prefs se load hoga

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId'); // ✅ login ke baad saved userId le lo
    });
  }

  List<Widget> get _pages {
    return [
      HomeScreen(),
      TestScreen(),
      userId != null
          ? ScoreScreen() // ✅ yaha pass kar diya (userId: userId!)
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "TEST"),
          BottomNavigationBarItem(icon: Icon(Icons.score), label: "SCORE"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "MY PROFILE",
          ),
        ],
      ),
    );
  }
}
