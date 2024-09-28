import 'package:dailyplanner/screen/loginscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../const/authentication.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen ({super.key});

  @override
  State<Registerscreen> createState() => _Registerscreen();
}

class _Registerscreen extends State<Registerscreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    phonenumberController.dispose();
  }
  void signupUser() async {
    // set isLoading to true.
    setState(() {
      isLoading = true;
    });

    try {
      // signup user using our authmethod
      String res = await AuthMethod().signupUser(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          confirmPass: confirmPasswordController.text,
          phoneNumber: phonenumberController.text
      );

      // Check if signup was successful
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        // Navigate to the next screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Loginscreen(),
          ),
        );
      } else {
        // In lỗi ra console
        print("Lỗi đăng ký: $res");
        throw Exception(res);
      }
    } catch (e) {
      print('Lỗi đăng ký 1: $e');
      setState(() {
        isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký tài khoản'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên đầy đủ'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: phonenumberController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Xác nhận mật khẩu'),
                obscureText: true,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: signupUser,
                  child: Text('Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
