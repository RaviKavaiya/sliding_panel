part of sliding_panel;

/// This describes the state of the panel.
enum PanelState {
  /// The panel is having height of 0.0.
  ///
  /// When [PanelController.dismiss] is called, this is the state.
  ///
  /// Note that a panel is in [dismissed] state, ONLY if the [PanelSize.closedHeight]
  /// is NOT 0.0. If it is 0.0, [closed] state is returned instead.
  dismissed,

  /// The panel is fully closed and having [PanelSize.closedHeight].
  closed,

  /// The panel is collapsed and having [PanelSize.collapsedHeight].
  collapsed,

  /// The panel is fully expanded and having [PanelSize.expandedHeight].
  expanded,

  /// The panel is currently animating in some position.
  /// After this, panel would either be [dismissed], [closed], [collapsed] or [expanded].
  ///
  /// Note when user is swiping (moving) the panel manually,
  /// the state would be [indefinite].
  /// But, when the user releases his finger and panel starts snapping
  /// (or scrolling, if snapping is turned off), this would be the state.
  animating,

  /// The current height of the panel is more than [PanelSize.closedHeight],
  /// less than [PanelSize.expandedHeight] and not any of
  /// the specified in [PanelSize] (not exactly equal).
  ///
  /// This is the case when panel is being manually swiped (moved) by the user.
  /// After releasing the finger, if snapping is turned on,
  /// panel would have either [closed], [collapsed] or [expanded] state.
  ///
  /// If snapping is turned off and not scrolling, panel stays in this state
  /// until moved by user or [PanelController].
  indefinite,
}
