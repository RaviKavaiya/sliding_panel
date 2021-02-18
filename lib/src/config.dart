part of sliding_panel;

/// This decides the initial state of the panel.
///
/// If this is a two state panel and a value of
/// [collapsed] is given, it will be considered as [expanded].
///
/// NOTE that this value can't be changed once the panel is created.
enum InitialPanelState {
  /// The panel has position of 0.0. Means, panel is totally invisible.
  ///
  /// To see the panel, call close(), collapse() or expand() from
  /// the [PanelController].
  dismissed,

  /// The panel is having [PanelSize.closedHeight].
  ///
  /// This is the default state.
  closed,

  /// The panel is having [PanelSize.collapsedHeight].
  collapsed,

  /// The panel is having [PanelSize.collapsedHeight].
  expanded,
}

/// Apply snapping effect to panel while opening / closing.
///
/// i.e., If the user is swiping the panel and leaves panel
/// in any position between [PanelState.closed] and [PanelState.expanded],
/// it will be animated to the NEAREST [PanelState].
///
/// For two-state panels, [PanelState.collapsed] is not used.
///
/// Default : [disabled]
enum PanelSnapping {
  /// Don't snap the panel to the nearest position when user leaves the panel.
  disabled,

  /// Bring the panel to the nearest position when the user leaves the panel.
  /// More precisely, when user drags the panel in a direction and leaves,
  /// the panel moves to NEXT [PanelState], which seems to be the nearest
  /// one to current position.
  ///
  /// Note that, snap is ONLY applied, when dragging stops with a non-zero
  /// velocity. It means, if user stops dragging AFTER keeping panel idle
  /// under finger for one second, snapping will NOT be applied.
  enabled,

  /// Same as [enabled], but snapping is applied, even with zero dragging
  /// velocity. So, if user keeps the panel held for some time and then leaves,
  /// panel will still snap.
  forced,
}

/// The widget that is displayed over [PanelContent.panelContent] when collapsed.
///
/// [PanelContent.headerWidget] is still shown above this, if provided.
///
/// Crossfades when sliding.
class PanelCollapsedWidget {
  /// The widget content.
  final Widget collapsedContent;

  /// By default, [collapsedContent] is hidden only in [PanelState.expanded] mode.
  /// Set this to false, if you plan to hide
  /// [collapsedContent] in [PanelState.collapsed] mode.
  ///
  /// If false, this is useful in case you plan to show
  /// some content in [PanelState.closed] mode.
  ///
  /// Default : true
  final bool hideInExpandedOnly;

  const PanelCollapsedWidget(
      {this.collapsedContent, this.hideInExpandedOnly = true});
}

/// The widget that will be shown above the panel,
/// regardless of [PanelState] (A persistent widget).
///
/// This can be used to drag the panel.
/// (Ofcourse, other parts of the panel will also do).
///
/// Generally, a 'pill' or a 'tablet' kind of header
/// can be shown here, that hints user to scroll.
///
/// If the height of this widget is not calculatable, it will NOT be shown.
class PanelHeaderWidget {
  /// The widget content.
  final Widget headerContent;

  /// The decoration to be applied on the [headerContent].
  ///
  /// Note that [PanelDecoration.boxShadows] is ignored.
  final PanelDecoration decoration;

  /// This denotes additional capabilities of [PanelHeaderWidget].
  ///
  /// Taken from [AppBar].
  final PanelHeaderOptions options;

  /// A callback that is called whenever user taps the
  /// [headerContent]. Useful in cases when tapping expands the panel.
  ///
  /// If [headerContent] itself contains a tappable widget,
  /// it will take precedence.
  final VoidCallback onTap;

  const PanelHeaderWidget({
    this.headerContent,
    this.decoration = const PanelDecoration(),
    this.options = const PanelHeaderOptions(),
    this.onTap,
  });
}

/// The widget that will be shown below the panel,
/// regardless of [PanelState] (A persistent widget).
///
/// This can be used to show a [ButtonBar] like widget.
///
/// Note that, this will only be shown, when panel is expanded.
///
/// If the height of this widget is not calculatable, it will NOT be shown.
class PanelFooterWidget {
  /// The widget content.
  final Widget footerContent;

