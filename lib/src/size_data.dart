part of sliding_panel;

/// This class gives you the [PanelSize] parameters of the current panel.
///
/// This may seem to be unusual, since these parameters are to be provided by the user,
/// but these parameters also get changed while applying [PanelAutoSizing]...
///
/// You may have some specific task to do, which relies upon the
/// updated [PanelSize] data, due to auto resizing applied, so this class comes handy.
///
/// The values you get from this object are always up-to-date.
class PanelSizeData {
  final double _closedHeight, _collapsedHeight, _expandedHeight;
  final double _totalHeight;
  final double? _constrainedHeight, _constrainedWidth;

  PanelSizeData._({
    required double closedHeight,
    required double collapsedHeight,
    required double expandedHeight,
    required double totalHeight,
    required double? constrainedHeight,
    required double? constrainedWidth,
  })   : _closedHeight = closedHeight,
        _collapsedHeight = collapsedHeight,
        _expandedHeight = expandedHeight,
        _totalHeight = totalHeight,
        _constrainedHeight = constrainedHeight,
        _constrainedWidth = constrainedWidth;

  PanelSizeData._empty()
      : _closedHeight = 0.0,
        _collapsedHeight = 0.0,
        _expandedHeight = 0.0,
        _totalHeight = 0.0,
        _constrainedHeight = 0.0,
        _constrainedWidth = 0.0;

  /// Get [PanelSize.closedHeight] of this panel.
  double get closedHeight => _closedHeight;

  /// Get [PanelSize.collapsedHeight] of this panel.
  double get collapsedHeight => _collapsedHeight;

  /// Get [PanelSize.expandedHeight] of this panel.
  double get expandedHeight => _expandedHeight;

  /// Get current maximum height the panel is using.
  /// This may change due to [PanelAutoSizing].
  ///
  /// ([constrainedHeight] * [PanelSize.expandedHeight])
  double get totalHeight => _totalHeight;

  /// Get total height (in pixels), the panel is allowed to take in the screen.
  /// It is allocated whenever panel is updated. (i.e., build method called)
  double? get constrainedHeight => _constrainedHeight;

  /// Get total width (in pixels), the panel is allowed to take in the screen.
  /// It is allocated whenever panel is updated. (i.e., build method called)
  double? get constrainedWidth => _constrainedWidth;

  @override
  String toString() =>
      'PanelSizeData { closedHeight : $closedHeight, collapsedHeight : $collapsedHeight, expandedHeight : $expandedHeight, totalHeight : $totalHeight, constrainedHeight : $constrainedHeight, constrainedWidth : $constrainedWidth }';
}
