part of sliding_panel;

class _PanelScrollPosition extends ScrollPositionWithSingleContext {
  VoidCallback _dragCancelled;
  final _PanelMetadata metadata;

  bool get shouldListScroll => pixels > 0.0;

  _PanelScrollPosition({
    ScrollPhysics physics,
    ScrollContext context,
    double initPix = 0.0,
    bool keepScroll = true,
    ScrollPosition oldPos,
    this.metadata,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initPix,
          keepScrollOffset: keepScroll,
          oldPosition: oldPos,
        );

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    return super.applyContentDimensions(
        minScrollExtent - metadata.extraClosedHeight,
        maxScrollExtent + metadata.extraExpandedHeight);
  }

  @override
  void applyUserOffset(double delta) {
    // whenever dragged

    _dragPanel(
      metadata,
      delta: delta,
      isGesture: false,
      shouldListScroll: shouldListScroll,
      dragFromBody: false,
      scrollContentSuper: () {
        super.applyUserOffset(delta);
      },
    );
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    // like onDragStart

    _PanelAnimation.clear();

    _dragCancelled = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }

  @override
  void goBallistic(double velocity) {
    // like onDragEnd

    if (!metadata.isDraggable) {
      super.goBallistic(velocity);
      return;
    }

    if ((velocity.abs() == 0.0) ||
        (velocity < 0.0 && shouldListScroll) ||
        (velocity > 0.0 && metadata.isExpanded)) {
      // when dragged and released slowly in middle OR at start with scrolling OR at end
      super.goBallistic(velocity);
      return;
    }

    _dragCancelled?.call(); // must call
    _dragCancelled = null;

    if (!metadata.snapPanel) {
      // no panel snapping, just scroll the panel
      _scrollPanel(
        this,
        velocity: velocity,
        ballisticEnd: (x) {
          super.goBallistic(x);
        },
      );
    } else {
      // snap the panel

      if (!((metadata.allowedDraggingTill
              .containsKey(PanelDraggingDirection.DOWN)) ||
          (metadata.allowedDraggingTill
              .containsKey(PanelDraggingDirection.UP)))) {
        double percent =
            ((metadata.totalHeight * metadata.snappingTriggerPercentage) / 100);

        percent = percent.clamp(0.0, 750.0);

        if (percent >= 0.0) {
          if (velocity.abs() <= percent) {
            _scrollPanel(
              this,
              velocity: velocity,
            );
            return;
          }
        }
      }

      _PanelSnapData snapData = _PanelSnapData(
        scrollPos: this,
        dragVelocity: velocity,
      );

      snapData.prepareSnapping();

      if (snapData.shouldPanelSnap) {
        snapData.snapPanel();
      } else {
        super.goBallistic(velocity);
      }
    }
  }
}

class _PanelScrollController extends ScrollController {
  final _PanelMetadata metadata;

  _PanelScrollController({double initScrollOffset = 0.0, this.metadata})
      : super(initialScrollOffset: initScrollOffset);

  _PanelScrollPosition _scrollPosition;

  @override
  _PanelScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    _scrollPosition = _PanelScrollPosition(
      physics: physics,
      context: context,
      oldPos: oldPosition,
      metadata: metadata,
    );
    return _scrollPosition;
  }
}
