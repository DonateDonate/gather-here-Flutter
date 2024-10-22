import 'package:flutter/material.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeveloperScreen extends StatelessWidget {
  static get name => 'developer';
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
        appBarBackgroundColor: Colors.blueAccent,
        backgroundColor: Colors.blueAccent,
        titleColor: Colors.white,
        title: '팀원소개',
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gather Here! 를\n개발한 사람들',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColor.white),
              ),
              SizedBox(height: 20),
              _Box(
                title: 'Flutter',
                iconName: ['flutter'],
                names: ['김도연', '김종민'],
                urls: ['https://github.com/FirstDo', 'https://github.com/spicypunch'],
              ),
              SizedBox(height: 20),
              _Box(
                title: 'Backend',
                iconName: ['spring', 'ubuntu'],
                names: ['김산하'],
                urls: ['https://github.com/kimsanhaa'],
              ),
            ],
          ),
        ));
  }
}

class _Box extends StatelessWidget {
  final String title;
  final List<String> iconName;
  final List<String> names;
  final List<String> urls;

  const _Box({
    required this.title,
    required this.iconName,
    required this.names,
    required this.urls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stackHeader(),
          const SizedBox(height: 10),
          ...List.generate(names.length, (index) => index).map(
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  launchUrlString(urls[index]);
                },
                borderRadius: BorderRadius.circular(10),
                child: _member(names[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stackHeader() {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColor.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const Spacer(),
        ...iconName.map((name) => Container(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset('asset/img/$name.png', width: 20, height: 20, fit: BoxFit.fill),
            )),
      ],
    );
  }

  Widget _member(String name) {
    return Ink(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Image.asset('asset/img/github.png', width: 20, height: 20),
          ),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(color: AppColor.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColor.white),
        ],
      ),
    );
  }
}
