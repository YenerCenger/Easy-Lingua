import 'package:easy_lingua/screens/dashboard.dart';
import 'package:easy_lingua/screens/register.dart';
import 'package:easy_lingua/widgets/background_circles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      // show error message
      return;
    }
    if (_form.currentState == null || !_form.currentState!.validate()) {
      // Show error message
      return;
    }
    _form.currentState!.save();
    // eğer giriş başarılıysa yönlendir
    try {
      await _firebase.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      // işlem başarılıysa Dashboarda yönlendiriyoruz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
    } catch (error) {
      String errorMessage = 'An unexpected error occurred. Please try again.';

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        ),
      );
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
                        SizedBox(height: 50),
                        Text(
                          'Welcome Back!',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            color: const Color.fromRGBO(0, 0, 0, 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 19),
                        Image.asset('assets/images/login.png'),
                        const SizedBox(height: 19),
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
                              autocorrect: true,
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
                              autocorrect: false,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a password';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Color.fromRGBO(80, 194, 201, 1),
                          ),
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                            ),
                            Text(
                              "Don't have an account?",
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
                                    builder: (context) => RegistrationScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Color.fromRGBO(80, 194, 201, 1),
                              ),
                              child: Text('Sign Up'),
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
