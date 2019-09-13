part of sliding_panel;

class PanelController {
  static double _defaultCallback([double x]) {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');
    return 0.0;
  }

  static Future<Null> _defaultCallbackFuture([double x]) {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');
    return Future.value(null);
  }

  static void _defaultCallbackResult({dynamic result}) {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');
  }

  Future<Null> Function() _closePanelCallback = _defaultCallbackFuture;

  Future<Null> Function() _collapsePanelCallback = _defaultCallbackFuture;

  Future<Null> Function() _expandPanelCallback = _defaultCallbackFuture;

  void Function(double value) _setPanelPositionCallback = _defaultCallback;

  Future<Null> Function(double value) _setAnimatedPanelPositionCallback =
      _defaultCallbackFuture;

  double Function() _getCurrentPanelPositionCallback = _defaultCallback;

  PanelState Function() _currentPanelStateCallback = () {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');

    return PanelState.closed;
  };

  void Function({dynamic result}) _sendResultCallback = _defaultCallbackResult;

  Future<Null> Function({dynamic result}) _popWithResultCallback =
      ({dynamic result}) {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');
    return;
  };

  void _control(
    Future<Null> Function() _closePanelCallback,
    Future<Null> Function() _collapsePanelCallback,
    Future<Null> Function() _expandPanelCallback,
    void Function(double value) _setPanelPositionCallback,
    Future<Null> Function(double value) _setAnimatedPanelPositionCallback,
    double Function() _getCurrentPanelPositionCallback,
    PanelState Function() _currentPanelStateCallback,
    void Function({dynamic result}) _sendResultCallback,
    Future<Null> Function({dynamic result}) _popWithResultCallback,
  ) {
    this._closePanelCallback = _closePanelCallback;
    this._collapsePanelCallback = _collapsePanelCallback;
    this._expandPanelCallback = _expandPanelCallback;
    this._setPanelPositionCallback = _setPanelPositionCallback;
    this._setAnimatedPanelPositionCallback = _setAnimatedPanelPositionCallback;
    this._getCurrentPanelPositionCallback = _getCurrentPanelPositionCallback;
    this._currentPanelStateCallback = _currentPanelStateCallback;
    this._sendResultCallback = _sendResultCallback;
    this._popWithResultCallback = _popWithResultCallback;
  }

  /// Bring the panel to [PanelState.closed].
  ///
  /// Returned future is completed when the panel is closed.
  ///
  /// (Animates to [PanelSize.closedHeight]).
  Future<Null> close() async => _closePanelCallback();

  /// Bring the panel to [PanelState.collapsed], if this is not a Two-state panel.
  ///
  /// Returned future is completed when the panel is collapsed.
  ///
  /// (Animates to [PanelSize.collapsedHeight]).
  Future<Null> collapse() async => _collapsePanelCallback();

  /// Bring the panel to [PanelState.expanded].
  ///
  /// Returned future is completed when the panel is expanded.
  ///
  /// (Animates to [PanelSize.expandedHeight]).
  Future<Null> expand() async => _expandPanelCallback();

  /// Set panel position WITHOUT animation.
  ///
  /// This doesn't return a [Future], as the effect is immediate.
  ///
  /// value >= 0.0 && value <= 2.0.
  /// value >= 0.0 && value <= 1.0, for Two-state panel.
  ///
  /// 0.0 : [PanelSize.closedHeight] ... 1.0 : [PanelSize.collapsedHeight].
  /// 1.0 : [PanelSize.collapsedHeight] ... 2.0 : [PanelSize.expandedHeight].
  ///
  ///
  /// 0.0 : [PanelSize.closedHeight] ... 1.0 : [PanelSize.expandedHeight], for Two-state panel.
  void setPanelPosition(double value) => _setPanelPositionCallback(value);

  /// Set panel position WITH animation.
  ///
  /// Returned future is completed when the panel is animated.
  ///
  /// value >= 0.0 && value <= 2.0.
  /// value >= 0.0 && value <= 1.0, for Two-state panel.
  ///
  /// 0.0 : [PanelSize.closedHeight] ... 1.0 : [PanelSize.collapsedHeight].
  /// 1.0 : [PanelSize.collapsedHeight] ... 2.0 : [PanelSize.expandedHeight].
  ///
  ///
  /// 0.0 : [PanelSize.closedHeight] ... 1.0 : [PanelSize.expandedHeight], for Two-state panel.
  Future<Null> setAnimatedPanelPosition(double value) =>
      _setAnimatedPanelPositionCallback(value);

  /// Get current position of the panel.
  ///
  /// Returns between 0.0 to 2.0 and 0.0 to 1.0 for Two-state panel.
  ///
  /// 0.0 : [PanelSize.closedHeight] ... 1.0 : [PanelSize.collapsedHeight].
  /// 1.0 : [PanelSize.collapsedHeight] ... 2.0 : [PanelSize.expandedHeight].
  ///
  ///
  /// 0.0 : [PanelSize.closedHeight] ... 1.0 : [PanelSize.expandedHeight], for Two-state panel.
  double getCurrentPanelPosition() => _getCurrentPanelPositionCallback();

  /// Returns the current [PanelState] of the panel.
  PanelState getCurrentPanelState() => _currentPanelStateCallback();

  /// Triggers a [Notification] with given result, without changing panel state.
  ///
  /// This result can be anything except null.
  ///
  /// Useful in cases like, return some value back to the parent when user taps some item inside panel.
  void sendResult({dynamic result}) {
    if (result != null) _sendResultCallback(result: result);
  }

  /// Closes this panel and triggers a [Notification] with given result.
  ///
  /// Returned future is completed when the panel is closed.
  ///
  /// This result can be anything except null.
  ///
  /// Useful in cases like, return some value back to the parent when user taps some item inside panel.
  ///
  /// This can be thought of as example of [Navigator.pop] with result.
  Future<Null> popWithResult({dynamic result}) =>
      _popWithResultCallback(result: result);
}
