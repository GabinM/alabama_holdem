import 'dart:io';

// Énumération des couleurs de cartes
enum Suit { coeurs, carreaux, trefles, piques }

// Énumération des valeurs de cartes
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

// Classe représentant une carte avec sa couleur et sa valeur
class Card {
  final Suit suit;
  final Rank rank;
  Card(this.suit, this.rank);

  // Convertit la carte en chaîne de caractères (ex: "A♥" pour As de Coeur)
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

  // Vérifie si deux cartes ont la même couleur
  bool hasSameSuit(Card c) => c.suit == suit;
  // Vérifie si deux cartes ont la même valeur
  bool hasSameRank(Card c) => c.rank == rank;

  // Retourne la valeur numérique de la carte (2-14)
  int get rankValue => rank.index + 2;
}

// Classe représentant un jeu de 52 cartes
class Deck {
  final List<Card> cards = [];

  // Initialise un jeu complet de 52 cartes
  Deck() {
    for (var s in Suit.values) {
      for (var r in Rank.values) {
        cards.add(Card(s, r));
      }
    }
  }

  // Mélange le jeu de cartes
  void shuffle() => cards.shuffle();
  // Tire une carte du dessus du jeu
  Card draw() => cards.removeLast();
}

// Classe représentant un joueur
class Player {
  final String name;
  int chips;  // Nombre de jetons du joueur
  List<Card> hand = [];  // Main du joueur
  bool folded = false;  // Si le joueur s'est couché
  bool hasActed = false;  // Si le joueur a déjà agi dans le tour actuel
  int totalBet = 0;  // Mise totale du joueur dans la main
  int lastBet = 0;  // Dernière mise du joueur

  Player(this.name, {this.chips = 1000});

  // Ajoute une carte à la main du joueur
  void addCard(Card c) => hand.add(c);
  // Vide la main du joueur
  void resetHand() => hand.clear();
}

// Classe principale du jeu de poker
class PokerGame {
  final Deck deck = Deck();
  final List<Player> players;
  List<Card> board = [];  // Cartes sur la table
  int pot = 0;  // Pot actuel
  int currentBet = 0;  // Mise courante
  int dealerIndex = 0;  // Index du donneur

  PokerGame(this.players) {
    deck.shuffle();
  }

  // Joue une main complète de poker fermé
  void playClosedPoker() {
    resetForNewHand();
    dealHands();
    bettingRound();
    showDown();
  }

  // Réinitialise le jeu pour une nouvelle main
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

  // Distribue 5 cartes à chaque joueur
  void dealHands() {
    for (var p in players) {
      for (int i=0; i<5; i++) {
        p.addCard(deck.draw());
      }
    }
  }

  // Ajoute une carte sur la table
  void addCardToBoard(Card c) => board.add(c);

  // Vide la table
  void clearBoard() => board.clear();

  // Gère un tour d'enchères
  void bettingRound() {
    int idx = (dealerIndex + 1) % players.length;
    int toAct = players.where((p) => !p.folded).length;
    currentBet = 0;

    while (toAct > 0) {
      final p = players[idx];
      if (!p.folded) {
        _askAction(p);
        p.hasActed = true;
        if (players.where((p) => p.totalBet==currentBet && p.hasActed).length == players.where((p) => !p.folded).length) {
          toAct = 0;
        }
      }
      idx = (idx + 1) % players.length;
    }

    dealerIndex = (dealerIndex + 1) % players.length;
  }

