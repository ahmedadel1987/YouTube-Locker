import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FamilyControlApp());
}

class FamilyControlApp extends StatelessWidget {
  const FamilyControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Pro ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform =
  MethodChannel('family_control/device_policy');

  bool locked = false;
  bool busy = false;

  // Controls whether the password area is visible.
  bool showPassword = false;

  final TextEditingController passwordController =
  TextEditingController();

  // ------------------------------------------------------------
  // LOCK
  // ------------------------------------------------------------

  Future<void> lockApps() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final bool success =
          await platform.invokeMethod<bool>('lockApps') ?? false;

      if (!mounted) return;

      if (success) {
        setState(() {
          locked = true;
          showPassword = false;
          passwordController.clear();
        });

        showMessage('Apps locked successfully');
      } else {
        showMessage(
          'Could not lock apps.',
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      showMessage(
        'Android error: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SHOW PASSWORD
  // ------------------------------------------------------------

  void openUnlockPanel() {
    if (busy) return;

    setState(() {
      showPassword = true;
      passwordController.clear();
    });
  }

  // ------------------------------------------------------------
  // CANCEL PASSWORD
  // ------------------------------------------------------------

  void cancelUnlock() {
    setState(() {
      showPassword = false;
      passwordController.clear();
    });
  }

  // ------------------------------------------------------------
  // UNLOCK
  // ------------------------------------------------------------

  Future<void> unlockApps() async {
    if (busy) return;

    // Check password first.
    if (passwordController.text != '1234') {
      passwordController.clear();

      showMessage(
        'Incorrect password',
      );

      return;
    }

    setState(() {
      busy = true;
    });

    try {
      final bool success =
          await platform.invokeMethod<bool>('unlockApps') ?? false;

      if (!mounted) return;

      if (success) {
        setState(() {
          locked = false;
          showPassword = false;
          passwordController.clear();
        });

        showMessage(
          'Apps unlocked successfully',
        );
      } else {
        showMessage(
          'Could not unlock apps.',
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      showMessage(
        'Android error: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Youtue Pro',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // ------------------------------------------------
                // STATUS ICON
                // ------------------------------------------------

                Icon(
                  locked
                      ? Icons.play_disabled
                      : Icons.play_circle,
                  size: 90,
                ),

                const SizedBox(height: 25),

                // ------------------------------------------------
                // STATUS
                // ------------------------------------------------

                Text(
                  locked
                      ? 'Your APPS ARE LOCKED'
                      : 'Press Open',

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  locked
                      ? 'Your apps cannot be opened anymore'
                      : 'Enjoy Youtube Without Ads',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // ------------------------------------------------
                // LOCK BUTTON
                // ------------------------------------------------

                SizedBox(
                  width: 220,
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                    busy || locked
                        ? null
                        : lockApps,

                    child: busy && !locked
                        ? const SizedBox(
                      width: 25,
                      height: 25,
                      child:
                      CircularProgressIndicator(),
                    )
                        : const Text(
                      'Open',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------------------------------------
                // UNLOCK BUTTON
                // ------------------------------------------------

                SizedBox(
                  width: 220,
                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                    busy || !locked
                        ? null
                        : openUnlockPanel,

                    child: const Text(
                      'UNLOCK',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ------------------------------------------------
                // PASSWORD PANEL
                // ------------------------------------------------

                if (showPassword) ...[
                  const SizedBox(height: 10),

                  Card(
                    elevation: 3,

                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        children: [
                          const Text(
                            'Authentication',

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Enter the password to unlock the apps.',
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller:
                            passwordController,

                            obscureText: true,

                            keyboardType:
                            TextInputType.number,

                            autofocus: true,

                            decoration:
                            const InputDecoration(
                              labelText:
                              'Password',

                              hintText:
                              'Enter password',

                              border:
                              OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                  busy
                                      ? null
                                      : cancelUnlock,

                                  child:
                                  const Text(
                                    'CANCEL',
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child:
                                ElevatedButton(
                                  onPressed:
                                  busy
                                      ? null
                                      : unlockApps,

                                  child:
                                  busy
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                    CircularProgressIndicator(),
                                  )
                                      : const Text(
                                    'UNLOCK',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 35),

                // ------------------------------------------------
                // PROTECTED APPS
                // ------------------------------------------------

                const Text(
                  'Supported apps',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'YouTube • Facebook • Instagram • TikTok',

                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}