import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Optional: for custom font
import '../screens/profile/profile_screen.dart';

class CineboxAppBar extends StatelessWidget implements PreferredSizeWidget {

  final bool showProfileButton;
  const CineboxAppBar({super.key, this.showProfileButton = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16), // Top and bottom margins
      child: AppBar(
        backgroundColor: Colors.transparent, // Keeps the background image visible
        elevation: 0,
        centerTitle: false,

        // 1. CENTER LOGO
        title: Text(
          "CINEBOX",
          style: GoogleFonts.bebasNeue( // Or your preferred font
            fontSize: 36,
            color: Colors.redAccent,
            letterSpacing: 5,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 2. RIGHT PROFILE ICON
        actions: [
          if (showProfileButton)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(0),
                child: const Icon(Icons.person, color: Colors.white, size: 36),
              ),
            ),
          const SizedBox(width: 8), // Padding from right edge
        ],
      ),
    );
  }

  // Adjust preferred size to account for the top and bottom padding
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 32); // 16 top + 16 bottom
}