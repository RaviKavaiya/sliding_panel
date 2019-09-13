part of sliding_panel;

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
  bool _isHeightCalculated = false;

  GlobalKey _keyCollapsed = GlobalKey();
  bool _collapsedCalculated = false;

  GlobalKey _keyContent = GlobalKey();
  bool _contentCalculated = false;

  GlobalKey _keyHeader = GlobalKey();
  double calcHeaderHeight = 0.0;
  bool _headerCalculated = false;

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
    )..addListener(() {
        setState(() {});
        _animationListener(this, isCollapsedAnimation: false);
      });

    _animCollapsed = AnimationController(
      vsync: this,
      duration: _extractCollapsedDuration(this),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: widget.initialState == InitialPanelState.closed ? 0.0 : 1.0,
    )..addListener(() {
        setState(() {});
        _animationListener(this, isCollapsedAnimation: true);
      });

    _animExpanded = AnimationController(
      vsync: this,
      duration: _extractExpandedDuration(this),
      lowerBound: 1.0,
      upperBound: 2.0,
      value: widget.initialState == InitialPanelState.expanded ? 2.0 : 1.0,
    )..addListener(() {
        setState(() {});
        _animationListener(this, isCollapsedAnimation: false);
      });

    widget.panelController?._control(
      () => _closePanel(this),
      () => _collapsePanel(this),
      () => _expandPanel(this),
      _setPanelPosition,
      _setAnimatedPanelPosition,
      () => _getCurrentPanelPosition(this),
      () => _getCurrentPanelState(this),
      _sendResult,
      _popWithResult,
    );

    SchedulerBinding.instance.addPostFrameCallback((x) {
      _updatePanelSize();
    });
  }

  @override
  void didUpdateWidget(SlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final _screenHeight = MediaQuery.of(context).size.height;

    bool isUpdated = false;

    if (widget.size.closedHeight != _closedHeight) {
      _closedHeight = widget.size.closedHeight;
      isUpdated = true;
    }

    if (widget.size.collapsedHeight != _collapsedHeight) {
      double _temp = widget.size.collapsedHeight;

      if (_temp > 0 && _temp <= 1.0) {
        _temp = _temp * _screenHeight;
      }

      if ((_getCurrentPanelState(this) == PanelState.collapsed) &&
          (!_isTwoStatePanel)) {
        double newValue = ((min(_collapsedHeight, _temp)) /
            ((max(_collapsedHeight, _temp) - _closedHeight) + _closedHeight));

        bool isNowBigger = _collapsedHeight < _temp;

        _collapsedHeight = _temp;

        _animCollapsed.value = newValue;

        if (isNowBigger) {
          _collapsePanel(this);
        } else {
          _closePanel(this);
        }
      } else {
        _collapsedHeight = _temp;
      }
      isUpdated = true;
    }

    if (widget.size.expandedHeight != _expandedHeight) {
      double _temp = widget.size.expandedHeight;

      if (_temp > 0 && _temp <= 1.0) {
        _temp = _temp * _screenHeight;
      }

      if (_getCurrentPanelState(this) == PanelState.expanded) {
        double newValue = (((min(_expandedHeight, _temp)) /
                ((max(_expandedHeight, _temp) - _closedHeight) +
                    _closedHeight)) +
            1.0);

        bool isNowBigger = _expandedHeight < _temp;

        _expandedHeight = _temp;

        if (widget.isTwoStatePanel) {
          _isTwoStatePanel = widget.isTwoStatePanel;
          _animFull.value = (newValue - 1.0);
        } else {
          _animExpanded.value = newValue;
        }

        if (isNowBigger) {
          _expandPanel(this);
        } else {
          if (_isTwoStatePanel) {
            _closePanel(this);
          } else {
            _collapsePanel(this);
          }
        }
      } else {
        _expandedHeight = _temp;
      }
      isUpdated = true;
    }

    if (widget.duration != _duration) {
      _duration = widget.duration;
      isUpdated = true;
    }

    // setting again, in case it is not done yet.
    if (_closedHeight > 0 && _closedHeight <= 1.0) {
      _closedHeight = _closedHeight * _screenHeight;
    }

    if (_collapsedHeight > 0 && _collapsedHeight <= 1.0) {
      _collapsedHeight = _collapsedHeight * _screenHeight;
    }

    if (_expandedHeight > 0 && _expandedHeight <= 1.0) {
      _expandedHeight = _expandedHeight * _screenHeight;
    }

    if (widget.isTwoStatePanel != _isTwoStatePanel) {
      var currentState = _getCurrentPanelState(this);

      if (currentState == PanelState.closed) {
        _isTwoStatePanel = widget.isTwoStatePanel;
        _animFull.value = 0.0;
      } else {
        _isTwoStatePanel = widget.isTwoStatePanel;
        _animFull.value = 1.0;
      }

      isUpdated = true;
    }

    // If the panel's heights or duration are really changed, update the animation controller duration also.
    if (isUpdated) {
      if (_isTwoStatePanel) {
        _animFull.duration = _duration;
      } else {
        _animCollapsed.duration = _extractCollapsedDuration(this);
        _animExpanded.duration = _extractExpandedDuration(this);
      }
    }

    _headerCalculated = false;
    _collapsedCalculated = false;
    _contentCalculated = false;

    SchedulerBinding.instance.addPostFrameCallback((x) {
      _updatePanelSize();
    });
  }

  @override
  void dispose() {
    _animCollapsed?.dispose();
    _animExpanded?.dispose();
    _animFull?.dispose();
    super.dispose();
  }

  void _updatePanelSize() {
    final screenHeight = MediaQuery.of(context).size.height;

    final RenderBox boxHeader =
        _keyHeader?.currentContext?.findRenderObject() ?? null;

    final RenderBox boxCollapsed =
        _keyCollapsed?.currentContext?.findRenderObject() ?? null;

    final RenderBox boxContent =
        _keyContent?.currentContext?.findRenderObject() ?? null;

    bool toShowHeader;

    if ((boxHeader?.size?.height ?? null) != null) {
      // header provided and size calculated.
      // so, this height has to be added to all other heights.

      toShowHeader = true;

      final headerHeight = boxHeader.size.height;

      setState(() {
        _headerCalculated = true;

        calcHeaderHeight = headerHeight;

        if (widget.autoSizing.headerSizeIsClosed) {
          if (_closedHeight < headerHeight) {
            _closedHeight = headerHeight;
          }
        }
      });
    } else {
      // no header given or size can't be determined.
      toShowHeader = false;
    }

    if ((!_isTwoStatePanel) && (widget.autoSizing.autoSizeCollapsed)) {
      // two-state panels don't have collapsedWidget

      if ((boxCollapsed?.size?.height ?? null) != null) {
        // collapsedWidget provided and size calculated.

        final colHeight = boxCollapsed.size.height;

        if (colHeight < screenHeight) {
          // if it is less than screen's height.
          setState(() {
            if (toShowHeader) {
              // add header height to collapsedHeight.
              _collapsedHeight = colHeight + calcHeaderHeight;
            } else {
              _collapsedHeight = colHeight;

              if (calcHeaderHeight > _collapsedHeight) {
                // this should not happen, still set collapsed to closed height.
                _collapsedHeight = calcHeaderHeight;
              }
            }
          });
        }
      }
    }

    setState(() {
      _collapsedCalculated = true;
    });

    if (((boxContent?.size?.height ?? null) != null) &&
        (widget.autoSizing.autoSizeExpanded)) {
      // panelContent provided and size calculated.

      final expHeight = boxContent.size.height;

      setState(() {
        if (expHeight < _collapsedHeight) {
          // collapsedHeight is more than expanded, so add it to expandedHeight.

          if (toShowHeader) {
            // set expanded in a manner that,
            // it should be less than screen height (otherwise, it should be of screen's height).
            // and maximum of (it's actual height + header height) and (collapsedHeight (which also includes header height))

            _expandedHeight = min(screenHeight,
                max(expHeight + calcHeaderHeight, _collapsedHeight));
          } else {
            // set expanded to collapsed.
            _expandedHeight = _collapsedHeight;
          }
        } else {
          if (toShowHeader) {
            // select minimum of screen height / boxHeight including header.
            _expandedHeight = min(
                expHeight + calcHeaderHeight, screenHeight + calcHeaderHeight);
          } else {
            // select minimum of screen height / boxHeight.
            _expandedHeight = min(expHeight, screenHeight);
          }
        }
      });
    }

    setState(() {
      _contentCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHeightCalculated) {
      _isHeightCalculated = true;

      final _screenHeight = MediaQuery.of(context).size.height;
      bool isUpdated = false;

      if (_closedHeight > 0 && _closedHeight <= 1.0) {
        _closedHeight = _closedHeight * _screenHeight;
        isUpdated = true;
      }
      if (_collapsedHeight > 0 && _collapsedHeight <= 1.0) {
        _collapsedHeight = _collapsedHeight * _screenHeight;
        isUpdated = true;
      }
      if (_expandedHeight > 0 && _expandedHeight <= 1.0) {
        _expandedHeight = _expandedHeight * _screenHeight;
        isUpdated = true;
      }

      if (isUpdated) {
        _animFull.duration = _duration;
        _animCollapsed.duration = _extractCollapsedDuration(this);
        _animExpanded.duration = _extractExpandedDuration(this);
      }
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _contentCalculated
            ? Container()
            : Offstage(
                child: Container(
                    key: _keyContent,
                    child: widget.content?.panelContent ?? Container()),
              ),

        ((widget.content?.collapsedWidget?.collapsedContent ?? null) == null)
            ? Container()
            : (_collapsedCalculated)
                ? Container()
                : Offstage(
                    child: Container(
                        key: _keyCollapsed,
                        child: widget.content.collapsedWidget.collapsedContent),
                  ),

        // the body part
        widget.content.bodyContent == null
            ? Container()
            : Positioned.fill(
                top: _getParallaxSlideAmount(this),
                child: widget.content.bodyContent),

        // the backdrop shadow
        widget.backdropConfig.enabled
            ? GestureDetector(
                onVerticalDragUpdate:
                    (widget.isDraggable && widget.backdropConfig.dragFromBody)
                        ? (details) => _onPanelDrag(this, details)
                        : null,
                onVerticalDragEnd:
                    (widget.isDraggable && widget.backdropConfig.dragFromBody)
                        ? (details) => _onPanelDragEnd(this, details)
                        : null,
                onTap: () => _handleBackdropTap(this),
                child: Opacity(
                  opacity: _getBackdropOpacityAmount(this),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    // setting color null enables Gesture recognition when collapsed / closed
                    color: _getBackdropColor(this),
                  ),
                ),
              )
            : Container(),

        // the panel content
        GestureDetector(
          onVerticalDragUpdate: widget.isDraggable
              ? (details) => _onPanelDrag(this, details)
              : null,
          onVerticalDragEnd: widget.isDraggable
              ? (details) => _onPanelDragEnd(this, details)
              : null,
          child: Container(
            height: _isTwoStatePanel
                ? _getTwoStateHeight(this)
                : _animExpanded.value > 1.0
                    ? _getExpandedCurrentHeight(this)
                    : _getCollapsedCurrentHeight(this),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // header widget
                widget.content.headerContent != null
                    ? Offstage(
                        offstage: (!_headerCalculated),
                        child: Container(
                          key: _keyHeader,
                          width: MediaQuery.of(context).size.width -
                              (widget.decoration.margin == null
                                  ? 0
                                  : widget.decoration.margin.horizontal) -
                              (widget.decoration.padding == null
                                  ? 0
                                  : widget.decoration.padding.horizontal),
                          child: _headerCalculated
                              ? Container(
                                  height: widget.autoSizing.headerSizeIsClosed
                                      ? _closedHeight
                                      : _isTwoStatePanel
                                          ? calcHeaderHeight * _animFull.value
                                          : calcHeaderHeight *
                                              _animCollapsed.value,
                                  child: widget.content.headerContent,
                                )
                              : Container(
                                  child: widget.content.headerContent,
                                ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      // expanded panel
                      Positioned(
                        width: MediaQuery.of(context).size.width -
                            (widget.decoration.margin == null
                                ? 0
                                : widget.decoration.margin.horizontal) -
                            (widget.decoration.padding == null
                                ? 0
                                : widget.decoration.padding.horizontal),
                        child: _contentCalculated
                            ? Container(
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
                                      : widget.content.collapsedWidget
                                              .hideInExpandedOnly
                                          ? (_animExpanded.value - 1.0)
                                          : (_animCollapsed.value),
                                  child: widget.content.panelContent,
                                ),
                              )
                            : Container(),
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
                              child: _collapsedCalculated
                                  ? Container(
                                      height: widget.content.collapsedWidget
                                              .hideInExpandedOnly
                                          ? _collapsedHeight
                                          : _closedHeight,
                                      child: Opacity(
                                        opacity: widget.content.collapsedWidget
                                                .hideInExpandedOnly
                                            ? (1.0 -
                                                (_animExpanded.value - 1.0))
                                            : (1.0 - _animCollapsed.value),
                                        child: IgnorePointer(
                                          ignoring: widget
                                                  .content
                                                  .collapsedWidget
                                                  .hideInExpandedOnly
                                              ? _animExpanded.value == 2.0
                                              : _animCollapsed.value == 1.0,
                                          child: widget.content.collapsedWidget
                                                  .collapsedContent ??
                                              Container(),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  Future<Null> _setAnimatedPanelPosition(double value) async {
    if (_isTwoStatePanel) {
      // Two state panels have value between 0.0 and 1.0 only
      if (value >= 0.0 && value <= 1.0) {
        await _animFull.animateTo(value, curve: widget.curve);
      }
    } else {
      if (value >= 0.0 && value <= 2.0) {
        if (value <= 1.0) {
          if (_animExpanded.value != 1.0) {
            await _animExpanded.animateTo(1.0, curve: Curves.linear);
            await _animCollapsed.animateTo(value, curve: Curves.linear);
          } else
            await _animCollapsed.animateTo(value, curve: widget.curve);
        } else {
          if (_animCollapsed.value != 1.0) {
            await _animCollapsed.animateTo(1.0, curve: Curves.linear);
            await _animExpanded.animateTo(value, curve: Curves.linear);
          } else
            await _animExpanded.animateTo(value, curve: widget.curve);
        }
      }
    }
  }

  void _sendResult({dynamic result}) {
    SlidingPanelResult(result: result).dispatch(context);
  }

  Future<Null> _popWithResult({dynamic result}) async {
    if (result != null) {
      await _closePanel(this);
      _sendResult(result: result);
    }
  }
}
