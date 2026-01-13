import 'package:flutter/material.dart';
import 'package:ghost_signal/screens/challenge_screen.dart';
import 'package:ghost_signal/themes/app_theme.dart';
import 'package:ghost_signal/widgets/feature_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'morse_screen.dart';
import 'caesar_screen.dart';
import 'steganography_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkBg,
              AppTheme.darkBg,
              AppTheme.neonGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        _buildWelcomeCard(),
                        const SizedBox(height: 30),
                        _buildFeaturesGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 20,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.neonGreen, AppTheme.neonBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonGreen.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.radar, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              'GhostSignal',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.neonGreen, AppTheme.neonBlue],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glowingContainer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.neonGreen, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Secret Message Decoder',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Crack codes, decode messages, and send secret communications. Your gateway to the world of cryptography.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final availableWidth = screenWidth - (horizontalPadding * 2);

    // Calculate crossAxisCount based on screen width
    int crossAxisCount = 2;
    if (availableWidth > 600) {
      crossAxisCount = 3;
    }
    if (availableWidth < 400) {
      crossAxisCount = 1;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 1 ? 2.5 : 0.85,
          children: [
            FeatureCard(
              title: 'Morse Code',
              subtitle: 'Auto Decoder',
              icon: Icons.graphic_eq,
              gradient: const [AppTheme.neonGreen, AppTheme.neonBlue],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MorseScreen()),
                );
              },
            ),
            FeatureCard(
              title: 'Caesar Cipher',
              subtitle: 'Brute Force',
              icon: Icons.lock_clock,
              gradient: const [AppTheme.neonPurple, AppTheme.neonPink],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CaesarScreen()),
                );
              },
            ),
            FeatureCard(
              title: 'Steganography',
              subtitle: 'Hide Messages',
              icon: Icons.hide_source,
              gradient: const [AppTheme.neonBlue, AppTheme.neonPurple],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SteganographyScreen(),
                  ),
                );
              },
            ),
            FeatureCard(
              title: 'Challenges',
              subtitle: 'Daily Puzzles',
              icon: Icons.emoji_events,
              gradient: const [AppTheme.neonPink, AppTheme.neonGreen],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengeScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