  /// The decoration to be applied on the [footerContent].
  final PanelDecoration decoration;

  const PanelFooterWidget({
    this.footerContent,
    this.decoration = const PanelDecoration(),
  });
}

/// The content to be displayed in the panel.
class PanelContent {
  /// The widget that will be shown above the panel,
  /// regardless of [PanelState] (A persistent widget).
  ///
  /// This can be used to drag the panel.
  /// (Ofcourse, other parts of the panel will also do).
  ///
  /// Generally, a 'pill' or a 'tablet' kind of header
  /// can be shown here, that hints user to scroll.
  ///
  /// If the height of this widget is not calculatable, it will NOT be shown.
  final PanelHeaderWidget headerWidget;

  /// The widget that will be shown below the panel,
  /// regardless of [PanelState] (A persistent widget).
  ///
  /// This can be used to show a [ButtonBar] like widget.
  ///
  /// Note that, this will only be shown, when panel is expanded.
  ///
  /// If the height of this widget is not calculatable, it will NOT be shown.
  final PanelFooterWidget footerWidget;

  /// The widgets that are shown as the panel content.
  /// When collapsed, content till [collapsedWidget] is shown.
  ///
  /// If [collapsedWidget] is provided, that will be
  /// shown over this and will crossfade when sliding.
  ///
  /// Return a valid [List] of [Widget]s to be shown.
  final List<Widget> panelContent;

  /// The widget that will be shown underneath the panel.
  /// This can be ignored if you already have your own
  /// content ready and using the [SlidingPanel] additionally.
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

/// Specify maximum width of the panel.
/// Used to specify [BoxConstraints] in [Container].
///
/// Default : [double.infinity], which means as wide as allowed by screen.
///
/// Provide values in pixels.
class PanelMaxWidth {
  /// Maximum width occupied by the panel when device
  /// is in [Orientation.portrait] mode.
  final double portrait;

  /// Maximum width occupied by the panel when device
  /// is in [Orientation.landscape] mode.
  final double landscape;

  const PanelMaxWidth({
    this.portrait = double.infinity,
    this.landscape = double.infinity,
  });
}

/// Provide different height of the panel in percentage
/// of screen's height according to panel's current state.
/// None of these should be null.
///
/// Make sure : closedHeight < collapsedHeight < expandedHeight.
///
/// Give values between 0.0 and 1.0, considered as percentage.
class PanelSize {
  /// Initial height of the panel in percentage of screen.
  /// Panel is shown upto this when closed.
  ///
  /// Default : 0.25 (25%)
  final double closedHeight;

  /// Height of the panel in percentage of screen when panel is collapsed.
  ///
  /// Default : 0.40 (40%)
  final double collapsedHeight;

  /// Maximum height of the panel in percentage of screen.
  /// Panel is shown upto this when expanded.
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
/// To see detailed description of properties, please see [BoxDecoration],
/// as most of the properties are derived from it.
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
  /// Default : Canvas color (Theme.of(context).canvasColor).
  final Color backgroundColor;

  /// Apply padding to the panel children.
  final EdgeInsets padding;

  /// Apply margin around the panel.
  final EdgeInsets margin;

  /// A gradient to use when filling the panel.
  ///
  /// If this is specified, [backgroundColor] has no effect.
  final Gradient gradient;

  /// An image to paint above the [backgroundColor] or [gradient].
  final DecorationImage image;

  /// The blend mode applied to the [backgroundColor] or [gradient] of panel.
  ///
  /// If no [backgroundBlendMode] is provided then the default painting blend
  /// mode is used.
  ///
  /// If no [backgroundColor] or [gradient] is provided then this  has no impact.
  final BlendMode backgroundBlendMode;

  const PanelDecoration({
    this.border,
    this.borderRadius,
    this.boxShadows = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8.0,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      ),
    ],
    this.backgroundColor,
    this.padding,
    this.margin,
    this.gradient,
    this.image,
    this.backgroundBlendMode,
  });
}

