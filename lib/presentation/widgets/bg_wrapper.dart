import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover, // Fills the whole screen
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Important: Makes Scaffold see-through
        body: SafeArea(child: child),
      ),
    );
  }
}