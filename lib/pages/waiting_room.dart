import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:id_theft/pages/tracker_page.dart';

class WaitingRoom extends StatefulWidget {
  final String code;
  const WaitingRoom({required this.code, Key? key}) : super(key: key);
  @override
  _WaitingRoomState createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> {
  Stream<DocumentSnapshot>? groupStream;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    groupStream = FirebaseFirestore.instance
        .collection('games')
        .doc(widget.code)
        .snapshots();
    groupStream!.listen((event) {
      if ((event.data() as Map<String, dynamic>)['started']) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => TrackerPage(code: widget.code)),
            (route) => false);
      }
      textController.addListener(() => setState(() {}));
    });

    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return groupStream == null || user == null
        ? const CircularProgressIndicator()
        : SafeArea(
            child: Scaffold(
                body: StreamBuilder(
                    stream: groupStream,
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Text('error');
                      }
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                              child: Text(
                                  '${data['players']['groupSize']} people in the group now'),
                            ),
                            if (data['players'][user.uid]['name'] != '')
                              Text(List<String>.from(data['players']['names'])
                                  .join(', ')),
                            if (data['players'][user.uid]['name'] == '')
                              Row(
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                        hintText: 'Your Name'),
                                  )),
                                  ElevatedButton(
                                      onPressed: textController.text.isEmpty
                                          ? null
                                          : () async {
                                              DocumentReference
                                                  documentReference =
                                                  FirebaseFirestore.instance
                                                      .collection('games')
                                                      .doc(widget.code);
                                              // run transaction
                                              await FirebaseFirestore.instance
                                                  .runTransaction(
                                                      (transaction) async {
                                                DocumentSnapshot snapshot =
                                                    await transaction
                                                        .get(documentReference);
                                                if (!snapshot.exists) {
                                                  throw Exception(
                                                      "game does not exist");
                                                }
                                                // make updates
                                                final data = snapshot.data()
                                                    as Map<String, dynamic>;
                                                final players = data['players'];
                                                players[user.uid]['name'] =
                                                    textController.text;
                                                players['names'] = [
                                                  ...data['players']['names'],
                                                  textController.text
                                                ];
                                                transaction.update(
                                                    documentReference,
                                                    {'players': players});
                                              });
                                            },
                                      child: const Text('Set')),
                                ],
                              ),
                            if (data['creator'] == user.uid)
                              ElevatedButton(
                                  onPressed: data['players']['groupSize'] !=
                                          data['players']['names'].length
                                      ? null
                                      : () async {
                                          // get document
                                          await FirebaseFirestore.instance
                                              .collection('games')
                                              .doc(widget.code)
                                              .update({'started': true});
                                        },
                                  child: const Text('Start Game')),
                          ],
                        ),
                      );
                    })),
          );
  }
}
