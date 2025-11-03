import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // function to open URL
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Disclaimer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: const [
                  Icon(Icons.info_outline, size: 80, color: Colors.redAccent),
                  SizedBox(height: 10),
                  Text(
                    'RankYard - Exam Prep App',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'One App for All Competitive Exams',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Disclaimer:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This app is not an official government app. It is created only for educational and exam preparation purposes. '
              'All information about exams such as CET, Banking, CLAT, UGC NET, etc. is collected from official government or '
              'exam-conducting websites. We do not represent any government entity.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Official Sources:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('UGC NET Official Site'),
              subtitle: const Text('https://ugcnet.nta.ac.in'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://ugcnet.nta.ac.in'),
            ),
            ListTile(
              title: const Text('HPSC Official Site'),
              subtitle: const Text('https://hpsc.gov.in'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://hpsc.gov.in'),
            ),
            ListTile(
              title: const Text('UPSC Official Site'),
              subtitle: const Text('https://upsc.gov.in'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://upsc.gov.in'),
            ),
            ListTile(
              title: const Text('NTA Official Site'),
              subtitle: const Text('https://nta.ac.in'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://nta.ac.in'),
            ),
          ],
        ),
      ),
    );
  }
}
