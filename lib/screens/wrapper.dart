import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smg07/models/user.dart';
import 'package:smg07/screens/main_menu.dart';

import 'authenticate/authenticate.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return S_MainMenu();
    }
  }
}
