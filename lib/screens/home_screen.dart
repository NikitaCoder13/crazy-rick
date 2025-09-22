import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final bool isAuthenticated;

  const HomeScreen({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Добро пожаловать!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Исследуйте вселенную Рика и Морти',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  // Карточка "Персонажи"
                  _buildNavigationCard(
                    context,
                    icon: Icons.people,
                    title: 'Персонажи',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).pushNamed('/characters');
                    },
                  ),
                  // Карточка "Эпизоды"
                  _buildNavigationCard(
                    context,
                    icon: Icons.movie,
                    title: 'Эпизоды',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pushNamed('/episodes');
                    },
                  ),
                  // Карточка "Избранные персонажи"
                  _buildNavigationCard(
                    context,
                    icon: Icons.favorite,
                    title: "Избранное",
                    color: Colors.red,
                    onTap: () {
                      // Переход к эпизодам
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildNavigationCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ),
  );
}
