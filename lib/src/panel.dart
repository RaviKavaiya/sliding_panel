part of sliding_panel;

/// SlidingPanel
class SlidingPanel extends StatefulWidget {
  /// This decides the initial state of the panel.
  ///
  /// If this is a two state panel and a value of [PanelState.collapsed] is given, it will be considered as [PanelState.closed].
  final InitialPanelState initialState;

  /// The content to be displayed in the panel.
  final PanelContent content;

  /// Provide different height of the panel according to panel's current state.
  /// None of these should be null.
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

class _SlidingPanelState extends State<SlidingPanel>
    with TickerProviderStateMixin {
  // Controller for closed-to-collapsed slide (and vice versa)
  AnimationController _animCollapsed;

  // Controller for collapsed-to-expanded slide (and vice versa)
  AnimationController _animExpanded;

  // Controller for closed-to-expanded slide (and vice versa)
  AnimationController _animFull;

  double _closedHeight, _collapsedHeight, _expandedHeight;
  Duration _duration;
  bool _isTwoStatePanel;

  void _animationListener({bool isCollapsedAnimation}) {
    setState(() {});

    if (widget.onPanelSlide != null) {
      if (_isTwoStatePanel) {
        widget.onPanelSlide(_animFull.value);
      } else {
        if (isCollapsedAnimation) {
          widget.onPanelSlide(_animCollapsed.value);
        } else {
          widget.onPanelSlide(_animExpanded.value);
        }
      }
    }

    if (widget.onPanelCollapsed != null) {
      if (!(_isTwoStatePanel)) {
        if ((!_animExpanded.isAnimating) && (!_animCollapsed.isAnimating)) {
          if (_animCollapsed.value == 1.0 && _animExpanded.value == 1.0) {
            widget.onPanelCollapsed();
          }
        }
      }
    }

    if (widget.onPanelClosed != null) {
      if (_isTwoStatePanel) {
        if (!(_animFull.isAnimating)) {
          if (_animFull.value == 0.0) {
            widget.onPanelClosed();
          }
        }
      } else {
        if ((!_animExpanded.isAnimating) && (!_animCollapsed.isAnimating)) {
          if (_animCollapsed.value == 0.0 && _animExpanded.value == 1.0) {
            widget.onPanelClosed();
          }
        }
      }
    }

    if (widget.onPanelExpanded != null) {
      if (_isTwoStatePanel) {
        if (!(_animFull.isAnimating)) {
          if (_animFull.value == 1.0) {
            widget.onPanelExpanded();
          }
        }
      } else {
        if ((!_animExpanded.isAnimating) && (!_animCollapsed.isAnimating)) {
          if (_animCollapsed.value == 1.0 && _animExpanded.value == 2.0) {
            widget.onPanelExpanded();
          }
        }
      }
    }
  }

  Duration _extractCollapsedDuration() {
    double diffTotal = _expandedHeight - _closedHeight;
    double diffCollapsed = _collapsedHeight - _closedHeight;

    int dur = (((diffCollapsed * _duration.inMilliseconds) / diffTotal)
        .floor()
        .toInt());

    return Duration(milliseconds: dur);
  }

  Duration _extractExpandedDuration() {
    double diffTotal = _expandedHeight - _closedHeight;
    double diffExpanded = _expandedHeight - _collapsedHeight;

    int dur = (((diffExpanded * _duration.inMilliseconds) / diffTotal)
        .floor()
        .toInt());

    return Duration(milliseconds: dur);
  }

  @override
  void initState() {
    super.initState();

    _closedHeight = widget.size.closedHeight;
    _collapsedHeight = widget.size.collapsedHeight;
    _expandedHeight = widget.size.expandedHeight;
    _duration = widget.duration;
    _isTwoStatePanel = widget.isTwoStatePanel;

    _animFull = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: widget.initialState == InitialPanelState.expanded ? 1.0 : 0.0,
    )..addListener(() => _animationListener(isCollapsedAnimation: false));

    _animCollapsed = AnimationController(
      vsync: this,
      duration: _extractCollapsedDuration(),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: widget.initialState == InitialPanelState.closed ? 0.0 : 1.0,
    )..addListener(() => _animationListener(isCollapsedAnimation: true));

    _animExpanded = AnimationController(
      vsync: this,
      duration: _extractExpandedDuration(),
      lowerBound: 1.0,
      upperBound: 2.0,
      value: widget.initialState == InitialPanelState.expanded ? 2.0 : 1.0,
    )..addListener(() => _animationListener(isCollapsedAnimation: false));

    widget.panelController?._control(
      _collapsePanel,
      _expandPanel,
      _closePanel,
      _setPanelPosition,
      _setAnimatedPanelPosition,
      _getCurrentPanelPosition,
      _getCurrentPanelState,
      _sendResult,
      _popWithResult,
    );
  }

