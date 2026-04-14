import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _messages = [
    '⚽ O time de hoje tá rindo da sua cara. Quantas tentativas você vai precisar?',
    '🔥 Todo mundo já jogou o Futdle hoje. E você, vai ficar de fora?',
    '😏 Novo desafio liberado. Tá com medo de errar?',
    '🏆 O ranking de hoje tá rolando. Bora mostrar quem manda!',
    '⚡ Um novo time pra adivinhar. Será que você consegue de primeira?',
    '🎯 Desafio do dia liberado! Prove que você manja de futebol.',
    '😤 Seus amigos já jogaram. Não deixa eles tirarem onda de você!',
    '🌟 Novo dia, novo time. Vem mostrar seu conhecimento!',
    '👀 O time de hoje é difícil. Será que você acerta?',
    '🔔 Futdle te desafia! Quantas tentativas você vai precisar hoje?',
  ];

  static int get _dayOfYear {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays;
  }

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await scheduleDailyNotification();
  }

  static Future<void> scheduleDailyNotification() async {
    await _plugin.cancelAll();

    final messageIndex = _dayOfYear % _messages.length;

    // Schedule for 10:00 AM today, or tomorrow if already past
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'Futdle ⚽',
      _messages[messageIndex],
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'futdle_daily',
          'Desafio Diário',
          channelDescription: 'Lembrete diário do Futdle',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
