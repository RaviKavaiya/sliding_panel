import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class TwoStateExample extends StatefulWidget {
  @override
  _TwoStateExampleState createState() => _TwoStateExampleState();
}

class _TwoStateExampleState extends State<TwoStateExample> with SingleTickerProviderStateMixin {
  PanelController pc;

  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    pc = PanelController();

    animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  String selected = "To go back, open the panel, select an option.\nYour favorite food will be shown here.";

  BackPressBehavior behavior = BackPressBehavior.PERSIST;

  List<Widget> get _content => [
        ListTile(
          onTap: () {
            pc.popWithThrowResult(result: 'Pizza').then((_) {
              setState(() {
                selected = "You ordered Pizza.\n\nNow you can go back.";
                behavior = BackPressBehavior.POP;
              });
            });
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
            pc.popWithResult(result: 'Malai Kofta');
          },
          title: Text(
            'Malai Kofta',
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
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Samosas');
          },
          title: Text(
            'Samosas',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Toast');
          },
          title: Text(
            'Toast',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Frankie');
          },
          title: Text(
            'Frankie',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Burger');
          },
          title: Text(
            'Burger',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Salad');
          },
          title: Text(
            'Salad',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Chips');
          },
          title: Text(
            'Chips',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Cookies');
          },
          title: Text(
            'Cookies',
            style: Theme.of(context).textTheme.title,
          ),
        ),
      ];

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
            print('You sent ${food.result}...');
            selected = "You ordered ${food.result}.\n\nNow you can go back.";
            behavior = BackPressBehavior.POP;
          });
          return false; // if true, no more notifications will be received
        },
        child: SlidingPanel(
          panelController: pc,
          initialState: InitialPanelState.dismissed,
          backdropConfig: BackdropConfig(enabled: true, shadowColor: Colors.blue),
          decoration: PanelDecoration(
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          content: PanelContent(
            panelContent: _content,
            headerWidget: PanelHeaderWidget(
              headerContent: Text(
                'Menu',
                style: Theme.of(context).textTheme.headline,
              ),
              decoration: PanelDecoration(
                margin: EdgeInsets.all(16),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              options: PanelHeaderOptions(
                centerTitle: true,
                elevation: 16,
                leading: IconButton(
                  onPressed: () {
                    if (pc.currentState == PanelState.expanded)
                      pc.close();
                    else
                      pc.expand();
                  },
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: animationController.view,
                  ),
                ),
              ),
            ),
            bodyContent: Center(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      selected,
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Two state panels are better used when something like \'modal bottom sheet\' is needed.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'This is a panel, which shows a list inside it and user can tap an item to close the panel. \n\nWe have set \'BackPressBehavior\' to \'PERSIST\' so that user can\'t close the panel manually.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Note that when you select \'Pasta\', the panel isn\'t closed.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Notice the amount the panel slides when you drag it.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Panel is currently dismissed. Click below button to bring it to closed state.',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                  RaisedButton(
                    onPressed: pc.close,
                    child: Text('Open the panel'),
                  ),
                  SizedBox(height: 150),
                ],
              ),
            ),
          ),
          isTwoStatePanel: true,
          // only close and expand...
          snapping: PanelSnapping.forced,
          panelClosedOptions: PanelClosedOptions(
              sendResult: 'nothing', throwResult: 'cake', detachDragging: true, resetScrolling: true),
          // when panel closes, dont allow re-opening by drags, and
          // send and throw default results.
          size: PanelSize(closedHeight: 0.0, expandedHeight: 0.8),
          // closedHeight can also be > 0
          // we are explicitly giving expandedHeight here,
          // so if anything goes wrong, this size will be used
          autoSizing: PanelAutoSizing(autoSizeExpanded: true, useMinExpanded: true, headerSizeIsClosed: true),
          // we used 'useMinExpand'. Means, if autosizing goes above
          // 80% of screen (expandedHeight: 0.8), it will use 0.8 only.
          //
          maxWidth: PanelMaxWidth(landscape: 400),
          // if the device comes to landscape mode,
          // it can take maximum 400 pixels width.
          // portrait mode isn't affected here.
          //
          duration: Duration(milliseconds: 500),
          backPressBehavior: behavior,
          dragMultiplier: 2.0,
          onThrowResult: (result) {
            print('You thrown ${result.toString()} at me...');
          },
          onPanelSlide: (x) {
            animationController.value = pc.percentPosition(pc.sizeData.closedHeight, pc.sizeData.expandedHeight);
          },
//          isDraggable: false,
          // above will even won't allow user to drag the panel
        ),
      ),
    );
  }
}
