part of sliding_panel;

/// A controller that controls the [SlidingPanel] programmatically.
///
/// Attaching the same controller to different panels
/// would simply control the latest attached panel only.
class PanelController {
  _SlidingPanelState panel;

  bool _controlling = false;

  /// A flag that indicates whether this controller is
  /// actively controlling a [SlidingPanel].
  ///
  /// If it returs false, it indicates that you need to pass
  /// this controller as a parameter in [SlidingPanel.panelController].
  bool get controlling => _controlling;

  Duration _durationCollapsed;
  Duration _durationExpanded;

  double _diffHeight = 0.0;

  void _updateDurations() {
    // Duration is calculated from dismissed state to expanded.
    _diffHeight = panel._metadata.expandedHeight - 0.0;

    double diffCollapsed =
        panel._metadata.collapsedHeight - panel._metadata.closedHeight;

    double diffExpanded =
        panel._metadata.expandedHeight - panel._metadata.collapsedHeight;

    double _durCollapsed =
        ((diffCollapsed * panel.widget.duration.inMilliseconds) / _diffHeight);

    double _durExpanded =
        ((diffExpanded * panel.widget.duration.inMilliseconds) / _diffHeight);

    if (_durCollapsed.isInfinite || _durCollapsed.isNaN) {
      _durationCollapsed = Duration(milliseconds: 0);
    } else {
      _durationCollapsed =
          Duration(milliseconds: (_durCollapsed.floor().toInt()).abs());
    }

    if (_durExpanded.isInfinite || _durExpanded.isNaN) {
      _durationExpanded = Duration(milliseconds: 0);
    } else {
      _durationExpanded =
          Duration(milliseconds: (_durExpanded.floor().toInt()).abs());
    }
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
    this.panel = null;

    this.panel = panel;

    _updateDurations();
    _controlling = true;
  }

  void _printError() {
    print(
        'ERROR: This SlidingPanel does not have any PanelController attached.\nIt is necessary for the panel to work.');
  }

  /// Re-calculates the panel's size forcefully when using [PanelAutoSizing].
  ///
  /// The [then] callback is called when the recalculation work is done.
  ///
  /// This is useful when you have changed (replaced) the [PanelContent].
  /// and want the panel to adjust its size again.
  void rebuild({VoidCallback then}) {
    if (controlling) panel.rebuild(then: then);
  }

  /// Used to dismiss the panel.
  /// No matter how much [PanelSize.closedHeight] is given, by calling this,
  /// the panel gets completely hidden as if you gave it a
  /// [PanelSize.closedHeight] to 0.0.
  ///
  /// (Animation is played).
  ///
  /// This is not intended to be a general purpose function to hide the panel.
  /// Instead, use of [close] is suggested. This can be used for, like if you
  /// are using [PanelAutoSizing.headerSizeIsClosed] and you want to hide the
  /// panel including the header also.
  ///
  /// Returned future is completed when the panel is dismissed.
  Future<Null> dismiss() async {
    if (controlling)
      await _setPanelPosition(panel,
          duration: _getDuration(from: currentPosition, to: 0.0),
          to: 0.0,
          shouldClamp: false);
    else
      return _printError();
  }

