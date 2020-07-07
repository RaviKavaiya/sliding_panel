part of sliding_panel;

/// SlidingPanel
class SlidingPanel extends StatefulWidget {
  /// This decides the initial state of the panel.
  ///
  /// If this is a two state panel and [InitialPanelState.collapsed]
  /// is given, it will be considered as [InitialPanelState.expanded].
  ///
  /// NOTE that this value can't be changed once the panel is created.
  ///
  /// Default : [InitialPanelState.closed]
  final InitialPanelState initialState;

  /// If true, the panel is created (instantiated) with [PanelState.dismissed].
  /// After initialization is completed, the panel animates to given
  /// [initialState].
  ///
  /// Useful when navigating to a new route, that contains an open
  /// SlidingPanel.
  ///
  /// For modal panels, this is ignored, as they always animate while created.
  ///
  /// NOTE that this value can't be changed once the panel is created.
  ///
  /// Default : false
  final bool animatedAppearing;

  /// The content to be displayed in the panel.
  final PanelContent content;

  /// Provide different height of the panel in percentage
  /// of screen's height according to panel's current state.
  /// None of these should be null.
  ///
  /// Make sure : closedHeight < collapsedHeight < expandedHeight.
  ///
  /// Give values between 0.0 and 1.0, considered as percentage.
  final PanelSize size;

  /// Specify maximum width of the panel.
  /// Used to specify [BoxConstraints] in [Container].
  ///
  /// Default : [double.infinity], which means as wide as allowed by screen.
  ///
  /// Provide values in pixels.
  final PanelMaxWidth maxWidth;

  /// The decoration to be applied on the [PanelContent].
  final PanelDecoration decoration;

  /// Various configurations related to making [SlidingPanel]
  /// look and act like a backdrop widget.
  ///
  /// To use features, first set [BackdropConfig.enabled] to true.
  ///
  /// If enabled, a dark shadow is displayed over the
  /// [PanelContent.bodyContent] and various options are enabled.
  final BackdropConfig backdropConfig;

  /// Control this panel programmatically using a controller.
  final PanelController panelController;

  /// If provided, the panel's height will be automatically calculated
  /// based on the content.
  ///
  /// For more details, please visit [PanelAutoSizing].
  final PanelAutoSizing autoSizing;

  /// To render default background behind the panel.
  ///
  /// If false, [PanelContent] is rendered with transparent background.
  ///
  /// Default : true
  final bool renderPanelBackground;

  /// Apply snapping effect to panel while opening / closing.
  ///
  /// i.e., If the user is swiping the panel and leaves panel
  /// in any position between [PanelState.closed] and [PanelState.expanded],
  /// it will be animated to the NEAREST [PanelState].
  ///
  /// For two-state panels, [PanelState.collapsed] is not used.
  ///
  /// Default : [PanelSnapping.disabled]
  final PanelSnapping snapping;

  /// If [snapping] is applied, you can also provide this value
  /// to control at which extent the snapping takes place.
  ///
  /// When you provide this value, it will be used whether to snap
  /// the panel or not.
  /// Panel is snapped, if the speed of user's swiping is more
  /// than this much percentage of the device's screen height.
  ///
  /// In other words, if user swipes the panel at such speed
  /// as if he swiped panel for 1 second, and if it would cover more
  /// than this much of percentage of screen height, snapping is applied.
  ///
  /// This is useful, in cases like you don't want the panel to be
  /// snapped every time. If the user swipes panel at certain speed,
  /// then only snapping should take place.
  ///
  /// You can provide any non-negative value, considered as
  /// 'percentage of the screen height'. e.g., If you provide 250.0,
  /// it will be considered as 250% of screen height.
  /// It is suggested to keep it between '80.0' to '200.0'.
  ///
  /// If you provide this value, it will be clamped (adjusted)
  /// between '0.0 and 750.0' actual PIXELS of the screen.
  /// Since, going beyond has no actual usefulness.
  ///
  /// Note that, even if keeping any value, if the user holds
  /// the panel for one second in idle state after swiping
  /// and then releases the finger, IT WILL NOT be snapped.
  /// This is kept in case the user forcefully wants the panel
  /// to be in the that position. To overcome this problem,
  /// set [snapping] to [PanelSnapping.forced].
  ///
  /// Default : 0.0
  final double snappingTriggerPercentage;

  /// Whether this panel is draggable by user.
  /// If false and user swipes the panel,
  /// internal content will start scrolling.
  ///
  /// Default : true
  final bool isDraggable;

