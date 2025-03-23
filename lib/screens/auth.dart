import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:wetube/screens/about.dart';
import 'package:wetube/utils/launch_url.dart';
import 'package:wetube/widgets/google_auth_button.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * 0.75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage("assets/logo.png"),
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: MediaQuery.of(context).size.width * 0.25,
                        ),
                        const Text(
                          "WeTube",
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: GoogleAuthButton(),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 20,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => About(),
                            ),
                          );
                        },
                        child: Column(
                          spacing: 10,
                          children: [
                            Icon(Icons.info),
                            const Text("About us"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          openUrl('https://github.com/parbhat-cpp/wetube-app');
                        },
                        child: Column(
                          spacing: 10,
                          children: [
                            Icon(Bootstrap.github),
                            const Text("GitHub"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
