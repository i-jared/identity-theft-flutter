import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:id_theft/general/enums.dart';
import 'package:id_theft/state/tracker_state.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    Hive.registerAdapter(NumberStatusAdapter());
    groupStream = FirebaseFirestore.instance
        .collection('games')
        .doc(widget.code)
        .snapshots();
    init();
  }

  void init() async {
    var openBox = await Hive.openBox('guesses');
    openBox.clear();
    var data = List<NumberStatus>.from(await openBox.get('data') ??
        List<NumberStatus>.generate(125, (i) => NumberStatus.unknown));
    setState(() {
      box = openBox;
      numberStates = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackerState = Provider.of<TrackerState>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => edit = !edit),
          child: edit ? const Icon(Icons.check) : const Icon(Icons.edit)),
      appBar: AppBar(centerTitle: true, title: const Text('Identity Theft')),
      body: StreamBuilder(
          stream: groupStream,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              print(snapshot.error);
              return const CircularProgressIndicator();
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return Container(
                color: Colors.white,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(children: <Widget>[
                        const SizedBox(height: 10),
                        Row(children: [
                          Flexible(
                              flex: 8,
                              child: Row(
                                  children: [' ', ...data['players']['names']]
                                      .map((name) => Expanded(
                                              child: Text(
                                            name,
                                            textAlign: TextAlign.center,
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
                                        padding: const EdgeInsets.only(
                                            top: 30, bottom: 100),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 6),
                                        itemCount: 150,
                                        itemBuilder: (context, i) {
                                          if (i % 6 == 0) {
                                            return Center(
                                              child: Text(
                                                '${i ~/ 6 % 5 + 1}',
                                                style: Theme.of(context)
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
                                            color = Colors.lightBlue;
                                          } else if (i ~/ 6 < 15) {
                                            color = Colors.lightGreen;
                                          } else if (i ~/ 6 < 20) {
                                            color = Colors.yellow;
                                          } else {
                                            color = Colors.orange;
                                          }
                                          Widget child;
                                          switch (numberStates[k]) {
                                            case NumberStatus.unknown:
                                              child = const SizedBox.shrink();
                                              break;
                                            case NumberStatus.maybe:
                                              child = const Center(
                                                  child: Text('?',
                                                      style: TextStyle(
                                                          fontSize: 20)));
                                              break;
                                            case NumberStatus.yes:
                                              child = const Icon(Icons.check);
                                              break;
                                            case NumberStatus.no:
                                              child = const Icon(Icons.clear);
                                              break;
                                            default:
                                              child = const SizedBox.shrink();
                                              break;
                                          }
                                          return GestureDetector(
                                            onTap: () => toggleItem(k),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: color,
                                                  border: Border.all()),
                                              child: child,
                                            ),
                                          );
                                        }))
                              ])),
                          const Spacer(),
                        ]))
                      ]));
          }),
    );
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