/// This denotes additional capabilities of [PanelHeaderWidget].
///
/// Taken from [AppBar].
class PanelHeaderOptions {
  /// If this is true, the top padding specified by the [MediaQuery] will be
  /// added to the top of the header.
  ///
  /// Default : true
  final bool primary;

  /// Whether to center the [PanelHeaderWidget.headerContent].
  ///
  /// This option is kept, because if you use [Center] widget in
  /// [PanelHeaderWidget.headerContent], it will not work (as [Center] takes
  /// the whole available space).
  ///
  /// Default : false
  final bool centerTitle;

  /// This controls the size of the shadow below the header.
  ///
  /// If [forceElevated] is false, this is applied only
  /// when the [PanelContent.panelContent] has been scrolled.
  ///
  /// Default : 8.0
  final double elevation;

  /// Whether to apply [elevation] even if the content is not scrolled.
  ///
  /// When set to true, the [elevation] is applied regardless.
  ///
  /// Default : false
  final bool forceElevated;

  /// Whether the header stays on top of the content all the time.
  /// If false, the header also gets scrolled with [PanelContent.panelContent].
  ///
  /// Default : true
  final bool alwaysOnTop;

  /// Whether the header should become visible when
  /// user scrolls in reverse direction.
  ///
  /// [alwaysOnTop] takes precedence over this.
  ///
  /// If false, the user will need to scroll to top to see the header.
  ///
  /// Default : false
  final bool floating;

  /// A widget to display before the [PanelHeaderWidget.headerContent].
  ///
  /// Basically, an [IconButton] can be displayed here.
  final Widget leading;

  /// Widgets to display after the [PanelHeaderWidget.headerContent].
  ///
  /// Basically, [IconButton]s can be used to represent common actions.
  final List<Widget> trailing;

  /// How the [leading] and [trailing] should be
  /// vertically aligned in the header.
  ///
  /// Default : [MainAxisAlignment.center]
  final MainAxisAlignment iconsAlignment;

  /// The color to paint the shadow below the app bar. Typically this should be set
  /// along with [elevation].
  ///
  /// If this property is null, then [AppBarTheme.shadowColor] of
  /// [ThemeData.appBarTheme] is used, if that is also null, the default value
  /// is fully opaque black.
  final Color shadowColor;

  const PanelHeaderOptions({
    this.primary = true,
    this.centerTitle = false,
    this.elevation = 8.0,
    this.forceElevated = false,
    this.alwaysOnTop = true,
    this.floating = false,
    this.leading,
    this.trailing,
    this.iconsAlignment = MainAxisAlignment.center,
    this.shadowColor,
  });
}

/// Various configurations related to making [SlidingPanel]
/// look and act like a backdrop widget.
///
/// To use features, first set [BackdropConfig.enabled] to true.
///
/// If enabled, a dark shadow is displayed over the
/// [PanelContent.bodyContent] and various options are enabled.
class BackdropConfig {
  /// Whether this is a Backdrop panel.
  ///
  /// Default : false
  final bool enabled;

  /// If true, and [SlidingPanel.isDraggable] is also true,
  /// this panel can also be moved by dragging on the [PanelContent.bodyContent].
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

  /// Whether to collapse the panel by tapping the
  /// [PanelContent.bodyContent], if this is not a Two-state panel.
  ///
  /// When enabled, if the panel's height is more that
  /// [PanelSize.collapsedHeight], tapping the body collapses the panel.
  ///
  /// Default : true.
  final bool collapseOnTap;

  /// Whether to close the panel by tapping the [PanelContent.bodyContent].
  ///
  /// When enabled, if the panel's height is more that
  /// [PanelSize.closedHeight], tapping the body closes the panel.
  ///
  /// Note that [collapseOnTap] takes precedence over this.
  /// If both these are true, then if height is more than
  /// [PanelSize.collapsedHeight] it is collapsed first then closed.
  ///
  /// Default : true.
  final bool closeOnTap;

  /// Whether this panel applies backdrop effects even if
  /// panel's height is below [PanelState.collapsed] mode.
  /// It means, the [dragFromBody], [shadowColor], [opacity] and [closeOnTap]
  /// will work even in collapsed mode.
  ///
  /// Set this to false, if you plan to have these effects o
  /// nly in panel height above [PanelState.collapsed] mode.
  ///
  /// Default : true
  final bool effectInCollapsedMode;

