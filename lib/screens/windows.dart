import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:playground/screens/dashboard_screen.dart';
import 'package:playground/screens/minesweeper_screen.dart';

class WindowsScreen extends StatefulWidget {
  const WindowsScreen({super.key});

  @override
  State<WindowsScreen> createState() => _WindowsScreenState();
}

class _WindowsScreenState extends State<WindowsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/images/windows.png",   // path MUST be first
                fit: BoxFit.cover,             // fills full screen
              ),
            ),

            // My Computer icon (top-left corner)
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      'assets/images/mycomputer.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "My Resume",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 90,
              left: 10,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      showDialog(
                        context: context,
                        barrierDismissible: true, // tap outside to close
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/minesweeper.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                          Text(
                                            "Minesweeper",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 3,
                                                  color: Colors.black,
                                                  offset: Offset(1, 1),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 70),
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent.shade700,
                                            border: Border.all(color: Colors.white)
                                          ),

                                          height: 30,
                                          width: 48,
                                          child: Icon(Icons.minimize),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Container(
                                        color: Colors.blueAccent.shade700,
                                        height: 30,
                                        width: 48,
                                        child: Icon(Icons.event_rounded,color: Colors.grey.shade700,   ),
                                      ),
                                      const SizedBox(width: 3),
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          color: Colors.red,
                                          height: 30,
                                          width: 48,
                                          child: Icon(Icons.close),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height/1.39,
                                    width: 320,
                                    child: MinesweeperScreen(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder:
                      //         (context) =>
                      //     const MinesweeperScreen(),
                      //   ),
                      // );
                    },
                    child: SvgPicture.asset(
                      'assets/images/minesweeper.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Minesweeper",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 190,
              left: 20,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameStoreDashboard(),
                        ),
                      );

                    },
                    child: SvgPicture.asset(
                      'assets/images/folder.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Projects",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }}

