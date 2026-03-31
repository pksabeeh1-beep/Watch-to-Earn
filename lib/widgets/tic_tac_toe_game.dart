import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, "");
  bool isUserTurn = true;
  String status = "Your Turn (X)";
  bool gameOver = false;

  void _handleTap(int index) {
    if (board[index] != "" || !isUserTurn || gameOver) return;

    setState(() {
      board[index] = "X";
      isUserTurn = false;
      status = "Bot is thinking...";
    });

    if (_checkWinner("X")) {
      setState(() {
        status = "You Won!";
        gameOver = true;
      });
    } else if (!board.contains("")) {
      setState(() {
        status = "It's a Draw!";
        gameOver = true;
      });
    } else {
      Future.delayed(const Duration(seconds: 1), _botMove);
    }
  }

  void _botMove() {
    if (gameOver) return;

    int move = _getBestMove();
    
    setState(() {
      board[move] = "O";
      isUserTurn = true;
      status = "Your Turn (X)";
    });

    if (_checkWinner("O")) {
      setState(() {
        status = "Bot Won!";
        gameOver = true;
      });
    } else if (!board.contains("")) {
      setState(() {
        status = "It's a Draw!";
        gameOver = true;
      });
    }
  }

  int _getBestMove() {
    // 1. Try to win
    int winMove = _findWinningMove("O");
    if (winMove != -1) return winMove;

    // 2. Block user
    int blockMove = _findWinningMove("X");
    if (blockMove != -1) return blockMove;

    // 3. Random move
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") availableMoves.add(i);
    }
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  int _findWinningMove(String player) {
    const List<List<int>> winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var condition in winConditions) {
      int count = 0;
      int emptyIndex = -1;
      for (int index in condition) {
        if (board[index] == player) {
          count++;
        } else if (board[index] == "") {
          emptyIndex = index;
        }
      }
      if (count == 2 && emptyIndex != -1) {
        return emptyIndex;
      }
    }
    return -1;
  }

  bool _checkWinner(String player) {
    const List<List<int>> winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var condition in winConditions) {
      if (board[condition[0]] == player &&
          board[condition[1]] == player &&
          board[condition[2]] == player) {
        return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      isUserTurn = true;
      status = "Your Turn (X)";
      gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: status.contains("Won") ? Colors.green : (status.contains("Draw") ? Colors.orange : Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _handleTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: board[index] == "X" ? Colors.blue : Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (gameOver) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Reset", style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
