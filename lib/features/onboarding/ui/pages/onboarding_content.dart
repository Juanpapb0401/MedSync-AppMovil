import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../components/components.dart';

class _SlideData {
  final String svgAsset;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
  });
}

const _slides = [
  _SlideData(
    svgAsset: 'assets/images/onboarding/slide1.svg',
    title: '¿Olvidaste cómo tomar tu medicamento?',
    subtitle: 'MedSync te recuerda cada toma en el momento exacto, sin que tengas que preocuparte.',
  ),
  _SlideData(
    svgAsset: 'assets/images/onboarding/slide2.svg',
    title: 'Tu cuidador lo organiza todo',
    subtitle: 'El cuidador configura horarios y dosis para que tú solo confirmes cada toma.',
  ),
  _SlideData(
    svgAsset: 'assets/images/onboarding/slide3.svg',
    title: 'Tu celular te avisa en el momento exacto',
    subtitle: 'Alarmas precisas y recordatorios para que nunca olvides ninguna toma.',
  ),
];

class OnboardingContent extends StatefulWidget {
  const OnboardingContent({super.key});

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth/login');
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _slides.length - 1;

    return Column(
      children: [
        // Botón Saltar
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLast)
                TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Saltar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Slides
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _OnboardingSlide(data: _slides[i]),
          ),
        ),
        // Dots de progreso
        OnboardingProgressDots(
          count: _slides.length,
          currentIndex: _currentIndex,
        ),
        const SizedBox(height: 24),
        // Botón principal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: MedSyncButton(
            label: isLast ? 'Comenzar' : 'Siguiente',
            onPressed: isLast ? _finish : _next,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _SlideData data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            data.svgAsset,
            width: 260,
            height: 220,
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
