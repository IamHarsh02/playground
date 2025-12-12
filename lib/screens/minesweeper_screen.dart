import 'dart:math';
import 'package:flutter/material.dart';

class MinesweeperScreen extends StatefulWidget {
  const MinesweeperScreen({super.key});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

enum Difficulty { beginner, intermediate, expert, insane }

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  // Dynamic board based on difficulty
  late int rows;
  late int cols;
  late int totalMines;
  Difficulty difficulty = Difficulty.beginner;

  late List<List<Cell>> board;
  bool isGameOver = false;
  bool isWin = false;
  bool hasGenerated = false; // generate after first safe click
  int flagsPlaced = 0;

  @override
  void initState() {
    super.initState();
    _applyDifficulty();
    _reset();
  }

  void _applyDifficulty() {
    switch (difficulty) {
      case Difficulty.beginner: // Classic beginner
        rows = 9;
        cols = 9;
        totalMines = 10;
        break;
      case Difficulty.intermediate: // Classic intermediate
        rows = 16;
        cols = 16;
        totalMines = 40;
        break;
      case Difficulty.expert: // Classic expert (widescreen)
        rows = 16;
        cols = 30;
        totalMines = 99;
        break;
      case Difficulty.insane: // Extra large board, more boxes and mines
        rows = 24;
        cols = 30;
        totalMines = 180;
        break;
    }
  }

  void _reset() {
    board = List.generate(rows, (_) => List.generate(cols, (_) => Cell()));
    isGameOver = false;
    isWin = false;
    hasGenerated = false;
    flagsPlaced = 0;
    setState(() {});
  }

  void _generateBoard(int safeR, int safeC) {
    // Place mines avoiding first click and its neighbors
    final random = Random();
    int mines = 0;

    bool isSafe(int r, int c) =>
        (r - safeR).abs() <= 1 && (c - safeC).abs() <= 1;

    while (mines < totalMines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);
      if (board[r][c].isMine || isSafe(r, c)) continue;
      board[r][c].isMine = true;
      mines++;
    }

