import 'package:flutter/material.dart';

class ExamTile extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final double height;

  const ExamTile({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.height = 100, // thoda bada height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
          color: Colors.black12,
        ),
        child: Row(
          children: [
            // Image upar nahi balki left me, home screen style ke liye vertical alignment
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.auto_stories, color: Colors.white);
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