  /// When this is set to true, the panel will be draggable,
  /// even when panel is closed. This also means that content behind
  /// the panel will not be able to receive gestures. (e.g., button taps).
  ///
  /// In most cases, this should not be used, as the panel must be
  /// removed from the widget tree OR setting this option to 'false'
  /// after some interaction, to allow normal user interaction behind the panel.
  ///
  /// Can be used to show user some alert dialog like things,
  /// where user has to make a choice and this blocks other interaction.
  ///
  /// This will not work when panel is in [PanelState.dismissed] state.
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

/// If provided, the panel's height will be automatically calculated
/// based on the content. This technically modifies the [PanelSize]
/// parameter as the panel's content size after panel is created.
/// Also repeats this process when resolution of device changes. (e.g., Orientation change).
///
/// Note that even by setting this, please don't omit the [PanelSize] parameter.
/// If the height is not calculatable, [PanelSize] parameters will be used.
///
/// Any height is maximum to screen size.
///
/// If this is used, when using a scrollable element, make sure it is shrinked.
/// (e.g., When using ListView, set its shrinkWrap: true, when using Column,
/// set its mainAxisSize: MainAxisSize.min).
/// This is applicable to any level of the children. (e.g., Column inside Container...).
///
/// Moreover, take care when using [Center] widget, as that takes full space
/// of parent and that's why it is not suggested to use.
///
/// If the [PanelContent.panelContent] contains more number of items,
/// PanelSize.expandedHeight] is set to 1.0 (100% of available height).
///
/// While using this, you can not change height of the panel runtime.
///
/// Although tested, this feature can't be considered to be Super Stable.
/// This also introduces a small processing overhead while calculating the height.
/// When opting for production release of your app, please test the app thoroughly while using this.
class PanelAutoSizing {
  /// If true and [PanelContent.headerWidget] is provided,
  /// set panel's [PanelSize.closedHeight] to the header's height.
  ///
  /// If [PanelSize.closedHeight] is more than
  /// header's height, NOTHING will change.
  ///
  /// Default : false
  final bool headerSizeIsClosed;

  /// If true, set panel's [PanelSize.collapsedHeight]
  /// to the [PanelContent.collapsedWidget]'s height.
  ///
  /// If [PanelContent.headerWidget] is used, its height
  /// will also be added to this.
  ///
  /// Invalid for Two-state panels.
  ///
  /// Default : false
  final bool autoSizeCollapsed;

  /// If true, set panel's [PanelSize.expandedHeight]
  /// to the [PanelContent.panelContent]'s height.
  ///
  /// If [PanelContent.headerWidget] is used, its height
  /// will also be added to this.
  ///
  /// Default : false
  final bool autoSizeExpanded;

  /// If [autoSizeExpanded] is true and if you also want to take
  /// [PanelSize.expandedHeight] in the consideration, use this.
  ///
  /// Whenever panel's size is calculated, panel will use the
  /// [PanelSize.expandedHeight] and [autoSizeExpanded] in the
  /// following manner.
  /// height = minimum of ([PanelSize.expandedHeight], [autoSizeExpanded]).
  ///
  /// Default : false
  final bool useMinExpanded;

  const PanelAutoSizing(
      {this.headerSizeIsClosed = false,
      this.autoSizeCollapsed = false,
      this.autoSizeExpanded = false,
      this.useMinExpanded = false});
}

/// This decides the action to be taken when user presses the back button.
///
/// Note that this will continue to work, even if the panel
/// is not currently visible. (i.e., [PanelState.closed] with height 0.0).
///
/// For normal panels, any of these can be used.
/// But for Two-state panels, these behaviors can be used:
/// [POP], [PERSIST], [CLOSE_POP], [CLOSE_PERSIST].
///
/// Default : [POP]
enum BackPressBehavior {
  /// Just pop the route without considering the panel state.
  ///
  /// Also valid for two-state panels.
  ///
  /// This is the default behavior.
  POP,

