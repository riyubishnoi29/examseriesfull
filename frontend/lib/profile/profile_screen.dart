import 'package:examtrack/services/api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final profile = await ApiService.getProfile();
    setState(() => user = profile);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Please login to view your profile",
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Top gradient header (Black-Red)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.redAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundImage: NetworkImage(
                        user!['profile_picture'] ??
                            'https://www.gravatar.com/avatar/placeholder',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Name + Edit Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // TODO: Add Edit Profile functionality
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Info Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _infoCard(
                      icon: Icons.person,
                      label: "Name",
                      value: user!['name'],
                    ),
                    const SizedBox(height: 15),
                    _infoCard(
                      icon: Icons.email,
                      label: "Email",
                      value: user!['email'],
                    ),
                    const SizedBox(height: 15),
                    _infoCard(
                      icon: Icons.calendar_today,
                      label: "Joined",
                      value: user!['created_at'],
                    ),
                    const SizedBox(height: 30),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.redAccent,
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () async {
                          await ApiService.logout();
                          setState(() => user = null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable info card widget (Black + Red theme)
  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.redAccent, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:examtrack/services/api_service.dart';
// import 'package:flutter/material.dart';

// class ProfileScreen extends StatefulWidget {
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   Map<String, dynamic>? user;

//   @override
//   void initState() {
//     super.initState();
//     loadProfile();
//   }

//   void loadProfile() async {
//     final profile = await ApiService.getProfile();
//     setState(() => user = profile);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (user == null) {
//       return Scaffold(
//         body: Center(
//           child: Text(
//             "Please login to view your profile",
//             style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // User Name + Email
//             Text(
//               user!['name'],
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               user!['email'],
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 25),

//             // Info Card
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(18),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.person, color: Colors.blue),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             "Name: ${user!['name']}",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 25),
//                     Row(
//                       children: [
//                         const Icon(Icons.email, color: Colors.blue),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             "Email: ${user!['email']}",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 25),
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today, color: Colors.blue),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             "Joined: ${user!['created_at']}",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Logout Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   backgroundColor: Colors.red,
//                 ),
//                 icon: const Icon(Icons.logout),
//                 label: const Text("Logout", style: TextStyle(fontSize: 18)),
//                 onPressed: () async {
//                   await ApiService.logout();
//                   setState(() => user = null);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
