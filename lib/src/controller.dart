part of sliding_panel;

/// A controller that controls the [SlidingPanel] programmatically.
///
/// A controller can be attached to a single [SlidingPanel] only. Means, once attached, this controller can't be used to control other [SlidingPanel]s. So, keep one controller per [SlidingPanel].
class PanelController {
  _SlidingPanelState panel;

  bool _controlling = false;

  /// A flag that indicates whether this controller is actively controlling a [SlidingPanel].
  ///
  /// If it returs false, it indicates that you need to pass this controller as a parameter in [SlidingPanel.panelController].
  bool get controlling => _controlling;

  Duration _durationCollapsed;
  Duration _durationExpanded;

  double _diffHeight = 0.0;

  void _updateDurations() {
    _diffHeight = panel._scrollController.metadata.expandedHeight -
        panel._scrollController.metadata.closedHeight;

    double diffCollapsed = panel._scrollController.metadata.collapsedHeight -
        panel._scrollController.metadata.closedHeight;

    double diffExpanded = panel._scrollController.metadata.expandedHeight -
        panel._scrollController.metadata.collapsedHeight;

    _durationCollapsed = Duration(
        milliseconds:
            ((((diffCollapsed * panel.widget.duration.inMilliseconds) /
                        _diffHeight)
                    .floor()
                    .toInt())
                .abs()));

    _durationExpanded = Duration(
        milliseconds: ((((diffExpanded * panel.widget.duration.inMilliseconds) /
                    _diffHeight)
                .floor()
                .toInt())
            .abs()));
  }

  Duration _getDuration({double from, double to}) {
    return Duration(
        milliseconds: (((((to - from) * panel.widget.duration.inMilliseconds) /
                    _diffHeight)
                .floor()
                .toInt())
            .abs()));
  }

  void _control(_SlidingPanelState panel) {
    if (!controlling) {
      this.panel = panel;

      _updateDurations();
      _controlling = true;
    } else {
      print(
          'Error! Reason : This PanelController is already attached to a different SlidingPanel and so can\'t control any other panel. Please create a new PanelController in order to control this panel.');
    }
  }

  void _checkAttached() {
    if (panel._scrollController._scrollPosition == null) {
      _controlling = false;
      print(
          'Error! Reason : You have not attached the `PanelContent.scrollController`. Please attach the scrollController as it is necessary for the panel to work.');
    }
  }

  void _printError() {
    print(
        'Error! Reason : This controller is not attached to any SlidingPanel.\nOr you have not attached the `PanelContent.scrollController`. Please attach the scrollController as it is necessary for the panel to work.');
  }

  /// Bring the panel to [PanelState.closed].
  ///
  /// Returned future is completed when the panel is closed.
  ///
  /// (Animates to [PanelSize.closedHeight]).
  Future<Null> close() async => controlling
      ? _setPanelPosition(panel,
          duration: currentState == PanelState.collapsed
              ? _durationCollapsed
              : currentState == PanelState.expanded
                  ? panel.widget.duration
                  : _getDuration(
                      from: currentPosition,
                      to: panel._scrollController._scrollPosition.metadata
                          .closedHeight),
          to: panel._scrollController._scrollPosition.metadata.closedHeight)
      : _printError();

  /// Bring the panel to [PanelState.collapsed], if this is not a Two-state panel.
  ///
  /// Returned future is completed when the panel is collapsed.
  ///
  /// (Animates to [PanelSize.collapsedHeight]).
  Future<Null> collapse() async => controlling
      ? panel._metadata.isTwoStatePanel
          ? null
          : _setPanelPosition(panel,
              duration: currentState == PanelState.closed
                  ? _durationCollapsed
                  : currentState == PanelState.expanded
                      ? _durationExpanded
                      : _getDuration(
                          from: currentPosition,
                          to: panel._scrollController._scrollPosition.metadata
                              .collapsedHeight),
              to: panel
                  ._scrollController._scrollPosition.metadata.collapsedHeight)
      : _printError();

  /// Bring the panel to [PanelState.expanded].
  ///
  /// Returned future is completed when the panel is expanded.
  ///
  /// (Animates to [PanelSize.expandedHeight]).
  Future<Null> expand() async => controlling
      ? _setPanelPosition(panel,
          duration: currentState == PanelState.collapsed
              ? _durationExpanded
              : currentState == PanelState.closed
                  ? panel.widget.duration
                  : _getDuration(
                      from: currentPosition,
                      to: panel._scrollController._scrollPosition.metadata
                          .expandedHeight),
          to: panel._scrollController._scrollPosition.metadata.expandedHeight)
      : _printError();

