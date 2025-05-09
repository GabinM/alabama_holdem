import 'dart:io';

enum Suit { hearts, diamonds, clubs, spades }

enum Rank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
}

class Card {
  final Suit suit;
  final Rank rank;
  Card(this.suit, this.rank);
  String toString() => '${rank.name.toUpperCase()} de ${suit.name}';
}

class Deck {
  final cards = <Card>[];
  Deck() {
    for (var s in Suit.values) {
      for (var r in Rank.values) {
        cards.add(Card(s, r));
      }
    }
  }
  void shuffle() => cards.shuffle();
  Card draw() => cards.removeLast();
}

class Player {
  final String name;
  int chips;
  List<Card> hand = [];
  bool folded = false;
  Player(this.name, {this.chips = 1000});
}

class PokerGame {
  final Deck deck = Deck();
  final List<Player> players;
  int pot = 0;
  PokerGame(this.players) {
    deck.shuffle();
  }

  void dealHands() {
    for (var p in players) {
      p.hand = [deck.draw(), deck.draw()];
    }
  }

  void playClosedPoker() {
    // 1. dealHands()
    // 2. un seul tour d'enchères
    // 3. show down → evaluateHands()
  }

  void evaluateHands() {
    // Appeler HandEvaluator sur chaque main
  }
}

class GameMenu {
  void displayMenu() {
    print('\n=== ALABAMA HOLDEM POKER ===');
    print('1. Nouvelle partie');
    print('2. Règles du jeu');
    print('3. Quitter');
    print('\nVotre choix : ');
  }

  void showRules() {
    print('\n=== RÈGLES DU JEU ===');
    print('Le Alabama Holdem est une variante du poker où :');
    print('- Chaque joueur reçoit 2 cartes');
    print('- Les enchères se font en un seul tour');
    print('- La meilleure main gagne le pot');
    print('\nAppuyez sur Entrée pour revenir au menu...');
    stdin.readLineSync();
  }

  void startGame() {
    // TODO: Lancement du jeu
  }
}

void main() {
  GameMenu menu = GameMenu();
  bool running = true;

  while (running) {
    menu.displayMenu();
    String? input = stdin.readLineSync();
    
    if (input == null) {
      print('\nErreur de saisie. Veuillez réessayer.');
      continue;
    }

    switch (input) {
      case '1':
        menu.startGame();
        break;
      case '2':
        menu.showRules();
        break;
      case '3':
        running = false;
        print('\nMerci d\'avoir joué !');
        break;
      default:
        print('\nChoix invalide. Veuillez réessayer.');
    }
  }
}
