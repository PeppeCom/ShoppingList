import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/pages/services/database.dart';
import '/pages/services/mylista.dart';
import '/pages/services/view_elemento.dart';
import '/standard/costanti.dart';
import 'package:random_string/random_string.dart';
import 'package:share_plus/share_plus.dart';

class ScriviLista extends StatefulWidget {
  final String titolo;
  final String tipoPagina;
  final Color colore;
  final String idLista;

  const ScriviLista({
    super.key,
    required this.titolo,
    required this.tipoPagina,
    required this.colore,
    required this.idLista,
  });

  @override
  _ScriviListaState createState() => _ScriviListaState();
}

class _ScriviListaState extends State<ScriviLista> {
  String? elementoLista;
  dynamic prezzo;
  String? descrizione;
  bool comprato = false;
  double totaleSpesa = 0;
  List<MyLista>? _mylista;
  String? idElemento;

  static const List<String> items = <String>[
    condividi,
    mostraTotaleLista,
    azzeraTotaleLista,
  ];

  // riporto a null i parametri
  void parametriNull() {
    elementoLista = null;
    descrizione = null;
    prezzo = null;
    comprato = false;
  }

  _condividiComeTesto(String scelto) async {
    if (scelto == condividi) {
      if (_mylista?.isEmpty ?? true) {
        erroreListaVuota(context);
      } else {
        String testo = 'Lista ${widget.titolo}:\n';
        _mylista?.forEach((element) {
          testo += element.elemento;
          testo += element.descrizione == 'Nessuna descrizione'
              ? '\n'
              : ' - ${element.descrizione}\n';
        });
        await Share.share(testo);
      }
    } else if (scelto == azzeraTotaleLista) {
      azzerareContoLista(_mylista);
    } else {
      mostraTotaleSpesa();
    }
  }

  @override
  void initState() {
    _mylista = [];

    super.initState();
  }

