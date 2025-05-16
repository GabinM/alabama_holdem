import 'dart:io';

enum Suit { coeurs, carreaux, trefles, piques }

enum Rank {
  deux,
  trois,
  quatre,
  cinq,
  six,
  sept,
  huit,
  neuf,
  dix,
  valet,
  dame,
  roi,
  as,
}

class Card {
  final Suit suit;
  final Rank rank;
  Card(this.suit, this.rank);

  @override
  String toString() {
    final suitSymbols = {
      Suit.coeurs: '♥',
      Suit.carreaux: '♦',
      Suit.trefles: '♣',
      Suit.piques: '♠',
    };
    final rankLabels = {
      Rank.deux: '2',
      Rank.trois: '3',
      Rank.quatre: '4',
      Rank.cinq: '5',
      Rank.six: '6',
      Rank.sept: '7',
      Rank.huit: '8',
      Rank.neuf: '9',
      Rank.dix: '10',
      Rank.valet: 'J',
      Rank.dame: 'Q',
      Rank.roi: 'K',
      Rank.as: 'A',
    };
    return '${rankLabels[rank]}${suitSymbols[suit]}';
  }

  bool hasSameSuit(Card c) => c.suit == suit;
  bool hasSameRank(Card c) => c.rank == rank;

  int get rankValue => rank.index + 2;
}


class Deck {
  final List<Card> cards = [];

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
  bool hasActed = false;
  int lastBet = 0;

  Player(this.name, {this.chips = 1000});

  void addCard(Card c) => hand.add(c);
  void resetHand() => hand.clear();
}

class PokerGame {
  final Deck deck = Deck();
  final List<Player> players;
  List<Card> board = [];
  int pot = 0;
  int currentBet = 0;
  int dealerIndex = 0;

  PokerGame(this.players) {
    deck.shuffle();
  }

  void playClosedPoker() {
    resetForNewHand();
    dealHands();
    bettingRound();
    showDown();
  }

  void resetForNewHand() {
    deck.cards.addAll(board);
    board.clear();
    for (var p in players) {
      deck.cards.addAll(p.hand);
      p.resetHand();
      p.folded = false;
      p.hasActed = false;
      p.lastBet = 0;
    }
    pot = 0;
    currentBet = 0;
    deck.shuffle();
  }

  void dealHands() {
    for (var p in players) {
      p.addCard(deck.draw());
      p.addCard(deck.draw());
    }
  }

  void addCardToBoard(Card c) => board.add(c);

  void clearBoard() => board.clear();

  void bettingRound() {
    int idx = (dealerIndex + 1) % players.length;
    int toAct = players.where((p) => !p.folded).length;
    currentBet = 0;

    while (toAct > 0) {
      final p = players[idx];
      if (!p.folded) {
        _askAction(p);
        p.hasActed = true;
        toAct--;
      }
      idx = (idx + 1) % players.length;
    }

    dealerIndex = (dealerIndex + 1) % players.length;
  }

  void _askAction(Player p) {
    print(
      '\nTour de ${p.name}  |  Mise courante = $currentBet  |  Jetons = ${p.chips}',
    );
    print('Votre main : ${p.hand[0]}, ${p.hand[1]}');
    print('1) Fold   2) Call $currentBet   3) Raise   4) All-in');
    final choice = int.tryParse(stdin.readLineSync()!) ?? 0;

    switch (choice) {
      case 1:
        fold(p);
        break;
      case 2:
        call(p, currentBet);
        break;
      case 3:
        stdout.write('Montant de la relance : ');
        final amt = int.tryParse(stdin.readLineSync()!) ?? currentBet;
        raise(p, amt);
        currentBet = amt;
        break;
      case 4:
        allIn(p);
        if (p.lastBet > currentBet) {
          currentBet = p.lastBet;
        }
        break;
      default:
        print('Action invalide, réessayez.');
        _askAction(p);
    }
  }

  void showDown() {
    print('\n=== Showdown ===');
    final alive = players.where((p) => !p.folded).toList();
    final scores = <Player, int>{};

    for (var p in alive) {
      final score = evaluateHand(p.hand);
      scores[p] = score;
      print('${p.name} : ${p.hand[0]}, ${p.hand[1]} → score = $score');
    }

    final winner =
        scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    print('\nLe gagnant est ${winner.name}, il remporte $pot jetons !');
    winner.chips += pot;
  }

  int evaluateHand(List<Card> hand) {
    return hand.map((c) => c.rank.index).reduce((a, b) => a > b ? a : b);
  }

  void fold(Player p) {
    p.folded = true;
    print('${p.name} se couche.');
  }

  void call(Player p, int amount) {
    final toPay = amount - p.lastBet;
    if (p.chips >= toPay) {
      p.chips -= toPay;
      pot += toPay;
      p.lastBet = amount;
      print('${p.name} suit ($amount).');
    } else {
      print('${p.name} n’a pas assez de jetons pour suivre, il se couche.');
      fold(p);
    }
  }

  void raise(Player p, int amount) {
    final toPay = amount - p.lastBet;
    if (p.chips >= toPay) {
      p.chips -= toPay;
      pot += toPay;
      p.lastBet = amount;
      print('${p.name} relance à $amount.');
    } else {
      print('${p.name} n’a pas assez de jetons pour relancer, il se couche.');
      fold(p);
    }
  }

  void allIn(Player p) {
    final all = p.chips;
    pot += all;
    p.lastBet += all;
    p.chips = 0;
    print('${p.name} tape all-in ($all).');
  }
}

class GameMenu {
  void displayMenu() {
    print('\n=== ALABAMA HOLDEM POKER ===');
    print('1. Nouvelle partie');
    print('2. Règles du jeu');
    print('3. Quitter');
    stdout.write('\nVotre choix : ');
  }

  void showRules() {
    print('\n=== RÈGLES DU JEU ===');
    print('- Chaque joueur reçoit 2 cartes');
    print('- Un seul tour d’enchères');
    print('- La meilleure main gagne le pot');
    stdout.write('\nAppuyez sur Entrée pour revenir au menu...');
    stdin.readLineSync();
  }

  void startGame() {
    stdout.write('Combien de joueurs ? (2 par défaut) : ');
    int playerNb;
    try {
      playerNb = int.parse(stdin.readLineSync() ?? '2');
    } catch (e) {
      print('Utilisation de la valeur par défaut (2)');
      playerNb = 2;
    }

    stdout.write('Combien de jetons de départ ? (1000 par défaut) : ');
    int chipsPerPlayer;
    try {
      chipsPerPlayer = int.parse(stdin.readLineSync() ?? '1000');
    } catch (e) {
      print('Utilisation de la valeur par défaut (1000)');
      chipsPerPlayer = 1000;
    }

    final players = <Player>[];
    for (var i = 1; i <= playerNb; i++) {
      stdout.write('Nom du joueur n°$i : ');
      var name = stdin.readLineSync();
      if (name == null || name.trim().isEmpty) {
        name = 'Anonyme $i';
      }
      players.add(Player(name, chips: chipsPerPlayer));
    }

    final game = PokerGame(players);
    game.playClosedPoker();
  }
}

void main() {
  final menu = GameMenu();
  var running = true;

  while (running) {
    menu.displayMenu();
    final input = stdin.readLineSync();
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
