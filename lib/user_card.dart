import 'package:flutter/material.dart';

import 'user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text("${user.sex} - Ativo: ${user.active}"),
    );
  }
}
