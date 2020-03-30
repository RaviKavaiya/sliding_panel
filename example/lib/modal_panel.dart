import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class ModalPanelExample extends StatefulWidget {
  @override
  _ModalPanelExampleState createState() => _ModalPanelExampleState();
}

class _ModalPanelExampleState extends State<ModalPanelExample> {
  PanelController pc;

  String selected = 'Open the panel, and then choose an item.';

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modal panel'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'SlidingPanel can also act as a modal barrier. (Like, showModalBottomSheet())',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'This example uses the \'showModalSlidingPanel()\' to show a simple SlidingPanel, and then we wait for a result from that panel.',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
            child: Text(
              selected,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          RaisedButton(
            onPressed: () async {
              setState(() {
                selected = 'Waiting for the result...';
              });

              final result = await showModalSlidingPanel(
                context: context,
                panel: (context) {
                  return SlidingPanel(
                    panelController: pc,
                    backdropConfig: BackdropConfig(enabled: true),
                    isTwoStatePanel: true,
                    snapping: PanelSnapping.forced,
                    size: PanelSize(closedHeight: 0.00, expandedHeight: 0.8),
                    autoSizing: PanelAutoSizing(autoSizeExpanded: true, headerSizeIsClosed: true),
                    duration: Duration(milliseconds: 500),
                    //
                    // panel will appear expanded
                    initialState: InitialPanelState.expanded,
                    //
                    content: PanelContent(
                      panelContent: [
                        Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            title: Text('SlidingPanel'),
                            onTap: () {
                              Navigator.of(context).pop('SlidingPanel :)');
                              // looks familiar, right?
                            },
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            title: Text('Others'),
                            onTap: () {
                              Navigator.of(context).pop('others ???');
                            },
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            title: Text('Nothing'),
                            onTap: () {
                              Navigator.of(context).pop('nothing :(');
                            },
                          ),
                        ),
                      ],
                      headerWidget: PanelHeaderWidget(
                        headerContent: Text(
                          'You like ...',
                          style: Theme.of(context).textTheme.headline,
                        ),
                        options: PanelHeaderOptions(
                          centerTitle: true,
                          elevation: 4,
                          forceElevated: true,
                          primary: false,
                        ),
                        decoration: PanelDecoration(padding: EdgeInsets.all(16)),
                      ),
                    ),
                  );
                },
              );

              setState(() {
                if (result == null)
                  selected = 'You just closed the panel.';
                else
                  selected = 'Your choice : $result';
              });
            },
            child: Text('Open the panel'),
          ),
          SizedBox(height: 150),
        ],
      ),
    );
  }
}
