part of sliding_panel;

/// This decides the initial state of the panel.
///
/// If this is a two state panel and a value of [collapsed] is given, it will be considered as [closed].
///
///  NOTE that this value can't be changed once the panel is created.
enum InitialPanelState {
  /// The panel is fully closed and having [PanelSize.closedHeight].
  ///
  /// This is the default state.
  closed,

  /// The panel is fully collapsed and having [PanelSize.collapsedHeight].
  collapsed,

  /// The panel is fully expanded and having [PanelSize.collapsedHeight].
  expanded,
}

/// The widget that is displayed over [PanelContent.panelContent] when collapsed.
///
/// Crossfades when sliding.
class PanelCollapsedWidget {
  /// The widget content.
  final Widget collapsedContent;

  /// By default, [collapsedContent] is hidden only in [PanelState.expanded] mode.
  /// Set this to false, if you plan to hide [collapsedContent] in [PanelState.collapsed] mode.
  ///
  /// Default : true
  final bool hideInExpandedOnly;

  const PanelCollapsedWidget(
      {this.collapsedContent, this.hideInExpandedOnly = true});
}

/// The content to be displayed in the panel.
class PanelContent {
  /// The widget that is shown as the panel content. When collapsed, content till [collapsedWidget] is shown.
  ///
  /// If [collapsedWidget] is provided, that will be shown over this and will crossfade when sliding.
  final Widget panelContent;

  /// The widget that will be shown underneath the panel.
  ///
  /// Fitted to screen.
  final Widget bodyContent;

  /// The widget that is displayed over [panelContent] when collapsed.
  ///
  /// Crossfades when sliding.
  final PanelCollapsedWidget collapsedWidget;

  const PanelContent(
      {@required this.panelContent,
      this.bodyContent,
      this.collapsedWidget = const PanelCollapsedWidget()})
      : assert(panelContent != null);
}

/// Provide different height of the panel according to panel's current state.
/// None of these should be null.
class PanelSize {
  /// Initial height of the panel. Panel is shown upto this when opened.
  ///
  /// Default : 0.0
  final double closedHeight;

  /// Minimum height of the panel. Panel is shown upto this when collapsed.
  ///
  /// Default : 100.0
  final double collapsedHeight;

  /// Maximum height of the panel. Panel is shown upto this when expanded.
  ///
  /// Default : 300.0
  final double expandedHeight;

  const PanelSize(
      {this.closedHeight = 0.0,
      this.collapsedHeight = 100.0,
      this.expandedHeight = 300.0});
}

/// The decoration to be applied on the [PanelContent].
class PanelDecoration {
  /// The border to render around the panel.
  final Border border;

  /// Provide this to round the corners of the panel.
  final BorderRadiusGeometry borderRadius;

  /// Provide this to show custom shadows behind panel.
  ///
  /// Default: A mild box shadow is applied.
  final List<BoxShadow> boxShadows;

  /// Background color of the panel.
  ///
  /// Default : [Colors.white]
  final Color backgroundColor;

  /// Apply padding to the panel children.
  final EdgeInsetsGeometry padding;

  /// Apply margin around the panel.
  final EdgeInsetsGeometry margin;

  const PanelDecoration({
    this.border,
    this.borderRadius,
    this.boxShadows = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8.0,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      ),
    ],
    this.backgroundColor = Colors.white,
    this.padding,
    this.margin,
  });
}

/// Various configurations related to making [SlidingPanel] look and act like a backdrop widget.
///
/// To use features, first set [BackdropConfig.enabled] to true.
///
/// If enabled, a dark shadow is displayed over the [PanelContent.bodyContent] and various options are enabled.
class BackdropConfig {
  /// Whether this is a Backdrop panel.
  ///
  /// Default : false
  final bool enabled;

  /// If true, and [SlidingPanel.isDraggable] is also true, this panel can also be moved by dragging on the [PanelContent.bodyContent].
  ///
  /// It can move panel from [PanelState.collapsed] to [PanelState.closed] and [PanelState.expanded].
  /// And from [PanelState.expanded] to [PanelState.closed] and [PanelState.collapsed].
  ///
  /// Otherwise, the panel can be moved by dragging the panel itself only.
  ///
  /// Default : true
  final bool dragFromBody;

  /// Provide custom shadow color over [PanelContent.bodyContent].
  ///
  /// This is applied when panel slides.
  ///
  /// Default : [Colors.black]
  final Color shadowColor;

  /// Opacity of panel when panel is expanded.
  ///
  /// 0.0 : transparent ... 1.0 : opaque.
  ///
  /// Default : 0.5
  final double opacity;

  /// Whether to collapse the panel by tapping the [PanelContent.bodyContent], if this is not a Two-state panel.
  ///
  /// When enabled, if the panel is expanded, tapping the body collapses the panel.
  ///
  /// Default : true.
  final bool collapseOnTap;

  /// Whether to close the panel by tapping the [PanelContent.bodyContent].
  ///
  /// When enabled, if the panel is collapsed, tapping the body closes the panel.
  ///
  /// To enable this [collapseOnTap] must also be enabled.
  ///
  /// Default : true.
  final bool closeOnTap;

  /// Whether this panel applies backdrop effects even in [PanelState.collapsed] mode. It means, the [dragFromBody], [shadowColor], [opacity] and [closeOnTap] will work even in collapsed mode.
  /// Set this to false, if you plan to have these effects only in [PanelState.expanded] mode.
  ///
  /// Default : true
  final bool effectInCollapsedMode;

  const BackdropConfig(
      {this.enabled = false,
      this.dragFromBody = true,
      this.shadowColor = Colors.black,
      this.opacity = 0.5,
      this.collapseOnTap = true,
      this.closeOnTap = true,
      this.effectInCollapsedMode = true});
}
