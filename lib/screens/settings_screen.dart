import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadNotificationSettings();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _notificationsEnabled = false;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (enabled) {
      final bool? result = await _requestNotificationPermission();
      if (result == true) {
        setState(() {
          _notificationsEnabled = true;
        });
        _showNotificationEnabledToast();
      }
    } else {
      setState(() {
        _notificationsEnabled = false;
      });
      await _notificationsPlugin.cancelAll();
    }
  }

  Future<bool?> _requestNotificationPermission() async {
    final androidResult = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (androidResult != null) return androidResult;

    final iosResult = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return iosResult;
  }

  void _showNotificationEnabledToast() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Уведомления включены')));
  }

  Future<void> _testNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Тестовое уведомление',
      'Это тест пуш-уведомления от Rick and Morty App!',
      details,
    );
  }

  Future<void> _logout() async {
    await SupabaseService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Уведомления'),
          _buildNotificationSettings(),

          const SizedBox(height: 24),
          _buildSectionHeader('Аккаунт'),
          _buildAccountSettings(),

          const SizedBox(height: 24),
          _buildSectionHeader('О приложении'),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.amber,
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Пуш-уведомления', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: Colors.amber,
                ),
              ],
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.notifications),
                label: const Text('Тестовое уведомление'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Email'),
              subtitle: Text(
                SupabaseService.currentUser?.email ?? 'Неизвестно',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Избранные персонажи'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Выйти', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rick and Morty App',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Версия: 1.0.0', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Данные: The Rick and Morty API',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
