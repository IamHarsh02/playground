import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final List<Project> projects = [
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
    // Project(
    //   title: 'Ios native world clock',
    //   description:
    //       'A native iOS-style world clock with alarms, timers, and smooth animations.',
    //   badge: 'iOS',
    //   colorA: const Color(0xFF64748B),
    //   colorB: const Color(0xFF94A3B8),
    //   imageAsset: 'assets/images/ios_world_clock.png',
    // ),
    // Project(
    //   title: 'kmm project weather app',
    //   description:
    //       'Kotlin Multiplatform Mobile weather app sharing logic across Android/iOS.',
    //   badge: 'KMM',
    //   colorA: const Color(0xFF22C55E),
    //   colorB: const Color(0xFF16A34A),
    //   imageAsset: 'assets/images/kmm_weather.png',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final featured = projects.first;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Projects', style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _buildHeroBanner(featured),
          const SizedBox(height: 16),
          _buildRow('My Projects', projects),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(Project p) {
    return AspectRatio(
      aspectRatio: 9 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image if available
          if (p.imageAsset != null)
            Image.asset(
              p.imageAsset!,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stack) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          p.colorA.withOpacity(0.7),
                          p.colorB.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    p.colorA.withOpacity(0.7),
                    p.colorB.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          // Dark overlay for readability
          Container(color: Colors.black.withOpacity(0.35)),
          Positioned(
            left: 24,
            bottom: 28,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Text(
                    p.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _primaryBtn('Play', () => _handlePrimaryAction(p)),
                    const SizedBox(width: 12),
                    _secondaryBtn('More Info', () => _showProjectDialog(p)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, List<Project> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final p = items[index];
              return _ProjectCard(
                project: p,
                onTap: () => _showProjectDialog(p),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }

  void _handlePrimaryAction(Project p) {
    if (p.action == ProjectAction.openGameStore) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameStoreDashboard()),
      );
    } else {
      _showProjectDialog(p);
    }
  }

  void _showProjectDialog(Project p) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF111111),
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (p.imageAsset != null)
                        Image.asset(
                          p.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stack) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [p.colorA, p.colorB],
                                  ),
                                ),
                              ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [p.colorA, p.colorB],
                            ),
                          ),
                        ),
                      Container(color: Colors.black.withOpacity(0.35)),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            p.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (p.action == ProjectAction.openGameStore)
                            _primaryBtn('Play', () => _handlePrimaryAction(p)),
                          if (p.action == ProjectAction.openGameStore)
                            const SizedBox(width: 10),
                          if (p.githubUrl != null)
                            _secondaryBtn(
                              'GitHub',
                              () => _openGithub(p.githubUrl!),
                            ),
                          const Spacer(),
                          _badge(p.badge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: const [
                          _Pill('Flutter'),
                          _Pill('Dart'),
                          _Pill('Firebase'),
                          _Pill('REST'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openGithub(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _primaryBtn(String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.play_arrow),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      label: Text(label),
    );
  }

  Widget _secondaryBtn(String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      label: Text(label),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
          color: Colors.white10,
        ),
        child: Stack(
          children: [
            // Thumb: image if available, otherwise gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  project.imageAsset != null
                      ? Image.asset(
                        project.imageAsset!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder:
                            (context, error, stack) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [project.colorA, project.colorB],
                                ),
                              ),
                            ),
                      )
                      : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [project.colorA, project.colorB],
                          ),
                        ),
                      ),
            ),
            // Title
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                project.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
            ),
            // Badge
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  project.badge,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Project {
  final String title;
  final String description;
  final String badge;
  final Color colorA;
  final Color colorB;
  final ProjectAction? action;
  final String? imageAsset;
  final String? githubUrl;
  const Project({
    required this.title,
    required this.description,
    required this.badge,
    required this.colorA,
    required this.colorB,
    this.action,
    this.imageAsset,
    this.githubUrl,
  });
}

enum ProjectAction { openGameStore }

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
