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
  hasSameSuit(Card c){
    return c.suit == this.suit;
  }
  hasSameRank(Card c){
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
  addCard(Card c){
    this.hand.add(c);
  }
  resetHand(){
    this.hand.clear();
  }
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
      p.addCard(deck.draw());
      p.addCard(deck.draw());
    }
  }

  void playClosedPoker() {
    // 1. dealHands()
    // 2. un seul tour d’enchères
    // 3. show down → evaluateHands()
  }

  void evaluateHands() {
    // Appeler HandEvaluator sur chaque main
  }
}
