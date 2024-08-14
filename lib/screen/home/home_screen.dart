import 'package:flutter/material.dart';

import 'package:gather_here/common/components/default_layout.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'Home',
      backgroundColor: Colors.red,
      appBarBackgroundColor: Colors.green,
      child: Center(
        child: ElevatedButton(onPressed: (){
          context.pushNamed('home');
        }, child: Text('Push')),
      ),
    );
  }
}
