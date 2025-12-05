import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '/account/controllers/autenticazione.dart';
import '/account/login_screen.dart';
import '/pages/profilo.dart';
import '/standard/costanti.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Autenticazione auth = Autenticazione();
  late String email;
  late String nome;
  late String immagine;
  late String password;
  Random rand = Random();
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
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Profilo()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        height: 130,
                        width: 130,
                        image: AssetImage('assets/login-immagine.png'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Registrati qui',
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
                                vertical: 15.0,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Nome Utente',
                                ),
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return error =
                                        'Il campo non può essere vuoto. Immeti un nome';
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
                            //Bottone di registrazione email e password
                            ElevatedButton(
                              onPressed: () async {
                                if (formkey.currentState!.validate()) {
                                  immagine = randImageAccount[rand.nextInt(6)];
                                  dynamic result = await auth
                                      .registerWithEmailAndPassword(
                                        email,
                                        password,
                                        nome,
                                        immagine,
                                      )
                                      .whenComplete(
                                        // ignore: use_build_context_synchronously
                                        () => Navigator.of(context)
                                            .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => Profilo(),
                                              ),
                                            ),
                                      );
                                  if (result == null) {
                                    setState(() {
                                      error = 'Inserire una email valida';
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                              child: Text('Registrati'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    //Link per andare alla pagina di Accesso(Login screen)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text('Accedi qui'),
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
