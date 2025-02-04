import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_lingua/screens/dashboard.dart';
import 'package:easy_lingua/screens/login.dart';
import 'package:easy_lingua/widgets/background_circles.dart';
import 'package:easy_lingua/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = FirebaseAuth.instance;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _isAuthenticating = false;
  File? _selectedImage;

  SnackBar _errorMessage(String errorMessage) {
    return SnackBar(
      content: Text(
        errorMessage,
        style: TextStyle(
          color: Colors.white, // Yazı rengi beyaz
          fontSize: 16, // Yazı boyutu
          fontWeight: FontWeight.bold, // Kalın yazı
        ),
      ),
      backgroundColor: Colors.redAccent, // Arka plan rengi kırmızı
      behavior: SnackBarBehavior.floating, // Yüzen efekt
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlatma
      ),
      margin: EdgeInsets.all(20), // Etrafına boşluk ekleyelim
      duration: Duration(seconds: 3), // Mesaj süresi
    );
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      // show error message
      return;
    }
    _form.currentState!.save();

    if (_selectedImage == null) {
      // Show error if no image was picked
      ScaffoldMessenger.of(context).showSnackBar(
        _errorMessage("Please select a profile image!"),
      );
      return;
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      // SharedPreferences'a kaydetme
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', userCredentials.user!.uid);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': _enteredUsername,
        'email': _enteredEmail,
        'image_url': imageUrl,
        'dictionary': FieldValue.arrayUnion([]),
      });

      print('Uid olustu');

      // işlem başarılıysa Dashboarda yönlendiriyoruz
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(),
          ));
    } on FirebaseAuthException catch (error) {
      String errorMessage = 'An error occurred. Please try again.';
      if (error.code == 'user-not-found') {
        errorMessage = 'Account not found. Please check your email address.';
      } else if (error.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (error.code == 'invalid-email') {
        errorMessage = 'Invalid email address. Please enter a valid format.';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        _errorMessage(errorMessage),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(235, 235, 235, 1),
      body: Stack(
        children: [
          BackgroundCircles(),
          Center(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 25, right: 25),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome Onboard!',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            color: const Color.fromRGBO(0, 0, 0, 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 19),
                        Text(
                          " Let's help you learn languages.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color.fromRGBO(0, 0, 0, 0.6),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 28),
                        UserImagePicker(
                          onPickedImage: (pickedImage) {
                            _selectedImage = pickedImage;
                          },
                        ),
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border:
                                    InputBorder.none, // Alt çizgiyi kaldırır
                                enabledBorder: InputBorder
                                    .none, // Etkin durumda da kaldırır
                                focusedBorder: InputBorder
                                    .none, // Odaklandığında da kaldırır
                                hintText:
                                    "Enter your full name", // Kullanıcıya ipucu gösterir
                              ),
                              autocorrect: true,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 3) {
                                  return 'Please enter at least 3 characters.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border:
                                    InputBorder.none, // Alt çizgiyi kaldırır
                                enabledBorder: InputBorder
                                    .none, // Etkin durumda da kaldırır
                                focusedBorder: InputBorder
                                    .none, // Odaklandığında da kaldırır
                                hintText:
                                    "Enter your email", // Kullanıcıya ipucu gösterir
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an email address';
                                }
                                // Daha güvenli bir e-posta regex deseni
                                if (!RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border:
                                    InputBorder.none, // Alt çizgiyi kaldırır
                                enabledBorder: InputBorder
                                    .none, // Etkin durumda da kaldırır
                                focusedBorder: InputBorder
                                    .none, // Odaklandığında da kaldırır
                                hintText:
                                    "Enter password", // Kullanıcıya ipucu gösterir
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a password';
                                }
                                // Şifrenin en az 8 karakter, bir harf, bir rakam ve bir özel karakter içermesini zorunlu kılar
                                if (!RegExp(
                                        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                                    .hasMatch(value)) {
                                  return 'Password must be at least 8 characters long and include at least one letter, one number, and one special character (@\$!%*?&)';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(
                                    80, 194, 201, 1), // açık mavi arkaplan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Kenar yuvarlaklığı
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 17, horizontal: 120)),
                            onPressed: _submit,
                            child: Text(
                              'Register',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 19),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                            ),
                            Text(
                              'Already have an account?',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color.fromRGBO(0, 0, 0, 0.7),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Color.fromRGBO(80, 194, 201, 1),
                              ),
                              child: Text(' Sign in!'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
