part of sliding_panel;

class PanelController {
  static double _defaultCallback([double x]) {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');
    return 0.0;
  }

  static void _defaultCallbackResult({dynamic result}) {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');
  }

  VoidCallback _collapsePanelCallback = _defaultCallback;
  VoidCallback _expandPanelCallback = _defaultCallback;
  VoidCallback _closePanelCallback = _defaultCallback;

  void Function(double value) _setPanelPositionCallback = _defaultCallback;
  void Function(double value) _setAnimatedPanelPositionCallback =
      _defaultCallback;

  double Function() _getCurrentPanelPositionCallback = _defaultCallback;

  PanelState Function() _currentPanelStateCallback = () {
    print(
        'Action Failed! Reason : This controller is not attached to any SlidingPanel.');

    return PanelState.closed;
  };

  void Function({dynamic result}) _sendResultCallback = _defaultCallbackResult;

  void Function({dynamic result}) _popWithResultCallback =
      _defaultCallbackResult;

  void _control(
    VoidCallback _collapsePanelCallback,
    VoidCallback _expandPanelCallback,
    VoidCallback _closePanelCallback,
    void Function(double value) _setPanelPositionCallback,
    void Function(double value) _setAnimatedPanelPositionCallback,
    double Function() _getCurrentPanelPositionCallback,
    PanelState Function() _currentPanelStateCallback,
    void Function({dynamic result}) _sendResultCallback,
    void Function({dynamic result}) _popWithResultCallback,
  ) {
    this._collapsePanelCallback = _collapsePanelCallback;
    this._expandPanelCallback = _expandPanelCallback;
    this._closePanelCallback = _closePanelCallback;
    this._setPanelPositionCallback = _setPanelPositionCallback;
    this._setAnimatedPanelPositionCallback = _setAnimatedPanelPositionCallback;
    this._getCurrentPanelPositionCallback = _getCurrentPanelPositionCallback;
    this._currentPanelStateCallback = _currentPanelStateCallback;
    this._sendResultCallback = _sendResultCallback;
    this._popWithResultCallback = _popWithResultCallback;
  }

  /// Bring panel to the Collapsed state, if this is not a Two-state panel.
  ///
  /// (Animates to collapsedHeight).
  void collapse() {
    _collapsePanelCallback();
  }

  /// Bring panel to the Expanded state.
  ///
  /// (Animates to expandedHeight).
  void expand() {
    _expandPanelCallback();
  }

  /// Close the panel.
  ///
  /// (Animates to closedHeight).
  void close() {
    _closePanelCallback();
  }

  /// Set panel position WITHOUT animation.
  ///
  /// value >= 0.0 && value <= 2.0.
  /// value >= 0.0 && value <= 1.0, for Two-state panel.
  ///
  /// 0.0 : closedHeight ... 1.0 : collapsedHeight.
  /// 1.0 : collapsedHeight ... 2.0 : expandedHeight.
  ///
  ///
  /// 0.0 : closedHeight ... 1.0 : expandedHeight, for Two-state panel.
  void setPanelPosition(double value) {
    if (value >= 0.0 && value <= 2.0) _setPanelPositionCallback(value);
  }

  /// Set panel position WITH animation.
  ///
  /// value >= 0.0 && value <= 2.0.
  /// value >= 0.0 && value <= 1.0, for Two-state panel.
  ///
  /// 0.0 : closedHeight ... 1.0 : collapsedHeight.
  /// 1.0 : collapsedHeight ... 2.0 : expandedHeight.
  ///
  ///
  /// 0.0 : closedHeight ... 1.0 : expandedHeight, for Two-state panel.
  void setAnimatedPanelPosition(double value) {
    if (value >= 0.0 && value <= 2.0) _setAnimatedPanelPositionCallback(value);
  }

  /// Get current position of the panel.
  ///
  /// Returns between 0.0 to 2.0 and 0.0 to 1.0 for Two-state panel.
  ///
  /// 0.0 : closedHeight ... 1.0 : collapsedHeight.
  /// 1.0 : collapsedHeight ... 2.0 : expandedHeight.
  ///
  ///
  /// 0.0 : closedHeight ... 1.0 : expandedHeight, for Two-state panel.
  double getCurrentPanelPosition() => _getCurrentPanelPositionCallback();

  /// Returns the current state of the panel.
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
  /// This result can be anything except null.
  ///
  /// Useful in cases like, return some value back to the parent when user taps some item inside panel.
  ///
  /// This can be thought of as example of [Navigator.pop] with result.
  void popWithResult({dynamic result}) {
    if (result != null) _popWithResultCallback(result: result);
  }
}
