// stub — replaced in Task 12
import 'package:flutter/material.dart';
class OfficialLeagueScreen extends StatelessWidget {
  final String mode;
  const OfficialLeagueScreen({super.key, required this.mode});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Official $mode')));
}
