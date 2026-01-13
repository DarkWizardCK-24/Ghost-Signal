import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';

class CaesarScreen extends StatefulWidget {
  const CaesarScreen({super.key});

  @override
  State<CaesarScreen> createState() => _CaesarScreenState();
}

class _CaesarScreenState extends State<CaesarScreen> {
  final TextEditingController _inputController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _crackCipher() async {
    if (_inputController.text.isEmpty) {
      _showSnackBar('Please enter encrypted text', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _results = [];
    });

    try {
      final response = await ApiService.crackCaesar(_inputController.text);
      setState(() {
        _results = List<Map<String, dynamic>>.from(response['shifts'] ?? []);
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard!');
  }

  Color _getScoreColor(double score) {
    if (score > 0.3) return AppTheme.neonGreen;
    if (score > 0.15) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).size.width * 0.05;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Caesar Cipher Cracker',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.neonPurple,
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
              AppTheme.neonPurple.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenPadding),
              child: Column(
                children: [
                  _buildInputSection(),
                  const SizedBox(height: 16),
                  _buildActionButton(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _results.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList(screenPadding),
            ),
          ],
        ),
      ),
    );
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
              Icon(Icons.vpn_key, color: AppTheme.neonPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Enter Encrypted Text',
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
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter text encrypted with Caesar cipher...',
              hintStyle: GoogleFonts.inter(color: Colors.grey),
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
        onPressed: _isLoading ? null : _crackCipher,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology, color: Colors.black),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Crack Cipher (Brute Force)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter encrypted text above\nto crack Caesar cipher',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(double screenPadding) {
    return ListView.builder(
      padding: EdgeInsets.all(screenPadding),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        final shift = result['shift'];
        final text = result['text'];
        final score = (result['score'] ?? 0.0).toDouble();
        final isTopResult = index == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTopResult
                  ? AppTheme.neonGreen
                  : _getScoreColor(score).withOpacity(0.3),
              width: isTopResult ? 2 : 1,
            ),
            boxShadow: isTopResult
                ? [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Shift $shift',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score),
                          ),
                        ),
                      ),
                      if (isTopResult)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppTheme.neonGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Best Match',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neonGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(score * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        color: Colors.grey,
                        onPressed: () => _copyToClipboard(text),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}