  /// Never pop the route no matter what the panel state is.
  /// To pop the route you need to change this yourself
  /// to another behavior. (e.g., [POP]).
  ///
  /// Also valid for two-state panels.
  ///
  /// Useful in cases when the user must interact with the panel only.
  PERSIST,

  /// If the panel's height is more than [PanelSize.collapsedHeight],
  /// the panel will collapse.
  ///
  /// After collapsed, if the user taps back button again,
  /// the behavior would be [PERSIST]. i.e., route will not pop.
  ///
  /// If this is provided for two-state panels, [PERSIST] is applied instead.
  COLLAPSE_PERSIST,

  /// If the panel's height is more than [PanelSize.collapsedHeight],
  /// the panel will collapse.
  ///
  /// After collapsed, if the user taps back button again,
  /// the behavior would be [POP]. i.e., route will pop.
  ///
  /// If this is provided for two-state panels, [POP] is applied instead.
  COLLAPSE_POP,

  /// If the panel's height is more than [PanelSize.closedHeight],
  /// the panel will close.
  ///
  /// After closed, if the user taps back button again,
  /// the behavior would be [PERSIST]. i.e., route will not pop.
  CLOSE_PERSIST,

  /// If the panel's height is more than [PanelSize.closedHeight],
  /// the panel will close.
  ///
  /// After closed, if the user taps back button again,
  /// the behavior would be [POP]. i.e., route will pop.
  ///
  /// Also valid for two-state panels.
  CLOSE_POP,

  /// If the panel's height is more than [PanelSize.collapsedHeight],
  /// the panel will collapse. Again, if the panel's height is
  /// more than [PanelSize.closedHeight], and less than or equal
  /// to [PanelSize.collapsedHeight], the panel will close.
  ///
  /// After closed, if the user taps back button again,
  /// the behavior would be [PERSIST]. i.e., route will not pop.
  ///
  /// If this is provided for two-state panels, [CLOSE_PERSIST] is applied instead.
  COLLAPSE_CLOSE_PERSIST,

  /// If the panel's height is more than [PanelSize.collapsedHeight],
  /// the panel will collapse. Again, if the panel's height is
  /// more than [PanelSize.closedHeight], and less than or equal to
  /// [PanelSize.collapsedHeight], the panel will close.
  ///
  /// After closed, if the user taps back button again,
  /// the behavior would be [POP]. i.e., route will pop.
  ///
  /// If this is provided for two-state panels, [CLOSE_POP] is applied instead.
  COLLAPSE_CLOSE_POP,
}

/// When any of the [BackPressBehavior] is given, if the user
/// taps back button, panel's state is checked according to
/// [BackPressBehavior] and animates accordingly (if needed).
///
/// With this, you can even control the behavior of the panel,
/// that WHAT will happen AFTER the panel is animated.
/// If you want to pop the panel immediately after animation OR
/// wait for the user to tap again in order to pop the panel.
///
/// If no animation is played (e.g., the panel already satisfies the
/// [BackPressBehavior]), the behavior would be set to [POP_IMMEDIATELY].
///
/// Note that, this is simply ignored when [BackPressBehavior.POP]
/// is given, or any of the persistent behavior is given in [BackPressBehavior].
///
/// Also valid for two-state panels.
///
/// Default : [POP_AFTER_TAP]
enum PanelPoppingBehavior {
  /// When this is given, the route is NOT popped IMMEDIATELY,
  /// just the animation completes (If any).
  ///
  /// Route will be popped after another back press.
  ///
  /// This is the default behavior.
  POP_AFTER_TAP,

