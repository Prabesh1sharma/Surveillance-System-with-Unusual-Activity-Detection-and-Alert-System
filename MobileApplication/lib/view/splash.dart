import 'package:flutter/material.dart';
import 'dart:async';
import 'package:majorapp/view/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool showText = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => showText = true);
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient with glow effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC690CE), Color(0xFF8E44AD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Animated Camera Icon
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(39),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(51),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Moving Text: Starts from bottom and stops just above the camera icon
          AnimatedAlign(
            duration: const Duration(seconds: 2),
            curve: Curves.easeOut,
            alignment: showText
                ? Alignment(0.0, 0.4)
                : Alignment(
                    0.0,
                    1.0,
                  ), // Moves from bottom to just above the icon
            child: AnimatedOpacity(
              opacity: showText ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'For The Better Future',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Security & Surveillance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha(204),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
