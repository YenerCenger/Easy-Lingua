// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_lingua/screens/login.dart';
import 'package:easy_lingua/screens/word.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = FirebaseAuth.instance;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? _userUid;
  String? _username;
  String? _imageUrl;

  bool _isWord = true;

  int indexNumber = 0;

  void _logout() {
    _firebase.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  Future<void> fetchData() async {
    try {
      // SharedPreferences'tan uid'yi alıyoruz
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('uid');

      if (userUid != null) {
        setState(() {
          _userUid = userUid; // Dışarıdaki _userUid'e içerideki userUid'yi ata
        });
      }

      final userWords = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();

      if (userWords.exists) {
        setState(() {
          _username = userWords.data()?['username'] as String;
          _imageUrl = userWords.data()?['image_url'] as String?;
        });
        final words = userWords.data()?['dictionary'] as List<dynamic>?;

        if (words != null) {
          // Dictionary'deki her bir kelimeyi işle
          for (var entry in words) {
            final word = entry['word'];
            final meaning = entry['meaning'];
          }
        } else {
          print('Dictionary is empty or does not exist.');
        }
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching dictionary: $e');
    }
  }

  void indexUp() {
    setState(() {
      indexNumber = indexNumber + 1;
      _isWord = true;
    });
    ;
  }

  void indexDown() {
    setState(() {
      indexNumber = indexNumber - 1;
      _isWord = true;
    });
    ;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');
      if (uid != null) {
        setState(() => _userUid = uid);
        await fetchData(); // Verileri çek
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(235, 235, 235, 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(80, 194, 201, 1),
                  ),
                  child: Stack(
                    children: [
                      // Sol üstte alttaki yuvarlak
                      Positioned(
                        left: -100,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                                198, 234, 230, 0.35), // Turkuaz tonu
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Sağ üstte üstteki yuvarlak
                      Positioned(
                        top: -100,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                                198, 234, 230, 0.35), // Turkuaz tonu
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Logout butonu
                      Positioned(
                        top: 50,
                        right: 15,
                        child: IconButton(
                          onPressed: _logout,
                          icon: Icon(
                            Icons.logout,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Avatar
                      Center(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 120),
                              height: 100,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: _imageUrl != null &&
                                          _imageUrl!.isNotEmpty
                                      ? NetworkImage(_imageUrl!)
                                      : AssetImage(
                                              'assets/images/default-avatar.png')
                                          as ImageProvider,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Welcome $_username',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                color: const Color.fromRGBO(255, 255, 255, 0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 35),
                        Text(
                          "Let's Learn",
                          style: GoogleFonts.poppins(
                              color: const Color.fromRGBO(0, 0, 0, 0.7),
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        height: 220,
                        width: 330,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                  65, 0, 0, 0), // Gölgenin rengi
                              blurRadius: 10, // Gölgenin yumuşaklığı
                              spreadRadius: 2, // Gölgenin yayılma miktarı
                              offset: Offset(
                                  4, 4), // Gölgenin yatay ve dikey kayması
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_userUid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Center(
                                      child: Text(
                                          'User document does not exist.'));
                                }

                                // Dictionary alanını al
                                final dictionary = snapshot.data!['dictionary']
                                    as List<dynamic>?;

                                if (dictionary == null || dictionary.isEmpty) {
                                  return Center(
                                      child: Text('Dictionary is empty.'));
                                }

                                if (indexNumber > dictionary.length - 1) {
                                  indexNumber = indexNumber - dictionary.length;
                                }

                                if (indexNumber < 0) {
                                  indexNumber = indexNumber + dictionary.length;
                                }

                                final entry = dictionary.isNotEmpty
                                    ? dictionary[indexNumber]
                                    : {'word': 'No Data'};
                                final word = entry['word'];
                                final meaning = entry['meaning'];

                                // Dictionary'deki kelimeleri  indexine göre gösterir.
                                return SizedBox(
                                  height: 320,
                                  width: 330,
                                  child: Center(
                                    child: _isWord
                                        ? Text(
                                            word, // Kelimeyi dinamik olarak gösterir
                                            style: GoogleFonts.poppins(
                                              color: Color.fromRGBO(
                                                  80, 194, 201, 1),
                                              fontSize: 34,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : Text(
                                            meaning, // Kelimeyi dinamik olarak gösterir
                                            style: GoogleFonts.poppins(
                                              color: Color.fromRGBO(
                                                  80, 194, 201, 1),
                                              fontSize: 34,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                    65, 0, 0, 0), // Gölgenin rengi
                                blurRadius: 5, // Gölgenin yumuşaklığı
                                spreadRadius: 2, // Gölgenin yayılma miktarı
                                offset: Offset(
                                    3, 3), // Gölgenin yatay ve dikey kayması
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: indexDown,
                            icon: Icon(
                              Icons.navigate_before,
                              color: Color.fromRGBO(80, 194, 201, 1),
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(width: 33),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                    65, 0, 0, 0), // Gölgenin rengi
                                blurRadius: 5, // Gölgenin yumuşaklığı
                                spreadRadius: 2, // Gölgenin yayılma miktarı
                                offset: Offset(
                                    4, 4), // Gölgenin yatay ve dikey kayması
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isWord = !_isWord;
                              });
                              ;
                            },
                            icon: Transform.rotate(
                              angle: pi / 2,
                              child: Icon(
                                Icons.loop,
                                color: Color.fromRGBO(80, 194, 201, 1),
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 33),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                    65, 0, 0, 0), // Gölgenin rengi
                                blurRadius: 5, // Gölgenin yumuşaklığı
                                spreadRadius: 2, // Gölgenin yayılma miktarı
                                offset: Offset(
                                    4, 4), // Gölgenin yatay ve dikey kayması
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: indexUp,
                            icon: Icon(
                              Icons.navigate_next,
                              color: Color.fromRGBO(80, 194, 201, 1),
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(
                              80, 194, 201, 1), // açık mavi arkaplan
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Kenar yuvarlaklığı
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 17, horizontal: 120)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Words List',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: const Color.fromARGB(211, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 100, 150
