import 'package:flutter/material.dart';
import 'package:my_app/models/character.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/widgets/character_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Character> favoriteCharacters = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (SupabaseService.currentUser == null) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final favoriteIds = await SupabaseService.getFavorites();
      final characters = await _loadCharactersByIds(favoriteIds.toList());

      setState(() {
        favoriteCharacters = characters;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<List<Character>> _loadCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await ApiService.getCharactersByIds(ids);
      return (response as List)
          .map((characterJson) => Character.fromJson(characterJson))
          .toList();
    } catch (e) {
      final List<Character> characters = [];
      for (final id in ids) {
        try {
          final characterJson = await ApiService.getCharacter(id);
          final character = Character.fromJson(characterJson);
          characters.add(character);
        } catch (_) {
          continue;
        }
      }
      return characters;
    }
  }

  void _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await _loadFavorites();
  }

  void _onCharacterTap(Character character) {
    Navigator.of(context).pushNamed('/character', arguments: character);
  }

  void _onToggleFavorite(Character character) async {
    try {
      await SupabaseService.removeFromFavorites(character.id);
      setState(() {
        favoriteCharacters.removeWhere((c) => c.id == character.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${character.name} удален из избранного')),
      );
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
        title: const Text('Избранные персонажи'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh),
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
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Ошибка загрузки избранных',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _onRefresh, child: const Text('Повторить')),
          ],
        ),
      );
    }

    if (favoriteCharacters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Нет избранных персонажей',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/characters');
              },
              child: const Text('Перейти к персонажам'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        itemCount: favoriteCharacters.length,
        itemBuilder: (context, index) {
          final character = favoriteCharacters[index];
          return CharacterCard(
            character: character,
            isFavorite: true, // Всегда true на этом экране
            onTap: () => _onCharacterTap(character),
            onToggleFavorite: () => _onToggleFavorite(character),
          );
        },
      ),
    );
  }
}
