import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled17/login_screen.dart';
import 'package:untitled17/profhome.dart';
import 'package:untitled17/profile.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Input form controllers
  FocusNode emailFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();

  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();

  FocusNode confirmPasswordFocusNode = FocusNode();
  TextEditingController confirmPasswordController = TextEditingController();

  // Rive controller and inputs
  StateMachineController? controller;

  SMIInput<bool>? isChecking;
  SMIInput<double>? numLook;
  SMIInput<bool>? isHandsUp;

  SMIInput<bool>? trigSuccess;
  SMIInput<bool>? trigFail;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Internal counter for user sequence
  int userCounter = 0;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    emailFocusNode.addListener(emailFocus);
    passwordFocusNode.addListener(passwordFocus);
    confirmPasswordFocusNode.addListener(confirmPasswordFocus);
    super.initState();
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(emailFocus);
    passwordFocusNode.removeListener(passwordFocus);
    confirmPasswordFocusNode.removeListener(confirmPasswordFocus);
    super.dispose();
  }

  void emailFocus() {
    isChecking?.change(emailFocusNode.hasFocus);
  }

  void passwordFocus() {
    isHandsUp?.change(passwordFocusNode.hasFocus);
  }

  void confirmPasswordFocus() {
    isHandsUp?.change(confirmPasswordFocusNode.hasFocus);
  }

  String generateUserCode() {
    userCounter++;
    return 'u${userCounter.toString().padLeft(4, '0')}';
  }

  Future<void> registerUser() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      // Validation before registration
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Please fill all fields.';
        });
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          isLoading = false;
          errorMessage = 'Passwords do not match.';
        });
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await userCredential.user?.sendEmailVerification();

      String userCode = generateUserCode();

      print(
          "User registered successfully: ${userCredential.user?.email}, User Code: $userCode");

      // Navigate to the ProfilePage after successful registration
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailsPage()),
      );
    } on FirebaseAuthException catch (e) {
      print('Error during registration: $e');
      setState(() {
        errorMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        errorMessage = 'Unexpected error occurred.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Build Called Again");
    return Scaffold(
      backgroundColor: const Color(0xFFD6E2EA),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(23),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 110,
                width: 110,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFD6E2EA),
                  shape: BoxShape.rectangle,
                ),
                child: const Image(
                  image: AssetImage("images/spooooortttt.png"),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              width: 200,
              child: RiveAnimation.asset(
                "images/animated_login_character.riv",
                fit: BoxFit.fitHeight,
                stateMachines: const ["Login Machine"],
                onInit: (artboard) {
                  controller = StateMachineController.fromArtboard(
                    artboard,
                    "Login Machine",
                  );
                  if (controller == null) return;

                  artboard.addController(controller!);
                  isChecking = controller?.findInput("isChecking");
                  numLook = controller?.findInput("numLook");
                  isHandsUp = controller?.findInput("isHandsUp");
                  trigSuccess = controller?.findInput("trigSuccess");
                  trigFail = controller?.findInput("trigFail");
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      focusNode: emailFocusNode,
                      controller: emailController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.black)),
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) {
                        numLook?.change(value.length.toDouble());
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      focusNode: passwordFocusNode,
                      controller: passwordController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.black)),
                      obscureText: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      focusNode: confirmPasswordFocusNode,
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(color: Colors.black)),
                      obscureText: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                "Already have an account? Sign in",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              minWidth: 250.0,
              height: 50,
              color: Color.fromARGB(255, 41, 169, 92), // هنا تم تغيير اللون
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () {
                registerUser();
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