  /// Bring the panel to [PanelState.closed].
  ///
  /// Returned future is completed when the panel is closed.
  ///
  /// (Animates to [PanelSize.closedHeight]).
  Future<Null> close() async {
    if (controlling) {
      if (currentPosition == 0.0 && (panel._metadata.closedHeight > 0.0)) {
        // if closing from dismissed, DONT notify results yet
        panel._shouldNotifyOnClose = false;
      }

      return _setPanelPosition(panel,
          duration: currentState == PanelState.collapsed
              ? _durationCollapsed
              : currentState == PanelState.expanded
                  ? panel.widget.duration
                  : _getDuration(
                      from: currentPosition, to: panel._metadata.closedHeight),
          to: panel._metadata.closedHeight);
    } else {
      _printError();
    }
  }

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
                          to: panel._metadata.collapsedHeight),
              to: panel._metadata.collapsedHeight)
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
                      to: panel._metadata.expandedHeight),
          to: panel._metadata.expandedHeight)
      : _printError();

  /// Set panel position WITHOUT animation.
  ///
  /// This doesn't return a [Future], as the effect is immediate.
  ///
  /// Given [value] is clamped between
  /// [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  void setPanelPosition(double value) => controlling
      ? _setPanelPosition(panel, duration: Duration(milliseconds: 0), to: value)
      : _printError();

  /// Set panel position WITH animation.
  ///
  /// Returned future is completed when the panel is animated.
  ///
  /// Given [value] is clamped between
  /// [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  Future<Null> setAnimatedPanelPosition(double value) async => controlling
      ? _setPanelPosition(panel,
          duration:
              _getDuration(from: panel._metadata.currentHeight, to: value),
          to: value)
      : _printError();

  /// Get Panel's height between [PanelSize.closedHeight] and
  /// [PanelSize.expandedHeight], given specific [percent] between 0.0 and 1.0.
  ///
  /// If [forDismissed] is true, the calculation is done from 0.0 to
  /// [PanelSize.expandedHeight], rather than from [PanelSize.closedHeight].
  ///
  /// e.g.,
  ///
  /// [PanelSize.closedHeight] = 0.25
  ///
  /// [PanelSize.expandedHeight] = 0.75
  ///
  /// If you want to get 25% of panel's height,
  /// then pass '0.25' as parameter, you will get '0.375'.
  ///
  /// If you want to get 100% of panel's height,
  /// then pass '1.00' as parameter, you will get '0.75'.
  double getPercentToPanelPosition(double percent,
      {bool forDismissed = false}) {
    double min = 0.0;

    if (!forDismissed) min = panel._metadata.closedHeight;

    double max = panel._metadata.expandedHeight;

    double value = ((percent * (max - min)) + min);

    return (double.parse(value.toStringAsFixed(5)));
  }

  /// Get Panel's current position as percentage
  /// between 0.0 and 1.0, given minimum and maximum positions.
  ///
  /// This can be used, for example, to get values for an AnimationController.
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
  /// and you pass [min] as [PanelSize.closedHeight] and
  /// [max] as [PanelSize.expandedHeight], this will return '0.3'.
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
  ///
  /// Returns 0.0 if panel is [PanelState.dismissed].
  double get currentPosition =>
      controlling ? panel._metadata.currentHeight : 0.0;

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

    _PanelMetadata data = panel._metadata;

    if (data.currentHeight == 0.0 && data.closedHeight != 0.0)
      return PanelState.dismissed;
    else if (data.currentHeight == data.closedHeight)
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
  /// Useful in cases like, return some value back to the parent
  /// when user taps some item inside panel.
  void sendResult({dynamic result}) {
    if (result != null && controlling)
      SlidingPanelResult(result: result).dispatch(panel.context);
  }

  /// Dismisses this panel and then triggers a [Notification] with given result.
  ///
  /// Returned future is completed when the panel is dismissed.
  ///
  /// The result can be anything except null.
  ///
  /// Useful in cases like, dismiss the panel and then return
  /// some value back to the parent when user taps some item inside panel.
  ///
  /// If [shouldCloseOnly] is true, then panel will close instead
  /// of being dismissed.
  ///
  /// This can be thought of as example of [Navigator.pop] with result.
  Future<Null> popWithResult(
      {dynamic result, bool shouldCloseOnly = false}) async {
    panel._shouldNotifyOnClose = false;

    if (shouldCloseOnly)
      return close().then((_) {
        sendResult(result: result);
      });

    return dismiss().then((_) {
      sendResult(result: result);
    });
  }

  /// Sends the [result] back to the [SlidingPanel.onThrowResult].
  ///
  /// The result can be anything except null.
  ///
  /// Useful when you don't want to use
  /// [sendResult] with a [NotificationListener].
  void throwResult({dynamic result}) {
    if (result != null && controlling && panel.widget.onThrowResult != null) {
      panel.widget.onThrowResult(result);
    }
  }

  /// Dismisses this panel and then sends the [result]
  /// back to the [SlidingPanel.onThrowResult].
  ///
  /// Returned future is completed when the panel is dismissed.
  ///
  /// The result can be anything except null.
  ///
  /// If [shouldCloseOnly] is true, then panel will close instead
  /// of being dismissed.
  ///
  /// Useful when you don't want to use
  /// [popWithResult] with a [NotificationListener].
  Future<Null> popWithThrowResult(
      {dynamic result, bool shouldCloseOnly = false}) async {
    panel._shouldNotifyOnClose = false;

    if (shouldCloseOnly)
      return close().then((_) {
        throwResult(result: result);
      });

    return dismiss().then((_) {
      throwResult(result: result);
    });
  }

  /// Get the [PanelSize] parameters of the current panel.
  ///
  /// The values you get from this object are always up-to-date.
  PanelSizeData get sizeData {
    if (!controlling) return PanelSizeData._empty();

    _PanelMetadata metadata = panel._metadata;

    return PanelSizeData._(
      closedHeight: metadata.closedHeight,
      collapsedHeight: metadata.collapsedHeight,
      expandedHeight: metadata.expandedHeight,
      totalHeight: metadata.totalHeight,
      constrainedHeight: metadata.constrainedHeight,
      constrainedWidth: metadata.constrainedWidth,
    );
  }

  /// Contains [ScrollController] used by the panel and
  /// also contains some useful properties to use that controller.
  PanelScrollData get scrollData {
    if (!controlling) return PanelScrollData._empty();

    return PanelScrollData._(panel._scrollController);
  }
}
