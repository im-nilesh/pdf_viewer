import 'package:flutter/material.dart';
import 'package:pdf_viewer/screens/Main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      _usernameController.text = username;
    }
  }

  _saveUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _usernameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3C3C),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Title(
                    color: Colors.white,
                    child: const SizedBox(
                      height: 40,
                      child: const Text(
                        'Enter your Username',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Rounded corners for the border
                      borderSide: const BorderSide(
                        color: Color.fromARGB(
                            0, 60, 60, 60), // Color of the border
                        width: 2.0, // Width of the border
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Colors.black),
                      ),
                      onPressed: () {
                        _saveUsername();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
