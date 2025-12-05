import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/account/controllers/autenticazione.dart';
import '../account/sign_up_screen.dart';
import '/pages/homepage.dart';
import '/pages/profilo.dart';
import '/standard/costanti.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Autenticazione auth = Autenticazione();
  late String email;
  late String nome;
  late String password;
  Random rand = Random();
  late String immagine;
  String error = '';
  bool isHiddenPassword = true;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void _togglePasswordView() {
    if (isHiddenPassword == true) {
      isHiddenPassword = false;
    } else {
      isHiddenPassword = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  SizedBox(width: 10.0),
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Profilo()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Image(
                        height: 130,
                        width: 130,
                        image: AssetImage('assets/login-immagine.png'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Benvenuto\nAccedi per continuare',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: Form(
                        key: formkey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nome Utente',
                                ),
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return error =
                                        'Il campo non può essere vuoto. Inserisci un nome';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    nome = val;
                                  });
                                },
                              ),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                              ),
                              validator: (val) {
                                if (!EmailValidator.validate(val!)) {
                                  return error = 'Inserisci una email valida';
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                              ),
                              child: TextFormField(
                                obscureText: isHiddenPassword,
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: _togglePasswordView,
                                    child: isHiddenPassword
                                        ? Icon(Icons.visibility_rounded)
                                        : Icon(Icons.visibility_off_rounded),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                ),
                                validator: (val) {
                                  if (val!.length < 6) {
                                    return error =
                                        'Inserisci una password di almeno 6 caratteri';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                              ),
                            ),

                            //Bottone per accedere con email e password
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  if (formkey.currentState!.validate()) {
                                    immagine =
                                        randImageAccount[rand.nextInt(6)];
                                    dynamic result = await auth
                                        .signInWithEmailAndPassword(
                                          email.trim(),
                                          password,
                                          nome,
                                          immagine,
                                        )
                                        .then(
                                          // ignore: use_build_context_synchronously
                                          (value) => Navigator.of(context)
                                              .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(),
                                                ),
                                              ),
                                        );

                                    if (result == null) {
                                      setState(() {
                                        error =
                                            "Errore durante l'accesso. Riprovare";
                                      });
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    buildShowDialog(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      'Utente non registrato. Per favore registrati',
                                    );
                                  } else if (e.code == 'wrong-password') {
                                    // ignore: use_build_context_synchronously
                                    buildShowDialog(context, 'Password errata');
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                              child: Text('Accedi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Bottone Google
                    MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          auth.signInWithGoogle(context).whenComplete(() async {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }),
                      child: Image(
                        image: AssetImage('assets/signInWithGoogle.png'),
                        width: 200.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    //link per andare alla pagina di registrazione
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text('Registrati qui'),
                    ),
                    SizedBox(height: 15.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