    // Calculate neighbor counts
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        board[r][c].neighborMines =
            _neighbors(r, c).where((p) => board[p.$1][p.$2].isMine).length;
      }
    }
  }

  List<(int, int)> _neighbors(int r, int c) {
    final List<(int, int)> list = [];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        int nr = r + dr, nc = c + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) list.add((nr, nc));
      }
    }
    return list;
  }

  void _reveal(int r, int c) {
    if (isGameOver || isWin) return;
    final cell = board[r][c];
    if (cell.isRevealed || cell.isFlagged) return;

    if (!hasGenerated) {
      hasGenerated = true;
      _generateBoard(r, c);
    }

    cell.isRevealed = true;

    if (cell.isMine) {
      isGameOver = true;
      // Reveal all mines
      for (var row in board) {
        for (var c in row) {
          if (c.isMine) c.isRevealed = true;
        }
      }
      setState(() {});
      return;
    }

    // Flood fill zeros
    if (cell.neighborMines == 0) {
      final queue = <(int, int)>[(r, c)];
      while (queue.isNotEmpty) {
        final (cr, cc) = queue.removeLast();
        for (final (nr, nc) in _neighbors(cr, cc)) {
          final ncell = board[nr][nc];
          if (!ncell.isRevealed && !ncell.isFlagged && !ncell.isMine) {
            ncell.isRevealed = true;
            if (ncell.neighborMines == 0) queue.add((nr, nc));
          }
        }
      }
    }

    _checkWin();
    setState(() {});
  }

  void _toggleFlag(int r, int c) {
    if (isGameOver || isWin) return;
    final cell = board[r][c];
    if (cell.isRevealed) return;
    cell.isFlagged = !cell.isFlagged;
    flagsPlaced += cell.isFlagged ? 1 : -1;
    setState(() {});
  }

  void _checkWin() {
    // Win if all non-mine cells revealed
    int revealed = 0;
    int nonMines = rows * cols - totalMines;
    for (final row in board) {
      for (final cell in row) {
        if (!cell.isMine && cell.isRevealed) revealed++;
      }
    }
    if (revealed == nonMines) {
      isWin = true;
    }
  }

  Color _numberColor(int n) {
    switch (n) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.deepPurple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black87;
      case 8:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingMines = totalMines - flagsPlaced;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF111827),
      //   title: const Text('Minesweeper'),
      //   actions: [
      //     // Difficulty selector
      //     PopupMenuButton<Difficulty>(
      //       tooltip: 'Difficulty',
      //       initialValue: difficulty,
      //       onSelected: (d) {
      //         setState(() {
      //           difficulty = d;
      //           _applyDifficulty();
      //           _reset();
      //         });
      //       },
      //       itemBuilder:
      //           (context) => const [
      //             PopupMenuItem(
      //               value: Difficulty.beginner,
      //               child: Text('Beginner 9x9 / 10 mines'),
      //             ),
      //             PopupMenuItem(
      //               value: Difficulty.intermediate,
      //               child: Text('Intermediate 16x16 / 40 mines'),
      //             ),
      //             PopupMenuItem(
      //               value: Difficulty.expert,
      //               child: Text('Expert 16x30 / 99 mines'),
      //             ),
      //             PopupMenuItem(
      //               value: Difficulty.insane,
      //               child: Text('Insane 24x30 / 180 mines'),
      //             ),
      //           ],
      //       child: Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //         child: Center(
      //           child: Text(
      //             difficulty.name[0].toUpperCase() +
      //                 difficulty.name.substring(1),
      //             style: const TextStyle(fontSize: 14),
      //           ),
      //         ),
      //       ),
      //     ),
      //     IconButton(onPressed: _reset, icon: const Icon(Icons.refresh)),
      //   ],
      // ),
       backgroundColor:  Colors.grey,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),border: Border.all(color: Colors.grey.shade700) ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _counterTile(
                    label: 'Mines',
                    value: remainingMines.toString().padLeft(3, '0'),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _reset,
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(
                        isGameOver
                            ? Icons.sentiment_very_dissatisfied
                            : isWin
                            ? Icons.sentiment_very_satisfied
                            : Icons.sentiment_satisfied_alt,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  _counterTile(
                    label: 'Score',
                    value: '000',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final size = MediaQuery.of(context).size;
                final ratio = cols / rows; // width / height
                final maxW = size.width * 0.7; // reduce board width
                final maxH = size.height * 0.55; // reduce board height
                // compute board size preserving aspect ratio
                double w = maxW;
                double h = w / ratio;
                if (h > maxH) {
                  h = maxH;
                  w = h * ratio;
                }
                return SizedBox(
                  width: w,
                  height: h,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 1.5,
                        mainAxisSpacing: 1.5,
                      ),
                      itemCount: rows * cols,
                      itemBuilder: (context, index) {
                        final r = index ~/ cols;
                        final c = index % cols;
                        final cell = board[r][c];

                        return GestureDetector(
                          onTap: () => _reveal(r, c),
                          onLongPress: () => _toggleFlag(r, c),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  cell.isRevealed
                                      ? Colors.grey.shade400
                                      : const Color(0xFF9CA3AF),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Center(child: _buildCellContent(cell)),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // const SizedBox(height: 12),
            // if (isGameOver)
            //   const Text(
            //     'Game Over',
            //     style: TextStyle(color: Colors.redAccent, fontSize: 18),
            //   ),
            // if (isWin)
            //   const Text(
            //     'You Win!',
            //     style: TextStyle(color: Colors.greenAccent, fontSize: 18),
            //   ),
            // const SizedBox(height: 12),
            // const Text(
            //   'Tip: Long-press to flag a mine',
            //   style: TextStyle(color: Colors.white60),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _counterTile({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(Cell cell) {
    if (!cell.isRevealed) {
      if (cell.isFlagged) {
        return const Icon(Icons.flag, color: Colors.redAccent, size: 18);
      }
      return const SizedBox();
    }
    if (cell.isMine) {
      return const Icon(Icons.circle, color: Colors.black87, size: 12);
    }
    if (cell.neighborMines == 0) {
      return const SizedBox();
    }
    return Text(
      '${cell.neighborMines}',
      style: TextStyle(
        color: _numberColor(cell.neighborMines),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class Cell {
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int neighborMines = 0;
}
