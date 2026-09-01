import 'dart:math';
import 'package:game_papan/models/game_enums.dart';

class EloCalculator {
  static const int defaultKFactor = 32;

  /// Hitung perubahan rating berdasarkan outcome (win: 1.0, draw: 0.5, loss: 0.0)
  /// Jika gameMode == GameMode.vsBot, perubahan SELALU 0 sesuai spesifikasi requirement.
  static int calculateRatingDelta({
    required int playerRating,
    required int opponentRating,
    required MatchOutcome outcome,
    required GameMode gameMode,
    int kFactor = defaultKFactor,
  }) {
    // Sesuai requirement: "Tiap kali menang melawan player, maka ratingnya akan bertambah dan kalo kalah akan berkurang. Namun kalau melawan bot, maka rating akan tetap."
    if (gameMode == GameMode.vsBot) {
      return 0;
    }

    double actualScore;
    switch (outcome) {
      case MatchOutcome.win:
        actualScore = 1.0;
        break;
      case MatchOutcome.draw:
        actualScore = 0.5;
        break;
      case MatchOutcome.loss:
        actualScore = 0.0;
        break;
    }

    // Expected score formula: E = 1 / (1 + 10^((opp - player) / 400))
    double exponent = (opponentRating - playerRating) / 400.0;
    double expectedScore = 1.0 / (1.0 + pow(10.0, exponent));

    double delta = kFactor * (actualScore - expectedScore);
    int roundedDelta = delta.round();

    // Pastikan menang minimal dapat +1 jika bukan perfect ceiling, dan kalah minimal -1
    if (outcome == MatchOutcome.win && roundedDelta <= 0) {
      roundedDelta = 1;
    } else if (outcome == MatchOutcome.loss && roundedDelta >= 0) {
      roundedDelta = -1;
    }

    return roundedDelta;
  }
}
