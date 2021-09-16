import 'package:flutter/material.dart';
import 'package:identity_thief/general/enums.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:identity_thief/state/tracker_state.dart';
import 'package:provider/provider.dart';

class TrackerPage extends StatefulWidget {
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  var numberStates;

  bool edit = true;
  bool loading = true;
  var box;

  @override
  void initState() {
    Hive.registerAdapter(NumberStatusAdapter());
    init();
    super.initState();
  }

  void init() async {
    await Hive.initFlutter();
    var openBox = await Hive.openBox('testBox');
    var data = await openBox.get('data') ??
        List<NumberStatus>.generate(125, (i) => NumberStatus.unknown);
    setState(() {
      box = openBox;
      numberStates = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackerState = Provider.of<TrackerState>(context);
    var names = [
      ' ',
      trackerState.p1Name,
      trackerState.p2Name,
      trackerState.p3Name,
      trackerState.p4Name,
      trackerState.p5Name
    ];

    return Scaffold(
      drawer: Drawer(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            DrawerHeader(child: Image.asset('assets/icon.png')),
            Text('Edit Player Names',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            SizedBox(height: 30),
            TextFormField(controller: trackerState.p1Controller),
            TextFormField(controller: trackerState.p2Controller),
            TextFormField(controller: trackerState.p3Controller),
            TextFormField(controller: trackerState.p4Controller),
            TextFormField(controller: trackerState.p5Controller),
            SizedBox(height: 50),
            TextButton(onPressed: () {
              trackerState.save();
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.black, fontSize: 20),))
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => edit = !edit),
          child: edit ? Icon(Icons.check) : Icon(Icons.edit)),
      appBar: AppBar(centerTitle: true, title: Text('Identity Theft')),
      body: Container(
        color: Colors.white,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Column(children: <Widget>[
                SizedBox(height: 10),
                Row(children: [
                  Flexible(
                      flex: 8,
                      child: Row(
                          children: names
                              .map((name) => Expanded(
                                      child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                  )))
                              .toList())),
                  Spacer()
                ]),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 8,
                        child: Container(
                          child: Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  padding:
                                      EdgeInsets.only(top: 30, bottom: 100),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 6),
                                  itemCount: 150,
                                  itemBuilder: (context, i) {
                                    if (i % 6 == 0)
                                      return Center(
                                        child: Text(
                                          '${i ~/ 6 % 5 + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                      );
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
                                        child = SizedBox.shrink();
                                        break;
                                      case NumberStatus.maybe:
                                        child = Center(
                                            child: Text('?',
                                                style:
                                                    TextStyle(fontSize: 20)));
                                        break;
                                      case NumberStatus.yes:
                                        child = Icon(Icons.check);
                                        break;
                                      case NumberStatus.no:
                                        child = Icon(Icons.clear);
                                        break;
                                      default:
                                        child = SizedBox.shrink();
                                        break;
                                    }
                                    return GestureDetector(
                                      onTap: () => toggleItem(k),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: color, border: Border.all()),
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ]),
      ),
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
