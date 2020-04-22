import 'package:flutter/material.dart';
import 'package:sliding_panel/sliding_panel.dart';

class SafeAreaExample extends StatefulWidget {
  @override
  _SafeAreaExampleState createState() => _SafeAreaExampleState();
}

class _SafeAreaExampleState extends State<SafeAreaExample> with SingleTickerProviderStateMixin {
  PanelController pc;

  bool safe = true;

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

  List<Widget> get _content => [
        ListTile(
          leading: Icon(Icons.keyboard_arrow_up),
          selected: true,
          title: Text(
            'Notice above additional padding in the header. If you disable safeAreaConfig, this will come handy. You can also disable it by setting primary: false in header',
            style: textStyleTitle,
          ),
          trailing: Icon(Icons.keyboard_arrow_up),
        ),
        ListTile(
          onTap: () {
            setState(() {
              safe = !safe;
            });
          },
          selected: true,
          leading: Icon(Icons.touch_app),
          title: Text(
            'SafeAreaConfig : $safe',
            style: textStyleTitle,
          ),
        ),
        ...List.generate(
          15,
          (index) => ListTile(
            title: Text('Item ${index + 1}'),
          ),
        ),
      ];

  static final textStyleSubHead = ThemeData.dark().textTheme.subhead.copyWith(fontSize: 20);
  static final textStyleTitle = ThemeData.dark().textTheme.title.copyWith(fontSize: 22);
  static final textStyleHeadline = ThemeData.dark().textTheme.headline.copyWith(fontSize: 24);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        body: SlidingPanel(
          panelController: pc,
          safeAreaConfig: safe
              ? SafeAreaConfig.all(removePaddingFromContent: true)
              : SafeAreaConfig(removePaddingFromContent: false),
          backdropConfig: BackdropConfig(
            enabled: true,
            shadowColor: Color.fromRGBO(74, 118, 129, 1),
          ),
          size: PanelSize(closedHeight: 0.0, collapsedHeight: 0.5, expandedHeight: 1.0),
          decoration: PanelDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            backgroundColor: Color.fromRGBO(63, 96, 127, 1),
          ),
          content: PanelContent(
            panelContent: _content,
            headerWidget: PanelHeaderWidget(
              headerContent: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Header',
                    style: textStyleHeadline,
                  ),
                ),
              ),
              decoration: PanelDecoration(
                padding: EdgeInsets.all(16),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(63, 96, 127, 1),
                    Color.fromRGBO(74, 118, 129, 1),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              options: PanelHeaderOptions(
                elevation: 24,
                primary: true,
              ),
            ),
            footerWidget: PanelFooterWidget(
              footerContent: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    onPressed: null,
                    child: Text(
                      'Footer',
                      style: textStyleSubHead,
                    ),
                  ),
                ],
              ),
              decoration: PanelDecoration(
                padding: EdgeInsets.all(4),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            bodyContent: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(74, 118, 129, 0.9),
                        Color.fromRGBO(63, 96, 127, 0.9),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
                Center(
                  // Wrapping the content in SafeArea is up to you.
                  child: SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 8.0, left: 8.0, right: 8.0),
                          child: Text(
                            'This example uses `safeAreaConfig` in the panel.',
                            style: textStyleSubHead,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'So, intrusions like notch, nav-bar, status bar, etc. will be ignored by the panel and padded.',
                            style: textStyleSubHead,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '`bodyContent` and `backdropConfig` are not padded. They still get full screen height-width. Only header, content and footer are padded.',
                            style: textStyleSubHead,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Also notice the use of `primary: true` in `PanelHeaderOptions` here.',
                            style: textStyleSubHead,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(6.0),
                          child: RaisedButton(
                            onPressed: pc.collapse,
                            padding: EdgeInsets.all(16),
                            child: Text('Open panel'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            padding: EdgeInsets.all(16),
                            child: Text('Go back'),
                          ),
                        ),
                        SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          onPanelSlide: (x) {
            animationController.value = pc.percentPosition(pc.sizeData.closedHeight, pc.sizeData.expandedHeight);
          },
          parallaxSlideAmount: 0.0,
          snapping: PanelSnapping.forced,
          duration: Duration(milliseconds: 300),
          dragMultiplier: 1.5,
        ),
      ),
    );
  }
}
