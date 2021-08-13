import 'package:flutter/material.dart';
import 'package:identity_thief/general/enums.dart';

class TrackerPage extends StatefulWidget {
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  var names = [' ', 'Me', 'Player 1', 'Player 2', 'Player 3', 'Player 4'];
  var numberStates =
      List<NumberStatus>.generate(125, (i) => NumberStatus.unknown);
  bool edit = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => edit = !edit),
          child: edit ? Icon(Icons.check) : Icon(Icons.edit)),
      appBar: AppBar(centerTitle: true, title: Text('Identity Theft')),
      body: Container(
        color: Colors.white,
        child: Column(children: <Widget>[
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
                    child: GridView.builder(
                      padding: EdgeInsets.only(top: 30, bottom: 100),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6),
                      itemCount: 150,
                      itemBuilder: (context, i) {
                        if (i % 6 == 0)
                          return Center(
                            child: Text(
                              '${i ~/ 6 % 5 + 1}',
                              style: Theme.of(context).textTheme.headline6,
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
                                child:
                                    Text('?', style: TextStyle(fontSize: 20)));
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
  }
}
