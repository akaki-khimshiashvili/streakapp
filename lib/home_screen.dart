import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:streakapp/activity/activity_model.dart';
import 'package:streakapp/activity/activity_service.dart';
import 'package:streakapp/widgets/activity_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive column count
    final int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 1; // phone → full width cards
    } else if (screenWidth < 900) {
      crossAxisCount = 2; // tablet portrait → 2 columns
    } else {
      crossAxisCount = 3; // tablet landscape / desktop → 3 columns
    }

    return SafeArea(
      bottom: false,
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
              child: user == null
                  ? const Center(child: Text('Not signed in'))
                  : StreamBuilder<List<Activity>>(
                      stream: ActivityService.watchActivities(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1A1A2E),
                              strokeWidth: 2,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final activities = snapshot.data ?? [];

                        if (activities.isEmpty) {
                          return _buildEmptyState();
                        }

                        if (crossAxisCount == 1) {
                          // Phone: simple ListView, full-width cards
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: activities.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return CustomSquareWidget(
                                activity: activities[index],
                              );
                            },
                          );
                        }

                        // Tablet / desktop: responsive grid
                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.2,
                              ),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            return CustomSquareWidget(
                              activity: activities[index],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD4B8).withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No activities yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the play button below to\ncreate your first streak',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
