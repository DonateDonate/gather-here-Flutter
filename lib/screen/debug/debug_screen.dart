import 'package:flutter/material.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/const/const.dart';

class DebugScreen extends StatefulWidget {
  static get name => 'debug';

  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String url = '';

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(
        children: [
          TextField(
            onChanged: (text) {
              setState(() {
                this.url = text;
              });
            },
          ),
          DefaultButton(title: '변경하기', onTap: (){
            Const.changeURLs(url);
          })
        ],
      ),
    );
  }
}
