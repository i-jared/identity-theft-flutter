import 'package:flutter/material.dart';

class TrackerState extends ChangeNotifier {
  TextEditingController p1Controller;
  TextEditingController p2Controller;
  TextEditingController p3Controller;
  TextEditingController p4Controller;
  TextEditingController p5Controller;
  String _p1Name;

  String get p1Name => _p1Name;

  set p1Name(String p1Name) {
    _p1Name = p1Name;
    notifyListeners();
  }

  String _p2Name;

  String get p2Name => _p2Name;

  set p2Name(String p2Name) {
    _p2Name = p2Name;
    notifyListeners();
  }

  String _p3Name;

  String get p3Name => _p3Name;

  set p3Name(String p3Name) {
    _p3Name = p3Name;
    notifyListeners();
  }

  String _p4Name;

  String get p4Name => _p4Name;

  set p4Name(String p4Name) {
    _p4Name = p4Name;
    notifyListeners();
  }

  String _p5Name;

  String get p5Name => _p5Name;

  set p5Name(String p5Name) {
    _p5Name = p5Name;
    notifyListeners();
  }

  TrackerState()
      : _p1Name = 'Me',
        _p2Name = 'Player1',
        _p3Name = 'Player2',
        _p4Name = 'Player3',
        _p5Name = 'Player4',
        p1Controller = TextEditingController(text: 'Me'),
        p2Controller = TextEditingController(text: 'Player1'),
        p3Controller = TextEditingController(text: 'Player2'),
        p4Controller = TextEditingController(text: 'Player3'),
        p5Controller = TextEditingController(text: 'Player4');

  void save() {
    _p1Name = p1Controller.text;
    _p2Name = p2Controller.text;
    _p3Name = p3Controller.text;
    _p4Name = p4Controller.text;
    _p5Name = p5Controller.text;
    notifyListeners();
  }
}
