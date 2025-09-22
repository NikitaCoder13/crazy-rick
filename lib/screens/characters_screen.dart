import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_app/services/api_service.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  List<Character> characters = [];
  Set<int> favoriteIds = {};
  bool isLoading = true;
  bool hasMore = true;
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadCharacters();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreCharacters();
    }
  }

  Future<void> _loadCharacters() async {
    try {
      final data = await ApiService.getCharacters(1);
      setState(() {
        characters = _parseCharacters(data);
        isLoading = false;
        hasMore = data['info']['next'] != null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Обработка ошибки
    }
  }

  Future<void> _loadMoreCharacters() async {
    if (!hasMore || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.getCharacters(currentPage + 1);
      setState(() {
        characters.addAll(_parseCharacters(data));
        currentPage++;
        hasMore = data['info']['next'] != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Character> _parseCharacters(Map<String, dynamic> data) {
    return (data['results'] as List)
        .map((characterJson) => Character.fromJson(characterJson))
        .toList();
  }

  void _onCharacterTap(Character character) {
    Navigator.of(context).pushNamed('/character', arguments: character);
  }

  void _onToggleFavorite(Character character) {
    setState(() {
      if (favoriteIds.contains(character.id)) {
        favoriteIds.remove(character.id);
      } else {
        favoriteIds.add(character.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crazy Rickkk!'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Навигация к экрану настроек
            },
          ),
        ],
      ),
      body: isLoading && characters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: characters.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == characters.length) {
                        return _buildLoader();
                      }

                      final character = characters[index];
                      final isFavorite = favoriteIds.contains(character.id);

                      return CharacterCard(
                        character: character,
                        isFavorite: isFavorite,
                        onTap: () => _onCharacterTap(character),
                        onToggleFavorite: () => _onToggleFavorite(character),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: hasMore
            ? CircularProgressIndicator()
            : Text('Все персонажи загружены!'),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const CharacterCard({
    Key? key,
    required this.character,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар персонажа
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: character.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Информация о персонаже
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildStatusRow(character),
                    const SizedBox(height: 4),
                    Text(
                      'Species: ${character.species}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    if (character.type.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Type: ${character.type}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'Origin: ${character.origin.name}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Кнопка избранного
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(Character character) {
    Color statusColor;
    switch (character.status.toLowerCase()) {
      case 'alive':
        statusColor = Colors.green;
        break;
      case 'dead':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '${character.status} - ${character.gender}',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// в идеале перекинуть модели в отдельынй файл
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final Origin origin;
  final Location location;
  final List<String> episode;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episode,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      type: json['type'] ?? '',
      gender: json['gender'],
      image: json['image'],
      origin: Origin.fromJson(json['origin']),
      location: Location.fromJson(json['location']),
      episode: List<String>.from(json['episode']),
    );
  }
}

class Origin {
  final String name;
  final String url;

  Origin({required this.name, required this.url});

  factory Origin.fromJson(Map<String, dynamic> json) {
    return Origin(name: json['name'], url: json['url']);
  }
}

class Location {
  final String name;
  final String url;

  Location({required this.name, required this.url});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(name: json['name'], url: json['url']);
  }
}
