import 'package:flutter/material.dart';
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
  }

  String selected =
      "To go back, open the panel, select an option, then you can go back.\n\nYour favorite food will be shown here.";

  BackPressBehavior behavior = BackPressBehavior.PERSIST;

  Widget _content(ScrollController scrollController) {
    return ListView(
      shrinkWrap: true,
      controller: scrollController,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          pc.popWithResult(result: 'Pizza');
                        },
                        title: Text(
                          'Pizza',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          pc.popWithResult(result: 'Sandwich');
                        },
                        title: Text(
                          'Sandwich',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          pc.sendResult(result: 'Pasta');
                          // THIS WILL NOT CLOSE THE PANEL, JUST SEND THE RESULT
                        },
                        title: Text(
                          'Pasta',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          pc.popWithResult(result: 'Punjabi');
                        },
                        title: Text(
                          'Punjabi',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          pc.popWithResult(result: 'French Fries');
                        },
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
      body: NotificationListener<SlidingPanelResult>(
        // wrap panel with this listener
        onNotification: (food) {
          // whenever we sendResult() OR popWithResult(), this is called...

          // result can be of any type,
          // in fact, here you can specify different actions based on the type of result.
          setState(() {
            selected = "You like ${food.result}.\n\nNow you can go back.";
            behavior = BackPressBehavior.POP;
          });
          return false; // if true, no more notifications will be received
        },
        child: SlidingPanel(
          panelController: pc,
          backdropConfig: BackdropConfig(
              enabled: true, closeOnTap: true, shadowColor: Colors.blue),
          decoration: PanelDecoration(
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          content: PanelContent(
            panelContent: (context, scrollController) {
              return _content(scrollController);
            },
            bodyContent: Center(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      selected,
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Two state panels are better used when something like \'modal bottom sheet\' is needed.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'This is a panel, which shows a list inside it and user can tap an item to close the panel. \n\nWe have set \'BackPressBehavior\' to \'PERSIST\' so that user can\'t close the panel manually.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Note that when you select \'Pasta\', the panel isn\'t closed.',
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
          isTwoStatePanel: true,
          // only close and expand...
          snapPanel: true,
          size: PanelSize(closedHeight: 0.0, expandedHeight: 0.85),
          // closedHeight can also be > 0
          // we are explicitly giving expandedHeight here, so if anything goes wrong, this size will be used
          autoSizing: PanelAutoSizing(autoSizeExpanded: true),
          duration: Duration(milliseconds: 500),
          backPressBehavior: behavior,
          // don't allow user to close this panel by tapping back button

//          isDraggable: false,
          // above will even won't allow user to close the panel
        ),
      ),
    );
  }
}