  @override
  void didUpdateWidget(SlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool isUpdated = false;

    if (widget.size.closedHeight != _closedHeight) {
      _closedHeight = widget.size.closedHeight;
      isUpdated = true;
    }

    if (widget.size.collapsedHeight != _collapsedHeight) {
      _collapsedHeight = widget.size.collapsedHeight;
      isUpdated = true;
    }

    if (widget.size.expandedHeight != _expandedHeight) {
      _expandedHeight = widget.size.expandedHeight;
      isUpdated = true;
    }

    if (widget.duration != _duration) {
      _duration = widget.duration;
      isUpdated = true;
    }

    if (widget.isTwoStatePanel != _isTwoStatePanel) {
      _isTwoStatePanel = widget.isTwoStatePanel;
      isUpdated = true;
    }

    // If the panel's heights or duration are really changed, update the animation controller duration also.
    if (isUpdated) {
      if (_isTwoStatePanel) {
        _animFull.duration = _duration;
      } else {
        _animCollapsed.duration = _extractCollapsedDuration();
        _animExpanded.duration = _extractExpandedDuration();
      }
    }
  }

  @override
  void dispose() {
    _animCollapsed?.dispose();
    _animExpanded?.dispose();
    _animFull?.dispose();
    super.dispose();
  }

  double _getParallaxSlideAmount() {
    if (widget.parallaxSlideAmount > 0.0 && widget.parallaxSlideAmount <= 1.0) {
      if (_isTwoStatePanel) {
        return (-((_animFull.value) *
            (_expandedHeight - _closedHeight) *
            widget.parallaxSlideAmount));
      } else {
        return (-((((_animCollapsed.value) + (_animExpanded.value - 1.0)) / 2) *
            (_expandedHeight - _closedHeight) *
            widget.parallaxSlideAmount));
      }
    }
    return 0;
  }

  double _getExpandedCurrentHeight() {
    return ((_animExpanded.value - 1.0) * (_expandedHeight - _collapsedHeight) +
        _collapsedHeight);
  }

  double _getCollapsedCurrentHeight() {
    return (_animCollapsed.value * (_collapsedHeight - _closedHeight) +
        _closedHeight);
  }

  double _getTwoStateHeight() {
    return (_animFull.value * (_expandedHeight - _closedHeight) +
        _closedHeight);
  }

  double _getBackdropOpacityAmount() {
    if (_isTwoStatePanel) {
      return ((_animFull.value) * widget.backdropConfig.opacity);
    } else {
      double amount1 =
          ((((_animCollapsed.value) + (_animExpanded.value - 1.0)) / 2) *
              widget.backdropConfig.opacity);

      double amount2 =
          ((((_animExpanded.value - 1.0)) / 2) * widget.backdropConfig.opacity);

      if (widget.backdropConfig.effectInCollapsedMode) {
        return amount1;
      } else {
        if (_animExpanded.value > 1.0) {
          return amount2;
        } else {
          return 0.0;
        }
      }
    }
  }

  Color _getBackdropColor() {
    if (_isTwoStatePanel) {
      if (_animFull.value == 0.0)
        return null;
      else
        return widget.backdropConfig.shadowColor;
    } else {
      if (widget.backdropConfig.effectInCollapsedMode) {
        if (_animExpanded.value == 1.0 && _animCollapsed.value == 0.0)
          return null;
        else
          return widget.backdropConfig.shadowColor;
      } else {
        if (_animExpanded.value > 1.0)
          return widget.backdropConfig.shadowColor;
        else
          return null;
      }
    }
  }

  void _handleBackdropTap() {
    if (_isTwoStatePanel) {
      if (_animFull.value > 0.0 && widget.backdropConfig.closeOnTap) {
        _closePanel();
      }
    } else {
      if (widget.backdropConfig.effectInCollapsedMode) {
        if (_animExpanded.value > 1.0 && widget.backdropConfig.collapseOnTap)
          _collapsePanel();
        else if (widget.backdropConfig.closeOnTap) _closePanel();
      } else {
        if (_animExpanded.value > 1.0 && widget.backdropConfig.collapseOnTap)
          _collapsePanel();
      }
    }
  }

