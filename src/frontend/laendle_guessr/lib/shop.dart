import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  final int coinBalance = 2043;

  final List<Character> characters = [
    Character(name: 'Elkin', asset: 'assets/images/elkin.png'),
    Character(name: 'Riddle', asset: 'assets/images/riddle.png'),
    Character(name: 'Ursa', asset: 'assets/images/ursa.png'),
    Character(name: 'Aster', asset: 'assets/images/aster.png'),
    Character(name: 'Foxtrot', asset: 'assets/images/foxrot.png'),
    Character(name: 'Fritz', asset: 'assets/images/fritz.png'),
  ];

  ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '$coinBalance',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return CharacterCard(character: character);
        },
      ),
    );
  }
}

class Character {
  final String name;
  final String asset;
  final int price;

  Character({required this.name, required this.asset, this.price = 200});
}

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Image.asset(character.asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            character.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${character.price} ',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
