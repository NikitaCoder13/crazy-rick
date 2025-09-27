import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:my_app/widgets/info_card_widget.dart';
import 'package:my_app/widgets/info_row_widget.dart';

class EpisodeDetailScreen extends StatelessWidget {
  static const routeName = '/episode';

  const EpisodeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ID эпизода из аргументов
    final episodeId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Эпизод'),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getEpisode(episodeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final episode = snapshot.data!;
          return _buildEpisodeContent(episode);
        },
      ),
    );
  }

  Widget _buildEpisodeContent(Map<String, dynamic> episode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Center(
            child: Text(
              episode['name'] ?? 'Без названия',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Код эпизода
          Center(
            child: Text(
              episode['episode'] ?? 'Неизвестно',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),

          // Информация
          buildInfoCard('Информация', [
            buildInfoRow('Дата выхода', episode['air_date'] ?? 'Неизвестно'),
            buildInfoRow('Код', episode['episode'] ?? 'Неизвестно'),
          ]),

          // Персонажи (можно сделать кликабельный список)
          if (episode['characters'] != null) ...[
            const SizedBox(height: 16),
            buildInfoCard(
              'Персонажи (${(episode['characters'] as List).length})',
              [
                // Можно добавить список персонажей
                Text(
                  'Появлений: ${(episode['characters'] as List).length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
