import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class SizingExample extends StatefulWidget {
  @override
  _SizingExampleState createState() => _SizingExampleState();
}

class _SizingExampleState extends State<SizingExample> {
  PanelController pc;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  double _closed = 0.0,
      _collapsed = 0.15,
      _expanded = 0.5; // these can be in pixels also...

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'This is a sample panel',
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changing panel\'s height'),
      ),
      body: SlidingPanel(
        panelController: pc,
        parallaxSlideAmount: 0.0,
        content: PanelContent(
          panelContent: _content(),
          headerContent: Container(
            color: Colors.grey[100],
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16.0),
                width: 36,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
          bodyContent: Center(
            child: ListView(
              children: <Widget>[
                RaisedButton(
                  child: Text("Change collapsed height"),
                  onPressed: () {
                    setState(() {
                      _collapsed = 0.3;
                    });
                  },
                ),
                RaisedButton(
                  child: Text("Change expanded height"),
                  onPressed: () {
                    setState(() {
                      _expanded = 0.7;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'You can change the panel\'s height runtime. Panel will animate automatically to that position.',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'This feature is just a preview feature and may be REMOVED in future releases. \nSo, make sure to test its effects thoroughly before moving forward.',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
              ],
            ),
          ),
        ),
        size: PanelSize(
            closedHeight: _closed,
            collapsedHeight: _collapsed,
            expandedHeight: _expanded),
        autoSizing: PanelAutoSizing(headerSizeIsClosed: true),
      ),
    );
  }
}
