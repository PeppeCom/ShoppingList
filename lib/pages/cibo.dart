import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/account/login_screen.dart';
import '/pages/services/database.dart';
import '/pages/services/listpage.dart';
import '/pages/services/scrivi_lista.dart';
import '/pages/services/search_service.dart';
import '/standard/costanti.dart';
import '/standard/MyDrawer.dart';
import 'package:random_string/random_string.dart';

class Cibo extends StatefulWidget {
  const Cibo({super.key});

  @override
  _CiboState createState() => _CiboState();
}

class _CiboState extends State<Cibo> {
  String tipoPagina = 'Cibo';
  late String? titoloLista;
  Color colore = ciboTypeColor;
  FirebaseAuth auth = FirebaseAuth.instance;
  late String idLista;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser?.uid == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colore,
          centerTitle: true,
          title: Text(
            tipoPagina,
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
        ),
        drawer: Mydrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.food_bank_rounded, color: Colors.grey[850], size: 70.0),
            SizedBox(height: 10.0),
            Text(
              "Per iniziare a scrivere le tue liste",
              style: TextStyle(color: Colors.grey[400]),
            ),
            Text(
              "Premi il tasto e accedi con il tuo account",
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: colore),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.login_rounded),
                  label: Text("Accedi", style: TextStyle(color: colore)),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        drawer: Mydrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            parametroNull();
            addDialog(context);
          },
          backgroundColor: colore,
          child: Icon(Icons.edit_rounded),
        ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colore,
          title: Text(
            tipoPagina,
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_rounded),
              onPressed: () async {
                await showSearch(
                  context: context,
                  delegate: SearchService(
                    tipoPagina: tipoPagina,
                    colore: colore,
                  ),
                );
              },
            ),
          ],
        ),
        body: ListPage(
          tipoPagina: tipoPagina,
          titoloLista: titoloLista ?? '',
          colore: colore,
          idLista: idLista,
        ),
      );
    }
  }

  void parametroNull() {
    titoloLista = null;
  }

  Future<Future> addDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Titolo Lista'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Titolo lista'),
            onChanged: (value) {
              titoloLista = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Crea'),
              onPressed: () {
                if (titoloLista == '') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Errore campo vuoto'),
                        content: Text('Inserisci un titolo per la lista'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Capito'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  idLista = randomAlphaNumeric(28); // ho aggiunto questo
                  DatabaseService(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                    tipoPagina: tipoPagina,
                    titoloLista: titoloLista ?? '',
                    idLista: idLista, // ho aggiunto questo
                  ).creaListaPerPagina();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScriviLista(
                        titolo: titoloLista ?? '',
                        tipoPagina: tipoPagina,
                        colore: colore,
                        idLista: idLista,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
