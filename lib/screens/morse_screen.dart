import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';

class MorseScreen extends StatefulWidget {
  const MorseScreen({super.key});

  @override
  State<MorseScreen> createState() => _MorseScreenState();
}

class _MorseScreenState extends State<MorseScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  bool _isLoading = false;
  bool _isEncoding = false;
  double _confidence = 0.0;

  @override
  void dispose() {
    _inputController.dispose();
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

    try {
      final response = _isEncoding
          ? await ApiService.encodeMorse(_inputController.text)
          : await ApiService.decodeMorse(_inputController.text);

      setState(() {
        if (_isEncoding) {
          _output = response['morse'] ?? '';
          _confidence = 1.0;
        } else {
          _output = response['decoded'] ?? '';
          _confidence = response['confidence']?.toDouble() ?? 0.0;
        }
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).size.width * 0.05;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Morse Code',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.neonGreen,
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
              AppTheme.neonGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModeToggle(),
              const SizedBox(height: 24),
              _buildInputSection(),
              const SizedBox(height: 24),
              _buildActionButton(),
              const SizedBox(height: 24),
              if (_output.isNotEmpty) _buildOutputSection(),
            ],
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
              'Decode',
              !_isEncoding,
              () => setState(() {
                _isEncoding = false;
                _output = '';
              }),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              'Encode',
              _isEncoding,
              () => setState(() {
                _isEncoding = true;
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
          color: isActive ? AppTheme.neonGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? AppTheme.darkBg : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowingContainer(color: AppTheme.neonBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: AppTheme.neonBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isEncoding ? 'Enter Text' : 'Enter Morse Code',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: _isEncoding
                  ? 'Type your message...'
                  : 'Enter morse code (. - /)',
              hintStyle: GoogleFonts.inter(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.neonBlue.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processInput,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const LoadingIndicator(size: 24)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isEncoding ? Icons.lock : Icons.lock_open,
                    color: AppTheme.darkBg,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isEncoding ? 'Encode Message' : 'Decode Message',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBg,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOutputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowingContainer(color: AppTheme.neonPurple),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.neonPurple, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Result',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neonPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                color: AppTheme.neonPurple,
                onPressed: _copyToClipboard,
              ),
            ],
          ),
          if (!_isEncoding) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                Text(
                  'Confidence: ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  '${(_confidence * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _confidence > 0.7
                        ? AppTheme.neonGreen
                        : _confidence > 0.4
                            ? Colors.orange
                            : AppTheme.neonPink,
                  ),
                ),
              ],
            ),
          ],
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
        ],
      ),
    );
  }
}