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
  /// If false, this is useful in case you plan to show some content in [PanelState.closed] mode.
  ///
  /// Default : true
  final bool hideInExpandedOnly;

  const PanelCollapsedWidget(
      {this.collapsedContent, this.hideInExpandedOnly = true});
}

/// The widget that will be shown above the panel, regardless of [PanelState] (A persistent widget).
///
/// This can be used to drag the panel. (Ofcourse, other parts of the panel will also do).
///
/// Generally, a 'pill' or a 'tablet' kind of header can be shown here, that hints user to scroll.
///
/// If the height of this widget is not calculatable, it will NOT be shown.
class PanelHeaderWidget {
  /// The widget content.
  final Widget headerContent;

  /// The decoration to be applied on the [headerContent].
  final PanelDecoration decoration;

  /// A callback that is called whenever user taps the [headerContent]. Useful in cases when tapping expands the panel.
  ///
  /// If [headerContent] itself contains a tappable widget, it will take precedence.
  final VoidCallback onTap;

  const PanelHeaderWidget({
    this.headerContent,
    this.decoration = const PanelDecoration.empty(),
    this.onTap,
  });
}

/// The widget that will be shown below the panel, regardless of [PanelState] (A persistent widget).
///
/// This can be used to show a [ButtonBar] like widget.
///
/// If the height of this widget is not calculatable, it will NOT be shown.
class PanelFooterWidget {
  /// The widget content.
  final Widget footerContent;

  /// The decoration to be applied on the [footerContent].
  final PanelDecoration decoration;

  const PanelFooterWidget({
    this.footerContent,
    this.decoration = const PanelDecoration.empty(),
  });
}

/// The main widget that is shown as the panel content. When collapsed, content till [PanelCollapsedWidget.collapsedContent] is shown.
///
/// If [PanelCollapsedWidget.collapsedContent] is provided, that will be shown over this and will crossfade when sliding.
///
/// Return a valid [Widget] to be shown.
///
/// Given [ScrollController] should be attached to your [Scrollable] widgets, in order to handle drag of the panel and scroll of your widget properly.
///
/// If nested [Scrollable] elements are used, attach the given [ScrollController] to the root [Scrollable] only.
typedef PanelBodyBuilder = Widget Function(
  BuildContext context,

  /// Attach this to your [Scrollable] widget.
  ScrollController scrollController,
);

/// The content to be displayed in the panel.
class PanelContent {
  /// The widget that will be shown above the panel, regardless of [PanelState] (A persistent widget).
  ///
  /// This can be used to drag the panel. (Ofcourse, other parts of the panel will also do).
  ///
  /// Generally, a 'pill' or a 'tablet' kind of header can be shown here, that hints user to scroll.
  ///
  /// If the height of this widget is not calculatable, it will NOT be shown.
  final PanelHeaderWidget headerWidget;

  /// The widget that will be shown below the panel, regardless of [PanelState] (A persistent widget).
  ///
  /// This can be used to show a [ButtonBar] like widget.
  ///
  /// If the height of this widget is not calculatable, it will NOT be shown.
  final PanelFooterWidget footerWidget;

  /// The widget that is shown as the panel content. When collapsed, content till [collapsedWidget] is shown.
  ///
  /// If [collapsedWidget] is provided, that will be shown over this and will crossfade when sliding.
  ///
  /// Return a valid [Widget] to be shown.
  ///
  /// Given [ScrollController] should be attached to your [Scrollable] widgets, in order to handle drag of the panel and scroll of your widget properly.
  ///
  /// If nested [Scrollable] elements are used, attach the given [ScrollController] to the root [Scrollable] only.
  final PanelBodyBuilder panelContent;

  /// The widget that will be shown underneath the panel. This can be ignored if you already have your own content ready and using the [SlidingPanel] additionally.
  ///
  /// Fitted to screen.
  final Widget bodyContent;

  /// The widget that is displayed over [panelContent] when collapsed.
  ///
  /// Crossfades when sliding.
  final PanelCollapsedWidget collapsedWidget;

  const PanelContent({
    this.headerWidget = const PanelHeaderWidget(),
    this.footerWidget = const PanelFooterWidget(),
    @required this.panelContent,
    this.bodyContent,
    this.collapsedWidget = const PanelCollapsedWidget(),
  }) : assert(panelContent != null);
}

/// Specify maximum width of the panel. Used to specify [BoxConstraints] in [Container].
///
/// Default : [double.infinity], which means as wide as allowed by screen.
///
/// Provide values in pixels.
class PanelMaxWidth {
  /// Maximum width occupied by the panel when device is in [Orientation.portrait] mode.
  final double portrait;

  /// Maximum width occupied by the panel when device is in [Orientation.landscape] mode.
  final double landscape;

  const PanelMaxWidth({
    this.portrait = double.infinity,
    this.landscape = double.infinity,
  });
}

/// Provide different height of the panel in percentage of screen's height according to panel's current state.
/// None of these should be null.
///
/// Make sure : closedHeight < collapsedHeight < expandedHeight.
///
/// Give values between 0.0 and 1.0, considered as percentage.
class PanelSize {
  /// Initial height of the panel in percentage of screen. Panel is shown upto this when closed.
  ///
  /// Default : 0.25 (25%)
  final double closedHeight;

