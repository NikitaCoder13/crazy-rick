import 'package:flutter/material.dart';
import 'package:my_app/screens/character_detail_screen.dart';
import 'package:my_app/screens/characters_screen.dart';
import 'package:my_app/screens/episode_detail_screen.dart';
import 'package:my_app/screens/episodes_screen.dart';
import 'package:my_app/screens/favorites_screen.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/register_screen.dart';
import 'package:my_app/screens/settings_screen.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.amber),
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: Colors.amber,
        fontFamily: 'TinkoffSans',
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          labelSmall: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/characters': (context) => CharactersScreen(),
        '/character': (context) => CharacterDetailScreen(),
        '/episodes': (context) => EpisodesScreen(),
        '/episode': (context) => EpisodeDetailScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

// Обертка для проверки аутентификации
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;

    if (user != null) {
      return HomeScreen(isAuthenticated: true);
    } else {
      return LoginScreen();
    }
  }
}
