import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Аутентификация
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // Избранные персонажи
  static Future<void> addToFavorites(int characterId) async {
    await client.from('favorites').insert({
      'user_id': currentUser!.id,
      'character_id': characterId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> removeFromFavorites(int characterId) async {
    await client
        .from('favorites')
        .delete()
        .eq('user_id', currentUser!.id)
        .eq('character_id', characterId);
  }

  static Future<Set<int>> getFavorites() async {
    final response = await client
        .from('favorites')
        .select('character_id')
        .eq('user_id', currentUser!.id);

    return (response as List)
        .map((item) => item['character_id'] as int)
        .toSet();
  }
}