  /// When this is given, the route is popped IMMEDIATELY,
  /// after completing the animation (If any).
  POP_IMMEDIATELY,
}

/// This helps you to execute specific actions when panel is closed.
///
/// Use case example : You are waiting for the user to perform a
/// desired action with the panel (like a choice), and user just
/// closes the panel, without interacting with it.
/// In such cases, you need a DEFAULT value to be notified / thrown
/// in order to handle this situation. [sendResult] and [throwResult]
/// can be used for it.
///
/// Note that these actions only get triggered ([sendResult] and [throwResult]),
/// when panel is brought to closed state, NOT having previous state as
/// [PanelState.dismissed].
///
/// To use all features, [detachDragging] needs to be true.
class PanelClosedOptions {
  /// Specifies whether user should not be able to scroll (drag) the panel
  /// after it is closed.
  ///
  /// While user is dragging the panel to close it, and when it reaches to
  /// [PanelSize.closedHeight], immediately the dragging is detached from
  /// the panel. Means, user can't re-open the panel by simply dragging.
  ///
  /// NOTE that when you set this to true, a closed panel can ONLY
  /// be opened by a [PanelController] and will NOT handle user drags
  /// until opened. So, it is suggested to use when you are having
  /// [PanelSize.closedHeight] = 0.0. (This is not a restriction).
  ///
  /// Default : false
  final bool detachDragging;

  /// Specifies whether to reset panel's scrolling position
  /// when the panel is closed.
  ///
  /// Needs [detachDragging] to be true.
  ///
  /// Default : false
  final bool resetScrolling;

  /// Triggers [PanelController.sendResult] with result as
  /// [sendResult] when the panel closes.
  ///
  /// Not triggered when null.
  ///
  /// Needs [detachDragging] to be true.
  final Object sendResult;

  /// Triggers [PanelController.throwResult] with result as
  /// [throwResult] when the panel closes.
  ///
  /// Not triggered when null.
  ///
  /// Needs [detachDragging] to be true.
  final Object throwResult;

  const PanelClosedOptions(
      {this.detachDragging = false,
      this.resetScrolling = false,
      this.sendResult,
      this.throwResult});
}

/// Apply necessary top, bottom and sides (left and right) padding to
/// the panel to avoid OS intrusions like notch, status bar and nav-bar.
///
/// This is much like [SafeArea]. This does NOT apply padding to the
/// [PanelContent.bodyContent]. This allows us for example, to have the
/// panel avoid intrusions while still allowing bodyContent to occupy
/// whole available space. The [BackdropConfig]'s shadow is also not
/// affected by this. So, you always get full-screen shadow.
///
/// This can be used on any type of panel.
///
/// Default : [SafeAreaConfig.all].
class SafeAreaConfig {
  /// Whether to apply padding on top side of panel.
  final bool top;

  /// Whether to apply padding on bottom side of panel.
  final bool bottom;

  /// Whether to apply padding on both sides (left and right) of panel.
  final bool sides;

  /// If true, padding derived from [MediaQuery] will NOT be added to the
  /// [PanelContent]. Some widgets like [ListTile] add the padding automatically.
  /// Set this to true to prevent them adding the extra space.
  ///
  /// This option comes handy when you are opting to add padding to all
  /// sides (e.g., top=bottom=sides=true), the necessary paddings are
  /// already applied. So, there is no need for extra padding to be apploed
  /// to the content. So, set this to true in such cases.
  final bool removePaddingFromContent;

  /// If [PanelContent.bodyContent] is a [CustomScrollView] (e.g., slivers),
  /// you may see additional space in your [PanelContent.panelContent].
  ///
  /// In such cases, set this to true in order to fix that.
  ///
  /// Don't set this to true if your bodyContent is any normal widget.
  final bool bodyHasSlivers;

  /// Apply no padding.
  ///
  /// Assumes that the [PanelContent.bodyContent] is a normal child.
  /// (No slivers).
  ///
  /// Also, don't remove padding from the content.
  const SafeAreaConfig({
    this.top = false,
    this.bottom = false,
    this.sides = false,
    this.removePaddingFromContent = false,
    this.bodyHasSlivers = false,
  });

  /// Apply padding on all sides:
  /// top, bottom, left and right.
  ///
  /// Assumes that the [PanelContent.bodyContent] is a normal child.
  /// (No slivers).
  ///
  /// Also, don't remove padding from the content.
  ///
  /// This is the default.
  const SafeAreaConfig.all({bool removePaddingFromContent, bool bodyHasSlivers})
      : this.top = true,
        this.bottom = true,
        this.sides = true,
        this.removePaddingFromContent = removePaddingFromContent ?? false,
        this.bodyHasSlivers = bodyHasSlivers ?? false;
}
