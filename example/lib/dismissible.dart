import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class DismissibleExample extends StatefulWidget {
  @override
  _DismissibleExampleState createState() => _DismissibleExampleState();
}

class _DismissibleExampleState extends State<DismissibleExample> {
  PanelController pc;
  PanelState currentState = PanelState.closed;

  bool isBackdrop = false;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  List<Widget> get _content => [
        ListTile(
          onTap: pc.dismiss,
          title: Text(
            'Dismiss this panel',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          title: Text(
            'This is my SlidingPanel',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dismissible panel'),
      ),
      body: SlidingPanel(
        panelController: pc,
        content: PanelContent(
          panelContent: _content,
          bodyContent: Center(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Current state : ${currentState.toString().substring(11)}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Wrap(
                  runSpacing: 4,
                  spacing: 4,
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Close"),
                      onPressed: pc.close,
                    ),
                    RaisedButton(
                      child: Text("Collapse"),
                      onPressed: pc.collapse,
                    ),
                    RaisedButton(
                      child: Text("Expand"),
                      onPressed: pc.expand,
                    ),
                    RaisedButton(
                      child: Text("Draggable from body"),
                      onPressed: () => setState(() => isBackdrop = !isBackdrop),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'This is a Dismissible panel. Try it using above given buttons.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Note when you change the device\'s resolution (e.g., rotating), the panel also persists the position and state',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Here, the panel\'s closedHeight is given as \'0.20\'. Means, panel can\'t go below this point. \nBut when you call \'dismiss()\' on the controller, this restriction is ignored and panel goes to position \'0.0\'.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'After dismissing, you can bring back the panel to any state you want.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 32, bottom: 4),
                  child: Text(
                    'About the \'dismissed\' state: ',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'This state is ONLY returned (notified) when CURRENT HEIGHT is 0.0 and \'closedHeight\' IS NOT SET TO 0.0. If \'closedHeight\' is set to 0.0, \'closed\' state is notified, NOT \'dismissed\'.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Moreover, \'draggableInClosed\' from \'backdropConfig\' will behave the same way as mentioned above. If \'closedHeight\' is 0.0 and current position also, even dismissed panel is draggable. \nBut, if \'closedHeight\' is NOT 0.0, then dismissed panel IS NOT a draggable panel.\n\nTo make this more clear, click on "\'"Draggable from body".',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                SizedBox(height: 200),
              ],
            ),
          ),
        ),
        decoration: PanelDecoration(backgroundColor: Colors.yellow[200]),
        onPanelStateChanged: (state) => setState(() => currentState = state),
        snapping: PanelSnapping.forced,
        isDraggable: true,
        backdropConfig: BackdropConfig(
            enabled: isBackdrop,
            draggableInClosed: isBackdrop,
            dragFromBody: isBackdrop,
            collapseOnTap: isBackdrop,
            closeOnTap: isBackdrop),
        size: PanelSize(
            closedHeight: 0.15, collapsedHeight: 0.30, expandedHeight: 0.60),
        duration: Duration(milliseconds: 500),
        parallaxSlideAmount: 0.0,
      ),
    );
  }
}
