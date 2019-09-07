import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliding_panel/sliding_panel.dart';

class TwoStateExample extends StatefulWidget {
  @override
  _TwoStateExampleState createState() => _TwoStateExampleState();
}

class _TwoStateExampleState extends State<TwoStateExample> {
  PanelController pc;

  @override
  void initState() {
    super.initState();

    pc = PanelController();

    SchedulerBinding.instance.addPostFrameCallback((x) {
      _updateSize(); // This is called to make panel size according to content
    });
  }

  GlobalKey keyContent = GlobalKey();

  double _height = 200;

  Widget _content() {
    return Column(
      children: <Widget>[
        Container(
          key: keyContent,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 16.0),
                child: Text(
                  'We offer this!!!',
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              Divider(
                color: Colors.black,
                height: 32,
              ),
              Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Pizza',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Sandwich',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Pasta',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Punjabi',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'French Fries',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Two state panel'),
      ),
      body: SlidingPanel(
        panelController: pc,
        backdropConfig: BackdropConfig(
            enabled: true, closeOnTap: true, shadowColor: Colors.blue),
        decoration: PanelDecoration(
          margin: EdgeInsets.all(16),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        content: PanelContent(
          panelContent: _content(),
          bodyContent: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Two state panels are better used when something like \'modal bottom sheet\' is needed.',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                RaisedButton(
                  child: Text("Open panel"),
                  onPressed: () {
                    pc.expand();
                  },
                ),
              ],
            ),
          ),
        ),
        isTwoStatePanel: true, // only close and expand...
        size: PanelSize(
            closedHeight: 0,
            expandedHeight: _height), // closedHeight can also be > 0
      ),
    );
  }

  _updateSize() {
    final RenderBox renderBox = keyContent.currentContext.findRenderObject();

    setState(() {
      _height = renderBox.size.height + 16;
    });
  }
}