  /// The scroll physics that determine how
  /// the scroll view should respond to user input.
  ///
  /// Default: Platform Convention
  final ScrollPhysics physics;

  /// Specify the amount of [PanelContent.bodyContent]
  /// to slide up when panel slides.
  ///
  /// 0.0 : No sliding ... 1.0 : Slide one-to-one
  ///
  /// Default : 0.2.
  final double parallaxSlideAmount;

  /// A multiplier applied at every user gesture for sliding the panel.
  ///
  /// Controls the amount how much more the panel slides.
  /// When user drags the panel, this value is multiplied
  /// with number of added pixels to resize the panel.
  ///
  /// Given value is clamped between 1.0 and 5.0. For a good experience,
  /// keep this between 1.25 to 2.0.
  ///
  /// Default : 1.0
  final double dragMultiplier;

  /// Provide duration for the overall sliding time.
  ///
  /// Here, 'overall sliding time' means, sliding from
  /// [PanelState.dismissed] to [PanelState.expanded].
  ///
  /// This will be adjusted when [PanelController.dismiss],
  /// [PanelController.close], [PanelController.collapse],
  /// [PanelController.expand] or [PanelController.setAnimatedPanelPosition]
  /// are used.
  /// This will be calculated accordingly.
  ///
  /// Default : 1000 milliseconds
  final Duration duration;

  /// The curve to be used in animations.
  ///
  /// Default : [Curves.fastOutSlowIn]
  final Curve curve;

  /// Whether this panel will work as modal bottom sheet
  /// (i.e., just close and expand, no collapsing).
  ///
  /// If true, only [PanelSize.closedHeight] and
  /// [PanelSize.expandedHeight] will work, [PanelSize.collapsedHeight]
  /// and [BackdropConfig.effectInCollapsedMode] will simply be ignored.
  ///
  /// [PanelContent.collapsedWidget] will also be ignored.
  ///
  /// Also, [PanelController.currentState]
  /// will not return [PanelState.collapsed].
  ///
  /// Default : false
  final bool isTwoStatePanel;

  /// This decides the action to be taken when user presses the back button.
  ///
  /// Note that this will continue to work, even if the panel
  /// is not currently visible. (i.e., [PanelState.closed] with height 0.0).
  ///
  /// For normal panels, any of these can be used.
  /// But for Two-state panels, these behaviors can be used:
  /// [BackPressBehavior.POP], [BackPressBehavior.PERSIST], [BackPressBehavior.CLOSE_POP].
  ///
  /// Default : [BackPressBehavior.POP]
  final BackPressBehavior backPressBehavior;

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
  /// [BackPressBehavior]), the behavior would be
  /// set to [PanelPoppingBehavior.POP_IMMEDIATELY].
  ///
  /// Note that, this is simply ignored when [BackPressBehavior.POP]
  /// is given,  or any of the persistent behavior is given in [BackPressBehavior].
  ///
  /// Also valid for two-state panels.
  ///
  /// Default : [PanelPoppingBehavior.POP_AFTER_TAP]
  final PanelPoppingBehavior panelPoppingBehavior;

  /// If [SlidingPanel.isDraggable] and [SlidingPanel.snapping] is applied,
  /// you can control how much user can drag the panel by setting this value.
  ///
  /// If you restrict panel dragging at some point, the widgets provided
  /// in [PanelContent.panelContent] WILL start scrolling after reaching the limit.
  ///
  /// This option has NO effect on two-state panels.
  ///
  /// Note that, the panel can still be resized (animated) using [PanelController].
  /// In other words, even if you restrict dragging of the panel, you can
  /// still animate the panel BEYOND below limit by using [PanelController].
  ///
  /// To apply restriction, [PanelDraggingDirection.ALLOW]
  /// MUST not be given as parameter.
  ///
  /// Also, this option is only valid when [snapping] is applied.
  ///
  /// Given values will be clamped between
  /// [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  ///
  /// If you use this, [snappingTriggerPercentage] will have no effect
  /// and panel will ALWAYS snap to a [PanelState].
  ///
  /// Default : [PanelDraggingDirection.ALLOW] with
  /// value 0.0 (means allow the panel to be dragged)
  @Deprecated('This feature is not stable. Though this works well under some circumstances, '
      'it has some flaws that cause problems like panel not draggable, '
      'content not scrollable, etc. So, use of this should be avoided.'
      'This feature was deprecated since v1.0.3.'
      'This feature may be removed in future releases.')
  final Map<PanelDraggingDirection, double> allowedDraggingTill;

