import 'package:flutter/material.dart';
import 'package:loyalty/core/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Buy & Get Stamps',
      description:
          'Lorem ipsum dolor sit amet consectetur. Velit eu urna in vel condimentum adipiscing id. Justo pretium tortor orci tempor.',
      imagePath: 'assets/onboard/step_1.png',
      floatingElements: [
        FloatingElement(
          type: FloatingElementType.button,
          text: 'Buy Now',
          position: FloatingPosition.topRight,
        ),
        FloatingElement(
          type: FloatingElementType.stampsCard,
          position: FloatingPosition.bottomLeft,
        ),
      ],
    ),
    OnboardingStep(
      title: 'Collect & Earn Rewards',
      description:
          'Lorem ipsum dolor sit amet consectetur. Velit eu urna in vel condimentum adipiscing id. Justo pretium tortor orci tempor.',
      imagePath: 'assets/onboard/all_stamps.png',
      floatingElements: [],
    ),
    OnboardingStep(
      title: 'Redeem & Enjoy',
      description:
          'Lorem ipsum dolor sit amet consectetur. Velit eu urna in vel condimentum adipiscing id. Justo pretium tortor orci tempor.',
      imagePath: 'assets/onboard/reward.png',
      floatingElements: [],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_steps[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingStep step) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main image - fills the green section
                _buildOnboardingImage(step.imagePath),
                // Floating elements
                ...step.floatingElements.map((element) =>
                    _buildFloatingElement(element)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildFloatingElement(FloatingElement element) {
    switch (element.type) {
      case FloatingElementType.button:
        return Positioned(
          top: element.position == FloatingPosition.topRight ? 80 : null,
          bottom: element.position == FloatingPosition.bottomLeft ? 180 : null,
          right: element.position == FloatingPosition.topRight ? 30 : null,
          left: element.position == FloatingPosition.bottomLeft ? 30 : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              element.text ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
          ),
        );
      case FloatingElementType.stampsCard:
        return Positioned(
          bottom: 180,
          left: 30,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Stamps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: index < 2 ? primaryColor : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: index < 2
                          ? const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    );
                  }),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildBottomSection() {
    final step = _steps[_currentPage];
    final isLastPage = _currentPage == _steps.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pagination indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            step.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Buttons
          if (isLastPage) ...[
            // Create account button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Sign in button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _completeOnboarding,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryTextColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Data models
class OnboardingStep {
  final String title;
  final String description;
  final String imagePath;
  final List<FloatingElement> floatingElements;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.floatingElements,
  });
}

class FloatingElement {
  final FloatingElementType type;
  final String? text;
  final FloatingPosition position;

  FloatingElement({
    required this.type,
    this.text,
    required this.position,
  });
}

enum FloatingElementType {
  button,
  stampsCard,
}

enum FloatingPosition {
  topRight,
  bottomLeft,
}

