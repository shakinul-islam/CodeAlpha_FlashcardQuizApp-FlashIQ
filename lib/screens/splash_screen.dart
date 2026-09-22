import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ৩.৫ সেকেন্ড পর মেইন স্ক্রিনে স্মুথ ফেড ট্রানজিশন
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3748);
    final primaryColor = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ১. App Logo with Premium Glow/Shadow
              Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(isDark ? 0.2 : 0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        // লোগো না থাকলে নিচের আইকনটি ফলব্যাক হিসেবে কাজ করবে (টেস্টিং এর জন্য)
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 130,
                          height: 130,
                          color: primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.style_rounded,
                            size: 60,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 800.ms)
                  .shimmer(
                    duration: 1200.ms,
                    delay: 800.ms,
                    color: Colors.white24,
                  ),

              const SizedBox(height: 30),

              // ২. App Name (Modern Typography)
              Text(
                    'Flash Quiz',
                    style: GoogleFonts.outfit(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: textColor,
                    ),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 10),

              // ৩. Subtitle
              Text(
                    'Master Your Memory',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              const Spacer(flex: 4),

              // ৪. Loading Indicator (Optional soft touch)
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryColor.withOpacity(0.7),
                  ),
                ),
              ).animate(delay: 1000.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 30),

              // ৫. Footer Text (Inter)
              Text(
                    'Made with ❤️ by Shakinul',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade500
                          : const Color(0xFF7F8C8D),
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate(delay: 1200.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
