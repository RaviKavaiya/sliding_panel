part of sliding_panel;

/// SlidingPanel
class SlidingPanel extends StatefulWidget {
  /// This decides the initial state of the panel.
  ///
  /// If this is a two state panel and a value of [PanelState.collapsed] is given, it will be considered as [PanelState.closed].
  final InitialPanelState initialState;

  /// The content to be displayed in the panel.
  final PanelContent content;

  /// Provide different height of the panel in pixels or percentage according to panel's current state.
  /// None of these should be null.
  ///
  /// Make sure : closedHeight < collapsedHeight < expandedHeight.
  ///
  /// If you give height > 0 and <= 1.0, it is considered as percentage of the screen size, if it is > 1.0, it is considered as pixels.
  ///
  /// e.g., if you give 0.5, it is 50% of the screen, if you give 1.0, it is full screen, but if you give 75, it is pixels.
  final PanelSize size;

  /// The decoration to be applied on the [PanelContent].
  final PanelDecoration decoration;

  /// Various configurations related to making [SlidingPanel] look and act like a backdrop widget.
  ///
  /// To use features, first set [BackdropConfig.enabled] to true.
  ///
  /// If enabled, a dark shadow is displayed over the [PanelContent.bodyContent] and various options are enabled.
  final BackdropConfig backdropConfig;

  /// Control this panel using controller.
  final PanelController panelController;

  /// If provided, the panel's height will be automatically calculated based on the content.
  ///
  /// For more details, please visit [PanelAutoSizing].
  final PanelAutoSizing autoSizing;

  /// To render default background behind the panel.
  ///
  /// If false, only [PanelContent.panelContent], [PanelContent.collapsedWidget] and [PanelContent.bodyContent] is rendered.
  ///
  /// Default : true
  final bool renderPanelBackground;

  /// Apply snapping effect to panel while opening / closing.
  ///
  /// Default : true
  final bool snapPanel;

  /// Whether this panel is draggable by user.
  ///
  /// Default : true
  final bool isDraggable;

  /// Specify the amount of [PanelContent.bodyContent] to slide up when panel slides.
  ///
  /// 0.0 : No sliding ... 1.0 : Slide one-to-one
  ///
  /// Default : 0.2.
  final double parallaxSlideAmount;

  /// Provide duration for the overall sliding time. This will be divided between 2 slides (i.e., closed-to-collapsed and collapsed-to-expanded) in proportion to specified heights.
  ///
  /// Default : 350 milliseconds
  final Duration duration;

  /// The curve to be used in animations.
  ///
  /// Default : [Curves.fastOutSlowIn]
  final Curve curve;

  /// Whether this panel will work as modal bottom sheet (i.e., just close and expand, no collapsing).
  ///
  /// If true, only [PanelSize.closedHeight] and [PanelSize.expandedHeight] will work, [PanelSize.collapsedHeight] and [BackdropConfig.effectInCollapsedMode] will simply be ignored.
  ///
  /// [PanelContent.collapsedWidget] will also be ignored.
  ///
  /// Also, panel would be either in [PanelState.closed], [PanelState.animating] or [PanelState.expanded] state only.
  ///
  /// Default : false
  final bool isTwoStatePanel;

  /// A callback that is called whenever the panel is slided.
  ///
  /// 0.0 : closed ... 1.0 : collapsed.
  /// 1.0 : collapsed ... 2.0 : expanded.
  final void Function(double position) onPanelSlide;

  /// A callback that is called whenever the panel is fully expanded.
  final VoidCallback onPanelExpanded;

  /// A callback that is called whenever the panel is fully collapsed.
  final VoidCallback onPanelCollapsed;

  /// A callback that is called whenever the panel is closed.
  final VoidCallback onPanelClosed;

  SlidingPanel({
    Key key,
    this.initialState = InitialPanelState.closed,
    @required this.content,
    this.size = const PanelSize(),
    this.decoration = const PanelDecoration(),
    this.backdropConfig = const BackdropConfig(),
    this.panelController,
    this.autoSizing = const PanelAutoSizing(),
    this.renderPanelBackground = true,
    this.snapPanel = true,
    this.isDraggable = true,
    this.parallaxSlideAmount = 0.2,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.fastOutSlowIn,
    this.isTwoStatePanel = false,
    this.onPanelSlide,
    this.onPanelExpanded,
    this.onPanelCollapsed,
    this.onPanelClosed,
  });

  @override
  _SlidingPanelState createState() => _SlidingPanelState();
}
