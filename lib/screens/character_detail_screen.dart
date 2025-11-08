import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_app/models/character.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:my_app/widgets/info_card_widget.dart';
import 'package:my_app/widgets/info_row_widget.dart';

class CharacterDetailScreen extends StatelessWidget {
  static const routeName = '/character';

  const CharacterDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final character = ModalRoute.of(context)!.settings.arguments as Character;

    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        backgroundColor: Colors.amber,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар по центру
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: character.image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Статус и пол
            _buildStatusRow(character),
            const SizedBox(height: 16),

            // Основная информация
            buildInfoCard('Основная информация', [
              buildInfoRow('Вид', character.species),
              if (character.type.isNotEmpty)
                buildInfoRow('Тип', character.type),
              buildInfoRow('Пол', character.gender),
            ]),
            const SizedBox(height: 16),

            // Локации
            buildInfoCard('Локации', [
              buildInfoRow('Происхождение', character.origin.name),
              buildInfoRow('Местоположение', character.location.name),
            ]),

            // Эпизоды (если нужно показать список)
            if (character.episode.isNotEmpty) ...[
              const SizedBox(height: 16),
              buildInfoCard('Эпизоды (${character.episode.length})', [
                // Можно добавить список эпизодов
              ]),
            ],
          ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '${character.status} - ${character.gender}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
