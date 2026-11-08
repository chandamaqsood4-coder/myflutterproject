import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int totalPlayers;

  const GameScreen({super.key, this.totalPlayers = 2});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  static const Color background = Color(0xFFF5F0FF);
  static const Color purple = Color(0xFF9575CD);
  static const Color darkPurple = Color(0xFF4A4063);

  final List<Color> playerColors = const [
    Color(0xFFF48FB1),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
  ];

  final List<String> playerEmojis = const ['🐻', '🐰', '🐱', '🐼'];

  late List<int> playerPositions;
  late List<int> scores;

  int currentPlayer = 0;
  int diceValue = 1;
  int round = 1;

  bool rolling = false;
  bool gameOver = false; 

  String message = 'Player 1 ki turn hai!';

  // Board ka size: 7 x 7
  static const int boardSize = 7;
  static const int finishPosition = 48;

  // Board ke tamam cells ko snake pattern mein arrange karna.
  late final List<List<int>> path = _createPath();

  List<List<int>> _createPath() {
    final List<List<int>> result = [];

    for (int row = boardSize - 1; row >= 0; row--) {
      if ((boardSize - 1 - row).isEven) {
        for (int col = 0; col < boardSize; col++) {
          result.add([row, col]);
        }
      } else {
        for (int col = boardSize - 1; col >= 0; col--) {
          result.add([row, col]);
        }
      }
    }

    return result;
  }

  @override
  void initState() {
    super.initState();

    playerPositions = List.filled(widget.totalPlayers, 0);
    scores = List.filled(widget.totalPlayers, 0);
  }

  Future<void> rollDice() async {
    if (rolling || gameOver) return;

    setState(() {
      rolling = true;
      message = 'Player ${currentPlayer + 1} dice roll kar raha hai...';
    });

    // Dice rolling animation.
    for (int i = 0; i < 12; i++) {
      await Future.delayed(const Duration(milliseconds: 90));

      if (!mounted) return;

      setState(() {
        diceValue = random.nextInt(6) + 1;
      });
    }

    if (!mounted) return;

    final int rolled = diceValue;

    setState(() {
      rolling = false;

      int newPosition = playerPositions[currentPlayer] + rolled;

      if (newPosition >= finishPosition) {
        newPosition = finishPosition;
      }

      playerPositions[currentPlayer] = newPosition;

      // Special tiles.
      if (newPosition == 8 || newPosition == 19) {
        playerPositions[currentPlayer] = min(finishPosition, newPosition + 2);

        message = '⭐ Lucky tile! 2 extra steps!';
      } else if (newPosition == 13 || newPosition == 30) {
        playerPositions[currentPlayer] = max(0, newPosition - 2);

        message = '😵 Trap tile! 2 steps peeche!';
      } else {
        message = 'Player ${currentPlayer + 1} ne $rolled roll kiya!';
      }

      // Player finish par pohanch gaya.
      if (playerPositions[currentPlayer] >= finishPosition) {
        playerPositions[currentPlayer] = finishPosition;
        scores[currentPlayer]++;

        gameOver = true;
        message = '🏆 Player ${currentPlayer + 1} jeet gaya!';

        return;
      }

      // Agle player ki turn.
      currentPlayer++;

      if (currentPlayer >= widget.totalPlayers) {
        currentPlayer = 0;
        round++;
      }

      message += '\nAb Player ${currentPlayer + 1} ki turn hai!';
    });
  }

  void restartGame() {
    setState(() {
      playerPositions = List.filled(widget.totalPlayers, 0);
      scores = List.filled(widget.totalPlayers, 0);

      currentPlayer = 0;
      diceValue = 1;
      round = 1;

      rolling = false;
      gameOver = false;

      message = 'Player 1 ki turn hai!';
    });
  }

  Widget buildPlayerToken(int playerIndex) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: playerColors[playerIndex],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          playerEmojis[playerIndex],
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget buildBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardWidth = constraints.maxWidth;
        final double cellSize = boardWidth / boardSize;

        return Container(
          width: boardWidth,
          height: boardWidth,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFD7C8EF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: purple.withValues(alpha: 0.18),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Board tiles.
              for (int i = 0; i < path.length; i++)
                Positioned(
                  left: path[i][1] * cellSize,
                  top: path[i][0] * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _tileColor(i),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Center(child: _tileContent(i)),
                    ),
                  ),
                ),

              // Player tokens.
              for (int p = 0; p < widget.totalPlayers; p++)
                Positioned(
                  left:
                      path[playerPositions[p]][1] * cellSize + (p % 2) * 13 + 3,
                  top:
                      path[playerPositions[p]][0] * cellSize +
                      (p ~/ 2) * 13 +
                      3,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: buildPlayerToken(p),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _tileColor(int index) {
    if (index == 0) return const Color(0xFFB9E8D1);

    if (index == finishPosition) {
      return const Color(0xFFFFD9A8);
    }

    if (index == 8 || index == 19) {
      return const Color(0xFFFFE5A8);
    }

    if (index == 13 || index == 30) {
      return const Color(0xFFFFCDD5);
    }

    const colors = [
      Color(0xFFD7F0FF),
      Color(0xFFE8DDF8),
      Color(0xFFDDF4E5),
      Color(0xFFFFE4EB),
      Color(0xFFFFF0CC),
    ];

    return colors[index % colors.length];
  }

  Widget _tileContent(int index) {
    if (index == 0) {
      return const Text(
        'START',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: darkPurple,
        ),
      );
    }

    if (index == finishPosition) {
      return const Text('🏁', style: TextStyle(fontSize: 22));
    }

    if (index == 8 || index == 19) {
      return const Text('⭐', style: TextStyle(fontSize: 19));
    }

    if (index == 13 || index == 30) {
      return const Text('🕳️', style: TextStyle(fontSize: 18));
    }

    return Text(
      '${index + 1}',
      style: const TextStyle(
        fontSize: 9,
        color: Color(0xFF82759B),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildPlayerScore(int index) {
    final bool isCurrent = currentPlayer == index && !gameOver;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrent
            ? playerColors[index].withValues(alpha: 0.25)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrent ? playerColors[index] : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(playerEmojis[index], style: const TextStyle(fontSize: 25)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                Text(
                  'Position: ${playerPositions[index]} / $finishPosition',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E82A8),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent) const Icon(Icons.touch_app_rounded, color: purple),
        ],
      ),
    );
  }

  void showWinnerDialog() {
    final int winner = currentPlayer;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Center(
            child: Text(
              '🏆 YOU WIN!',
              style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(playerEmojis[winner], style: const TextStyle(fontSize: 65)),
              const SizedBox(height: 10),
              Text(
                'Player ${winner + 1} jeet gaya!',
                style: const TextStyle(
                  fontSize: 20,
                  color: darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total rounds: $round',
                style: const TextStyle(color: Color(0xFF8E82A8)),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                restartGame();
              },
              icon: const Icon(Icons.replay),
              label: const Text('PLAY AGAIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('HOME'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && gameOver) {
          // Dialog sirf ek baar show hoga.
          if (!ModalRoute.of(context)!.isCurrent) return;
          showWinnerDialog();
        }
      });
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkPurple,
        elevation: 0,
        title: const Text(
          '🎲 DICE BATTLE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8DDF8), Color(0xFFFFE5EC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'ROUND $round',
                      style: const TextStyle(
                        fontSize: 23,
                        color: darkPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      gameOver
                          ? 'Game complete!'
                          : 'Player ${currentPlayer + 1} ki turn',
                      style: const TextStyle(color: darkPurple),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Board.
              buildBoard(),

              const SizedBox(height: 18),

              // Dice.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Transform.rotate(
                  key: ValueKey(diceValue),
                  angle: rolling ? random.nextDouble() * 0.3 : 0,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: purple.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'][diceValue - 1],
                        style: const TextStyle(
                          fontSize: 65,
                          color: purple,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: rolling || gameOver
                      ? null
                      : () async {
                          await rollDice();

                          if (mounted && gameOver) {
                            showWinnerDialog();
                          }
                        },
                  icon: const Icon(Icons.casino_rounded),
                  label: Text(
                    rolling
                        ? 'ROLLING...'
                        : 'PLAYER ${currentPlayer + 1} ROLL DICE',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '👥 PLAYERS',
                  style: TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              for (int i = 0; i < widget.totalPlayers; i++) buildPlayerScore(i),

              const SizedBox(height: 10),

              const Text(
                '⭐ Bonus: +2 steps     🕳️ Trap: -2 steps',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E82A8), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
