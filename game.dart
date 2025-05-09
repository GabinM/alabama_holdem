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
  bool hasSameSuit(Card c){
    return c.suit == this.suit;
  }
  bool hasSameRank(Card c){
    return c.rank == this.rank;
  }
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
  void addCard(Card c){
    this.hand.add(c);
  }
  void resetHand(){
    this.hand.clear();
  }
}

class PokerGame {
  final Deck deck = Deck();
  final List<Player> players;
  List<Card> board = <Card>[];
  int pot = 0;
  PokerGame(this.players) {
    deck.shuffle();
  }

  void addCardToBoard(Card c){
    this.board.add(c);
  }

  void clearBoard(){
    this.board.clear();
  }

  void dealHands() {
    for (var p in players) {
      p.addCard(deck.draw());
      p.addCard(deck.draw());
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
    print("combien de joueurs ? (2 par défaut) : ");
    int? playerNb;
    try{
      playerNb = int.parse(stdin.readLineSync() ?? "2" );  
    } on FormatException {
      print("utilisation de la valeur par défaut (2)");
      playerNb = 2;
    }
    print("combien de jetons de départ ? (1000 par défaut) : ");
    int? chipsPerPlayer;
    try{
      chipsPerPlayer = int.parse(stdin.readLineSync()?? "1000");
    } on FormatException {
      print("utilisation de la valeur par défaut (1000)");
      chipsPerPlayer = 1000;
    }

    List<Player> players = <Player>[];
    for(int i = 1; i < playerNb+1; i++){
      print("quel nom pour le joueur n°${i} ? : ");
      String? name = stdin.readLineSync();
      if(name == null || name == "\n"){
        name = "anonyme ${i}";
      }
      players.add(new Player(name, chips : chipsPerPlayer));
    }
    PokerGame game = new PokerGame(players);
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
