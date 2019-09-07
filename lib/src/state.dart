part of sliding_panel;

/// This describes current state of the panel.
enum PanelState {
  /// The panel is fully closed and having [PanelSize.closedHeight].
  closed,

  /// The panel is fully collapsed and having [PanelSize.collapsedHeight].
  collapsed,

  /// The panel is fully expanded and having [PanelSize.collapsedHeight].
  expanded,

  /// The panel is currently animating in some position. After this, panel would either be [closed], [collapsed] or [expanded].
  animating,
}
