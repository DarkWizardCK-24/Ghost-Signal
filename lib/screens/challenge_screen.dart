import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../themes/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final TextEditingController _answerController = TextEditingController();
  Map<String, dynamic>? _currentChallenge;
  bool _isLoading = false;
  bool _isStarted = false;
  int _timeElapsed = 0;
  Timer? _timer;
  bool _isCompleted = false;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _loadScore() {
    // In a real app, load from local storage
    setState(() => _totalScore = 0);
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);

    try {
      final challenge = await ApiService.getDailyChallenge();
      setState(() {
        _currentChallenge = challenge;
        _isLoading = false;
        _isStarted = true;
        _isCompleted = false;
        _timeElapsed = 0;
      });
      _startTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading challenge: ${e.toString()}', isError: true);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _timeElapsed++);
    });
  }

  void _checkAnswer() {
    if (_answerController.text.isEmpty) {
      _showSnackBar('Please enter your answer', isError: true);
      return;
    }

    final userAnswer = _answerController.text.trim().toUpperCase();
    final correctAnswer = _currentChallenge?['answer']?.toString().toUpperCase() ?? '';

    if (userAnswer == correctAnswer) {
      _timer?.cancel();
      final points = _currentChallenge?['points'] ?? 0;
      final timeBonus = _timeElapsed < 30 ? 50 : _timeElapsed < 60 ? 25 : 0;
      final totalPoints = ((points as num) + timeBonus).toInt();

      setState(() {
        _isCompleted = true;
        _totalScore += totalPoints;
      });

      _showSuccessDialog(totalPoints, timeBonus);
    } else {
      _showSnackBar('Incorrect! Try again', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.neonPink : AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(int points, int timeBonus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.neonGreen, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: AppTheme.neonGreen, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Challenge Complete!',
                style: GoogleFonts.inter(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Congratulations!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildScoreItem('Challenge Points', _currentChallenge?['points'] ?? 0),
              if (timeBonus > 0) _buildScoreItem('Speed Bonus', timeBonus),
              const Divider(color: Colors.grey, height: 30),
              _buildScoreItem('Total Earned', points, isTotal: true),
              const SizedBox(height: 10),
              Text(
                'Time: ${_formatTime(_timeElapsed)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentChallenge = null;
                _isStarted = false;
                _answerController.clear();
              });
            },
            child: Text(
              'Done',
              style: GoogleFonts.inter(
                color: AppTheme.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int points, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.neonGreen : Colors.white,
              ),
            ),
          ),
          Text(
            '+$points',
            style: GoogleFonts.inter(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppTheme.neonGreen : AppTheme.neonBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  Color _getDifficultyLabelColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.neonGreen;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return AppTheme.neonPink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Challenge',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.neonPink,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.neonPink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neonPink, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: AppTheme.neonPink,
                  size: isSmallScreen ? 16 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_totalScore',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonPink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              AppTheme.neonPink.withOpacity(0.05),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : !_isStarted
                ? _buildStartScreen()
                : _buildChallengeScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 30 : 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.neonPink, AppTheme.neonPurple],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPink.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events,
                size: isSmallScreen ? 60 : 80,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Daily Challenge',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 24 : 32,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.neonPink, AppTheme.neonPurple],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Test your code-breaking skills\nwith timed morse puzzles',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPink,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 32 : 48,
                    vertical: isSmallScreen ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: isSmallScreen ? 24 : 28,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Start Challenge',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeScreen() {
    final difficulty = _currentChallenge?['difficulty'] ?? 'medium';
    final morse = _currentChallenge?['morse'] ?? '';
    final points = _currentChallenge?['points'] ?? 0;
    final screenPadding = MediaQuery.of(context).size.width * 0.05;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimerCard(),
          const SizedBox(height: 20),
          _buildInfoCard(difficulty, points),
          const SizedBox(height: 20),
          _buildMorseCard(morse),
          const SizedBox(height: 20),
          _buildAnswerSection(),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowingContainer(color: AppTheme.neonPink),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.timer, color: AppTheme.neonPink, size: 28),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Time',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(_timeElapsed),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.neonPink,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String difficulty, int points) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowingContainer(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Difficulty',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyLabelColor(difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDifficultyLabelColor(difficulty),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _getDifficultyColor(difficulty),
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyLabelColor(difficulty),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 2,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Points',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$points',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorseCard(String morse) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glowingContainer(color: AppTheme.neonBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq, color: AppTheme.neonBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Decode This',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              morse,
              style: GoogleFonts.robotoMono(
                fontSize: isSmallScreen ? 16 : 20,
                color: Colors.white,
                height: 1.8,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glowingContainer(color: AppTheme.neonGreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Answer',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonGreen,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _answerController,
                enabled: !_isCompleted,
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter decoded message...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                ),
                onSubmitted: (_) => _checkAnswer(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!_isCompleted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.black,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Submit Answer',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}