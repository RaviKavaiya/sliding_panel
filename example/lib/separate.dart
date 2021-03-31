import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class SeparateContentExample extends StatefulWidget {
  @override
  _SeparateContentExampleState createState() => _SeparateContentExampleState();
}

class _SeparateContentExampleState extends State<SeparateContentExample> {
  PanelController? pc;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  List<Widget> get _content => [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(24.0),
                child: Text(
                  'This is SlidingPanel',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Container(
                margin: EdgeInsets.all(24.0),
                child: Text(
                  'This panel doesn\'t contain bodyContent, but the SlidingPanel is attached to previous widget tree.',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Container(
                margin: EdgeInsets.all(24.0),
                child: Text(
                  'Here you get some more content.',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Container(
                margin: EdgeInsets.all(24.0),
                child: Text(
                  'Some useful content.',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Container(
                margin: EdgeInsets.all(24.0),
                child: Text(
                  'See you later!',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Separate Panel Content'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'You can also use SlidingPanel in a different way.',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Suppose you already have some app screen ready and want to add SlidingPanel to that screen, you don\'t need to change everything.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '\nJust put your old content and SlidingPanel in a Stack widget. \n\nFor example, this is the example!',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
          ),
          SlidingPanel(
            panelController: pc,
            backdropConfig: BackdropConfig(
                enabled: true, closeOnTap: true, shadowColor: Colors.blue),
            content: PanelContent(
              panelContent: _content,
              bodyContent: null,
              // see this...
            ),
            snapping: PanelSnapping.enabled,
            size: PanelSize(
                closedHeight: 0.15,
                collapsedHeight: 0.40,
                expandedHeight: 0.85),
            autoSizing: PanelAutoSizing(
              autoSizeExpanded: true,
            ),
            //
            parallaxSlideAmount: 1.0,
            // Parallax sliding is not available if you don't use 'bodyContent'.
            //
            duration: Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }
}
