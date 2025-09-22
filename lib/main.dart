import 'package:flutter/material.dart';
import 'package:my_app/screens/character_screen.dart';
import 'package:my_app/screens/characters_screen.dart';
import 'package:my_app/screens/episodes_screen.dart';
import 'package:my_app/screens/home_screen.dart';

final mockCharacters = [
  Character(
    id: 361,
    name: "Toxic Rick",
    status: "Dead",
    species: "Humanoid",
    type: "Rick's Toxic Side",
    gender: "Male",
    image: "https://rickandmortyapi.com/api/character/avatar/361.jpeg",
    origin: Origin(
      name: "Alien Spa",
      url: "https://rickandmortyapi.com/api/location/64",
    ),
    location: Location(
      name: "Earth",
      url: "https://rickandmortyapi.com/api/location/20",
    ),
    episode: ["https://rickandmortyapi.com/api/episode/27"],
  ),
  Character(
    id: 1,
    name: "Rick Sanchez",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Male",
    image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
    origin: Origin(
      name: "Earth (C-137)",
      url: "https://rickandmortyapi.com/api/location/1",
    ),
    location: Location(
      name: "Citadel of Ricks",
      url: "https://rickandmortyapi.com/api/location/3",
    ),
    episode: [
      "https://rickandmortyapi.com/api/episode/1",
      "https://rickandmortyapi.com/api/episode/2",
      "https://rickandmortyapi.com/api/episode/3",
    ],
  ),
  Character(
    id: 2,
    name: "Morty Smith",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Male",
    image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
    origin: Origin(name: "unknown", url: ""),
    location: Location(
      name: "Citadel of Ricks",
      url: "https://rickandmortyapi.com/api/location/3",
    ),
    episode: [
      "https://rickandmortyapi.com/api/episode/1",
      "https://rickandmortyapi.com/api/episode/2",
    ],
  ),
  Character(
    id: 3,
    name: "Summer Smith",
    status: "Alive",
    species: "Human",
    type: "",
    gender: "Female",
    image: "https://rickandmortyapi.com/api/character/avatar/3.jpeg",
    origin: Origin(
      name: "Earth (Replacement Dimension)",
      url: "https://rickandmortyapi.com/api/location/20",
    ),
    location: Location(
      name: "Earth (Replacement Dimension)",
      url: "https://rickandmortyapi.com/api/location/20",
    ),
    episode: [
      "https://rickandmortyapi.com/api/episode/6",
      "https://rickandmortyapi.com/api/episode/7",
    ],
  ),
];

void main() {
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
        '/': (context) => HomeScreen(isAuthenticated: true),
        '/characters': (context) => CharactersScreen(),
        '/character': (context) => CharacterScreen(),
        '/episodes': (context) => EpisodesScreen(),
      },
    );
  }
}
