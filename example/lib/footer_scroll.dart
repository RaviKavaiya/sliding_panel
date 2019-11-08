import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliding_panel/sliding_panel.dart';

class FooterAndScroll extends StatefulWidget {
  @override
  _FooterAndScrollState createState() => _FooterAndScrollState();
}

class MyListItem extends StatefulWidget {
  final String name;

  MyListItem({this.name});

  @override
  _MyListItemState createState() => _MyListItemState();
}

class _MyListItemState extends State<MyListItem> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          selected = !selected;
        });
      },
      title: Text(
        widget.name,
        style: Theme.of(context).textTheme.title,
      ),
      leading: Icon(
        Icons.check_circle,
        color: selected ? Colors.blue : null,
      ),
    );
  }
}

class _FooterAndScrollState extends State<FooterAndScroll> {
  PanelController pc;

  bool shadowStart = false, shadowEnd = true;

  static final List<String> food = [
    'Pizza',
    'Sandwich',
    'Pasta',
    'Punjabi',
    'Burger',
    'Shakes',
    'Noodles'
  ];

  List<MyListItem> foodItems;

  @override
  void initState() {
    super.initState();

    foodItems = List.generate(
      food.length,
      (index) => MyListItem(
        name: food[index],
      ),
    );

    pc = PanelController();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // listen to scroll events
      pc.scrollData.scrollController.addListener(_scrolled);
      _scrolled();
    });
  }

  void _scrolled() {
    setState(() {
      // determine whether to show shadows on each end
      shadowStart = !pc.scrollData.atStart;
      shadowEnd = !pc.scrollData.atEnd;
    });
  }

  Widget _content(ScrollController scrollController) {
    return ListView(
      shrinkWrap: true,
      controller: scrollController,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              type: MaterialType.transparency,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: foodItems,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MaxWidth and FooterWidget'),
      ),
      body: SlidingPanel(
        panelController: pc,
        backdropConfig: BackdropConfig(
          enabled: true,
          closeOnTap: false,
          dragFromBody: false,
          collapseOnTap: false,
          shadowColor: Colors.blue,
        ),
        decoration: PanelDecoration(
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        content: PanelContent(
          panelContent: (context, scrollController) {
            return _content(scrollController);
          },
          headerWidget: PanelHeaderWidget(
            headerContent: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Selection',
                      style: Theme.of(context).textTheme.headline,
                    ),
                  ),
                ),
              ],
            ),
            decoration: PanelDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              boxShadows: shadowStart
                  ? const <BoxShadow>[
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
          ),
          footerWidget: PanelFooterWidget(
            footerContent: ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    pc.close();
                  },
                  child: Text('OK'),
                ),
                FlatButton(
                  onPressed: () {
                    pc.close();
                  },
                  child: Text('CANCEL'),
                ),
              ],
            ),
            decoration: PanelDecoration(
              backgroundColor: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(4)),
              boxShadows: shadowEnd
                  ? const <BoxShadow>[
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, -3),
                      ),
                    ]
                  : null,
            ),
          ),
          bodyContent: Center(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'This is the example of panel, having a PanelFooterWidget.\nThis also uses PanelMaxWidth.',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RaisedButton(
                    child: Text("Open panel"),
                    onPressed: () {
                      pc.expand();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        isTwoStatePanel: true,
        isDraggable: false,
        size: PanelSize(closedHeight: 0.0, expandedHeight: 0.7),
        //
        maxWidth: PanelMaxWidth(landscape: 400, portrait: 350),
        // if the device comes to landscape mode, it can take maximum 400 pixels width.
        // if portrait, max it to 350.
        //
        duration: Duration(milliseconds: 1500),
        parallaxSlideAmount: 0.0,
      ),
    );
  }
}
