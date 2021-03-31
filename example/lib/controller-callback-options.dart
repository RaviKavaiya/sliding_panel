import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class CustomizeDemo extends StatefulWidget {
  @override
  _CustomizeDemoState createState() => _CustomizeDemoState();
}

class _CustomizeDemoState extends State<CustomizeDemo> {
  PanelController? pc;

  bool draggable = true,
      snap = true,
      backdrop = true,
      dragBody = true,
      snapForced = true;
  bool additional = false;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  Widget _contentCollapsed() {
    return Container(
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Welcome',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Swipe up... or tap outside to close',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _content => [
        if (additional)
          Container(
            color: Colors.blue,
            padding: EdgeInsets.all(24.0),
            margin: EdgeInsets.all(24.0),
            child: Text(
              'Some additional content!!!',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: FlutterLogo(
            size: 108,
          ),
        ),
        Container(
          margin: EdgeInsets.all(24.0),
          child: Text(
            'This is a SlidingPanel',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Container(
          margin: EdgeInsets.all(24.0),
          child: Text(
            'Swipe Up / Down to Expand and Collapse / Close the panel',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Container(
          margin: EdgeInsets.all(24.0),
          child: Text(
            'Moreover, tap area outside the panel to collapse / close it!',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ];

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
          panelContent: _content,
          collapsedWidget: PanelCollapsedWidget(
            collapsedContent: _contentCollapsed(),
          ),
          bodyContent: Center(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Wrap(
                  runSpacing: 4,
                  spacing: 4,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      child: Text("Open panel"),
                      onPressed: () {
                        pc!.collapse().then((_) {
//                          print('panel is collapsed now');
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.done,
                        color: backdrop ? Colors.blue : Colors.black,
                      ),
                      label: Text("Backdrop"),
                      onPressed: () {
                        setState(() {
                          backdrop = !backdrop;
                        });
                      },
                    ),
                    ElevatedButton(
                      child: Text(
                          "Toggle additional content, rebuild then expand"),
                      onPressed: () {
                        setState(() {
                          additional = !additional;
                          pc!.rebuild(then: pc!.expand);
                        });
                      },
                    ),
                    ElevatedButton(
                      child: Text("Get current state"),
                      onPressed: () {
                        print(pc!.currentState);
                      },
                    ),
                    ElevatedButton(
                      child: Text("Get current position"),
                      onPressed: () {
                        print(pc!.currentPosition);
                        // get position between closedHeight and expandedHeight
                      },
                    ),
                    ElevatedButton(
                      child: Text("Get 50% of panel's height"),
                      onPressed: () {
                        print(pc!.getPercentToPanelPosition(0.5));
                        // we give 50% as parameter, this wil return 50% of the panel's height, (gets updated when we use AutoSizing)
                      },
                    ),
                    ElevatedButton(
                      child: Text("Set position"),
                      onPressed: () {
                        pc!.setPanelPosition(0.3); // just set position
                      },
                    ),
                    ElevatedButton(
                      child: Text("Set position with animation"),
                      onPressed: () {
                        pc!.setAnimatedPanelPosition(0.3); // set with animation
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.done,
                        color: snap ? Colors.blue : Colors.black,
                      ),
                      label: Text("Snappable"),
                      onPressed: () {
                        setState(() {
                          snap =
                              !snap; // snap means, when you stop dragging panel manually, it takes a position automatically

                          if (!snap) snapForced = false;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.done,
                        color: draggable ? Colors.blue : Colors.black,
                      ),
                      label: Text("Draggable"),
                      onPressed: () {
                        setState(() {
                          draggable =
                              !draggable; // if false, the panel stays in its state and user can't move it manually
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.done,
                        color: dragBody ? Colors.blue : Colors.black,
                      ),
                      label: Text("Drag from body"),
                      onPressed: () {
                        setState(() {
                          dragBody =
                              !dragBody; // if true, panel can also be moved by dragging over body
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.done,
                        color: snapForced ? Colors.blue : Colors.black,
                      ),
                      label: Text("Snap forcefully"),
                      onPressed: () {
                        setState(() {
                          snapForced =
                              !snapForced; // if true, panel will ALWAYS snap
                          if (snapForced) snap = true;
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'PanelController can be used to control the panel. \nDifferent callbacks are also there, see console while you play with the panel',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'To use all these features, first disable backdrop',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
          ),
        ),
        size: PanelSize(
          closedHeight: 0,
          collapsedHeight: 0.5, // 50% of screen
          expandedHeight: 0.9, // 90% of screen
        ),
        autoSizing: PanelAutoSizing(
          autoSizeCollapsed: true,
          autoSizeExpanded: true,
        ),
        onPanelSlide: (amount) {
          // DO SOMETHING HERE...
        },
        onPanelStateChanged: (state) {
//          print('panel in $state state.');
        },
        duration: Duration(milliseconds: 1000),
        parallaxSlideAmount: 0.0,
        snapping: snapForced
            ? PanelSnapping.forced
            : snap
                ? PanelSnapping.enabled
                : PanelSnapping.disabled,
        isDraggable: draggable,
        decoration: PanelDecoration(
          backgroundColor: Colors.orange[200],
          boxShadows: [
            BoxShadow(
              blurRadius: 16.0,
              color: Colors.orange[400]!.withOpacity(0.75),
              spreadRadius: 4,
              offset: Offset(0, -3),
            ),
          ],
        ),
      ),
    );
  }
}
