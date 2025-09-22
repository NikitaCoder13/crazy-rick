import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/episode.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({super.key});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  List<Episode> episodes = [];
  bool isLoading = true;
  bool hasMore = true;
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadEpisodes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreEpisodes();
    }
  }

  Future<void> _loadEpisodes() async {
    try {
      final data = await ApiService.getEpisodes(1);
      setState(() {
        episodes = _parseEpisodes(data);
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

  Future<void> _loadMoreEpisodes() async {
    if (!hasMore || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.getEpisodes(currentPage + 1);
      setState(() {
        episodes.addAll(_parseEpisodes(data));
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

  List<Episode> _parseEpisodes(Map<String, dynamic> data) {
    return (data['results'] as List)
        .map((episodeJson) => Episode.fromJson(episodeJson))
        .toList();
  }

  void _onEpisodeTap(Episode episode) {
    // Навигация к деталям эпизода
    Navigator.of(context).pushNamed('/episode', arguments: episode);
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
      body: isLoading && episodes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: episodes.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == episodes.length) {
                        return _buildLoader();
                      }

                      final episode = episodes[index];
                      return EpisodeCard(
                        episode: episode,
                        onTap: () => _onEpisodeTap(episode),
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
            : Text('Все эпизоды загружены!'),
      ),
    );
  }
}

// Виджет карточки эпизода
class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final VoidCallback onTap;

  const EpisodeCard({Key? key, required this.episode, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(episode.name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                episode.episode,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Air date: ${episode.airDate}',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Characters: ${episode.characters.length}',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
