import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'XO', 
    home: TicTacToePage(),
  ));
}

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  List<String> board = List.filled(9, '');
  bool isAiTurn = false;
  String winner = '';


  String playerSymbol = 'X'; 
  String aiSymbol = 'O';
  bool aiStarts = false; 

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      winner = '';
      aiSymbol = (playerSymbol == 'X') ? 'O' : 'X';
      isAiTurn = aiStarts;
    });

    if (isAiTurn) {
      Future.delayed(const Duration(milliseconds: 500), () => aiMove());
    }
  }

  String checkWinner(List<String> b) {
    const lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var line in lines) {
      if (b[line[0]] != '' && b[line[0]] == b[line[1]] && b[line[0]] == b[line[2]]) {
        return b[line[0]];
      }
    }
    if (!b.contains('')) return 'Tie';
    return '';
  }

  int getScore(String result, int depth) {
    if (result == aiSymbol) return 10 - depth;
    if (result == playerSymbol) return depth - 10;
    return 0;
  }

  int minimax(List<String> currentBoard, int depth, bool isMaximizing) {
    String result = checkWinner(currentBoard);
    if (result != '') return getScore(result, depth);

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (currentBoard[i] == '') {
          currentBoard[i] = aiSymbol;
          int score = minimax(currentBoard, depth + 1, false);
          currentBoard[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (currentBoard[i] == '') {
          currentBoard[i] = playerSymbol;
          int score = minimax(currentBoard, depth + 1, true);
          currentBoard[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  void aiMove() {
    if (winner != '') return;
    int bestScore = -1000;
    int move = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = aiSymbol;
        int score = minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    if (move != -1) {
      setState(() {
        board[move] = aiSymbol;
        winner = checkWinner(board);
        isAiTurn = false;
      });
    }
  }

  void playerMove(int index) {
    if (board[index] == '' && winner == '' && !isAiTurn) {
      setState(() {
        board[index] = playerSymbol;
        winner = checkWinner(board);
        isAiTurn = true;
      });
      if (winner == '') {
        Future.delayed(const Duration(milliseconds: 500), () => aiMove());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('XO'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                winner == '' 
                    ? (isAiTurn ? "AI Thinking..." : "Your Turn ($playerSymbol)") 
                    : (winner == 'Tie' ? "Draw!" : "Winner: $winner"),
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionChip(
                    label: Text("Play as $playerSymbol"),
                    backgroundColor: Colors.blueGrey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                    onPressed: () {
                      setState(() {
                        playerSymbol = (playerSymbol == 'X') ? 'O' : 'X';
                        resetGame();
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ActionChip(
                    avatar: Icon(aiStarts ? Icons.android : Icons.person, size: 18, color: Colors.cyanAccent),
                    label: Text(aiStarts ? "AI Starts" : "You Start"),
                    backgroundColor: Colors.blueGrey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                    onPressed: () {
                      setState(() {
                        aiStarts = !aiStarts;
                        resetGame();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Container(
                constraints: const BoxConstraints(maxWidth: 380),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => playerMove(i),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          board[i],
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: board[i] == 'X' ? Colors.cyanAccent : Colors.pinkAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: resetGame,
                icon: const Icon(Icons.refresh),
                label: const Text("Restart Game"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}