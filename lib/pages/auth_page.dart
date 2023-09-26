import 'dart:convert';

import 'package:faulty_vaulty/pages/home_page.dart';
import 'package:faulty_vaulty/services/file_services.dart';
import 'package:faulty_vaulty/widgets/clear_button_widget.dart';
import 'package:faulty_vaulty/widgets/confirm_button_widget.dart';
import 'package:faulty_vaulty/widgets/passcode_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String? passcode;

  String capturedPasscode = "";
  capturePasscode({required int value}) {
    String intial = capturedPasscode;
    String newcode = "$intial$value";
    setState(() {
      capturedPasscode = newcode;
      wrongPasscode = false;
    });
  }

  clearPasscode() {
    String intial = capturedPasscode;
    String newcode = intial.substring(0, intial.length - 1);
    setState(() {
      capturedPasscode = newcode;
      wrongPasscode = false;
    });
  }

  bool passcodeVisible = false;

  bool wrongPasscode = false;

  bool fetching = true;
  Future fetchPasscode() async {
    await FileServices.userPasscodeFile().then(
      (file) async {
        final content = await file.readAsString();
        Map json = {};
        if (content.isNotEmpty) {
          json = jsonDecode(content) as Map;
          setState(() {
            passcode = json['passcode'];
            fetching = false;
          });
        }
      },
    );
  }

  @override
  void initState() {
    fetchPasscode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        statusBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
            Theme.of(context).colorScheme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            Theme.of(context).colorScheme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    passcode == null ? "Create Passcode" : "Enter Passcode",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  capturedPasscode.trim().isEmpty
                      ? "_ _ _ _"
                      : passcodeVisible
                          ? capturedPasscode
                          : capturedPasscode.replaceAll(RegExp(r'[0-9]'), "*"),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                if (wrongPasscode)
                  const Text(
                    "Wrong Passcode",
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                AnimatedOpacity(
                  opacity: capturedPasscode.trim().isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        passcodeVisible = !passcodeVisible;
                      });
                      Future.delayed(const Duration(seconds: 5), () {
                        setState(() {
                          passcodeVisible = false;
                        });
                      });
                    },
                    icon: Icon(
                      passcodeVisible ? Iconsax.eye_slash : Iconsax.eye,
                    ),
                  ),
                ),
                Table(
                  children: [
                    TableRow(
                      children: [
                        PasscodeInputWidget(
                            value: 1, function: capturePasscode),
                        PasscodeInputWidget(
                            value: 2, function: capturePasscode),
                        PasscodeInputWidget(
                            value: 3, function: capturePasscode),
                      ],
                    ),
                    TableRow(
                      children: [
                        PasscodeInputWidget(
                            value: 4, function: capturePasscode),
                        PasscodeInputWidget(
                            value: 5, function: capturePasscode),
                        PasscodeInputWidget(
                            value: 6, function: capturePasscode),
                      ],
                    ),
                    TableRow(
                      children: [
                        PasscodeInputWidget(
                            value: 7, function: capturePasscode),
                        PasscodeInputWidget(
                            value: 8, function: capturePasscode),
                        PasscodeInputWidget(
                            value: 9, function: capturePasscode),
                      ],
                    ),
                    TableRow(
                      children: [
                        AnimatedOpacity(
                          opacity:
                              capturedPasscode.trim().isNotEmpty ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 700),
                          child: GestureDetector(
                            onTap: () {
                              clearPasscode();
                            },
                            child: const ClearButtonWidget(),
                          ),
                        ),
                        PasscodeInputWidget(
                            value: 0, function: capturePasscode),
                        AnimatedOpacity(
                          opacity:
                              capturedPasscode.trim().isNotEmpty ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 700),
                          child: GestureDetector(
                            onTap: () {
                              if (passcode == null) {
                                FileServices.userPasscodeFile().then(
                                  (file) async {
                                    Map json = {
                                      "passcode": capturedPasscode,
                                    };
                                    await file.writeAsString(jsonEncode(json));
                                  },
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const HomePage();
                                    },
                                  ),
                                );
                              } else {
                                if (passcode == capturedPasscode) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const HomePage();
                                      },
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    wrongPasscode = true;
                                  });
                                }
                              }
                            },
                            child: const ConfirmButtonWidget(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
