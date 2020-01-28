part of sliding_panel;

/// Contains [ScrollController] used by the panel and also contains
/// some useful properties to use that controller.
///
/// NOTE: A beta feature. Although simple, this is tested roughly.
/// Some features may not work in all cases. Feedback needed.
class PanelScrollData {
  ScrollController _scrollController;

  PanelScrollData._(this._scrollController);

  PanelScrollData._empty() : _scrollController = null;

  /// Get the [ScrollController] used by the [SlidingPanel].
  ///
  /// This is exactly the same controller used in the [PanelContent].
  ScrollController get scrollController => _scrollController;

  /// Whether the scrollable content is at its starting position.
  bool get atStart {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == scrollController.position.minScrollExtent) return true;
    } else {
      if (scrollController.position.pixels < 0.0) return true;
    }
    return false;
  }

  /// Whether the scrollable content is at its ending position (i.e., scrolled to end).
  bool get atEnd {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) return true;
    }
    return false;
  }

  /// Whether the scrollable content's position is between starting and ending position.
  bool get inBetween {
    return (!scrollController.position.atEdge);
  }
}