  void _onPanelDrag(DragUpdateDetails details) {
    if (_isTwoStatePanel) {
      if (details.primaryDelta != 0) {
        if (details.primaryDelta < 0) {
          // swipe upside
          if (_animFull.value != 1.0) {
            // drag until fully expanded
            _animFull.value -=
                details.primaryDelta / (_expandedHeight - _closedHeight);
          }
        } else {
          // swipe downside
          if (_animFull.value != 0.0) {
            // drag until fully closed
            _animFull.value -=
                details.primaryDelta / (_expandedHeight - _closedHeight);
          }
        }
      }
    } else {
      if (details.primaryDelta != 0) {
        // actually swiped
        if (details.primaryDelta < 0) {
          // swipe upside
          if (_animExpanded.value != 2.0) {
            // panel is not fully expanded
            // otherwise no updation needed
            if (_animCollapsed.value < 1.0) {
              // panel is not open fully in collapsed mode
              _animCollapsed.value -=
                  details.primaryDelta / (_collapsedHeight - _closedHeight);
            } else {
              // panel collapsed, now expand it
              _animExpanded.value -=
                  details.primaryDelta / (_expandedHeight - _collapsedHeight);
            }
          }
        } else {
          // swipe downside
          if (_animCollapsed.value != 0.0) {
            // panel is not fully closed
            // otherwise no updation needed
            if (_animExpanded.value > 1.0) {
              // panel is not closed fully in expanded mode
              _animExpanded.value -=
                  details.primaryDelta / (_expandedHeight - _collapsedHeight);
            } else {
              // panel collapsed, now close it
              _animCollapsed.value -=
                  details.primaryDelta / (_collapsedHeight - _closedHeight);
            }
          }
        }
      }
    }
  }