  /// Height of the panel in percentage of screen when panel is collapsed.
  ///
  /// Default : 0.40 (40%)
  final double collapsedHeight;

  /// Maximum height of the panel in percentage of screen. Panel is shown upto this when expanded.
  ///
  /// Default : 0.85 (85%)
  final double expandedHeight;

  const PanelSize({
    this.closedHeight = 0.25,
    this.collapsedHeight = 0.40,
    this.expandedHeight = 0.85,
  });
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

  const PanelDecoration.empty({
    this.border,
    this.borderRadius,
    this.boxShadows,
    this.backgroundColor,
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

  /// Opacity of [shadowColor] to be applied when panel slides.
  ///
  /// 0.0 : transparent ... 1.0 : opaque.
  ///
  /// Default : 0.5
  final double opacity;

  /// Whether to collapse the panel by tapping the [PanelContent.bodyContent], if this is not a Two-state panel.
  ///
  /// When enabled, if the panel's height is more that [PanelSize.collapsedHeight], tapping the body collapses the panel.
  ///
  /// Default : true.
  final bool collapseOnTap;

  /// Whether to close the panel by tapping the [PanelContent.bodyContent].
  ///
  /// When enabled, if the panel's height is more that [PanelSize.closedHeight], tapping the body closes the panel.
  ///
  /// Note that [collapseOnTap] takes precedence over this. If both these are true, then if height is more than [PanelSize.collapsedHeight] it is collapsed first then closed.
  ///
  /// Default : true.
  final bool closeOnTap;

  /// Whether this panel applies backdrop effects even if panel's height is below [PanelState.collapsed] mode. It means, the [dragFromBody], [shadowColor], [opacity] and [closeOnTap] will work even in collapsed mode.
  /// Set this to false, if you plan to have these effects only in panel height above [PanelState.collapsed] mode.
  ///
  /// Default : true
  final bool effectInCollapsedMode;

  /// When this is set to true, the panel will be draggable, even when panel is closed. This also means that content behind the panel will not be able to receive gestures. (e.g., button taps).
  ///
  /// In most cases, this should not be used, as the panel must be removed from the widget tree OR setting this option 'false' after some interaction, to allow normal user interaction behind the panel.
  ///
  /// Can be used to show user some alert dialog like things, where user has to make a choice and this blocks other interaction.
  ///
  /// This takes precedence over [effectInCollapsedMode] when applying [shadowColor].
  ///
  /// Default : false
  final bool draggableInClosed;

  const BackdropConfig({
    this.enabled = false,
    this.dragFromBody = true,
    this.shadowColor = Colors.black,
    this.opacity = 0.5,
    this.collapseOnTap = true,
    this.closeOnTap = true,
    this.effectInCollapsedMode = true,
    this.draggableInClosed = false,
  });
}

/// If provided, the panel's height will be automatically calculated based on the content. This technically modifies the [PanelSize] parameter as the panel's content size after panel is created. Also repeats this process when resolution of device changes. (e.g., Orientation change).
///
/// Note that even by setting this, please don't omit the [PanelSize] parameter. If the height is not calculatable, [PanelSize] parameters will be used.
///
/// Any height is maximum to screen size.
///
/// If this is used, when using a scrollable element, make sure it is shrinked.
/// (e.g., When using ListView, set its shrinkWrap: true, when using Column, set its mainAxisSize: MainAxisSize.min). Moreover, take care when using [Center] widget, as that takes full space of parent and that's why it is not suggested to use. This is applicable to any level of the children. (e.g., Column inside Container...).
///
/// If the [PanelContent.panelContent] contains a [Scrollable] widget (e.g., [ListView]), and it contains more number of items, [PanelSize.expandedHeight] is set to 1.0 (100% of screen height).
///
/// While using this, you can not change height of the panel runtime. (Obviously!)
///
/// Although tested, this feature can't be considered to be Super Stable. This also introduces a small processing overhead while calculating the height. When opting for production release of your app, please test the app thoroughly while using this.
class PanelAutoSizing {
  /// If true and [PanelContent.headerWidget] is provided, set panel's [PanelSize.closedHeight] to the header's height.
  ///
  /// If [PanelSize.closedHeight] is more than header's height, NOTHING will change.
  ///
  /// Default : false
  final bool headerSizeIsClosed;

  /// If true, set panel's [PanelSize.collapsedHeight] to the [PanelContent.collapsedWidget]'s height.
  ///
  /// If [PanelContent.headerWidget] is used, its height will also be added to this.
  ///
  /// Invalid for Two-state panels.
  ///
  /// Default : false
  final bool autoSizeCollapsed;

  /// If true, set panel's [PanelSize.expandedHeight] to the [PanelContent.panelContent]'s height.
  ///
  /// If [PanelContent.headerWidget] is used, its height will also be added to this.
  ///
  /// Default : false
  final bool autoSizeExpanded;

  const PanelAutoSizing(
      {this.headerSizeIsClosed = false,
      this.autoSizeCollapsed = false,
      this.autoSizeExpanded = false});
}

/// This decides the action to be taken when user presses the back button.
///
/// Note that this will continue to work, even if the panel is not currently visible. (i.e., [PanelState.closed] with height 0.0).
///
/// For normal panels, any of these can be used. But for Two-state panels, these behaviors can be used:
/// [POP], [PERSIST], [CLOSE_POP].
///
/// Default : [POP]
enum BackPressBehavior {
  /// Just pop the route without considering the panel state.
  ///
  /// Also valid for two-state panels.
  ///
  /// This is the default behavior.
  POP,

  /// Never pop the route no matter what the panel state is. To pop the route you need to change this yourself to another behavior. (e.g., [POP]).
  ///
  /// Also valid for two-state panels.
  ///
  /// Useful in cases when the user must interact with the panel only.
  PERSIST,

  /// If the panel's height is more than [PanelSize.collapsedHeight], the panel will collapse.
  ///
  /// After collapsed, if the user taps back button again, the behavior would be [PERSIST]. i.e., route will not pop.
  ///
  /// If this is provided for two-state panels, [PERSIST] is applied instead.
  COLLAPSE_PERSIST,

  /// If the panel's height is more than [PanelSize.collapsedHeight], the panel will collapse.
  ///
  /// After collapsed, if the user taps back button again, the behavior would be [POP]. i.e., route will pop.
  ///
  /// If this is provided for two-state panels, [POP] is applied instead.
  COLLAPSE_POP,

  /// If the panel's height is more than [PanelSize.closedHeight], the panel will close.
  ///
  /// After closed, if the user taps back button again, the behavior would be [PERSIST]. i.e., route will not pop.
  ///
  /// If this is provided for two-state panels, [PERSIST] is applied instead.
  CLOSE_PERSIST,

  /// If the panel's height is more than [PanelSize.closedHeight], the panel will close.
  ///
  /// After closed, if the user taps back button again, the behavior would be [POP]. i.e., route will pop.
  ///
  /// Also valid for two-state panels.
  CLOSE_POP,

  /// If the panel's height is more than [PanelSize.collapsedHeight], the panel will collapse. Again, if the panel's height is more than [PanelSize.closedHeight], and less than or equal to [PanelSize.collapsedHeight], the panel will close.
  ///
  /// After closed, if the user taps back button again, the behavior would be [PERSIST]. i.e., route will not pop.
  ///
  /// If this is provided for two-state panels, [PERSIST] is applied instead.
  COLLAPSE_CLOSE_PERSIST,

  /// If the panel's height is more than [PanelSize.collapsedHeight], the panel will collapse. Again, if the panel's height is more than [PanelSize.closedHeight], and less than or equal to [PanelSize.collapsedHeight], the panel will close.
  ///
  /// After closed, if the user taps back button again, the behavior would be [POP]. i.e., route will pop.
  ///
  /// If this is provided for two-state panels, [CLOSE_POP] is applied instead.
  COLLAPSE_CLOSE_POP,
}

/// When any of the [BackPressBehavior] is given, if the user taps back button, panel's state is checked according to [BackPressBehavior] and animates accordingly (if needed).
///
/// With this, you can even control the behavior of the panel, that WHAT will happen AFTER the panel is animated. If you want to pop the panel immediately after animation OR wait for the user to tap again in order to pop the panel.
///
/// If no animation is played (e.g., the panel already satisfies the [BackPressBehavior]), the behavior would be set to [POP_IMMEDIATELY].
///
/// Note that, this is simply ignored when [BackPressBehavior.POP]is given,  or any of the persistent behavior is given in [BackPressBehavior].
///
/// Also valid for two-state panels.
///
/// Default : [POP_AFTER_TAP]
enum PanelPoppingBehavior {
  /// When this is given, the route is NOT popped IMMEDIATELY, just the animation completes (If any).
  ///
  /// Route will be popped after another back press.
  ///
  /// This is the default behavior.
  POP_AFTER_TAP,

  /// When this is given, the route is popped IMMEDIATELY, after completing the animation (If any).
  POP_IMMEDIATELY,
}

/// If [SlidingPanel.isDraggable] and [SlidingPanel.snapPanel] are true, you can control how much user can drag the panel by setting this value. If you restrict panel dragging at some point, the [Scrollable] widget provided in [PanelBodyBuilder] WILL start scrolling after reaching the limit.
///
/// This option has NO effect on two-state panels.
///
/// Note that, the panel can still be resized (animated) using [PanelController]. In other words, even if you restrict dragging of the panel, you can still animate the panel BEYOND below limit by using [PanelController].
///
/// This is used in conjunction with [SlidingPanel.allowedDraggingTill].
///
/// Default : [ALLOW]
enum PanelDraggingDirection {
  /// Allows the panel to be dragged in any position, no restriction.
  ///
  /// This is the default.
  ALLOW,

  /// Apply the restriction, when user is dragging the panel upside.
  UP,

  /// Apply the restriction, when user is dragging the panel downside.
  DOWN,
}
