import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_layout.dart';

import 'my_page_provider.dart';

class MyPageScreen extends ConsumerWidget {
  static String get name => 'my_page';

  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(myPageProvider);

    return memberState.when(
      loading: () => const CircularProgressIndicator(),
      data: (memberInfo) => Text('$memberInfo'),
      error: (err, stack) => Text('$err'),
    );

    // return DefaultLayout(
    //   title: '마이 페이지',
    //   child: SafeArea(
    //     child: DefaultLayout(
    //       title: '마이 페이지',
    //       child: Column(
    //         children: [
    //           Row(
    //             children: [
    //               Image.network(
    //                 .,
    //                 fit: BoxFit.cover,
    //               ),
    //               Column(
    //                 children: [
    //                   Text('',)
    //                 ],
    //               )
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
