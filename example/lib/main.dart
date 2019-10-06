import 'package:example/controller-callback-options.dart';
import 'package:example/separate.dart';
import 'package:example/sizing.dart';
import 'package:example/two-state.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SlidingPanel Examples'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TwoStateExample()),
              );
            },
            title: Text('Two state panel with sending result'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SizingExample()),
              );
            },
            title: Text('Changing panel\'s height runtime'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SeparateContentExample()),
              );
            },
            title: Text('Panel without bodyContent'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomizeDemo()),
              );
            },
            title: Text('Use of PanelController, Callbacks and customization'),
          ),
        ],
      ),
    );
  }
}
