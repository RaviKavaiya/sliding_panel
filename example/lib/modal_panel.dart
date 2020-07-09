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
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'This example uses the \'showModalSlidingPanel()\' to show a simple SlidingPanel, and then we wait for a result from that panel.',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
            child: Text(
              selected,
              style: Theme.of(context).textTheme.headline6,
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
                    safeAreaConfig:
                        SafeAreaConfig.all(removePaddingFromContent: true),
                    backdropConfig: BackdropConfig(enabled: true),
                    isTwoStatePanel: true,
                    snapping: PanelSnapping.forced,
                    size: PanelSize(closedHeight: 0.00, expandedHeight: 0.8),
                    autoSizing: PanelAutoSizing(
                        autoSizeExpanded: true, headerSizeIsClosed: true),
                    duration: Duration(milliseconds: 500),
                    //
                    // panel will appear expanded
                    initialState: InitialPanelState.expanded,
                    //
                    content: PanelContent(
                      panelContent: [
                        ListTile(
                          title: Text('SlidingPanel'),
                          onTap: () {
                            Navigator.of(context).pop('SlidingPanel :)');
                            // looks familiar, right?
                          },
                        ),
                        ListTile(
                          title: Text('showModalBottomSheet'),
                          onTap: () {
                            Navigator.of(context).pop('showModalBottomSheet');
                          },
                        ),
                        ListTile(
                          title: Text('Others'),
                          onTap: () {
                            Navigator.of(context).pop('Others ???');
                          },
                        ),
                        ListTile(
                          title: Text('Nothing'),
                          onTap: () {
                            Navigator.of(context).pop('Nothing :(');
                          },
                        ),
                        ListTile(
                          title: Text('Just close THIS!!!'),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                      headerWidget: PanelHeaderWidget(
                        headerContent: Text(
                          'For choice selection, you prefer...',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        options: PanelHeaderOptions(
                          centerTitle: true,
                          elevation: 4,
                          forceElevated: true,
                          primary: false,
                        ),
                        onTap: () => pc.currentState == PanelState.closed
                            ? pc.expand()
                            : pc.close(),
                        decoration:
                            PanelDecoration(padding: EdgeInsets.all(16)),
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
