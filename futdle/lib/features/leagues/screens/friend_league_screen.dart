// stub — replaced in Task 15
import 'package:flutter/material.dart';
class FriendLeagueScreen extends StatelessWidget {
  final String leagueId;
  const FriendLeagueScreen({super.key, required this.leagueId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Friend $leagueId')));
}
