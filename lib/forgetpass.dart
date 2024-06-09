import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth.dart';
import 'constants.dart';

class ForgotPassScreen extends StatelessWidget {
  ForgotPassScreen({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        elevation: 0,
        title: Text(
          'forget_your_password?'.tr,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                onChanged: (value) {},
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "email".tr,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: size.width * .5,
                height: 50,
                color: Color.fromARGB(255, 41, 169, 92),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onPressed: () async {
                  if (_controller.text.trim().isEmpty) {
                    showToast(context, msg: "Please enter your email");
                    return;
                  }
                  await AuhtService.forgotYourPassword(_controller.text.trim());
                },
                child: Text(
                  'send_link'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showToast(BuildContext context, {required String msg}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}