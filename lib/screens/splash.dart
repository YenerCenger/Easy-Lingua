import 'package:easy_lingua/screens/register.dart';
import 'package:easy_lingua/widgets/background_circles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(235, 235, 235, 1),
      body: Stack(
        children: [
          BackgroundCircles(),
          Center(
            child: Stack(
              children: [
                Image.asset('assets/images/splash.png'),
                Positioned(
                  top: 110,
                  left: 30,
                  child: Text(
                    'Start Your learning adventure\nwith EasyLingua',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 220,
                  left: 25,
                  child: Text(
                    "  Improve your language skills with \ninteractive lessons and fun content,\nall at your own pace. Begin your\njourney today and enjoy the process\nof mastering a new language!",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                    top: 400,
                    left: 16,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(
                              80, 194, 201, 1), // açık mavi arkaplan
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Kenar yuvarlaklığı
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 17, horizontal: 68)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Get Started!',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
