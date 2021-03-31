part of sliding_panel;

/// Denotes the result returned by the [SlidingPanel].
class SlidingPanelResult extends Notification {
  final dynamic result;

  SlidingPanelResult({required this.result}) : assert(result != null);

  @override
  String toString() => 'SlidingPanelResult { result : ${result.toString()} }';
}
