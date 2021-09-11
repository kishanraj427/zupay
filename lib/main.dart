import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zupay/homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZuPay Assignment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ZuPay Assignment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool signIn = true;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(""),
          elevation: 0,
        ),
        body: signIn ? login() : register());
  }

  Widget login() {
    TextEditingController eId = new TextEditingController(),
        ePass = new TextEditingController();
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 50,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: eId,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextField(
                    controller: ePass,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Password',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Text(
                      'Log In',
                      style: TextStyle(fontSize: 20),
                    ),
                    color: Colors.blue,
                    padding: EdgeInsets.all(10),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      if (eId.text != "" && ePass.text != "") {
                        auth
                            .signInWithEmailAndPassword(
                                email: eId.text, password: ePass.text)
                            .then((value) {
                          if (value.user != null) {
                            Fluttertoast.showToast(
                                msg: "LogIn Successful",
                                backgroundColor: Colors.green,
                                textColor: Colors.white);
                            gotoHome();
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have any account ?',
                          style: TextStyle(fontSize: 17),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              signIn = false;
                            });
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget register() {
    TextEditingController eId = new TextEditingController(),
        eName = new TextEditingController(),
        ePass = new TextEditingController();
    return Column(
      children: [
        Text(
          'Register Your Self',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 50,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: eName,
                    decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextField(
                    controller: eId,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextField(
                    controller: ePass,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Password',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 20),
                    ),
                    color: Colors.blue,
                    padding: EdgeInsets.all(10),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      if (eName.text != "" &&
                          eId.text != "" &&
                          ePass.text != "") {
                        auth
                            .createUserWithEmailAndPassword(
                                email: eId.text, password: ePass.text)
                            .then((value) {
                          var user = value.user;
                          FirebaseDatabase.instance
                              .reference()
                              .child(user!.uid)
                              .set({
                                'email': user.email
                              });
                          Fluttertoast.showToast(
                              msg: "Registration Successful",
                              backgroundColor: Colors.green,
                              textColor: Colors.white);
                          gotoHome();
                        });
                      }
                    },
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Back to ',
                          style: TextStyle(fontSize: 17),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              signIn = true;
                            });
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.blue),
                          ),
                        ),
                        Text(
                          ' Page',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  gotoHome() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
    ));
  }
}
