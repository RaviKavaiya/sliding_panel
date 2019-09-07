import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class CustomizeDemo extends StatefulWidget {
  @override
  _CustomizeDemoState createState() => _CustomizeDemoState();
}

class _CustomizeDemoState extends State<CustomizeDemo> {
  PanelController pc;

  bool draggable = true, snap = true, backdrop = true, dragBody = true;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  Widget _contentCollapsed() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Welcome',
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Swipe up ...',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '(Or tap outside to close)',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FlutterLogo(
            size: 80,
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: Text(
            'This is SlidingPanel',
            style: Theme.of(context).textTheme.headline,
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: Text(
            'Swipe Up / Down to Expand and Collapse / Close the panel',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: Text(
            'Moreover, tap area outside the panel to collapse / close it!',
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customization'),
      ),
      body: SlidingPanel(
        panelController: pc,
        backdropConfig: BackdropConfig(
            enabled: backdrop,
            closeOnTap: true,
            shadowColor: Colors.blue,
            dragFromBody: dragBody),
        content: PanelContent(
          panelContent: _content(),
          collapsedWidget: PanelCollapsedWidget(
            collapsedContent: _contentCollapsed(),
          ),
          bodyContent: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'PanelController can be used to control the panel. \nDifferent callbacks are also there, see console while you play with the panel',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'To use all these features, first set enabled:false in BackdropConfig',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Wrap(
                  runSpacing: 4,
                  spacing: 4,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Open panel"),
                      onPressed: () {
                        pc.collapse(); // open panel in Collapsed mode
                      },
                    ),
                    RaisedButton(
                      child: Text("Get current state"),
                      onPressed: () {
                        print(pc.getCurrentPanelState());
                      },
                    ),
                    RaisedButton(
                      child: Text("Get current position"),
                      onPressed: () {
                        print(pc
                            .getCurrentPanelPosition()); // Position >= 0.0 and <= 2.0
                      },
                    ),
                    RaisedButton(
                      child: Text("Set position"),
                      onPressed: () {
                        pc.setPanelPosition(0.75); // just set position
                      },
                    ),
                    RaisedButton(
                      child: Text("Set position with animation"),
                      onPressed: () {
                        pc.setAnimatedPanelPosition(0.75); // set with animation
                      },
                    ),
                    RaisedButton(
                      child: Text("Toggle snappable"),
                      onPressed: () {
                        setState(() {
                          snap =
                              !snap; // snap means, when you stop dragging panel manually, it takes a position automatically
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Toggle backdrop"),
                      onPressed: () {
                        setState(() {
                          backdrop = !backdrop;
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Toggle draggable"),
                      onPressed: () {
                        setState(() {
                          draggable =
                              !draggable; // if false, the panel stays in its state and user can't move it manually
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Toggle drag from body"),
                      onPressed: () {
                        setState(() {
                          dragBody =
                              !dragBody; // if true, panel can also be moved by dragging over body
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        size: PanelSize(
            closedHeight: 0, collapsedHeight: 200, expandedHeight: 400),
        onPanelSlide: (amount) {
          // DO SOMETHING HERE...
        },
        onPanelClosed: () {
          print('Panel is closed.');
        },
        onPanelCollapsed: () {
          print('Panel in Collapsed state.');
        },
        onPanelExpanded: () {
          print('EXPANDED...');
        },
        duration: Duration(milliseconds: 1000),
        parallaxSlideAmount: 0.0,
        snapPanel: snap,
        isDraggable: draggable,
        decoration:
            PanelDecoration(backgroundColor: Colors.orange[200], boxShadows: [
          BoxShadow(
              blurRadius: 8.0,
              color: Colors.orange[400].withOpacity(0.75),
              spreadRadius: 2,
              offset: Offset(0, -3)),
        ]),
      ),
    );
  }
}
