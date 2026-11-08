import 'package:flutter/material.dart';
import 'package:thinkcodes/diseRollerApp/gamescreen.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2>
    with SingleTickerProviderStateMixin {
  int selectedPlayers = 2;

  late AnimationController _controller;
  late Animation<double> _animation;

  static const Color background = Color(0xFFF8F5FF);
  static const Color purple = Color(0xFFB39DDB);
  static const Color darkPurple = Color(0xFF4A4063);
  static const Color lightPurple = Color(0xFFEDE5FA);
  static const Color softPink = Color(0xFFFFE5EC);
  static const Color mint = Color(0xFFE0F2E9);
  static const Color peach = Color(0xFFFFE9DE);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(totalPlayers: selectedPlayers),
      ),
    );
  }

  Widget buildPlayerOption({
    required int players,
    required String emoji,
    required String title,
    required Color color,
  }) {
    final bool isSelected = selectedPlayers == players;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPlayers = players;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? purple : const Color(0xFFEAE3F3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 27)),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  color: darkPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF9575CD),
                  size: 19,
                )
              else
                const SizedBox(height: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeature({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: darkPurple, size: 25),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 15, 22, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text('🎲', style: TextStyle(fontSize: 27)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DICE BATTLE',
                          style: TextStyle(
                            color: darkPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Let the fun begin!',
                          style: TextStyle(
                            color: Color(0xFF9B90AD),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.casino_outlined,
                      color: Color(0xFF9575CD),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // WELCOME TEXT
              const Text(
                'Ready to',
                style: TextStyle(
                  fontSize: 30,
                  color: darkPurple,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'ROLL THE DICE?',
                style: TextStyle(
                  fontSize: 30,
                  color: darkPurple,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Gather your friends and see who gets lucky!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E82A8),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // ANIMATED DICE BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8DDF8), Color(0xFFFFE8F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _animation.value),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: -0.15,
                            child: Container(
                              height: 95,
                              width: 95,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: purple.withValues(alpha: 0.15),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '⚄',
                                  style: TextStyle(
                                    fontSize: 76,
                                    color: Color(0xFFB39DDB),
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Transform.rotate(
                            angle: 0.15,
                            child: Container(
                              height: 95,
                              width: 95,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDFD),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withValues(alpha: 0.10),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '⚂',
                                  style: TextStyle(
                                    fontSize: 76,
                                    color: Color(0xFFF3A9BE),
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'ROLL • PLAY • WIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Every roll brings a new surprise!',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8E82A8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PLAYER SELECTION
              const Text(
                '👥  Choose Players',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'How many players want to play?',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E82A8)),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  buildPlayerOption(
                    players: 2,
                    emoji: '👫',
                    title: '2 Players',
                    color: mint,
                  ),
                  buildPlayerOption(
                    players: 3,
                    emoji: '👨‍👩‍👧',
                    title: '3 Players',
                    color: softPink,
                  ),
                  buildPlayerOption(
                    players: 4,
                    emoji: '👨‍👩‍👧‍👦',
                    title: '4 Players',
                    color: peach,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // SELECTED PLAYER INFO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAE3F3)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Color(0xFF9575CD),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$selectedPlayers Players Selected',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: darkPurple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Take turns and beat the highest score!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8E82A8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Color(0xFF9CCDB0)),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // PLAY BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB39DDB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, size: 27),
                      const SizedBox(width: 10),
                      Text(
                        'PLAY WITH $selectedPlayers PLAYERS',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // FEATURES
              Row(
                children: [
                  buildFeature(
                    icon: Icons.casino_rounded,
                    title: 'Dice Fun',
                    color: lightPurple,
                  ),
                  buildFeature(
                    icon: Icons.people_alt_rounded,
                    title: 'Multiplayer',
                    color: mint,
                  ),
                  buildFeature(
                    icon: Icons.emoji_events_rounded,
                    title: 'Win Points',
                    color: softPink,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'Made with 💜 for game lovers',
                  style: TextStyle(fontSize: 12, color: Color(0xFFA69AB8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
