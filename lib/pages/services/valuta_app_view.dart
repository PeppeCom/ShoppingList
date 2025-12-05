import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/services/database.dart';
import '/standard/costanti.dart';
import 'package:rate_my_app/rate_my_app.dart';

class ValutaAppView extends StatefulWidget {
  final RateMyApp rateMyApp;
  const ValutaAppView({super.key, required this.rateMyApp});

  @override
  _ValutaAppViewState createState() => _ValutaAppViewState();
}

class _ValutaAppViewState extends State<ValutaAppView> {
  @override
  Widget build(BuildContext context) {
    return 
       Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 38.0, bottom: 40),
              child: Text(
                "Sostieni l'app dando un voto",
                style: TextStyle(color: Colors.grey[700], fontSize: 24),
              ),
            ),
            SizedBox(height: 40),
            Icon(
              Icons.star_border_rounded,
              color: valutaAppTypeColor,
              size: 170.0,
            ),
            SizedBox(height: 50.0),
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(valutaAppTypeColor),
              ),
              onPressed: () => widget.rateMyApp.showStarRateDialog(
                context,
                title: 'Valuta la nostra App',
                message:
                    "Stiamo lavorando per fornirti un'esperienza migliore.\nApprezzeremmo un tuo giudizio",
                starRatingOptions: StarRatingOptions(initialRating: 0),
                actionsBuilder: (context, valore) {
                  return [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancella'),
                    ),
                    TextButton(
                      onPressed: () {
                        mostraSnackBar(context, 'Grazie per la valutazione');

                        DatabaseService(
                          uid: FirebaseAuth.instance.currentUser!.uid,
                        ).campoValutazioneApp(
                          FirebaseAuth.instance.currentUser!.displayName ?? '',
                          FirebaseAuth.instance.currentUser!.email ?? '',
                          FirebaseAuth
                              .instance
                              .currentUser!
                              .providerData[0]
                              .providerId,
                          valore,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'),
                    ),
                  ];
                },
              ),
              child: Text(
                'Dacci un voto !',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110.0, bottom: 20.0),
              child: Text(
                'From\nSHOPPING LIST TEAM',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      );
  }
}

mostraSnackBar(context, String testo) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(duration: Duration(seconds: 2), content: Text(testo)),
  );
}
