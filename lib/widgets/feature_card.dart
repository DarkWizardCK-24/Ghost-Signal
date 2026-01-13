import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust padding based on available width
            final horizontalPadding = constraints.maxWidth > 150 ? 20.0 : 12.0;
            final verticalPadding = constraints.maxHeight > 150 ? 20.0 : 12.0;
            final iconSize = constraints.maxWidth > 150 ? 32.0 : 24.0;
            final titleFontSize = constraints.maxWidth > 150 ? 16.0 : 14.0;
            final subtitleFontSize = constraints.maxWidth > 150 ? 12.0 : 10.0;
            
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradient.map((c) => c.withOpacity(0.1)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.gradient[0].withOpacity(_isPressed ? 0.8 : 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient[0].withOpacity(_isPressed ? 0.5 : 0.2),
                    blurRadius: _isPressed ? 30 : 20,
                    spreadRadius: _isPressed ? 4 : 2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(constraints.maxWidth > 120 ? 8 : 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient[0].withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: iconSize,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight > 120 ? 8 : 2),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: subtitleFontSize,
                        color: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}