  void _onPanelDragEnd(DragEndDetails details) {
    int minFlingVelocityNeeded = 300;

    if (_isTwoStatePanel) {
      // don't do anything if panel is animating
      if (_animFull.isAnimating) return;

      if (details.velocity.pixelsPerSecond.dy.abs() >= minFlingVelocityNeeded) {
        // swipe speed more than desired
        double visualVelocity = -details.velocity.pixelsPerSecond.dy /
            (_expandedHeight - _closedHeight);

        if (widget.snapPanel) {
          _animFull.fling(velocity: visualVelocity);
        } else {
          _animFull.animateTo(_animFull.value + visualVelocity * 0.16,
              curve: widget.curve);
        }
      } else {
        if (widget.snapPanel) {
          if (_animFull.value > 0.5)
            _expandPanel();
          else
            _closePanel();
        }
      }
    } else {
      // don't do anything if panel is animating
      if (_animCollapsed.isAnimating || _animExpanded.isAnimating) return;

      if (details.velocity.pixelsPerSecond.dy.abs() >= minFlingVelocityNeeded) {
        // swipe speed more than desired

        double visualVelocity;

        if (_animExpanded.value > 1.0 && _animExpanded.value < 2.0) {
          // expanded state needs update
          visualVelocity = -details.velocity.pixelsPerSecond.dy /
              (_expandedHeight - _collapsedHeight);
        } else {
          // collapsed state needs update
          visualVelocity = -details.velocity.pixelsPerSecond.dy /
              (_collapsedHeight - _closedHeight);
        }

        if (widget.snapPanel) {
          if (_animExpanded.value > 1.0 && _animExpanded.value < 2.0) {
            _animExpanded.fling(velocity: visualVelocity);
          } else {
            _animCollapsed.fling(velocity: visualVelocity);
          }
        } else {
          if (_animExpanded.value > 1.0 && _animExpanded.value < 2.0) {
            _animExpanded.animateTo(_animExpanded.value + visualVelocity * 0.16,
                curve: widget.curve);
          } else {
            _animCollapsed.animateTo(
                _animCollapsed.value + visualVelocity * 0.16,
                curve: widget.curve);
          }
        }
      } else {
        if (widget.snapPanel) {
          if (((_animCollapsed.value == 0.0) ||
              (_animCollapsed.value == 1.0))) {
            // Panel is either fully collapsed or fully closed, so just check about expansion
            if ((_animExpanded.value > 1.5) && (_animExpanded.value < 2.0)) {
              // swiped more than half of expanded panel, but not expanded fully
              _expandPanel();
            } else if ((_animExpanded.value <= 1.5) &&
                (_animExpanded.value > 1.0)) {
              // swiped less than half of expanded panel, but not collapsed fully
              _collapsePanel();
            }
          } else {
            // Panel needs to be either closed or collapsed
            if ((_animCollapsed.value > 0.5) && (_animCollapsed.value < 1.0)) {
              // swiped more than half of collapsed panel, but not collapsed fully
              _collapsePanel();
            } else if ((_animCollapsed.value <= 0.5) &&
                (_animCollapsed.value > 0.0)) {
              // swiped less than half of collapsed panel, but not closed fully
              _closePanel();
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        // the body part
        widget.content.bodyContent == null
            ? Container()
            : Positioned.fill(
                top: _getParallaxSlideAmount(),
                child: widget.content.bodyContent),

        // the backdrop shadow
        widget.backdropConfig.enabled
            ? GestureDetector(
                onVerticalDragUpdate:
                    (widget.isDraggable && widget.backdropConfig.dragFromBody)
                        ? _onPanelDrag
                        : null,
                onVerticalDragEnd:
                    (widget.isDraggable && widget.backdropConfig.dragFromBody)
                        ? _onPanelDragEnd
                        : null,
                onTap: _handleBackdropTap,
                child: Opacity(
                  opacity: _getBackdropOpacityAmount(),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,

                    // setting color null enables Gesture recognition when collapsed / closed
                    color: _getBackdropColor(),
                  ),
                ),
              )
            : Container(),

        // the panel content
        GestureDetector(
          onVerticalDragUpdate: widget.isDraggable ? _onPanelDrag : null,
          onVerticalDragEnd: widget.isDraggable ? _onPanelDragEnd : null,
          child: Container(
            height: _isTwoStatePanel
                ? _getTwoStateHeight()
                : _animExpanded.value > 1.0
                    ? _getExpandedCurrentHeight()
                    : _getCollapsedCurrentHeight(),
            padding: widget.decoration.padding,
            margin: widget.decoration.margin,
            decoration: widget.renderPanelBackground
                ? BoxDecoration(
                    border: widget.decoration.border,
                    borderRadius: widget.decoration.borderRadius,
                    boxShadow: widget.decoration.boxShadows,
                    color: widget.decoration.backgroundColor,
                  )
                : null,
            child: Stack(
              children: <Widget>[
                // expanded panel
                Positioned(
                  top: 0.0,
                  width: MediaQuery.of(context).size.width -
                      (widget.decoration.margin == null
                          ? 0
                          : widget.decoration.margin.horizontal) -
                      (widget.decoration.padding == null
                          ? 0
                          : widget.decoration.padding.horizontal),
                  child: Container(
                    height: _isTwoStatePanel
                        ? _animFull.value > 0.0
                            ? _expandedHeight
                            : _closedHeight
                        : _animExpanded.value > 1.0
                            ? _expandedHeight
                            : _collapsedHeight,
                    child: Opacity(
                      opacity: (_isTwoStatePanel ||
                              (widget.content.collapsedWidget
                                      .collapsedContent ==
                                  null))
                          ? 1.0
                          : widget.content.collapsedWidget.hideInExpandedOnly
                              ? (_animExpanded.value - 1.0)
                              : (_animCollapsed.value),
                      child: widget.content.panelContent,
                    ),
                  ),
                ),

                // collapsed panel
                _isTwoStatePanel
                    ? Container()
                    : Positioned(
                        top: 0.0,
                        width: MediaQuery.of(context).size.width -
                            (widget.decoration.margin == null
                                ? 0
                                : widget.decoration.margin.horizontal) -
                            (widget.decoration.padding == null
                                ? 0
                                : widget.decoration.padding.horizontal),
                        child: Container(
                          height:
                              widget.content.collapsedWidget.hideInExpandedOnly
                                  ? _collapsedHeight
                                  : _closedHeight,
                          child: Opacity(
                            opacity: widget
                                    .content.collapsedWidget.hideInExpandedOnly
                                ? (1.0 - (_animExpanded.value - 1.0))
                                : (1.0 - _animCollapsed.value),
                            child: IgnorePointer(
                              ignoring: widget.content.collapsedWidget
                                      .hideInExpandedOnly
                                  ? _animExpanded.value == 2.0
                                  : _animCollapsed.value == 1.0,
                              child: widget.content.collapsedWidget
                                      .collapsedContent ??
                                  Container(),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _expandPanel() {
    if (_isTwoStatePanel) {
      // Just directly expand the panel
      if (_animFull.value != 1.0) {
        // Panel is not expanded
        _animFull.animateTo(1.0, curve: widget.curve);
      }
    } else {
      if (_animCollapsed.value != 1.0) {
        // Panel is closed, first collapse it, then expand
        if (!(_animCollapsed.isAnimating)) {
          _animCollapsed.animateTo(1.0, curve: Curves.linear).then((_) {
            _animExpanded.animateTo(2.0, curve: Curves.linear);
          });
        }
      } else {
        // Panel is already collapsed, just expand it
        if (!(_animExpanded.isAnimating)) {
          _animExpanded.animateTo(2.0, curve: widget.curve);
        }
      }
    }
  }

  void _collapsePanel() {
    if (!(_isTwoStatePanel)) {
      // Two state panels don't collapse
      if (_animCollapsed.value == 1.0) {
        // Panel is already collapsed, maybe expanded
        if ((!_animExpanded.isAnimating) && (_animExpanded.value != 1.0)) {
          // Panel is expanded, collapse it
          _animExpanded.animateTo(1.0, curve: widget.curve);
        }
      } else {
        // Panel is closed, collapse it
        if (!(_animCollapsed.isAnimating)) {
          _animCollapsed.animateTo(1.0, curve: widget.curve).then((_) {
            if ((!_animExpanded.isAnimating) && (_animExpanded.value != 1.0)) {
              // if, (rarely) panel is expanded, collapse it
              _animExpanded.value = 1.0;
            }
          });
        }
      }
    }
  }

  void _closePanel() {
    if (_isTwoStatePanel) {
      // Just directly close the panel
      if (_animFull.value != 0.0) {
        // Panel is not closed
        _animFull.animateTo(0.0, curve: widget.curve);
      }
    } else {
      if (_animExpanded.value == 2.0) {
        // Panel is expanded, first collapse it, then close
        if (!(_animExpanded.isAnimating)) {
          _animExpanded.animateTo(1.0, curve: Curves.linear).then((_) {
            _animCollapsed.animateTo(0.0, curve: Curves.linear);
          });
        }
      } else {
        // Panel is collapsed, just close it
        if (!(_animCollapsed.isAnimating)) {
          _animCollapsed.animateTo(0.0, curve: widget.curve);
        }
      }
    }
  }

  void _setPanelPosition(double value) {
    if (_isTwoStatePanel) {
      // Two state panels have value between 0.0 and 1.0 only
      if (value >= 0.0 && value <= 1.0) {
        _animFull.value = value;
      }
    } else {
      if (value >= 0.0 && value <= 2.0) {
        if (value <= 1.0) {
          _animCollapsed.value = value;
          if (_animExpanded.value != 1.0) _animExpanded.value = 1.0;
        } else {
          if (_animCollapsed.value != 1.0) _animCollapsed.value = 1.0;
          _animExpanded.value = value;
        }
      }
    }
  }

  void _setAnimatedPanelPosition(double value) {
    if (_isTwoStatePanel) {
      // Two state panels have value between 0.0 and 1.0 only
      if (value >= 0.0 && value <= 1.0) {
        _animFull.animateTo(value, curve: widget.curve);
      }
    } else {
      if (value >= 0.0 && value <= 2.0) {
        if (value <= 1.0) {
          _animCollapsed.animateTo(value, curve: widget.curve).then((_) {
            if (_animExpanded.value != 1.0)
              _animExpanded.animateTo(1.0, curve: widget.curve);
          });
        } else {
          if (_animCollapsed.value != 1.0) {
            _animCollapsed.animateTo(1.0, curve: widget.curve).then((_) {
              _animExpanded.animateTo(value, curve: widget.curve);
            });
          } else {
            _animExpanded.animateTo(value, curve: widget.curve);
          }
        }
      }
    }
  }

  double _getCurrentPanelPosition() {
    if (_isTwoStatePanel) return _animFull.value;
    return _animExpanded.value > 1.0
        ? _animExpanded.value
        : _animCollapsed.value;
  }

  PanelState _getCurrentPanelState() {
    if (_isTwoStatePanel) {
      if (_animFull.isAnimating) return PanelState.animating;

      if (_animFull.value == 0.0) return PanelState.closed;

      if (_animFull.value == 1.0) return PanelState.expanded;
    } else {
      if (_animCollapsed.isAnimating || _animExpanded.isAnimating)
        return PanelState.animating;
      else {
        if (_animCollapsed.value == 0.0 && _animExpanded.value == 1.0)
          return PanelState.closed;

        if (_animCollapsed.value == 1.0 && _animExpanded.value == 1.0)
          return PanelState.collapsed;

        if (_animCollapsed.value == 1.0 && _animExpanded.value == 2.0)
          return PanelState.expanded;
      }
    }
    return PanelState.closed;
  }

  void _sendResult({dynamic result}) {
    SlidingPanelResult(result: result).dispatch(context);
  }

  void _popWithResult({dynamic result}) {
    _closePanel();
    _sendResult(result: result);
  }
}
