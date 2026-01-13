import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../themes/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';

class SteganographyScreen extends StatefulWidget {
  const SteganographyScreen({super.key});

  @override
  State<SteganographyScreen> createState() => _SteganographyScreenState();
}

class _SteganographyScreenState extends State<SteganographyScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  bool _isLoading = false;
  bool _isHiding = true;
  String _selectedMode = 'advanced_jigsaw';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  final Map<String, Map<String, String>> _modes = {
    'last_word': {
      'name': 'Last Word',
      'icon': '📝',
      'security': 'Low',
      'description': 'Message hidden in last word of each line'
    },
    'first_letter': {
      'name': 'First Letter',
      'icon': '🔤',
      'security': 'Low',
      'description': 'First letter of each line spells message'
    },
    'jigsaw': {
      'name': 'Jigsaw Pattern',
      'icon': '🧩',
      'security': 'Medium',
      'description': 'Diagonal pattern: 1st word, 2nd word, 3rd word...'
    },
    'advanced_jigsaw': {
      'name': 'Advanced Jigsaw',
      'icon': '🎯',
      'security': 'High',
      'description': 'Variable sentence structures with noise'
    },
    'semantic_scatter': {
      'name': 'Semantic Scatter',
      'icon': '🌌',
      'security': 'Maximum',
      'description': 'Pattern: Position = 15 + (N × 35). Undetectable!'
    },
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _processInput() async {
    if (_inputController.text.isEmpty) {
      _showSnackBar('Please enter some text', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _output = '';
    });

    _slideController.reset();

    try {
      final response = _isHiding
          ? await ApiService.hideMessage(_inputController.text, _selectedMode)
          : await ApiService.extractMessage(_inputController.text, _selectedMode);

      setState(() {
        _output = _isHiding ? response['result'] : response['message'];
        _isLoading = false;
      });

      _slideController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}', isError: true);
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

  void _copyToClipboard() {
    if (_output.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _output));
      _showSnackBar('Copied to clipboard!');
    }
  }

  void _shareMessage() {
    if (_output.isNotEmpty) {
      Share.share(_output, subject: 'Secret Message from GhostSignal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Steganography',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.neonBlue,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              AppTheme.neonBlue.withOpacity(0.05),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildModeToggle(),
                const SizedBox(height: 20),
                _buildMethodSelector(),
                const SizedBox(height: 20),
                _buildInputSection(),
                const SizedBox(height: 20),
                _buildActionButton(),
                const SizedBox(height: 20),
                if (_output.isNotEmpty) _buildOutputSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: AppTheme.glowingContainer(),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Hide Message',
              _isHiding,
              () => setState(() {
                _isHiding = true;
                _output = '';
              }),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              'Extract Message',
              !_isHiding,
              () => setState(() {
                _isHiding = false;
                _output = '';
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.neonBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.neonBlue.withOpacity(0.3 + (_glowAnimation.value * 0.3)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.2 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: AppTheme.neonBlue, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Encoding Method',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._modes.entries.map((entry) => _buildMethodCard(entry.key, entry.value)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMethodCard(String key, Map<String, String> info) {
    final isSelected = _selectedMode == key;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonBlue.withOpacity(0.1) : AppTheme.accentDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.neonBlue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonBlue : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                info['icon']!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          info['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.neonBlue : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getSecurityColor(info['security']!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getSecurityColor(info['security']!),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          info['security']!,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _getSecurityColor(info['security']!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    info['description']!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.neonBlue, size: 24),
          ],
        ),
      ),
    );
  }

  Color _getSecurityColor(String security) {
    switch (security) {
      case 'Low':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow;
      case 'High':
        return AppTheme.neonGreen;
      case 'Maximum':
        return AppTheme.neonPurple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowingContainer(color: AppTheme.neonPurple),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, color: AppTheme.neonPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isHiding ? 'Secret Message' : 'Story with Hidden Message',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: _isHiding ? 3 : 8,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: _isHiding
                  ? 'Type your secret message...'
                  : 'Paste the story containing hidden message...',
              hintStyle: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _processInput,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.neonBlue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const LoadingIndicator(size: 24, color: Colors.black)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isHiding ? Icons.hide_source : Icons.search,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  _isHiding ? 'Hide in Story' : 'Extract Message',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOutputSection() {
    final modeInfo = _modes[_selectedMode]!;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glowingContainer(color: AppTheme.neonGreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 24),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _isHiding ? 'Story Generated' : 'Extracted Message',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        color: AppTheme.neonGreen,
                        onPressed: _copyToClipboard,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (_isHiding) const SizedBox(width: 8),
                      if (_isHiding)
                        IconButton(
                          icon: const Icon(Icons.share, size: 20),
                          color: AppTheme.neonGreen,
                          onPressed: _shareMessage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  _output,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              if (_isHiding) ...[
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple.withOpacity(0.1 * _glowAnimation.value),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.neonPurple.withOpacity(0.3 * _glowAnimation.value),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppTheme.neonPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Encoding Details',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neonPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Method: ${modeInfo['name']} ${modeInfo['icon']}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            modeInfo['description']!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          if (_selectedMode == 'semantic_scatter') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.neonBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppTheme.neonBlue.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🔍 Extraction Pattern',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.neonBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Base: 15 | Interval: 35',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Text(
                                    'Word N at position: 15 + (N × 35)',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 9,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Security: ',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getSecurityColor(modeInfo['security']!).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getSecurityColor(modeInfo['security']!),
                                  ),
                                ),
                                child: Text(
                                  modeInfo['security']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getSecurityColor(modeInfo['security']!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}