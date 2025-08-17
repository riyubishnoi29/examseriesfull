import 'package:flutter/material.dart';
import '../score/score_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Result"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Test Completed!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Text("Your Score:", style: TextStyle(fontSize: 22)),
              SizedBox(height: 8),
              Text(
                "$score / $total",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  ); // Back to Home tab
                },
                child: Text("Back to Home"),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              ScoreScreen(), // ✅ Score tab will fetch saved results automatically
                    ),
                  );
                },
                child: Text("View All Scores"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class ResultScreen extends StatelessWidget {
//   final int score;
//   final int total;

//   ResultScreen({required this.score, required this.total});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Test Result"),
//         automaticallyImplyLeading: false, // Back button disable
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Test Completed!",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 24),
//               Text("Your Score:", style: TextStyle(fontSize: 22)),
//               SizedBox(height: 8),
//               Text(
//                 "$score / $total",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//               SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.popUntil(
//                     context,
//                     (route) => route.isFirst,
//                   ); // Back to home
//                 },
//                 child: Text("Back to Home"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