  Future refreshList() async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {});
  }

  bool checkAcquisto(lista) {
    return lista.done;
  }

  //controllo al checkbox se l'utente ha inserito il prezzo dell'elemento comprato/da comprare
  //lo aggiungo ad un valore totale della spesa
  void prendiPrezzo(dynamic x, dynamic elemento) {
    if (x == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Quanto hai speso?",
            style: TextStyle(color: Colors.amber),
          ),
          content: TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {
                var temp = val;
                x = temp;
              });
            },
            decoration: InputDecoration(
              labelText: 'Prezzo',
              icon: Icon(
                Icons.attach_money_rounded,
                color: Colors.amber[100],
                size: 15.0,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                comprato = false;
                elemento.done = comprato;
                Navigator.of(context).pop();
              },
              child: Text('Annulla', style: TextStyle(color: Colors.lime[400])),
            ),
            TextButton(
              child: Text('Salva', style: TextStyle(color: Colors.lime[400])),
              onPressed: () {
                Navigator.of(context).pop();
                if (x == null) {
                  mostraErroreCampoVuoto(context);
                } else {
                  setState(() {
                    double temp = double.tryParse(x)!;
                    elemento.prezzo = temp;
                    totaleSpesa += temp;
                  });
                  DatabaseService(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                    tipoPagina: widget.tipoPagina,
                    titoloLista: widget.titolo,
                    idLista: widget.idLista,
                  ).updateElemento(x, elemento, elemento.done);
                  DatabaseService(
                    uid: FirebaseAuth.instance.currentUser?.uid,
                    tipoPagina: widget.tipoPagina,
                    titoloLista: widget.titolo,
                    idLista: widget.idLista,
                  ).updateAnteprimaLista(totaleSpesa);
                }

                mostraTotaleSpesa();
                parametriNull();
              },
            ),
          ],
        ),
      );
    } else {
      setState(() {
        var temp = x;
        totaleSpesa += double.tryParse(temp.toString())!;
      });
      DatabaseService(
        uid: FirebaseAuth.instance.currentUser?.uid,
        tipoPagina: widget.tipoPagina,
        titoloLista: widget.titolo,
        idLista: widget.idLista,
      ).updateAnteprimaLista(totaleSpesa);

      mostraTotaleSpesa();
      parametriNull();
    }
  }

  calcolaNuovoTotale(dynamic x) {
    setState(() {
      var temp = x;
      totaleSpesa -= double.tryParse(temp.toString())!;
    });

    mostraTotaleSpesa();
  }

  azzerareContoLista(lista) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Azzera Conto Spesa",
            style: TextStyle(color: Colors.red, fontSize: 17.0),
          ),
          content: Text(
            "Azzerando il conto della lista tutti gli elementi selezionati verranno deselezionati e il totale andrà a zero, sei sicuro?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annulla', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              child: Text('Conferma', style: TextStyle(color: Colors.red)),
              onPressed: () {
                for (int i = 0; i < lista.length; i++) {
                  if (lista[i].done) {
                    comprato = false;
                    lista[i].done = comprato;
                    totaleSpesa = 0;

                    DatabaseService(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                      tipoPagina: widget.tipoPagina,
                      titoloLista: widget.titolo,
                      idLista: widget.idLista,
                    ).updateElemento(lista[i].prezzo, lista[i], lista[i].done);
                    DatabaseService(
                      uid: FirebaseAuth.instance.currentUser?.uid,
                      tipoPagina: widget.tipoPagina,
                      titoloLista: widget.titolo,
                      idLista: widget.idLista,
                    ).updateAnteprimaLista(totaleSpesa);
                    refreshList();
                    mostraTotaleSpesa();
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  mostraTotaleSpesa() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.grey[600],
        content: Text(
          'Hai speso: $totaleSpesa ',
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  _rimuoviElementiSbagliati(selezionato) {
    List<MyLista> nuova = [];

    DatabaseService(
      uid: FirebaseAuth.instance.currentUser!.uid,
      tipoPagina: widget.tipoPagina,
      titoloLista: widget.titolo,
      idLista: widget.idLista,
    ).deleteElemento(selezionato.idElemento); // ho cambiato qui

    for (var elem in _mylista!) {
      if (elem.elemento != selezionato.elemento) {
        nuova.add(elem);
      }
    }
    setState(() => _mylista = nuova);
  }

  cancellaElemento(
    BuildContext context,
    List<MyLista> mylista,
    int index,
    String tipoPagina,
    String titolo,
  ) {
    setState(() {
      comprato = true;
      mylista[index].done = comprato;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          title: Text(
            'Attenzione',
            style: TextStyle(fontSize: 17.0, color: Colors.red),
          ),
          content: Text("Confermi di voler cancellare l'elemento?"),
          actions: [
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  comprato = false;
                  mylista[index].done = comprato;
                });
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                setState(() {
                  comprato = false;
                  mylista[index].done = comprato;
                });
              },
              child: Text('Conferma', style: TextStyle(color: Colors.red[400])),
            ),
          ],
        );
      },
    ).then((value) {
      if (value) {
        _rimuoviElementiSbagliati(mylista[index]);
        if (totaleSpesa > 0) {
          totaleSpesa -= double.tryParse(mylista[index].prezzo)!;
          mostraTotaleSpesa();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.colore,
        centerTitle: true,
        title: Text(widget.titolo.toUpperCase()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_rounded),
            onPressed: () {
              parametriNull();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Aggiungi elemento',
                      style: TextStyle(color: Colors.amber),
                    ),
                    content: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Inserisci elemento',
                        icon: Icon(
                          Icons.text_fields_rounded,
                          size: 15.0,
                          color: Colors.amber[300],
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          var temp = val;
                          elementoLista = temp;
                        });
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          parametriNull();
                        },
                        child: Text(
                          'Annulla',
                          style: TextStyle(color: Colors.lime[400]),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'Aggiungi',
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Colors.lime[400],
                          ),
                        ),
                        onPressed: () {
                          if (elementoLista == '') {
                            erroreCampoVuoto(context);
                          } else {
                            idElemento = randomAlphaNumeric(28);

                            Navigator.of(context).pop();

                            var listData = {
                              'Id Elemento': idElemento,
                              'Elemento': elementoLista,
                              'Prezzo': prezzo,
                              'Descrizione': descrizione,
                              'Ultima Modifica': DateTime.now(),
                              'Stato': comprato,
                            };
                            _mylista?.add(
                              MyLista(
                                idElemento ?? 'N/A',
                                elementoLista ?? 'N/A',
                                descrizione ?? 'Nessuna descrizione',
                                prezzo,
                                comprato,
                              ),
                            );

                            DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              tipoPagina: widget.tipoPagina,
                              titoloLista: widget.titolo,
                              idLista: widget.idLista,
                            ).aggiungiElementoAllaLista(listData);
                            DatabaseService(
                              uid: FirebaseAuth.instance.currentUser?.uid,
                              tipoPagina: widget.tipoPagina,
                              titoloLista: widget.titolo,
                              idLista: widget.idLista,
                            ).updateAnteprimaLista(totaleSpesa);
                          }
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Dettagli',
                          style: TextStyle(color: Colors.lime[400]),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  'Dettagli Elemento',
                                  style: TextStyle(color: Colors.amber),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        icon: Icon(
                                          Icons.attach_money_rounded,
                                          color: Colors.amber[300],
                                          size: 15.0,
                                        ),
                                        labelText: 'Prezzo',
                                      ),
                                      onChanged: (valore) {
                                        setState(() {
                                          var temp = valore;
                                          prezzo = temp;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 9.0),
                                    TextFormField(
                                      maxLength: 20,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        icon: Icon(
                                          Icons.description_rounded,
                                          size: 15.0,
                                          color: Colors.amber[300],
                                        ),
                                        labelText: 'Descrizione',
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          var temp = val;
                                          descrizione = temp;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Fatto',
                                      style: TextStyle(color: Colors.lime[400]),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _condividiComeTesto,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            itemBuilder: (BuildContext context) {
              return items.map((String scelto) {
                return PopupMenuItem<String>(
                  value: scelto,
                  child: Text(scelto),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Utenti')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(widget.tipoPagina)
            .doc(widget.idLista)
            .collection('Lista')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Caricamento...'),
                  SizedBox(height: 8.0),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: _mylista?.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: ListTile(
                    title: Text(
                      _mylista![index].elemento,
                      style: _mylista![index].done
                          ? TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[350],
                            )
                          : TextStyle(decoration: TextDecoration.none),
                    ),
                    subtitle: Text(
                      _mylista![index].descrizione,
                      style: TextStyle(
                        fontSize: 8.0,
                        color: _mylista![index].done
                            ? Colors.grey[350]
                            : Colors.grey[400],
                        decoration: _mylista![index].done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: Checkbox(
                      activeColor: widget.colore,
                      onChanged: (val) {
                        setState(() {
                          comprato = val!;
                          _mylista?[index].done = comprato;
                        });

                        if (_mylista![index].done) {
                          prendiPrezzo(
                            _mylista?[index].prezzo,
                            _mylista?[index],
                          );
                        }
                        if (!_mylista![index].done) {
                          calcolaNuovoTotale(_mylista?[index].prezzo);
                        }
                        DatabaseService(
                          uid: FirebaseAuth.instance.currentUser!.uid,
                          tipoPagina: widget.tipoPagina,
                          titoloLista: widget.titolo,
                          idLista: widget.idLista,
                        ).updateElemento(
                          _mylista?[index].prezzo,
                          _mylista?[index],
                          _mylista?[index].done,
                        );
                        DatabaseService(
                          uid: FirebaseAuth.instance.currentUser!.uid,
                          tipoPagina: widget.tipoPagina,
                          titoloLista: widget.titolo,
                          idLista: widget.idLista,
                        ).updateAnteprimaLista(totaleSpesa);
                      },
                      value: checkAcquisto(_mylista?[index]),
                    ),
                    onLongPress: () => cancellaElemento(
                      context,
                      _mylista!,
                      index,
                      widget.tipoPagina,
                      widget.titolo,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewElemento(
                          elemento: _mylista?[index].elemento,
                          desc: _mylista?[index].descrizione,
                          done: _mylista?[index].done,
                          prezzo: _mylista?[index].prezzo,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
