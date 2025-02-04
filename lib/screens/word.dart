// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_lingua/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = FirebaseAuth.instance;

class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  final _form = GlobalKey<FormState>();

  String? _userUid;
  String? _imageUrl;

  var _enteredWord = '';
  var _enteredMeaning = '';

  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();

  void _logout() {
    _firebase.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  SnackBar _errorMessage(String errorMessage, Color color) {
    return SnackBar(
      content: Text(
        errorMessage,
        style: TextStyle(
          color: Colors.white, // Yazı rengi beyaz
          fontSize: 16, // Yazı boyutu
          fontWeight: FontWeight.bold, // Kalın yazı
        ),
      ),
      backgroundColor: color, // Arka plan rengi kırmızı
      behavior: SnackBarBehavior.floating, // Yüzen efekt
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlatma
      ),
      margin: EdgeInsets.all(20), // Etrafına boşluk ekleyelim
      duration: Duration(seconds: 3), // Mesaj süresi
    );
  }

  void _submit() async {
    _form.currentState!.save();
    _wordController.clear();
    _meaningController.clear();

    // SharedPreferences'tan uid'yi alıyoruz
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString('uid');

    if (userUid == null) {
      // Kullanıcı ID'si yoksa, hata mesajı gösterilebilir
      ScaffoldMessenger.of(context).showSnackBar(
        _errorMessage('User ID not found!', Colors.redAccent),
      );
      return;
    }

    // Firebase Firestore'dan kullanıcı belgesini alıyoruz
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userUid);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      // Kullanıcı belgesindeki sözlük dizisini alıyoruz
      List<dynamic> dictionary = userSnapshot.data()?['dictionary'] ?? [];

      // Kelimeyi daha önce ekleyip eklemediğimizi kontrol ediyoruz
      bool wordExists =
          dictionary.any((entry) => entry['word'] == _enteredWord);

      if (!wordExists) {
        // Eğer kelime daha önce eklenmemişse, yeni kelimeyi ekliyoruz
        await userDoc.update({
          'dictionary': FieldValue.arrayUnion([
            {
              'word': _enteredWord,
              'meaning': _enteredMeaning,
            }
          ]),
        });

        // Başarılı bir şekilde kelime eklendiyse, kullanıcıya bildirim gönderiyoruz
        ScaffoldMessenger.of(context).showSnackBar(
          _errorMessage('Word added successfully!', Colors.lightGreenAccent),
        );
      } else {
        // Kelime zaten eklenmişse kullanıcıya bildirim gönderiyoruz
        ScaffoldMessenger.of(context).showSnackBar(
          _errorMessage('Word already exists!', Colors.redAccent),
        );
      }
    } else {
      // Eğer kullanıcı belgesi yoksa, hata mesajı gösteriyoruz
      ScaffoldMessenger.of(context).showSnackBar(
        _errorMessage('User not found!', Colors.redAccent),
      );
    }
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
        final words = userWords.data()?['dictionary'] as List<dynamic>?;
        setState(() {
          _imageUrl = userWords.data()?['image_url'] as String?;
        });

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

  @override
  void initState() {
    super.initState();
    fetchData();
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
                  height: 220,
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
                      Positioned(
                        top: 50,
                        left: 15,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: _imageUrl != null && _imageUrl!.isNotEmpty
                                  ? NetworkImage(_imageUrl!)
                                  : AssetImage(
                                          'assets/images/default-avatar.png')
                                      as ImageProvider,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Uygulama Adı
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 55,
                            ),
                            Text(
                              'EasyLingua',
                              style: GoogleFonts.poppins(
                                fontSize: 27,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      // Word List
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 150),
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.4),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Word List',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                color: const Color.fromRGBO(255, 255, 255, 0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 320,
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
                              padding: const EdgeInsets.all(8.0),
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
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return Center(
                                        child: Text(
                                            'User document does not exist.'));
                                  }

                                  // Dictionary alanını al
                                  final dictionary = snapshot
                                      .data!['dictionary'] as List<dynamic>?;

                                  if (dictionary == null ||
                                      dictionary.isEmpty) {
                                    return Center(
                                        child: Text('Dictionary is empty.'));
                                  }

                                  // Dictionary'deki her bir kelimeyi ListView'da göster
                                  return SizedBox(
                                    height: 320,
                                    width: 330,
                                    child: ListView.builder(
                                      itemCount: dictionary.length,
                                      itemBuilder: (context, index) {
                                        final entry = dictionary[index];
                                        final word = entry['word'];
                                        final meaning = entry['meaning'];

                                        return Card(
                                          color:
                                              Color.fromRGBO(80, 194, 201, 1),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    word,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "→",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    meaning,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 60,
                        width: 350,
                        padding: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _wordController,
                            decoration: InputDecoration(
                              border: InputBorder.none, // Alt çizgiyi kaldırır
                              enabledBorder:
                                  InputBorder.none, // Etkin durumda da kaldırır
                              focusedBorder: InputBorder
                                  .none, // Odaklandığında da kaldırır
                              hintText:
                                  "Enter a new word", // Kullanıcıya ipucu gösterir
                            ),
                            autocorrect: true,
                            onSaved: (value) {
                              _enteredWord = value!;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 60,
                        width: 350,
                        padding: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _meaningController,
                            decoration: InputDecoration(
                              border: InputBorder.none, // Alt çizgiyi kaldırır
                              enabledBorder:
                                  InputBorder.none, // Etkin durumda da kaldırır
                              focusedBorder: InputBorder
                                  .none, // Odaklandığında da kaldırır
                              hintText:
                                  "Meaning of the word", // Kullanıcıya ipucu gösterir
                            ),
                            autocorrect: true,
                            onSaved: (value) {
                              _enteredMeaning = value!;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(
                                80, 194, 201, 1), // açık mavi arkaplan
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Kenar yuvarlaklığı
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 30)),
                        onPressed: _submit,
                        child: Text(
                          'Add Word',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 259
