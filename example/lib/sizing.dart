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

  double _closed = 0.15, _collapsed = 0.40, _expanded = 0.70;

  List<Widget> get _content => [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'This is a sample panel',
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      ];

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
          panelContent: _content,
          bodyContent: Center(
            child: ListView(
              children: <Widget>[
                Wrap(
                  runSpacing: 4,
                  spacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    RaisedButton(
                      child: Text("Change expanded height"),
                      onPressed: () {
                        setState(() {
                          if (_expanded == 0.70)
                            _expanded = 0.85;
                          else
                            _expanded = 0.70;
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Change collapsed height"),
                      onPressed: () {
                        setState(() {
                          if (_collapsed == 0.40)
                            _collapsed = 0.60;
                          else
                            _collapsed = 0.40;
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Change closed height"),
                      onPressed: () {
                        setState(() {
                          if (_closed == 0.15)
                            _closed = 0.30;
                          else
                            _closed = 0.15;
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Get PanelSizeData"),
                      onPressed: () {
                        print(pc.sizeData);
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
                        'If you want to achieve such functionality, (its rarely needed) you need to turn off PanelAutoSizing.',
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'For best results (viewing animation), keep the panel in same position. (e.g., if you are changing \'collapsed\Height\', you should keep the panel in \'collapsed\' mode. (This is not compulsory)).',
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Checkout the PanelSizeData while you change these values, it gets updated.',
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Here, we also make use of \'animatedAppearing\'.',
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        size: PanelSize(closedHeight: _closed, collapsedHeight: _collapsed, expandedHeight: _expanded),
        snapping: PanelSnapping.enabled,
        initialState: InitialPanelState.collapsed,
        animatedAppearing: true,
      ),
    );
  }
}
