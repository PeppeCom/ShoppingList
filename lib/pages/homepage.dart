import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/account/login_screen.dart';
import '/pages/services/database.dart';
import '/pages/services/homepage_listView.dart';
import '/pages/services/scrivi_lista.dart';
import '/standard/costanti.dart';
import '/standard/MyDrawer.dart';
import 'package:random_string/random_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String homePageName = 'Ultime Liste';
  late String? tipoPagina;
  late String? titoloLista;
  late Color? colore;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool searchState = false;
  late String idLista;

  List selezionaTipoPagina = [
    'Cibo',
    'Elettronica',
    'Giochi',
    'Vestiti',
    'Libri',
    'Altro',
  ];

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser?.uid == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: homePageTypeColor,
          centerTitle: true,
          title: Text(
            homePageName,
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
        ),
        drawer: Mydrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.note_add_rounded, color: Colors.grey[850], size: 70.0),
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
          backgroundColor: homePageTypeColor,
          child: Icon(Icons.edit_rounded),
        ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: homePageTypeColor,
          title: Text(
            homePageName,
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
        ),
        body: HomePageListView(),
      );
    }
  }

  void parametroNull() {
    titoloLista = null;
    tipoPagina = null;
    colore = null;
  }

  Color? passaggioColore(tipoSelezionato) {
    if (tipoSelezionato == 'Cibo') {
      colore = ciboTypeColor;
    } else if (tipoSelezionato == 'Elettronica') {
      colore = elettronicaTypeColor;
    } else if (tipoSelezionato == 'Giochi') {
      colore = giochiTypeColor;
    } else if (tipoSelezionato == 'Vestiti') {
      colore = vestitiTypeColor;
    } else if (tipoSelezionato == 'Libri') {
      colore = libriTypeColor;
    } else if (tipoSelezionato == 'Altro') {
      colore = altroTypeColor;
    }
    return colore;
  }

  Future<Future> addDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Titolo Lista'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: homePageTypeColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  decoration: InputDecoration(hintText: '\t\tTitolo lista'),
                  onChanged: (value) {
                    titoloLista = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: homePageTypeColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonFormField(
                    elevation: 0,
                    hint: Text('\t\tTipo lista:'),
                    icon: Icon(Icons.arrow_drop_down_rounded, size: 33),
                    initialValue: tipoPagina,
                    onChanged: (newValue) {
                      setState(() => tipoPagina = newValue as String?);
                    },
                    items: selezionaTipoPagina.map((newValue) {
                      return DropdownMenuItem(
                        value: newValue,
                        child: Text('$newValue'),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
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
                idLista = randomAlphaNumeric(28);
                if (titoloLista == '') {
                  erroreCampoVuoto(context);
                } else {
                  passaggioColore(tipoPagina);
                  DatabaseService(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                    tipoPagina: tipoPagina ?? '',
                    titoloLista: titoloLista ?? '',
                    idLista: idLista,
                  ).creaListaPerPagina();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScriviLista(
                        titolo: titoloLista ?? '',
                        tipoPagina: tipoPagina ?? '',
                        colore: colore ?? Colors.grey,
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
