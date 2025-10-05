import 'package:climatrack/views/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'webview_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Accurate Rain Predictions',
      description:
          'Get precise rainfall probability forecasts for your event location and timing.',
      image: 'assets/images/forecast.png',
    ),
    OnboardingPage(
      title: 'Event Risk Assessment',
      description:
          'Analyze weather risks and make informed decisions for your outdoor events.',
      image: 'assets/images/risk.png',
    ),
    OnboardingPage(
      title: 'Real-time Updates',
      description:
          'Stay informed with live weather updates and alerts for your event.',
      image: 'assets/images/updates.png',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onIntroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url:
              'https://climatrack-flame.vercel.app/', // Replace with your actual URL
          title: 'ClimaTrack',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView.builder(
          controller: controller,
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == pages.length - 1;
            });
          },
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(pages[index].image, height: 400, fit: BoxFit.cover),
                const SizedBox(height: 32),
                Text(
                  pages[index].title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    pages[index].description,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[50]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 80,

        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text('Skip', style: TextStyle(color: Colors.white)),
              onPressed: _onIntroCompleted,
            ),
            Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: WormEffect(
                  spacing: 16,
                  dotColor: AppColors.primary.withOpacity(0.5),
                  activeDotColor: Theme.of(context).primaryColor,
                ),
                onDotClicked: (index) => controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                ),
              ),
            ),
            TextButton(
              child: Text(
                isLastPage ? 'Start' : 'Next',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: isLastPage
                  ? _onIntroCompleted
                  : () => controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}
