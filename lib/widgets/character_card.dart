import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/character.dart';

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
                    const SizedBox(height: 2),
                    _buildStatusRow(character),
                    const SizedBox(height: 2),
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
