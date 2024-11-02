import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 0, 0, 0),
            blurRadius: 25,
            spreadRadius: 1,
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Event Gate",
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 27,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  "assets/images/landing.png",
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  semanticLabel: "Landing Image",
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Welcome to Event Gate",
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "EventGate is a platform that allows you to create, find, and manage events. You can create events, invite people, and manage the event details.",
                        style: TextStyle(
                          color: Color.fromARGB(255, 128, 128, 128),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Get Started"),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    )));
  }
}
