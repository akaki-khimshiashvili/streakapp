import 'package:flutter/material.dart';
// Adjust project package name to your real pubspec app identifier
import 'package:streakapp/widgets/activity_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom:
          false, // Allows content grid scroll room under overlapping nav bounds
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Activities',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.0, // Retains uniform square templates dynamically
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Ensures trailing squares clear navbar overlap visibility
                children: const [
                  CustomSquareWidget(),
                  CustomSquareWidget(),
                  CustomSquareWidget(),
                  CustomSquareWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
