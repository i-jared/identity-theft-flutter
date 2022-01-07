import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:id_theft/pages/waiting_room.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late TextEditingController textController;
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference games = FirebaseFirestore.instance.collection('games');
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const CircularProgressIndicator();
    }
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 150, child: Image.asset('assets/icon.png')),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: textController,
                      inputFormatters: [
                        TextInputFormatter.withFunction(
                            (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                ))
                      ],
                      decoration: const InputDecoration(
                          hintText: 'Enter game code to join'),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          // get document
                          DocumentReference documentReference =
                              FirebaseFirestore.instance
                                  .collection('games')
                                  .doc(textController.text);
                          // run transaction
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot snapshot =
                                await transaction.get(documentReference);
                            if (!snapshot.exists) {
                              //todo display that group does not exist
                              const snackBar = SnackBar(
                                content: Text('Group does not exist'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                            // make updates if new player
                            final data =
                                snapshot.data() as Map<String, dynamic>;
                            final players = data['players'];
                            if (players[user.uid] == null) {
                              players[user.uid] = {
                                'name': '',
                                'numbers': {
                                  '1': 0,
                                  '2': 0,
                                  '3': 0,
                                  '4': 0,
                                  '5': 0
                                },
                              };
                              players['groupSize'] =
                                  data['players']['groupSize'] + 1;
                              players['ids'] = [
                                ...data['players']['ids'],
                                user.uid
                              ];
                              transaction.update(
                                  documentReference, {'players': players});
                            }
                          });

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WaitingRoom(code: textController.text)));
                        } catch (e) {
                          const snackBar = SnackBar(
                            content: Text('Something went wrong...'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: const Text('Join'))
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                  Random _rnd = Random();
                  String getRandomString(int length) =>
                      String.fromCharCodes(Iterable.generate(
                          length,
                          (_) =>
                              _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
                  final code = getRandomString(5);
                  await games.doc(code).set({
                    'id': code,
                    'creator': user.uid,
                    'started': false,
                    'players': {
                      'groupSize': 1,
                      'ids': [user.uid],
                      'names': [],
                      'guesses': {},
                      user.uid: {
                        'name': '',
                        'numbers': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
                      },
                    }
                  });

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WaitingRoom(code: code)));
                },
                child: const Text('Start a New Game'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
