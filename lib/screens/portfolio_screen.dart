import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playground/screens/windows.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'three_demo_screen.dart'; // Temporarily disabled
import 'package:http/http.dart' as http;
import 'dart:convert';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin {
  // Scroll & section keys
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _worksKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _blogsKey = GlobalKey();

  final ValueNotifier<double> bgScroll = ValueNotifier<double>(0);

  // Contact controllers
  final TextEditingController _contactName = TextEditingController();
  final TextEditingController _contactEmail = TextEditingController();
  final TextEditingController _contactSubject = TextEditingController();
  final TextEditingController _contactMessage = TextEditingController();

  // Animations
  late final AnimationController _heroController;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _heroFade;

  late final AnimationController _pulseController;
  late final AnimationController _ringController;

  // Role text switcher
  final List<String> _roles = const [
    'Flutter Developer',
    'Web Designer',
    'Mobile App Developer',
    "UI/UX Designer"
  ];
  int _roleIndex = 0;
  Timer? _roleTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      bgScroll.value = _scrollController.offset;
    });
    // existing animation init...

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _roleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _roleIndex = (_roleIndex + 1) % _roles.length;
      });
    });
  }

  @override
  void dispose() {
    _roleTimer?.cancel();
    _pulseController.dispose();
    _heroController.dispose();
    _scrollController.dispose();
    _ringController.dispose();
    _contactName.dispose();
    _contactEmail.dispose();
    _contactSubject.dispose();
    _contactMessage.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  // Responsive helper methods
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 20;
    if (_isTablet(context)) return 40;
    return 80;
  }

  double _getVerticalPadding(BuildContext context) {
    if (_isMobile(context)) return 40;
    if (_isTablet(context)) return 60;
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // 3D background (temporarily disabled)
          // Positioned.fill(
          //   child: ThreeBackground(
          //     scrollOffset: bgScroll,
          //   ),
          // ),
          // Luminous gradient glow overlay
          // const Positioned.fill(child: _LuminousGradientOverlay()),
          // Content scroll on top
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeader(),
                _buildHeroSection(),
                _buildWorksSection(),
                _buildAppsWorkedOnSection(),
                _buildSkillsSection(),
                _buildBlogsSection(),
                _buildAboutSection(),
                _buildContactSection(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildChatFab(),
    );
  }

  Widget _buildChatFab() {
    return FloatingActionButton.extended(
      onPressed: _openChatbot,
      backgroundColor: const Color(0xFFFF2D55),
      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      label: const Text('Chat', style: TextStyle(color: Colors.white)),
    );
  }

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111214),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _ChatbotSheet(),
    );
  }

  Widget _buildHeader() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      key: _homeKey,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 16 : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            width: isMobile ? 40 : 50,
            height: isMobile ? 40 : 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'HP',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Navigation Menu
          if (isMobile)
            // Mobile: Hamburger menu
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF1A1B23),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder:
                      (context) => _MobileMenu(
                        onHome: () {
                          Navigator.pop(context);
                          _scrollTo(_homeKey);
                        },
                        onAbout: () {
                          Navigator.pop(context);
                          _scrollTo(_aboutKey);
                        },
                        onSkills: () {
                          Navigator.pop(context);
                          _scrollTo(_skillsKey);
                        },
                        onProjects: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProjectsScreen(),
                            ),
                          );
                        },
                        onContact: () {
                          Navigator.pop(context);
                          _scrollTo(_contactKey);
                        },
                        onGameStore: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameStoreDashboard(),
                            ),
                          );
                        },
                      ),
                );
              },
            )
          else
            // Desktop: Full navigation
            Row(
              children: [
                _buildNavButton('Home', () => _scrollTo(_homeKey), true),
                _buildNavButton('About', () => _scrollTo(_aboutKey), false),
                _buildNavButton('Skills', () => _scrollTo(_skillsKey), false),
                _buildNavButton('Projects', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                  );
                }, false),
                _buildNavButton('Contact', () => _scrollTo(_contactKey), false),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WindowsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'VIEW GAME STORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, VoidCallback onTap, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      constraints: BoxConstraints(minHeight: isMobile ? 400 : 520),
      child:
          isMobile
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar on top for mobile
                  _buildHeroAvatar(isMobile: true),
                  const SizedBox(height: 40),
                  // Text content below
                  _buildHeroText(isMobile: true),
                ],
              )
              : Row(
                children: [
                  // Left side - Text content
                  Expanded(flex: 1, child: _buildHeroText(isMobile: false)),
                  // Right side - Decorative avatar with pulse
                  Expanded(flex: 1, child: _buildHeroAvatar(isMobile: false)),
                ],
              ),
    );
  }

  Widget _buildHeroText({required bool isMobile}) {
    return SlideTransition(
      position: _heroSlide,
      child: FadeTransition(
        opacity: _heroFade,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isMobile ? 20 : 24,
                  height: 2,
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 12),
                Text(
                  'Hello, I\'m',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Harsh Patare',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 32 : 48,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "I'm a ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 18 : 22,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder:
                      (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                  child: Text(
                    _roles[_roleIndex],
                    key: ValueKey(_roleIndex),
                    style: TextStyle(
                      color: const Color(0xFFFF7AB6),
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '|',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isMobile ? 20 : 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 14 : 18),
            Text(
              'Passionate about creating beautiful, functional, and\nuser‑friendly applications using modern technologies.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 14 : 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: isMobile ? 20 : 28),
            isMobile
                ? Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _primaryCta('Explore My Work', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProjectsScreen(),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _secondaryCta(
                        'Contact Me',
                        () => _scrollTo(_contactKey),
                      ),
                    ),
                  ],
                )
                : Row(
                  children: [
                    _primaryCta('Explore My Work', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProjectsScreen(),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    _secondaryCta('Contact Me', () => _scrollTo(_contactKey)),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAvatar({required bool isMobile}) {
    final avatarSize = isMobile ? 200.0 : 420.0;
    final ringSize = isMobile ? 180.0 : 380.0;
    final neonRingSize = isMobile ? 160.0 : 340.0;
    final glassRingSize = isMobile ? 140.0 : 300.0;
    final innerAvatarSize = isMobile ? 120.0 : 260.0;

    return Center(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft ambient glow
            Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.15),
                    const Color(0xFFFF2D55).withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.55, 1.0],
                ),
              ),
            ),
            // Rotating neon ring
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _ringController.value * 6.28318,
                  child: CustomPaint(
                    size: Size(neonRingSize, neonRingSize),
                    painter: _NeonRingPainter(
                      strokeWidth: isMobile ? 2.0 : 3.0,
                    ),
                  ),
                );
              },
            ),
            // Glass ring
            Container(
              width: glassRingSize,
              height: glassRingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.0),
              ),
            ),
            // Avatar with subtle pulse
            ScaleTransition(
              scale: _pulseController,
              child: Container(
                width: innerAvatarSize,
                height: innerAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: isMobile ? 20 : 40,
                      spreadRadius: isMobile ? 2 : 4,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/harsh.png',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stack) => Icon(
                        Icons.person,
                        color: Colors.white24,
                        size: isMobile ? 50 : 100,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryCta(String text, VoidCallback onTap) {
    return _HoverScale(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF2D55),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _secondaryCta(String text, VoidCallback onTap) {
    return _HoverScale(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildWorksSection() {
    final projects = [
      Project(
        title: 'Promptbook',
        description:
        "Browse AI-generated images and explore the exact prompts behind them.",
        badge: 'Top Rated',
        colorA: const Color(0xFF0EA5E9),
        colorB: const Color(0xFF06B6D4),
        imageAsset: 'assets/images/promptbook.png',
        githubUrl: 'https://play.google.com/store/apps/details?id=com.promptbook.app&pcampaignid=web_share',
      ),
      Project(
        title: 'Flutter web old game store',
        description:
            'A web-friendly Flutter game store dashboard with game details and Flame mini-games.',
        badge: 'Recently Added',
        colorA: const Color(0xFF10B981),
        colorB: const Color(0xFF3B82F6),
        action: ProjectAction.openGameStore,
        imageAsset: 'assets/images/game_store_web.png',
      ),
      Project(
        title: 'Car Check-In Check-Out System 🚗',
        description:
            'A check-in/out solution for car parking and handovers with QR and logs.',
        badge: 'New',
        colorA: const Color(0xFFEF4444),
        colorB: const Color(0xFFF59E0B),
        imageAsset: 'assets/images/car_checkin.png',
        githubUrl: 'https://github.com/IamHarsh02/car_checkin_system',
      ),
      Project(
        title: 'News Box',
        description:
            'News reader with categories, bookmarking, and offline reading support.',
        badge: 'New',
        colorA: const Color(0xFF6366F1),
        colorB: const Color(0xFF8B5CF6),
        imageAsset: 'assets/images/news_box.png',
        githubUrl: 'https://github.com/IamHarsh02/news_box',
      ),
      Project(
        title: 'Yo! Wallpaper App',
        description:
            'A curated wallpapers app with downloads, favorites, and dynamic theming.',
        badge: 'Top Rated',
        colorA: const Color(0xFF0EA5E9),
        colorB: const Color(0xFF06B6D4),
        imageAsset: 'assets/images/yo_wallpaper.png',
        githubUrl: 'https://github.com/IamHarsh02/yowallpaper',
      ),
      Project(
        title: 'Sports Mate Figma|App',
        description:
        "Sports-first marketplace.",
        badge: 'Top Rated',
        colorA: const Color(0xFF0EA5E9),
        colorB: const Color(0xFF06B6D4),
        imageAsset: 'assets/images/sportzmate_figma_prototype.png',
        githubUrl: 'https://www.figma.com/design/B1DBaHHfb3IcP8T0Zn4BAc/SportMate?node-id=0-1&p=f&t=rBKaPetZR0GP7Vw4-0',
      ),
      Project(
        title: 'Focus Garden App',
        description:
        "Focus Garden helps you stay productive and mindful by turning your focus time into a calming experience",
        badge: 'Top Rated',
        colorA: const Color(0xFF0EA5E9),
        colorB: const Color(0xFF06B6D4),
        imageAsset: 'assets/images/focus_garden.png',
        githubUrl: '',
      ),



    ];

    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);

    return Container(
      key: _worksKey,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'My Projects', subtitle: 'Recent works'),
          SizedBox(height: _isMobile(context) ? 30 : 60),
          ...projects.map(
            (project) => Padding(
              padding: EdgeInsets.only(bottom: _isMobile(context) ? 40 : 60),
              child: _ProjectCard(project: project),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsWorkedOnSection() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apps worked on',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          isMobile
              ? Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _openUrl(
                        "https://play.google.com/store/apps/details?id=com.ril.jiopeoplefirst&hl=en_US",
                      );
                    },
                    child: _FeaturedCard(
                      header: 'Link',
                      title:
                          'PeopleFirst(Only RIL Group) - Apps on Google Play',
                      subtitle: 'play.google.com',
                      description:
                          "PeopleFirst mobile app is a Reliance Industries Limited's (RIL) own Employee Centric app; a single point of contact between you and your HRBP. It allows you to access your HR data on mobile devices, anytime, anywhere (exclusively for Reliance employees).",
                      kind: FeaturedKind.link,
                      imageAsset: 'assets/images/peoplefirst.png',
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _openUrl(
                        "https://play.google.com/store/apps/details?id=com.ipl.delhi&hl=en_US",
                      );
                    },
                    child: _FeaturedCard(
                      header: 'Link',
                      title: '🚀 DC Fan Sabha',
                      subtitle: 'play.google.com',
                      description:
                          '🚀 Want a slice of what goes on inside Delhi Capitals? With the official Delhi Capitals app, you can now keep a close eye on your favourite DC stars. Get your hands on exclusive content, on and off the field \n The Delhi Capitals app gives you access to:\n 1. Live scores: Stay updated whenever Delhi Capitals are in action, no matter where you are! \n 2 Player updates: Passionate about the DC boys? We have got you covered with their updated profile player statistics and all their activities – across the globe, round the year. \n 3. Sneak peaks: Ever wondered what goes behind the show on field? Now, you can look inside the Delhi Capitals practice sessions and enjoy all the behind the scenes footages. \n 4. Delhi Capitals tickets: Get your tickets of Delhi Capitals matches and cheer for our boys from the stands in IPL. \n 5. Delhi Capitals merchandise: Wear the colours of Delhi Capitals with pride! Get yourself the official Delhi Capitals gear, and sport them like a true fan!6. Exclusive photos and videos: Browse pictures and videos of your favourite DC stars, on and off the field. \n kind: FeaturedKind.article',
                      kind: FeaturedKind.link,
                      imageAsset: 'assets/images/dc_fansabha.png',
                    ),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _openUrl(
                          "https://play.google.com/store/apps/details?id=com.ril.jiopeoplefirst&hl=en_US",
                        );
                      },
                      child: _FeaturedCard(
                        header: 'Link',
                        title:
                            'PeopleFirst(Only RIL Group) - Apps on Google Play',
                        subtitle: 'play.google.com',
                        description:
                            "PeopleFirst mobile app is a Reliance Industries Limited's (RIL) own Employee Centric app; a single point of contact between you and your HRBP. It allows you to access your HR data on mobile devices, anytime, anywhere (exclusively for Reliance employees).",
                        kind: FeaturedKind.link,
                        imageAsset: 'assets/images/peoplefirst.png',
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _openUrl(
                          "https://play.google.com/store/apps/details?id=com.ipl.delhi&hl=en_US",
                        );
                      },
                      child: _FeaturedCard(
                        header: 'Link',
                        title: '🚀 DC Fan Sabha',
                        subtitle: 'play.google.com',
                        description:
                            '🚀 Want a slice of what goes on inside Delhi Capitals? With the official Delhi Capitals app, you can now keep a close eye on your favourite DC stars. Get your hands on exclusive content, on and off the field \n The Delhi Capitals app gives you access to:\n 1. Live scores: Stay updated whenever Delhi Capitals are in action, no matter where you are! \n 2 Player updates: Passionate about the DC boys? We have got you covered with their updated profile player statistics and all their activities – across the globe, round the year. \n 3. Sneak peaks: Ever wondered what goes behind the show on field? Now, you can look inside the Delhi Capitals practice sessions and enjoy all the behind the scenes footages. \n 4. Delhi Capitals tickets: Get your tickets of Delhi Capitals matches and cheer for our boys from the stands in IPL. \n 5. Delhi Capitals merchandise: Wear the colours of Delhi Capitals with pride! Get yourself the official Delhi Capitals gear, and sport them like a true fan!6. Exclusive photos and videos: Browse pictures and videos of your favourite DC stars, on and off the field. \n kind: FeaturedKind.article',
                        kind: FeaturedKind.link,
                        imageAsset: 'assets/images/dc_fansabha.png',
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {}
  }

  Widget _buildBlogsSection() {
    final items = [
      BlogItem(
        title:
            'Flutter to Kotlin Multiplatform (KMM): A UI Widget Translation Guide',
        subtitle:
            "Introduction  If you’re a Flutter developer thinking about going native—or a native Android/iOS developer exploring Kotlin...",
      ),
      BlogItem(
        title: 'Why AI 🤖 is Powerful But We Shouldn’t Stop Thinking 🧠',
        subtitle: '“Is AI the Future? Navigating Tomorrow’s Intelligent World”',
      ),
      BlogItem(
        title: 'Books and the Mind: Exploring the Profound Impact of Reading',
        subtitle: '“A reader lives a thousand lives before he dies...”',
      ),
      BlogItem(
        title:
            'Flutter vs Jetpack Compose: Which UI Framework is Right for You?',
        subtitle:
            'When it comes to building apps with stunning, user‑friendly interfaces...',
      ),
    ];

    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      key: _blogsKey,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal blogs',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            height: isMobile ? 160 : 180,
            child: _AutoScrollList(items: items, onTap: _openMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _openMedium() async {
    final uri = Uri.parse('https://medium.com/@patareharsh');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {}
  }

  Widget _buildGameIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildSkillsSection() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);

    return Container(
      key: _skillsKey,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        children: [
          const _SectionHeader(title: 'My Skills', subtitle: 'What I can do'),
          SizedBox(height: isMobile ? 20 : 30),
          isMobile
              ? Column(
                children: const [
                  _SkillBar(label: 'Flutter', value: 0.85, delayMs: 0),
                  _SkillBar(label: 'Dart', value: 0.8, delayMs: 150),
                  _SkillBar(label: 'Firebase', value: 0.75, delayMs: 300),
                  _SkillBar(label: 'REST APIs', value: 0.8, delayMs: 450),
                  _SkillBar(label: 'UI/UX/Figma', value: 0.7, delayMs: 600),
                  _SkillBar(label: 'Kotlin', value: 0.6, delayMs: 750),
                  _SkillBar(label: 'Swift Ui', value: 0.6, delayMs: 900),
                  _SkillBar(label: 'SQL', value: 0.65, delayMs: 1050),
                  _SkillBar(
                    label: 'React/React Native',
                    value: 0.55,
                    delayMs: 1200,
                  ),
                  _SkillBar(label: 'Python', value: 0.6, delayMs: 1350),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        _SkillBar(label: 'Flutter', value: 0.85, delayMs: 0),
                        _SkillBar(label: 'Dart', value: 0.8, delayMs: 150),
                        _SkillBar(label: 'Firebase', value: 0.75, delayMs: 300),
                        _SkillBar(label: 'REST APIs', value: 0.8, delayMs: 450),
                        _SkillBar(
                          label: 'UI/UX/Figma',
                          value: 0.7,
                          delayMs: 600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: const [
                        _SkillBar(label: 'Kotlin', value: 0.6, delayMs: 0),
                        _SkillBar(label: 'Swift Ui', value: 0.6, delayMs: 150),
                        _SkillBar(label: 'SQL', value: 0.65, delayMs: 300),
                        _SkillBar(
                          label: 'React/React Native',
                          value: 0.55,
                          delayMs: 450,
                        ),
                        _SkillBar(label: 'Python', value: 0.6, delayMs: 600),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);

    return Container(
      key: _aboutKey,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child:
          isMobile
              ? Column(
                children: [
                  // Text on top for mobile
                  _StaggerFadeIn(
                    delayMs: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, I\'m Harsh.\nFlutter Developer.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "with 3 years of professional experience in Flutter. Lives in Thane, India, I specialized in crafting seamless, high-performance apps for both Android and iOS platforms. Passionate about creating intuitive and impactful user experiences, I'm always eager to learn and innovate in the ever-evolving world of mobile development",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Profile image placeholder below
                  _StaggerFadeIn(
                    delayMs: 200,
                    child: Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white30,
                                size: 60,
                              ),
                            ),
                          ),
                          ..._buildFloatingIcons(isMobile: true),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  // Left side - Text
                  Expanded(
                    flex: 1,
                    child: _StaggerFadeIn(
                      delayMs: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hi, I\'m Harsh.\nFlutter Developer.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "with 3 years of professional experience in Flutter. Lives in Thane, India, I specialized in crafting seamless, high-performance apps for both Android and iOS platforms. Passionate about creating intuitive and impactful user experiences, I'm always eager to learn and innovate in the ever-evolving world of mobile development",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right side - Profile image placeholder
                  Expanded(
                    flex: 1,
                    child: _StaggerFadeIn(
                      delayMs: 200,
                      child: Container(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Container(
                              width: 300,
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white30,
                                  size: 80,
                                ),
                              ),
                            ),
                            ..._buildFloatingIcons(isMobile: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  List<Widget> _buildFloatingIcons({required bool isMobile}) {
    if (isMobile) {
      return [
        Positioned(
          top: 10,
          right: -5,
          child: _buildTechIcon(Icons.android, Colors.green),
        ),
        Positioned(
          top: 40,
          right: 30,
          child: _buildTechIcon(Icons.computer, Colors.blue),
        ),
        Positioned(
          top: 80,
          left: -5,
          child: _buildTechIcon(Icons.phone_android, Colors.orange),
        ),
        Positioned(
          bottom: 60,
          left: 10,
          child: _buildTechIcon(Icons.web, Colors.purple),
        ),
        Positioned(
          bottom: 10,
          right: 15,
          child: _buildTechIcon(Icons.code, Colors.yellow),
        ),
      ];
    }
    return [
      Positioned(
        top: 20,
        right: -10,
        child: _buildTechIcon(Icons.android, Colors.green),
      ),
      Positioned(
        top: 60,
        right: 50,
        child: _buildTechIcon(Icons.computer, Colors.blue),
      ),
      Positioned(
        top: 120,
        left: -10,
        child: _buildTechIcon(Icons.phone_android, Colors.orange),
      ),
      Positioned(
        bottom: 100,
        left: 20,
        child: _buildTechIcon(Icons.web, Colors.purple),
      ),
      Positioned(
        bottom: 20,
        right: 30,
        child: _buildTechIcon(Icons.code, Colors.yellow),
      ),
    ];
  }

  Widget _buildTechIcon(IconData icon, Color color) {
    return ScaleTransition(
      scale: _pulseController,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildContactSection() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);
    final verticalPadding = _getVerticalPadding(context);

    return Container(
      key: _contactKey,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Get In Touch',
            subtitle: "Let's work together",
          ),
          SizedBox(height: isMobile ? 20 : 24),
          isMobile
              ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContactLine(
                          icon: Icons.place,
                          label: 'Location',
                          value: 'Mumbai, India',
                        ),
                        SizedBox(height: 12),
                        _ContactLine(
                          icon: Icons.email,
                          label: 'Email',
                          value: 'patareharsh@gmail.com',
                        ),
                        SizedBox(height: 12),
                        _ContactLine(
                          icon: Icons.call,
                          label: 'Call',
                          value: '+91 9702180830',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        _TextField(controller: _contactName, hint: 'Your Name'),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _contactEmail,
                          hint: 'your@email.com',
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _contactSubject,
                          hint: "What's this about?",
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _contactMessage,
                          hint: 'Your message here...',
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: _primaryCta('Send Message', _sendEmail),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ContactLine(
                            icon: Icons.place,
                            label: 'Location',
                            value: 'Mumbai, India',
                          ),
                          SizedBox(height: 12),
                          _ContactLine(
                            icon: Icons.email,
                            label: 'Email',
                            value: 'patareharsh@gmail.com',
                          ),
                          SizedBox(height: 12),
                          _ContactLine(
                            icon: Icons.call,
                            label: 'Call',
                            value: '+91 9702180830',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _TextField(
                            controller: _contactName,
                            hint: 'Your Name',
                          ),
                          const SizedBox(height: 12),
                          _TextField(
                            controller: _contactEmail,
                            hint: 'your@email.com',
                          ),
                          const SizedBox(height: 12),
                          _TextField(
                            controller: _contactSubject,
                            hint: "What's this about?",
                          ),
                          const SizedBox(height: 12),
                          _TextField(
                            controller: _contactMessage,
                            hint: 'Your message here...',
                            maxLines: 5,
                          ),
                          const SizedBox(height: 16),
                          _primaryCta('Send Message', _sendEmail),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isMobile = _isMobile(context);
    final horizontalPadding = _getHorizontalPadding(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 30 : 50,
      ),
      child: Column(
        children: [
          // Social Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                Icons.work,
                'https://www.linkedin.com/in/harsh-patare-3259b8219/',
              ),
              const SizedBox(width: 30),
              _buildSocialIcon(
                Icons.camera_alt,
                'https://www.instagram.com/2hharsh/',
              ),
              const SizedBox(width: 30),
              _buildSocialIcon(Icons.code, 'https://github.com/IamHarsh02'),
            ],
          ),
          const SizedBox(height: 40),

          // Copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '© 2025  Built by ',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
              Text(
                'Harsh Patare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '. Developed in ',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
              Text(
                'Flutter web ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text('.', style: TextStyle(color: Colors.white24, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),

        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    const String serviceId = 'YOUR_SERVICE_ID';
    const String templateIdOwner = 'YOUR_TEMPLATE_ID_OWNER';
    const String publicKey = 'YOUR_PUBLIC_KEY';
    const String recipientEmail = 'patareharsh@gmail.com';

    final name = _contactName.text.trim();
    final email = _contactEmail.text.trim();
    final subject = _contactSubject.text.trim();
    final message = _contactMessage.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name, email and message')),
      );
      return;
    }

    try {
      final ownerResp = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateIdOwner,
          'user_id': publicKey,
          'template_params': {
            'to_email': recipientEmail,
            'from_name': name,
            'from_email': email,
            'subject': subject,
            'message': message,
          },
        }),
      );
      if (ownerResp.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Message sent!')));
        _contactName.clear();
        _contactEmail.clear();
        _contactSubject.clear();
        _contactMessage.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send (${ownerResp.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white60, size: 18),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StaggerFadeIn extends StatefulWidget {
  final int delayMs;
  final Widget child;
  const _StaggerFadeIn({required this.delayMs, required this.child});

  @override
  State<_StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<_StaggerFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);
    Future.delayed(Duration(milliseconds: widget.delayMs), _controller.forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SkillBar extends StatefulWidget {
  final String label;
  final double value; // 0..1
  final int delayMs;
  const _SkillBar({
    required this.label,
    required this.value,
    required this.delayMs,
  });

  @override
  State<_SkillBar> createState() => _SkillBarState();
}

class _SkillBarState extends State<_SkillBar> {
  double _t = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _t = widget.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '${(widget.value * 100).round()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  width: constraints.maxWidth * _t,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7AB6), Color(0xFFFF2D55)],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String hint;
  final int maxLines;
  final TextEditingController? controller;
  const _TextField({required this.hint, this.maxLines = 1, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

enum FeaturedKind { link, article }

class _FeaturedCard extends StatelessWidget {
  final String header;
  final String title;
  final String subtitle;
  final String description;
  final FeaturedKind kind;
  final String? imageAsset; // optional thumbnail image
  const _FeaturedCard({
    required this.header,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.kind,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: const Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Text(header, style: const TextStyle(color: Colors.white70)),
          ),
          // Thumbnail area
          Container(
            height: 220,
            width: double.infinity,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
              ),
              gradient: LinearGradient(
                colors:
                    kind == FeaturedKind.link
                        ? [const Color(0xFF2563EB), const Color(0xFF60A5FA)]
                        : [const Color(0xFF334155), const Color(0xFF1F2937)],
              ),
            ),
            child:
                imageAsset != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            imageAsset!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stack) => Center(
                                  child: Text(
                                    'Add ${imageAsset!.split('/').last}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                          ),
                          // subtle gradient overlay for readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.15),
                                  Colors.black.withOpacity(0.35),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : (kind == FeaturedKind.link
                        ? Icon(
                          Icons.link,
                          color: Colors.white.withOpacity(0.9),
                          size: 72,
                        )
                        : Container(
                          width: 64,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.image, color: Colors.white70),
                        )),
          ),
          // Title strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.black.withOpacity(0.25),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Subtitle + description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlogItem {
  final String title;
  final String subtitle;
  BlogItem({required this.title, required this.subtitle});
}

class _AutoScrollList extends StatefulWidget {
  final List<BlogItem> items;
  final VoidCallback onTap;
  const _AutoScrollList({required this.items, required this.onTap});

  @override
  State<_AutoScrollList> createState() => _AutoScrollListState();
}

class _AutoScrollListState extends State<_AutoScrollList> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      final next = _controller.offset + 1.2;
      if (next >= max) {
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final item = widget.items[index % widget.items.length];
        return InkWell(
          onTap: widget.onTap,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111214),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Text(
                            '5d ago',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.remove_red_eye,
                            size: 14,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Image placeholder
                Container(
                  width: 140,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset("assets/images/medium.png"),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: widget.items.length * 1000,
    );
  }
}

class _ChatbotSheet extends StatefulWidget {
  const _ChatbotSheet();

  @override
  State<_ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<_ChatbotSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_ChatMsg> _messages = [];

  // Static responses (per spec)
  final List<String> _greetings = const [
    "Hey there! 👋 I'm Harsh's friendly portfolio bot. Ask me anything about him!",
    "Hi! 😊 You can ask about Harsh's projects, contact info, work history, or social links.",
  ];

  static const String _contactInfo =
      "📌 Here's how you can connect with Harsh:\n🔗 LinkedIn: https://www.linkedin.com/in/harsh-patare-3259b8219/\n📷 Instagram: https://www.instagram.com/2hharsh/\n💻 GitHub: https://github.com/IamHarsh02\n✍️ Medium: https://medium.com/@patareharsh";

  static const String _detailedInfo =
      "📞 Contact Number: 9702180830\n📧 Email: patareharsh@gmail.com";

  static const String _workHistory =
      "🏢 Current Organisation: Sportz Interactive\n📱 Currently working on the Delhi Capitals app\n\n💼 Previous Organisation: Reliance Jio\n📲 Worked on the PeopleFirst app";

  static const String _projects =
      "💡 You can explore Harsh's projects here:\n🔗 GitHub - https://github.com/IamHarsh02";

  final List<String> _fallback = const [
    "Hmm 🤔 I’m not sure about that one. Try 'contact info', 'detailed info', 'work history', or 'projects'.",
    "I don't have an answer for that yet 😅 Try asking about Harsh's work or socials!",
  ];

  // Resume helpers
  bool _showResumeActions = false;
  static const String _resumeMsg =
      "Sure! 📄 Here’s the PDF — you can also view it online";
  static const String _resumePdf =
      "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"; // dummy
  static const String _resumeDrive = "https://drive.google.com"; // placeholder

  // Quiz state
  bool _quizActive = false;
  bool _quizAsked = false;
  static const String _quizQuestion =
      "🎮 Quiz time! Guess which programming language I used for my first project!";
  static const String _correctAnswer = "flutter"; // accept 'flutter' or 'dart'
  static const String _bonusProject =
      "🎁 Bonus unlocked! Here are some projects:\n1) playground – Flutter Web\n2) car check in check out – Flutter\n3) yo wallpaper – Android (XML/Java)\n4) iOS world clock – Swift\n5) news app – Flutter";

  @override
  void initState() {
    super.initState();
    _pushBot(_greetings.first);
  }

  String _getBotResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    // Resume intent
    if (msg.contains('resume') || msg.contains('cv')) {
      _showResumeActions = true;
      return _resumeMsg;
    }

    // Thanks acknowledgement
    if (msg.contains('thank')) {
      return "You're welcome! 🙌 Happy to help.";
    }

    // Quiz triggers
    if (msg.contains('quiz') ||
        msg.contains('guess') ||
        msg.contains('first project')) {
      _quizActive = true;
      _quizAsked = true;
      return _quizQuestion;
    }

    if (_quizActive) {
      // Check answer
      if (msg.contains(_correctAnswer) || msg.contains('dart')) {
        _quizActive = false;
        return "Correct! 🎉 $_bonusProject";
      } else {
        return "Not quite 😅 Hint: It's used to build cross‑platform apps for mobile and web. Try again!";
      }
    }

    if (msg.contains('contact info') || msg.contains('contact'))
      return _contactInfo;
    if (msg.contains('detailed info') ||
        msg.contains('email') ||
        msg.contains('number')) {
      return _detailedInfo;
    }
    if (msg.contains('previous organisation') ||
        msg.contains('organisation') ||
        msg.contains('work history') ||
        msg.contains('experience')) {
      return _workHistory;
    }
    if (msg.contains('projects') || msg.contains('github')) return _projects;
    if (msg.contains('hello') || msg.contains('hi')) {
      return _greetings[DateTime.now().millisecondsSinceEpoch %
          _greetings.length];
    }
    return _fallback[DateTime.now().millisecondsSinceEpoch % _fallback.length];
  }

  void _pushUser(String text) {
    setState(() => _messages.add(_ChatMsg(text: text, isUser: true)));
    Future.delayed(const Duration(milliseconds: 150), () {
      final reply = _getBotResponse(text);
      _pushBot(reply);
    });
  }

  void _pushBot(String text) {
    setState(() => _messages.add(_ChatMsg(text: text, isUser: false)));
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openResume({required bool online}) async {
    final uri = Uri.parse(online ? _resumeDrive : _resumePdf);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF15171A),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.smart_toy_outlined, color: Colors.white70),
                  SizedBox(width: 10),
                  Text(
                    "Harsh's Portfolio Bot",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return _ChatBubble(message: m);
                },
              ),
            ),

            // Action chips (resume + quick prompts)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _quick('contact info'),
                  _quick('detailed info'),
                  _quick('work history'),
                  _quick('projects'),
                  _quick('start quiz'),
                  _quick('resume'),
                  if (_showResumeActions) ...[
                    ActionChip(
                      label: const Text(
                        'Download PDF',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF33363C),
                      onPressed: () => _openResume(online: false),
                    ),
                    ActionChip(
                      label: const Text(
                        'View Online',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF33363C),
                      onPressed: () => _openResume(online: true),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Input
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                              'Ask about Harsh... (e.g., resume, contact info, start quiz)',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF15171A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white38),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isEmpty) return;
                          _pushUser(v.trim());
                          _controller.clear();
                          // Clear resume actions when a new query comes (optional)
                          if (_showResumeActions &&
                              !v.toLowerCase().contains('resume')) {
                            setState(() => _showResumeActions = false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final v = _controller.text.trim();
                        if (v.isEmpty) return;
                        _pushUser(v);
                        _controller.clear();
                        if (_showResumeActions &&
                            !v.toLowerCase().contains('resume')) {
                          setState(() => _showResumeActions = false);
                        }
                      },
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

  Widget _quick(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF1E2126),
      onPressed: () {
        _pushUser(text);
      },
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final align =
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color =
        message.isUser ? const Color(0xFF2563EB) : const Color(0xFF1E2126);
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(message.isUser ? 12 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 12),
            ),
            border: Border.all(color: Colors.white10),
          ),
          child: SelectableText(
            message.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _LuminousGradientOverlay extends StatefulWidget {
  const _LuminousGradientOverlay();

  @override
  State<_LuminousGradientOverlay> createState() =>
      _LuminousGradientOverlayState();
}

class _LuminousGradientOverlayState extends State<_LuminousGradientOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + 2 * t, -1),
                end: Alignment(1 - 2 * t, 1),
                colors: const [
                  Color(0xFF00E5FF), // cyan
                  Color(0xFFFF2D55), // pink
                  Color(0xFF7C4DFF), // purple
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Container(
              // Reduce intensity to be a glow rather than solid cover
              color: Colors.black.withOpacity(0.75),
            ),
          );
        },
      ),
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  final double strokeWidth;
  _NeonRingPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      colors: const [
        Color(0xFFFF2D55),
        Color(0xFF7C4DFF),
        Color(0xFF00E5FF),
        Color(0xFFFF2D55),
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..shader = gradient.createShader(rect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      6.28318,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  const _ProjectCard({required this.project});

  String _getTechStack(Project project) {
    // Default tech stack for Flutter projects
    if (project.title.toLowerCase().contains('flutter') ||
        project.title.toLowerCase().contains('game store') ||
        project.title.toLowerCase().contains('car check') ||
        project.title.toLowerCase().contains('news box') ||
        project.title.toLowerCase().contains('wallpaper')) {
      return 'Flutter | Dart | Firebase | REST APIs';
    }
    return 'Flutter | Dart | Firebase';
  }

  void _handleAction(BuildContext context, Project project) {
    if (project.action == ProjectAction.openGameStore) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameStoreDashboard()),
      );
    }
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return _HoverScale(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B23),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child:
            isMobile
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Screenshot (Top for Mobile)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          project.imageAsset != null
                              ? Image.asset(
                                project.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            project.colorA.withOpacity(0.7),
                                            project.colorB.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.white30,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      project.colorA.withOpacity(0.7),
                                      project.colorB.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                    ),

                    // Project Info (Bottom for Mobile)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            project.title,
                            style: const TextStyle(
                              color: Color(0xFFB794F6),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            project.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tech Stack
                          Text(
                            'Tech Stack used : ${_getTechStack(project)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              if (project.githubUrl != null)
                                Expanded(
                                  child: _ProjectButton(
                                    label: project.title.toLowerCase().contains("promptbook")?"App Link": 'Github',
                                    onTap: () async {
                                      final uri = Uri.parse(project.githubUrl!);
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                ),
                              if (project.githubUrl != null &&
                                  project.action == ProjectAction.openGameStore)
                                const SizedBox(width: 12),
                              if (project.action == ProjectAction.openGameStore)
                                Expanded(
                                  child: _ProjectButton(
                                    label: 'View',
                                    onTap: () {
                                      _handleAction(context, project);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Project Screenshot (Left Side)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 400,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            project.imageAsset != null
                                ? Image.asset(
                                  project.imageAsset!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              project.colorA.withOpacity(0.7),
                                              project.colorB.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.white30,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                )
                                : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        project.colorA.withOpacity(0.7),
                                        project.colorB.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                      ),
                    ),

                    // Project Info (Right Side)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              project.title,
                              style: const TextStyle(
                                color: Color(0xFFB794F6),
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Description
                            Text(
                              project.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tech Stack
                            Text(
                              'Tech Stack used : ${_getTechStack(project)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Action Buttons
                            Row(
                              children: [
                                if (project.githubUrl != null)
                                  _ProjectButton(
                                    label: project.title.toLowerCase().contains("promptbook")?"App Link": 'Github',
                                    onTap: () async {
                                      final uri = Uri.parse(project.githubUrl!);
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                if (project.githubUrl != null &&
                                    project.action ==
                                        ProjectAction.openGameStore)
                                  const SizedBox(width: 16),
                                if (project.action ==
                                    ProjectAction.openGameStore)
                                  _ProjectButton(
                                    label: 'View',
                                    onTap: () {
                                      _handleAction(context, project);
                                    },
                                  ),
                              ],
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
}

class _ProjectButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProjectButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _HoverScale(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB794F6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onSkills;
  final VoidCallback onProjects;
  final VoidCallback onContact;
  final VoidCallback onGameStore;

  const _MobileMenu({
    required this.onHome,
    required this.onAbout,
    required this.onSkills,
    required this.onProjects,
    required this.onContact,
    required this.onGameStore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMobileMenuItem('Home', Icons.home, onHome),
          _buildMobileMenuItem('About', Icons.person, onAbout),
          _buildMobileMenuItem('Skills', Icons.code, onSkills),
          _buildMobileMenuItem('Projects', Icons.work, onProjects),
          _buildMobileMenuItem('Contact', Icons.email, onContact),
          const Divider(color: Colors.white24, height: 32),
          _buildMobileMenuItem('Game Store', Icons.sports_esports, onGameStore),
        ],
      ),
    );
  }

  Widget _buildMobileMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
