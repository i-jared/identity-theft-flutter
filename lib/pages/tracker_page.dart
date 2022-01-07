import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:id_theft/general/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class TrackerPage extends StatefulWidget {
  final String code;
  const TrackerPage({Key? key, required this.code}) : super(key: key);
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  late List<NumberStatus> numberStates;
  bool edit = true;
  bool loading = true;
  late Box box;
  late Stream<DocumentSnapshot> groupStream;
  late List<TextEditingController> controllers;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    groupStream = FirebaseFirestore.instance
        .collection('games')
        .doc(widget.code)
        .snapshots();
    controllers = List.generate(4, (i) {
      final c = TextEditingController();
      c.addListener(() => setState(() {}));
      return c;
    });

    init();
  }

  void init() async {
    var openBox = await Hive.openBox('guesses');
    var data = List<NumberStatus>.from(await openBox.get('data') ??
        List<NumberStatus>.generate(125, (i) => NumberStatus.unknown));
    setState(() {
      box = openBox;
      numberStates = data;
      loading = false;
    });
  }

  final TextStyle tileStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<DocumentSnapshot?>(
        initialData: null,
        create: (context) => FirebaseFirestore.instance
            .collection('games')
            .doc(widget.code)
            .snapshots(),
        builder: (context, _) {
          final snapshot = Provider.of<DocumentSnapshot?>(context);
          final data =
              snapshot == null ? null : snapshot.data() as Map<String, dynamic>;
          final nameList = data == null
              ? null
              : List<String>.generate(5, (i) {
                  if (i < data['players']['names'].length) {
                    return data['players']['names'][i];
                  } else {
                    return 'id${i + 1}';
                  }
                });
          return Scaffold(
              drawer: data == null || nameList == null
                  ? null
                  : Drawer(
                      child: ListView(
                      children: [
                        DrawerHeader(child: Text('Identity Theft')),
                        ExpansionTile(
                            title: Text('Make a Guess', style: tileStyle),
                            children: [
                              ...List<Widget>.generate(4, (i) {
                                final tempIds = data['players']['ids']
                                    .where((k) => k != user!.uid)
                                    .toList();
                                final tempNames = nameList
                                    .where((n) =>
                                        n !=
                                        nameList[data['players']['ids']
                                            .indexWhere((j) => j == user!.uid)])
                                    .toList();
                                final name = tempNames[i];
                                return ListTile(
                                    leading: Text(name),
                                    title: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: controllers[i],
                                    ),
                                    trailing: TextButton(
                                        onPressed: controllers[i]
                                                    .text
                                                    .isEmpty ||
                                                tempIds.length <= i
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
                                                      await transaction.get(
                                                          documentReference);
                                                  // make updates if new player
                                                  final data = snapshot.data()
                                                      as Map<String, dynamic>;
                                                  final players =
                                                      data['players'];
                                                  players['guesses']
                                                      [tempIds[i]] = {
                                                    "guesser": data['players']
                                                        [user!.uid]["name"],
                                                    "guess":
                                                        controllers[i].text,
                                                  };
                                                  transaction.update(
                                                      documentReference,
                                                      {'players': players});
                                                });
                                                controllers[i].clear();
                                                Navigator.pop(context);
                                              },
                                        child: Text(tempIds.length <= i
                                            ? "N/A"
                                            : 'Guess')));
                              }),
                              SizedBox(height: 20),
                              TextButton(
                                  onPressed: controllers
                                          .any((c) => c.text.isEmpty)
                                      ? null
                                      : () async {
                                          final tempIds = data['players']['ids']
                                              .where((k) => k != user!.uid)
                                              .toList();
                                          DocumentReference documentReference =
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
                                            // make updates if new player
                                            final data = snapshot.data()
                                                as Map<String, dynamic>;
                                            final players = data['players'];
                                            for (int i = 0; i < 4; i++) {
                                              final id = tempIds[i];
                                              players['guesses'][id] = {
                                                "guesser": data['players']
                                                    [user!.uid]["name"],
                                                "guess": controllers[i].text,
                                              };
                                              controllers[i].clear();
                                            }

                                            transaction.update(
                                                documentReference,
                                                {'players': players});
                                          });
                                          Navigator.pop(context);
                                        },
                                  child: Text('Final Guess')),
                              SizedBox(height: 20),
                            ]),
                        SizedBox(height: 50),
                        ListTile(
                            onTap: () async {
                              final dialog = SimpleDialog(
                                title: Text('Clear Tracker?'),
                                children: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Nevermind')),
                                  TextButton(
                                      onPressed: () async {
                                        setState(() => numberStates =
                                            List<NumberStatus>.generate(125,
                                                (i) => NumberStatus.unknown));
                                        await box.clear();
                                        Navigator.pop(context);
                                      },
                                      child: Text("Clear it!"))
                                ],
                              );
                              showDialog(
                                      context: context,
                                      builder: (context) => dialog)
                                  .then((_) => Navigator.pop(context));
                            },
                            title: Text('Erase Sheet', style: tileStyle)),
                      ],
                    )),
              floatingActionButton: FloatingActionButton(
                  onPressed: () => setState(() => edit = !edit),
                  child:
                      edit ? const Icon(Icons.check) : const Icon(Icons.edit)),
              appBar: AppBar(
                  centerTitle: true, title: const Text('Identity Theft')),
              body: snapshot == null ||
                      data == null ||
                      nameList == null ||
                      user == null
                  ? Center(child: const CircularProgressIndicator())
                  : Stack(
                      children: [
                        Container(
                            color: Colors.white,
                            child: loading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(children: <Widget>[
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      Flexible(
                                          flex: 8,
                                          child: Row(
                                              children: [' ', ...nameList]
                                                  .map((name) => Expanded(
                                                          child: Text(
                                                        name,
                                                        textAlign:
                                                            TextAlign.center,
                                                      )))
                                                  .toList())),
                                      const Spacer()
                                    ]),
                                    Expanded(
                                        child: Row(children: [
                                      Flexible(
                                          flex: 8,
                                          child: Column(children: [
                                            Expanded(
                                                child: GridView.builder(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 30,
                                                            bottom: 100),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 6),
                                                    itemCount: 150,
                                                    itemBuilder: (context, i) {
                                                      if (i % 6 == 0) {
                                                        return Center(
                                                          child: Text(
                                                            '${i ~/ 6 % 5 + 1}',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline6,
                                                          ),
                                                        );
                                                      }
                                                      int k = i - 1 - i ~/ 6;
                                                      Color color;
                                                      if (i ~/ 6 < 5) {
                                                        color = Colors.pink;
                                                      } else if (i ~/ 6 < 10) {
                                                        color =
                                                            Colors.lightBlue;
                                                      } else if (i ~/ 6 < 15) {
                                                        color =
                                                            Colors.lightGreen;
                                                      } else if (i ~/ 6 < 20) {
                                                        color = Colors.yellow;
                                                      } else {
                                                        color = Colors.orange;
                                                      }
                                                      Widget child;
                                                      switch (numberStates[k]) {
                                                        case NumberStatus
                                                            .unknown:
                                                          child = const SizedBox
                                                              .shrink();
                                                          break;
                                                        case NumberStatus.maybe:
                                                          child = const Center(
                                                              child: Text('?',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20)));
                                                          break;
                                                        case NumberStatus.yes:
                                                          child = const Icon(
                                                              Icons.check);
                                                          break;
                                                        case NumberStatus.no:
                                                          child = const Icon(
                                                              Icons.clear);
                                                          break;
                                                        default:
                                                          child = const SizedBox
                                                              .shrink();
                                                          break;
                                                      }
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            toggleItem(k),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: color,
                                                                  border: Border
                                                                      .all()),
                                                          child: child,
                                                        ),
                                                      );
                                                    }))
                                          ])),
                                      const Spacer(),
                                    ]))
                                  ])),
                        if (data['players']['guesses']?[user!.uid] != null)
                          Center(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 20,
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    height: 300,
                                    width: 300,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${data['players']["guesses"][user!.uid]["guesser"]} is guessing your ID!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        Text(
                                          '${data['players']["guesses"][user!.uid]["guess"]}',
                                          style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextButton(
                                            onPressed: () async {
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
                                                // make updates if new player
                                                final data = snapshot.data()
                                                    as Map<String, dynamic>;
                                                final players = data['players'];
                                                players['guesses'][user!.uid] =
                                                    null;
                                                transaction.update(
                                                    documentReference,
                                                    {'players': players});
                                              });
                                            },
                                            child: Text(
                                              "Done",
                                              style: TextStyle(fontSize: 30),
                                            ))
                                      ],
                                    ),
                                  )))
                      ],
                    ));
        });
  }

  void toggleItem(int i) {
    if (!edit) return;
    var numberStatesCopy = [...numberStates];
    NumberStatus newStatus;
    switch (numberStates[i]) {
      case NumberStatus.unknown:
        newStatus = NumberStatus.yes;
        break;
      case NumberStatus.maybe:
        newStatus = NumberStatus.no;
        break;
      case NumberStatus.yes:
        newStatus = NumberStatus.maybe;
        break;
      case NumberStatus.no:
        newStatus = NumberStatus.unknown;
        break;
      default:
        newStatus = NumberStatus.yes;
        break;
    }
    numberStatesCopy[i] = newStatus;
    setState(() => numberStates = numberStatesCopy);
    box.put('data', numberStatesCopy);
  }
}
