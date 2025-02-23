import 'package:flutter/material.dart';
import 'package:wetube/utils/launch_url.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About us'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Text(
                'This app is created by Parbhat Sharma, a Full stack developer. It is a hobby project with a sole purpose of connecting people and have a good time here.',
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text('For more information about the creator '),
                  GestureDetector(
                    onTap: () => openUrl('http://parbhatsharma.in/'),
                    child: const Text(
                      'click here',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
