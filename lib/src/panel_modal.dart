part of sliding_panel;

class _SlidingPanelModalRoute<T> extends PopupRoute<T> {
  _SlidingPanelModalRoute({@required this.panelRouteBuilder, @required this.duration});

  final SlidingPanel Function(_SlidingPanelModalRoute panelModalRoute) panelRouteBuilder;
  final Duration duration;

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => 'Sliding Panel Modal';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return panelRouteBuilder(this);
  }

  @override
  Duration get transitionDuration => duration;
}

/// Shows a modal [SlidingPanel].
///
/// Works similar to [showModalBottomSheet].
/// The normal SlidingPanel is just a widget. But by calling this,
/// the panel acts as a whole new route.
///
/// You can customize the panel as usual. (See below for changes).
///
/// Returns a `Future` that resolves to the value (if any) that was
/// passed to [Navigator.pop] when the SlidingPanel was closed.
///
///
///
/// Below things affect the panel behavior, rest is not affected:
///
/// [SlidingPanel.parallaxSlideAmount] will not work.
/// [SlidingPanel.animatedAppearing] is ignored, as the modal panel always
/// animtes while it appears.
/// [SlidingPanel.allowedDraggingTill] will not work.
/// [PanelContent.bodyContent] is ignored.
///
/// When initialized (this function is called), a new route will be pushed.
/// After pushing the route, the initial state (animation) of the panel is
/// decided by [SlidingPanel.initialState] as below:
///
/// (1) For two-state panels, [InitialPanelState.collapsed] is ALWAYS considered
/// to be [InitialPanelState.expanded].
///
/// (2) If [InitialPanelState.closed] is given, and IF [PanelSize.closedHeight]
/// is 0.0, it will be considered as [InitialPanelState.collapsed] (and
/// [InitialPanelState.expanded] for two-state).
///
/// (3) If [InitialPanelState.dismissed] is given, it will be considered as
/// [InitialPanelState.closed]. (Will also change the decision based on above
/// given conditions).
///
///
/// After this, panel will listen for changes in its position. Route's popping
/// is decided by [BackPressBehavior] and [PanelPoppingBehavior].
///
///
/// A panel is also considered to pop the route, when:
///
/// (1) When [PanelSize.closedHeight] is 0.0 and [PanelState.closed] happens,
/// either by dragging or by [PanelController], the route gets popped.
///
/// (2) When [PanelSize.closedHeight] is more than 0.0 (e.g.,
/// [PanelAutoSizing.headerSizeIsClosed] used), [PanelState.closed] won't pop
/// the route. At that time, currentHeight=0.0 ([PanelState.dismissed])
/// pops the route.
Future<T> showModalSlidingPanel<T>(
    {@required BuildContext context, @required SlidingPanel Function(BuildContext) panel}) {
  if (panel != null) {
    SlidingPanel _panel = panel(context);

    return Navigator.of(context).push(
      _SlidingPanelModalRoute(
        duration: _panel.duration,
        panelRouteBuilder: (route) {
          return SlidingPanel._modal(
            route,
            key: _panel.key,
            initialState: _panel.initialState,
            content: PanelContent(
                panelContent: _panel.content.panelContent,
                collapsedWidget: _panel.content.collapsedWidget,
                headerWidget: _panel.content.headerWidget,
                footerWidget: _panel.content.footerWidget,
                bodyContent: null),
            size: _panel.size,
            maxWidth: _panel.maxWidth,
            decoration: _panel.decoration,
            backdropConfig: _panel.backdropConfig,
            panelController: _panel.panelController,
            autoSizing: _panel.autoSizing,
            renderPanelBackground: _panel.renderPanelBackground,
            snapping: _panel.snapping,
            snappingTriggerPercentage: _panel.snappingTriggerPercentage,
            isDraggable: _panel.isDraggable,
            dragMultiplier: _panel.dragMultiplier,
            duration: _panel.duration,
            curve: _panel.curve,
            isTwoStatePanel: _panel.isTwoStatePanel,
            backPressBehavior: _panel.backPressBehavior,
            panelPoppingBehavior: _panel.panelPoppingBehavior,
            panelClosedOptions: _panel.panelClosedOptions,
            safeAreaConfig: _panel.safeAreaConfig,
            onPanelSlide: _panel.onPanelSlide,
            onPanelStateChanged: _panel.onPanelStateChanged,
            onThrowResult: _panel.onThrowResult,
          );
        },
      ),
    );
  }
  return Future.value(null);
}
