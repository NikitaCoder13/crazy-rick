import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_app/models/character.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:my_app/widgets/character_card.dart';

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
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (SupabaseService.currentUser != null) {
      final favorites = await SupabaseService.getFavorites();
      if (mounted) {
        setState(() {
          favoriteIds = favorites;
        });
      }
    }
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

  void _onToggleFavorite(Character character) async {
    if (SupabaseService.currentUser == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      if (favoriteIds.contains(character.id)) {
        await SupabaseService.removeFromFavorites(character.id);
      } else {
        await SupabaseService.addToFavorites(character.id);
      }

      setState(() {
        if (favoriteIds.contains(character.id)) {
          favoriteIds.remove(character.id);
        } else {
          favoriteIds.add(character.id);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Персонажи'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
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