  // Demande une action au joueur (suivre, relancer, se coucher, all-in)
  void _askAction(Player p) {
    print('\x1B[2J\x1B[0;0H');
    print(
      '\nTour de ${p.name}  |  Mise courante = $currentBet  |  Jetons = ${p.chips}',
    );
    print("Appuyez pour afficher la main");
    stdin.readLineSync();
    String rangMain1 = p.hand[0].toString();
    rangMain1 = rangMain1.substring(0, rangMain1.length - 1);
    if (rangMain1.length == 1) {
      rangMain1 += " ";
    }
    String rangMain2 = p.hand[1].toString();
    rangMain2 = rangMain2.substring(0, rangMain2.length - 1);
    if (rangMain2.length == 1) {
      rangMain2 += " ";
    }
    String rangMain3 = p.hand[2].toString();
    rangMain3 = rangMain3.substring(0, rangMain3.length - 1);
    if (rangMain3.length == 1) {
      rangMain3 += " ";
    }
    String rangMain4 = p.hand[3].toString();
    rangMain4 = rangMain4.substring(0, rangMain4.length - 1);
    if (rangMain4.length == 1) {
      rangMain4 += " ";
    }
    String rangMain5 = p.hand[4].toString();
    rangMain5 = rangMain5.substring(0, rangMain5.length - 1);
    if (rangMain5.length == 1) {
      rangMain5 += " ";
    }
    print("======= VOTRE MAIN ======\n");
    print(".---------.   .---------.   .---------.   .---------.   .---------.");    
    print("|      ${rangMain1} |   |      ${rangMain2} |   |      ${rangMain3} |   |      ${rangMain4} |   |      ${rangMain5} |");
    print("|         |   |         |   |         |   |         |   |         |");
    print("|    ${p.hand[0].toString()[p.hand[0].toString().length - 1]}    |   |    ${p.hand[1].toString()[p.hand[1].toString().length - 1]}    |   |    ${p.hand[2].toString()[p.hand[2].toString().length - 1]}    |   |    ${p.hand[3].toString()[p.hand[3].toString().length - 1]}    |   |    ${p.hand[4].toString()[p.hand[4].toString().length - 1]}    |",);
    print("|         |   |         |   |         |   |         |   |         |");
    print("| ${rangMain1}      |   | ${rangMain2}      |   | ${rangMain3}      |   | ${rangMain4}      |   | ${rangMain5}      |");
    print("._________.   ._________.   ._________.   ._________.   ._________.");
    print("");
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

  // Évalue les mains et détermine le gagnant
  void showDown() {
    print('\n=== Showdown ===');
    final alive = players.where((p) => !p.folded).toList();
    final scores = <Player, List<int>>{};

    for (var p in alive) {
      final score = evaluateHand(p.hand);
      scores[p] = score;
      print('${p.name} : ${p.hand[0]}, ${p.hand[1]}, ${p.hand[2]}, ${p.hand[3]}, ${p.hand[4]} → score = $score');
    }

    final validScores = scores.entries;
    if (validScores.isEmpty) {
      print("Erreur : aucune main évaluée.");
      return;
    }

    final winner =
        validScores
            .reduce((a, b) => compareHandsValue(a.value, b.value) ? a : b)
            .key;

    print('\nLe gagnant est ${winner.name}, il remporte $pot jetons !');
    winner.chips += pot;
  }

  // Le joueur se couche
  void fold(Player p) {
    p.folded = true;
    print('${p.name} se couche.');
  }

  // Le joueur suit la mise courante
  void call(Player p, int amount) {
    final toPay = amount - p.lastBet;
    if (p.chips >= toPay) {
      p.chips -= toPay;
      pot += toPay;
      p.lastBet = amount;
      p.totalBet += amount;
      print('${p.name} suit ($amount).');
    } else {
      print("${p.name} n'a pas assez de jetons pour suivre, il se couche.");
      fold(p);
    }
  }

  // Le joueur relance
  void raise(Player p, int amount) {
    final toPay = amount - p.lastBet;
    if (p.chips >= toPay) {
      p.chips -= toPay;
      pot += toPay;
      p.lastBet = amount;
      p.totalBet += amount;
      print('${p.name} relance à $amount.');
    } else {
      print("${p.name} n'a pas assez de jetons pour relancer, il se couche.");
      fold(p);
    }
  }

  // Évalue la force d'une main de poker
  List<int> evaluateHand(List<Card> cards) {
    cards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
    final values = cards.map((c) => c.rankValue).toList();

    final isFlush = cards.every((c) => c.suit == cards[0].suit);
    final isStraight = _isStraight(values);

    final rankCounts = <int, int>{};
    for (var c in cards) {
      rankCounts[c.rankValue] = (rankCounts[c.rankValue] ?? 0) + 1;
    }

    final counts =
        rankCounts.entries.toList()..sort(
          (a, b) =>
              b.value == a.value
                  ? b.key.compareTo(a.key)
                  : b.value.compareTo(a.value),
        );

    final countValues = counts.map((e) => e.value).toList();
    final rankValues = counts.map((e) => e.key).toList();

    // Détermine le type de main
    if (isFlush && isStraight && values.first == 14) {
      return [9]; // Quinte flush royale
    } else if (isFlush && isStraight) {
      return [8, values.first]; // Quinte flush
    } else if (countValues[0] == 4) {
      return [7, rankValues[0], rankValues[1]]; // Carré
    } else if (countValues[0] == 3 && countValues[1] == 2) {
      return [6, rankValues[0], rankValues[1]]; // Full
    } else if (isFlush) {
      return [5, ...values]; // Couleur
    } else if (isStraight) {
      return [4, values.first]; // Suite
    } else if (countValues[0] == 3) {
      return [3, rankValues[0], ...rankValues.sublist(1)]; // Brelan
    } else if (countValues[0] == 2 && countValues[1] == 2) {
      return [2, rankValues[0], rankValues[1], rankValues[2]]; // Double paire
    } else if (countValues[0] == 2) {
      return [1, rankValues[0], ...rankValues.sublist(1)]; // Une paire
    } else {
      return [0, ...values]; // Carte haute
    }
  }

  // Vérifie si les cartes forment une suite
  bool _isStraight(List<int> values) {
    final unique = values.toSet().toList()..sort((a, b) => b.compareTo(a));
    if (unique.length < 5) return false;

    for (int i = 0; i <= unique.length - 5; i++) {
      if (unique[i] - unique[i + 4] == 4) {
        return true;
      }
    }

    // Cas spécial : A-2-3-4-5
    return unique.contains(14) &&
        unique.contains(2) &&
        unique.contains(3) &&
        unique.contains(4) &&
        unique.contains(5);
  }

  // Compare deux mains pour déterminer la plus forte
  bool compareHandsValue(List<int> h1, List<int> h2) {
    for (int i = 0; i < h1.length && i < h2.length; i++) {
      if (h1[i] > h2[i]) return true;
      if (h1[i] < h2[i]) return false;
    }
    return true;
  }

  // Le joueur mise tous ses jetons
  void allIn(Player p) {
    final all = p.chips;
    pot += all;
    p.lastBet += all;
    p.chips = 0;
    print('${p.name} tape all-in ($all).');
  }
}

// Classe gérant le menu principal du jeu
class GameMenu {
  // Affiche le menu principal
  void displayMenu() {
    print('\n=== ALABAMA HOLDEM POKER ===');
    print('1. Nouvelle partie');
    print('2. Règles du jeu');
    print('3. Quitter');
    stdout.write('\nVotre choix : ');
  }

  // Affiche les règles du jeu
  void showRules() {
    print('\n=== RÈGLES DU JEU ===');
    print('- Chaque joueur reçoit 2 cartes');
    print("- Un seul tour d'enchères");
    print('- La meilleure main gagne le pot');
    stdout.write('\nAppuyez sur Entrée pour revenir au menu...');
    stdin.readLineSync();
  }

  // Démarre une nouvelle partie
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

// Point d'entrée du programme
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
