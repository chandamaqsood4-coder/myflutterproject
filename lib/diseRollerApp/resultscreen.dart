import 'package:flutter/material.dart';
import 'package:thinkcodes/diseRollerApp/gamescreen.dart';

class ResultScreen extends StatelessWidget {
  final int playerScore;
  final int computerScore;
  final int rounds;

  const ResultScreen({
    super.key,
    required this.playerScore,
    required this.computerScore,
    required this.rounds,
  });

  @override
  Widget build(BuildContext context) {
    final bool won = playerScore > computerScore;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Text(won ? '🏆' : '💜', style: const TextStyle(fontSize: 110)),

                const SizedBox(height: 25),

                Text(
                  won ? 'YOU WIN!' : 'GAME OVER!',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4063),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  won
                      ? 'Amazing! You defeated the computer!'
                      : 'Good try! Better luck next time!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF8E82A8),
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Column(
                    children: [
                      const Text(
                        'FINAL SCORE',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4063),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('YOU'),
                              const SizedBox(height: 8),
                              Text(
                                '$playerScore',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF81B99B),
                                ),
                              ),
                            ],
                          ),

                          const Text(
                            'VS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Column(
                            children: [
                              const Text('COMPUTER'),
                              const SizedBox(height: 8),
                              Text(
                                '$computerScore',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE9A58F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'Total Rounds: $rounds',
                        style: const TextStyle(color: Color(0xFF8E82A8)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB39DDB),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      '🎲 PLAY AGAIN',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
