import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AuthMethod {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User

  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
    required String confirmPass,
    required String phoneNumber,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty ||
          phoneNumber.isNotEmpty||
          confirmPass.isNotEmpty) {
        if (password != confirmPass){
          res = 'Mật khẩu không trùng khớp';
        }
        else {
          // register user in auth with email and password
          UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          // add user to your  firestore database
          print(cred.user!.uid);
          await _databaseReference.child("Users").child(cred.user!.uid).set({
            'name': name,
            'uid': cred.user!.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'createDate' : DateFormat('yyyy-MM-dd').format(DateTime.now())
          });

          res = "success";
        }
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // for sighout

}