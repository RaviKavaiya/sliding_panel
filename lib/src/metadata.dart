part of sliding_panel;

class _PanelMetadata {
  double constrainedHeight;
  double constrainedWidth;

  double totalHeight;

  double closedHeight, collapsedHeight, expandedHeight;
  double providedExpandedHeight;

  bool isTwoStatePanel;
  bool isDraggable;
  bool isModal;
  final bool animatedAppearing;

  PanelSnapping snapping;

  double snappingTriggerPercentage;

  double dragMultiplier;

  SafeAreaConfig safeAreaConfig;

  final InitialPanelState initialPanelState;

  final ValueNotifier<double> _heightInternal;

  final ValueNotifier<bool> _isBodyDrag;

  final VoidCallback listener;

  _PanelMetadata({
    @required this.closedHeight,
    @required this.collapsedHeight,
    @required this.expandedHeight,
    @required this.isTwoStatePanel,
    @required this.snapping,
    @required this.isDraggable,
    @required this.isModal,
    @required this.animatedAppearing,
    @required this.snappingTriggerPercentage,
    @required this.dragMultiplier,
    @required this.safeAreaConfig,
    @required this.initialPanelState,
    @required this.listener,
  })  : _heightInternal = ValueNotifier<double>((isModal ||
                initialPanelState == InitialPanelState.dismissed ||
                animatedAppearing)
            ? 0.0
            : initialPanelState == InitialPanelState.closed
                ? closedHeight
                : initialPanelState == InitialPanelState.collapsed
                    ? isTwoStatePanel
                        ? expandedHeight
                        : collapsedHeight
                    : expandedHeight)
          ..addListener(listener),
        totalHeight = double.infinity,
        _isBodyDrag = ValueNotifier<bool>(false),
        providedExpandedHeight = expandedHeight;

  bool get isClosed => _heightInternal.value <= closedHeight;

  bool get isCollapsed => _heightInternal.value == collapsedHeight;

  bool get isExpanded => _heightInternal.value >= expandedHeight;

  set currentHeight(double height) => _heightInternal.value = height;

  void _setInitialStateAgain() {
    // re-attach listener, to avoid unnecessary notify on close
    _removeHeightListener(listener);

    // modal panels ALWAYS initialize dismissed
    // dismissed panels also
    if (isModal ||
        initialPanelState == InitialPanelState.dismissed ||
        animatedAppearing)
      currentHeight = 0.0;
    else
      currentHeight = initialPanelState == InitialPanelState.closed
          ? closedHeight
          : initialPanelState == InitialPanelState.collapsed
              ? isTwoStatePanel
                  ? expandedHeight
                  : collapsedHeight
              : expandedHeight;

    _addHeightListener(listener);
  }

  void _removeHeightListener(VoidCallback listener) {
    _heightInternal.removeListener(listener);
  }

  void _addHeightListener(VoidCallback listener) {
    _heightInternal.addListener(listener);
  }

  double get currentHeight => _heightInternal.value;

  double get extraClosedHeight => isClosed ? 0.0 : 1.0;

  double get extraExpandedHeight => isExpanded ? 0.0 : 1.0;

  void addPixels(double pixels, {bool shouldMultiply = false}) {
    if (totalHeight == 0) return;

    final double toAdd = ((pixels * (shouldMultiply ? dragMultiplier : 1)) /
        totalHeight *
        expandedHeight);

    currentHeight =
        (currentHeight + toAdd)._safeClamp(closedHeight, expandedHeight);
  }
}
