import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class ResultExample extends StatefulWidget {
  @override
  _ResultExampleState createState() => _ResultExampleState();
}

class _ResultExampleState extends State<ResultExample> {
  PanelController pc;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  String selectedFood = "Your selected option will appear here...";

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 16.0),
                child: Text(
                  'What do you like?',
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              Divider(
                color: Colors.black,
                height: 32,
              ),
              Material(
                type: MaterialType
                    .transparency, // if you want to keep rounded borders as it is...
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Pizza',
                          style: Theme.of(context).textTheme.title,
                        ),
                        onTap: () {
                          pc.sendResult(
                              result: 'Pizza'); // just send the result
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Sandwich',
                          style: Theme.of(context).textTheme.title,
                        ),
                        onTap: () {
                          pc.popWithResult(
                              result:
                                  'Sandwich'); // send result as well as close the panel
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Pasta',
                          style: Theme.of(context).textTheme.title,
                        ),
                        onTap: () {
                          pc.popWithResult(result: 'Pasta');
                        },
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
        title: Text('Sending result back'),
      ),
      body: NotificationListener<SlidingPanelResult>(
        // wrap panel with this listener
        onNotification: (food) {
          // whenever we sendResult() OR popWithResult(), this is called...

          // result can be of any type,
          // in fact, here you can specify different actions based on the type of result.
          setState(() {
            selectedFood = "You like ${food.result}, right?";
          });
          return false; // if true, no more notifications will be received
        },
        child: SlidingPanel(
          panelController: pc,
          backdropConfig: BackdropConfig(
              enabled: true, closeOnTap: true, shadowColor: Colors.blue),
          parallaxSlideAmount: 0.1,
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
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 48.0, left: 12.0, right: 12.0, bottom: 12.0),
                    child: Text(
                      'You can send result back from panel (by using sendResult() and popWithResult()). \nGet values by implementing NotificationListener.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  RaisedButton(
                    child: Text("Select favorite food"),
                    onPressed: () {
                      pc.expand();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(selectedFood),
                  ),
                ],
              ),
            ),
          ),
          isTwoStatePanel:
              true, // sending results can work in normal panels also
          size: PanelSize(closedHeight: 0, expandedHeight: 300),
          autoSizing: PanelAutoSizing(autoSizeExpanded: true),
        ),
      ),
    );
  }
}
