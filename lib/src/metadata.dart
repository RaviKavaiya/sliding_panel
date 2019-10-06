part of sliding_panel;

class _PanelMetadata {
  double totalHeight;
  double closedHeight, collapsedHeight, expandedHeight;
  double dragClosedHeight, dragExpandedHeight;

  bool isTwoStatePanel;
  bool snapPanel;
  bool isDraggable;

  double snappingTriggerPercentage;

  final InitialPanelState initialPanelState;

  Map<PanelDraggingDirection, double> allowedDraggingTill;

  final ValueNotifier<double> _heightInternal;

  _PanelMetadata({
    @required this.closedHeight,
    @required this.collapsedHeight,
    @required this.expandedHeight,
    @required this.isTwoStatePanel,
    @required this.snapPanel,
    @required this.isDraggable,
    @required this.snappingTriggerPercentage,
    @required this.initialPanelState,
    @required this.allowedDraggingTill,
    @required VoidCallback whenSlided,
  })  : _heightInternal = ValueNotifier<double>(
            initialPanelState == InitialPanelState.closed
                ? closedHeight
                : initialPanelState == InitialPanelState.collapsed
                    ? isTwoStatePanel ? expandedHeight : collapsedHeight
                    : expandedHeight)
          ..addListener(whenSlided),
        totalHeight = double.infinity {
    if (allowedDraggingTill.containsKey(PanelDraggingDirection.UP)) {
      dragExpandedHeight = allowedDraggingTill[PanelDraggingDirection.UP];
    } else {
      dragExpandedHeight = expandedHeight;
    }
    if (allowedDraggingTill.containsKey(PanelDraggingDirection.DOWN)) {
      dragClosedHeight = allowedDraggingTill[PanelDraggingDirection.DOWN];
    } else {
      dragClosedHeight = closedHeight;
    }
  }

  bool get isClosed => _heightInternal.value <= closedHeight;

  bool get isCollapsed => _heightInternal.value == collapsedHeight;

  bool get isExpanded => _heightInternal.value >= expandedHeight;

  set currentHeight(double height) {
    _heightInternal.value = height.clamp(closedHeight, expandedHeight);
  }

  void _setInitialStateAgain() {
    currentHeight = initialPanelState == InitialPanelState.closed
        ? closedHeight
        : initialPanelState == InitialPanelState.collapsed
            ? isTwoStatePanel ? expandedHeight : collapsedHeight
            : expandedHeight;
  }

  double get currentHeight => _heightInternal.value;

  double get extraClosedHeight => isClosed ? 0.0 : 1.0;

  double get extraExpandedHeight => isExpanded ? 0.0 : 1.0;

  void addPercentage(double delta) {
    if (totalHeight == 0) return;

    currentHeight += delta;
  }

  void addPixels(double pixels) {
    if (totalHeight == 0) return;

    currentHeight += pixels / totalHeight * expandedHeight;
  }
}