  /// This helps you to execute specific actions when panel is closed.
  ///
  /// Use case example : You are waiting for the user to perform a
  /// desired action with the panel (like a choice), and user just
  /// closes the panel, without interacting with it.
  /// In such cases, you need a DEFAULT value to be notified / thrown
  /// in order to handle this situation. [PanelClosedOptions.sendResult]
  /// and [PanelClosedOptions.throwResult] can be used for it.
  ///
  /// To use all features, [PanelClosedOptions.detachDragging] needs to be true.
  final PanelClosedOptions panelClosedOptions;

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
  final SafeAreaConfig safeAreaConfig;

  /// A callback that is called whenever the panel is slided.
  ///
  /// Returned between [PanelSize.closedHeight] and [PanelSize.expandedHeight].
  final void Function(double position) onPanelSlide;

  /// A callback that is called whenever the state of the panel is changed.
  ///
  /// This will return any of the values of [PanelState].
  final void Function(PanelState state) onPanelStateChanged;

  /// A callback that is called whenever [PanelController.throwResult]
  /// or [PanelController.popWithThrowResult] is called.
  final void Function(dynamic result) onThrowResult;

  final bool _isModal;
  final _SlidingPanelModalRoute _panelModalRoute;

  const SlidingPanel({
    Key key,
    this.initialState = InitialPanelState.closed,
    this.animatedAppearing = false,
    @required
        this.content,
    this.size = const PanelSize(),
    this.maxWidth = const PanelMaxWidth(),
    this.decoration = const PanelDecoration(),
    this.backdropConfig = const BackdropConfig(),
    this.panelController,
    this.autoSizing = const PanelAutoSizing(),
    this.renderPanelBackground = true,
    this.snapping = PanelSnapping.disabled,
    this.snappingTriggerPercentage = 0.0,
    this.isDraggable = true,
    this.physics,
    this.parallaxSlideAmount = 0.2,
    this.dragMultiplier = 1.0,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.fastOutSlowIn,
    this.isTwoStatePanel = false,
    this.backPressBehavior = BackPressBehavior.POP,
    this.panelPoppingBehavior = PanelPoppingBehavior.POP_AFTER_TAP,
    @Deprecated('This feature is not stable. Though this works well under some circumstances, '
        'it has some flaws that cause problems like panel not draggable, '
        'content not scrollable, etc. So, use of this should be avoided.'
        'This feature was deprecated since v1.0.3.'
        'This feature may be removed in future releases.')
        this.allowedDraggingTill = const {PanelDraggingDirection.ALLOW: 0.0},
    this.panelClosedOptions = const PanelClosedOptions(),
    this.safeAreaConfig = const SafeAreaConfig.all(),
    this.onPanelSlide,
    this.onPanelStateChanged,
    this.onThrowResult,
  })  : this._isModal = false,
        _panelModalRoute = null;

  const SlidingPanel._modal(
    this._panelModalRoute, {
    Key key,
    this.initialState = InitialPanelState.closed,
    @required this.content,
    this.size = const PanelSize(),
    this.maxWidth = const PanelMaxWidth(),
    this.decoration = const PanelDecoration(),
    this.backdropConfig = const BackdropConfig(),
    this.panelController,
    this.autoSizing = const PanelAutoSizing(),
    this.renderPanelBackground = true,
    this.snapping = PanelSnapping.disabled,
    this.snappingTriggerPercentage = 0.0,
    this.isDraggable = true,
    this.physics,
    this.dragMultiplier = 1.0,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.fastOutSlowIn,
    this.isTwoStatePanel = false,
    this.backPressBehavior = BackPressBehavior.POP,
    this.panelPoppingBehavior = PanelPoppingBehavior.POP_AFTER_TAP,
    this.panelClosedOptions = const PanelClosedOptions(),
    this.safeAreaConfig = const SafeAreaConfig.all(),
    this.onPanelSlide,
    this.onPanelStateChanged,
    this.onThrowResult,
  })  : parallaxSlideAmount = 0.0,
        animatedAppearing = false,
        allowedDraggingTill = const {PanelDraggingDirection.ALLOW: 0.0},
        _isModal = true;

  @override
  _SlidingPanelState createState() => _SlidingPanelState();
}
