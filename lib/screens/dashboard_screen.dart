import 'package:flutter/material.dart';
import 'package:playground/screens/snake_game_screen.dart';
import 'game_details_screen.dart';
import 'portfolio_screen.dart';
import 'minesweeper_screen.dart';

class GameStoreDashboard extends StatefulWidget {
  const GameStoreDashboard({super.key});

  @override
  State<GameStoreDashboard> createState() => _GameStoreDashboardState();
}

class _GameStoreDashboardState extends State<GameStoreDashboard> {
  int selectedPlatform = 1; // PS4 selected by default
  int selectedNavItem = 0; // Home selected by default
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> platforms = ['Mobile', "Web"];

  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.person, 'title': 'Portfolio'},
  ];

  // New: map images per card index
  final List<String> _gameThumbs = const [
    'assets/images/minesweeper.png',
    'assets/images/breakout.png',
    'assets/images/snake.png',
  ];

  // Responsive helper methods
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 16;
    if (_isTablet(context)) return 20;
    return 20;
  }

  int _getGridCrossAxisCount(BuildContext context) {
    if (_isMobile(context)) return 1;
    if (_isTablet(context)) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          // Left Sidebar (hidden on mobile, shown on desktop)
          if (!isMobile)
            Container(
              width: 280,
              color: const Color(0xFF111827),
              child: Column(
                children: [
                  // Logo and Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.gamepad, color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Playground Store',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = selectedNavItem == index;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: InkWell(
                            onTap: () {
                              // Portfolio item
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PortfolioScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFF374151)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // User Profile Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.diamond,
                                    color: Color(0xFF4F46E5),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Guest',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header with Platform Tabs
                Container(
                  color: const Color(0xFF111827),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(context),
                    vertical: isMobile ? 12 : 16,
                  ),
                  child: Row(
                    children: [
                      // Mobile: Menu button
                      if (isMobile)
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      // Logo for mobile
                      if (isMobile) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.gamepad,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Playground Store',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                      ],
                      // Platform Tabs
                      ...platforms.asMap().entries.map((entry) {
                        final index = entry.key;
                        final platform = entry.value;
                        final isSelected = selectedPlatform == index;

                        return Padding(
                          padding: EdgeInsets.only(right: isMobile ? 8 : 16),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedPlatform = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: isMobile ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFF4F46E5)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                platform,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.grey,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isMobile ? 16 : _getHorizontalPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 24 : 40),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME TO THE',
                                style: TextStyle(
                                  color: const Color(0xFF4F46E5),
                                  fontSize: isMobile ? 12 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Playground Store',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 24 : 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isMobile ? 6 : 8),
                              Text(
                                'Play Your Favourite games',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isMobile ? 24 : 40),

                        // New Games Section
                        Text(
                          'New Games',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: isMobile ? 16 : 20),

                        // Games Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getGridCrossAxisCount(context),
                                crossAxisSpacing: isMobile ? 12 : 20,
                                mainAxisSpacing: isMobile ? 12 : 20,
                                childAspectRatio: isMobile ? 0.85 : 1.2,
                              ),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                if (index == 0) {
                                  // Minesweeper
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const MinesweeperScreen(),
                                    ),
                                  );
                                } else if (index == 1) {
                                  // Brick/Breakout details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => GameDetailsScreen(
                                            gameIndex: index,
                                          ),
                                    ),
                                  );
                                } else {
                                  // Snake
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SnakeGameScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9CA3AF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.all(
                                          isMobile ? 12 : 20,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: const Color(0xFF6B7280),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: _buildThumb(index),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isMobile ? 12 : 16,
                                      ),
                                      child: Text(
                                        index == 0
                                            ? 'Minesweeper'
                                            : index == 1
                                            ? 'Brick'
                                            : 'Snake and apple',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: isMobile ? 12 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  color: const Color(0xFF111827),
                  child: Center(
                    child: Text(
                      'Playground Store/ All rights reserved.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF111827),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gamepad, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Playground Store',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedNavItem == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PortfolioScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF374151)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(item['icon'], color: Colors.white, size: 20),
                          const SizedBox(width: 16),
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.diamond,
                            color: Color(0xFF4F46E5),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Guest',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '1',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumb(int index) {
    final path = _gameThumbs[index];
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return Center(
          child: Text(
            'Add ${path.split('/').last}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
