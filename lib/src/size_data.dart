part of sliding_panel;

/// This class gives you the [PanelSize] parameters of the current panel.
///
/// This may seem to be unusual, since these parameters are to be provided by the user, but these parameters also get changed while applying [PanelAutoSizing]...
///
/// You may have some specific task to do, which relies upon the updated [PanelSize] data, due to auto resizing applied, so this class comes handy.
///
/// The values you get from this object are always up-to-date.
class PanelSizeData {
  double _closedHeight, _collapsedHeight, _expandedHeight;
  double _totalHeight;

  PanelSizeData._(
      {double closedHeight,
      double collapsedHeight,
      double expandedHeight,
      double totalHeight})
      : _closedHeight = closedHeight,
        _collapsedHeight = collapsedHeight,
        _expandedHeight = expandedHeight,
        _totalHeight = totalHeight;

  PanelSizeData._empty()
      : _closedHeight = 0.0,
        _collapsedHeight = 0.0,
        _expandedHeight = 0.0,
        _totalHeight = 0.0;

  /// Get [PanelSize.closedHeight] of this panel.
  double get closedHeight => _closedHeight;

  /// Get [PanelSize.collapsedHeight] of this panel.
  double get collapsedHeight => _collapsedHeight;

  /// Get [PanelSize.expandedHeight] of this panel.
  double get expandedHeight => _expandedHeight;

  /// Get total height (in pixels), the panel is allowed to take in the screen. It is allocated whenever panel is updated. (i.e., build method called.)
  double get totalHeight => _totalHeight;

  @override
  String toString() =>
      'PanelSizeData { closedHeight : $closedHeight, collapsedHeight : $collapsedHeight, expandedHeight : $expandedHeight, totalHeight : $totalHeight }';
}