  /// Set panel position WITHOUT animation.
  ///
  /// This doesn't return a [Future], as the effect is immediate.
  ///
  /// Given [value] is clamped between [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  void setPanelPosition(double value) => controlling
      ? _setPanelPosition(panel, duration: Duration(milliseconds: 0), to: value)
      : _printError();

  /// Set panel position WITH animation.
  ///
  /// Returned future is completed when the panel is animated.
  ///
  /// Given [value] is clamped between [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  Future<Null> setAnimatedPanelPosition(double value) async => controlling
      ? _setPanelPosition(panel,
          duration: _getDuration(
              from: panel._scrollController.metadata.currentHeight, to: value),
          to: value)
      : _printError();

  /// Get Panel's height between [PanelSize.closedHeight] and [PanelSize.expandedHeight], given specific [percent] between 0.0 and 1.0.
  ///
  ///
  /// e.g.,
  ///
  /// [PanelSize.closedHeight] = 0.25
  ///
  /// [PanelSize.expandedHeight] = 0.75
  ///
  /// If you want to get 25% of panel's height, then pass '0.25' as parameter, you will get '0.375'.
  ///
  /// If you want to get 100% of panel's height, then pass '1.00' as parameter, you will get '0.75'.
  double getPercentToPanelPosition(double percent) {
    double min = panel._scrollController.metadata.closedHeight;
    double max = panel._scrollController.metadata.expandedHeight;

    double value = ((percent * (max - min)) + min);

    return (double.parse(value.toStringAsFixed(5)));
  }

  /// Get Panel's current position as percentage between 0.0 and 1.0, given minimum and maximum positions.
  ///
  ///
  /// e.g.,
  ///
  /// [PanelSize.closedHeight] = 0.25
  ///
  /// [PanelSize.collapsedHeight] = 0.40
  ///
  /// [PanelSize.expandedHeight] = 0.75
  ///
  /// If current state is [PanelState.collapsed], (position would be 0.4),
  /// and you pass [min] as [PanelSize.closedHeight] and [max] as [PanelSize.expandedHeight], this will return '0.3'.
  ///
  /// If current position is 0.6, this will return '0.7'.
  double percentPosition(double min, double max) {
    if (min >= max) return 0.0;

    if (currentPosition < min) return 0.0;

    if (currentPosition > max) return 1.0;

    double percent = ((currentPosition - min) / (max - min));

    return (double.parse(percent.toStringAsFixed(5)));
  }

  /// Get current position of the panel.
  ///
  /// Returns between [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  double get currentPosition =>
      controlling ? panel._scrollController.metadata.currentHeight : 0.0;

  /// Returns the current [PanelState] of the panel.
  PanelState get currentState {
    if (!controlling) {
      return PanelState.indefinite;
    }

    if ((!_PanelAnimation.isCleared) &&
        (_PanelAnimation.animation != null) &&
        (_PanelAnimation.animation.isAnimating)) {
      return PanelState.animating;
    }

    _PanelMetadata data = panel._scrollController.metadata;

    if (data.currentHeight == data.closedHeight)
      return PanelState.closed;
    else if ((data.currentHeight == data.collapsedHeight) &&
        (!panel._metadata.isTwoStatePanel))
      return PanelState.collapsed;
    else if (data.currentHeight == data.expandedHeight)
      return PanelState.expanded;
    else
      return PanelState.indefinite;
  }

  /// Triggers a [Notification] with given result, without changing panel state.
  ///
  /// The result can be anything except null.
  ///
  /// Useful in cases like, return some value back to the parent when user taps some item inside panel.
  void sendResult({dynamic result}) {
    if (result != null && controlling)
      SlidingPanelResult(result: result).dispatch(panel.context);
  }

  /// Closes this panel and then triggers a [Notification] with given result.
  ///
  /// Returned future is completed when the panel is closed.
  ///
  /// The result can be anything except null.
  ///
  /// Useful in cases like, close the panel and then return some value back to the parent when user taps some item inside panel.
  ///
  /// This can be thought of as example of [Navigator.pop] with result.
  Future<Null> popWithResult({dynamic result}) async => close().then((_) {
        sendResult(result: result);
      });

  /// Get the [PanelSize] parameters of the current panel.
  ///
  /// The values you get from this object are always up-to-date.
  PanelSizeData get sizeData {
    if (!controlling) return PanelSizeData._empty();

    _PanelMetadata metadata = panel._scrollController.metadata;

    return PanelSizeData._(
      closedHeight: metadata.closedHeight,
      collapsedHeight: metadata.collapsedHeight,
      expandedHeight: metadata.expandedHeight,
      totalHeight: metadata.totalHeight,
    );
  }

  /// Contains [ScrollController] used by the panel and also contains some useful properties to use that controller.
  PanelScrollData get scrollData {
    if (!controlling) return PanelScrollData._empty();

    return PanelScrollData._(panel._scrollController);
  }
}
