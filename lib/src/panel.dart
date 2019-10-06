part of sliding_panel;

class _SlidingPanelState extends State<SlidingPanel>
    with TickerProviderStateMixin {
  _PanelScrollController _scrollController;
  _PanelMetadata _metadata;

  PanelController _controller;

  PanelState _oldState;
  PanelState currentState;

  GlobalKey _keyHeader = GlobalKey();
  bool _headerCalculated = false;
  bool _toShowHeader = false;
  double _calculatedHeaderHeight = 0.0;

  GlobalKey _keyCollapsed = GlobalKey();
  bool _collapsedCalculated = false;

  GlobalKey _keyContent = GlobalKey();
  bool _contentCalculated = false;

  Size _screenSizeData;

  Map<PanelDraggingDirection, double> _getAllowedDraggingTill(
      Map<PanelDraggingDirection, double> allowedDraggingTill) {
    if ((widget.isTwoStatePanel) || (!widget.snapPanel)) {
      return const {PanelDraggingDirection.ALLOW: 0.0};
    } else {
      if ((allowedDraggingTill == null) || (allowedDraggingTill.length == 0)) {
        return const {PanelDraggingDirection.ALLOW: 0.0};
      } else {
        if (allowedDraggingTill.containsKey(PanelDraggingDirection.UP)) {
          if (allowedDraggingTill[PanelDraggingDirection.UP] >=
              widget.size.expandedHeight) {
            allowedDraggingTill.remove(PanelDraggingDirection.UP);
          }
        }
        if (allowedDraggingTill.containsKey(PanelDraggingDirection.DOWN)) {
          if (allowedDraggingTill[PanelDraggingDirection.DOWN] <=
              widget.size.closedHeight) {
            allowedDraggingTill.remove(PanelDraggingDirection.DOWN);
          }
        }
        return allowedDraggingTill.length == 0
            ? const {PanelDraggingDirection.ALLOW: 0.0}
            : allowedDraggingTill;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _metadata = _PanelMetadata(
      closedHeight: widget.size.closedHeight,
      collapsedHeight: widget.size.collapsedHeight,
      expandedHeight: widget.size.expandedHeight,
      isTwoStatePanel: widget.isTwoStatePanel,
      snapPanel: widget.snapPanel,
      isDraggable: widget.isDraggable,
      snappingTriggerPercentage: widget.snappingTriggerPercentage,
      initialPanelState: widget.initialState,
      allowedDraggingTill: _getAllowedDraggingTill(widget.allowedDraggingTill),
      whenSlided: _panelHeightChanged,
    );

    _scrollController = _PanelScrollController(
      metadata: _metadata,
    );

    _controller = PanelController().._control(this);
    widget?.panelController?._control(this);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller._checkAttached();
      widget?.panelController?._checkAttached();

      // this is needed here, otherwise the initial build will cause some glitch while calculating the auto panel size.
      if (widget.autoSizing.headerSizeIsClosed ||
          widget.autoSizing.autoSizeCollapsed ||
          widget.autoSizing.autoSizeExpanded) {
        _calculateHeights();
      } else {
        _calculateHeaderHeight();
        _collapsedCalculated = true;
        _contentCalculated = true;
      }

      _metadata
          ._setInitialStateAgain(); // set initial state, initially... (again!)

      // update durations again
      _controller._updateDurations();
      widget?.panelController?._updateDurations();
    });
  }

  void _calculateHeaderHeight() {
    final RenderBox boxHeader =
        _keyHeader?.currentContext?.findRenderObject() ?? null;

    // calculate header height
    if ((boxHeader?.size?.height ?? null) != null) {
      // header provided and size calculated.
      // so, this height has to be added to all other heights.

      final headerHeight = boxHeader.size.height;

      setState(() {
        _toShowHeader = true;

        _calculatedHeaderHeight = headerHeight;
        _headerCalculated = true;
      });
    } else {
      // no header given or size can't be determined.
      setState(() {
        _toShowHeader = false;
      });
    }
  }

  void _calculateHeights() {
    // take temporary variables.
    double _headerHeightTemp = _calculatedHeaderHeight;

    double _closedHeightTemp = _metadata.closedHeight;
    bool _closedHeightChanged = false;

    double _collapsedHeightTemp = _metadata.collapsedHeight;
    bool _collapsedHeightChanged = false;

    double _expandedHeightTemp = _metadata.expandedHeight;
    bool _expandedHeightChanged = false;

    // find all render boxes
    final RenderBox boxCollapsed =
        _keyCollapsed?.currentContext?.findRenderObject() ?? null;

    final RenderBox boxContent =
        _keyContent?.currentContext?.findRenderObject() ?? null;

    _calculateHeaderHeight();
    if (_toShowHeader) {
      _headerHeightTemp = _calculatedHeaderHeight;
    }

    if (widget.autoSizing.headerSizeIsClosed) {
      if (_closedHeightTemp < _calculatedHeaderHeight) {
        _closedHeightTemp = _calculatedHeaderHeight;
        _closedHeightChanged = true;
      }
    }

    // calculate collapsed widget height.
    if ((!_metadata.isTwoStatePanel) && (widget.autoSizing.autoSizeCollapsed)) {
      // not for two-state panels, as they don't have this widget.

      if ((boxCollapsed?.size?.height ?? null) != null) {
        // collapsedWidget provided and size calculated.

        final colHeight = boxCollapsed.size.height;

        if (colHeight < _screenSizeData.height) {
          // if it is less than screen's height.
          setState(() {
            if (_toShowHeader) {
              // add header height to collapsedHeight.
              _collapsedHeightTemp = colHeight + _headerHeightTemp;

              if (_headerHeightTemp > _collapsedHeightTemp) {
                // this should not happen.
                _collapsedHeightTemp = _headerHeightTemp;
              }
            } else {
              _collapsedHeightTemp = colHeight;
            }
            _collapsedHeightChanged = true;
          });
        }
      }
    }

    // calculate panel height
    if (((boxContent?.size?.height ?? null) != null) &&
        (widget.autoSizing.autoSizeExpanded)) {
      // panelContent provided and size calculated.

      final expHeight = boxContent.size.height;

      setState(() {
        if (expHeight < _collapsedHeightTemp) {
          // collapsedHeight is more than expanded, so add it to expandedHeight.
          // !!! this is not an ideal condition.

          if (_toShowHeader) {
            // set expanded in a manner that,
            // it should be less than screen height (otherwise, it should be of screen's height).
            // and maximum of (it's actual height + header height) and (collapsedHeight (which also includes header height))

            _expandedHeightTemp = min(_screenSizeData.height,
                max(expHeight + _headerHeightTemp, _collapsedHeightTemp));
          } else {
            // set expanded to collapsed.
            _expandedHeightTemp = _collapsedHeightTemp;
          }
        } else {
          if (_toShowHeader) {
            // select minimum of screen height / boxHeight including header.
            _expandedHeightTemp = min(expHeight + _headerHeightTemp,
                _screenSizeData.height + _headerHeightTemp);
          } else {
            // select minimum of screen height / boxHeight.
            _expandedHeightTemp = min(expHeight, _screenSizeData.height);
          }
        }
        _expandedHeightChanged = true;
      });
    }

    setState(() {
      if (_closedHeightChanged) {
        _metadata.closedHeight = _closedHeightTemp / _screenSizeData.height;
      }

      if (_collapsedHeightChanged) {
        _metadata.collapsedHeight =
            _collapsedHeightTemp / _screenSizeData.height;
      }

      if (_expandedHeightChanged) {
        _metadata.expandedHeight = _expandedHeightTemp / _screenSizeData.height;
      }

      _collapsedCalculated = true;
      _contentCalculated = true;
    });
  }

  void _panelHeightChanged() {
    setState(() {});

    widget?.onPanelSlide?.call(_metadata.currentHeight);

    if (widget.onPanelStateChanged != null) {
      currentState = _controller.currentState;

      if (currentState != _oldState) {
        _oldState = currentState;
        widget.onPanelStateChanged(currentState);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_screenSizeData == null) {
      _screenSizeData = MediaQuery.of(context).size;
    } else {
      if (MediaQuery.of(context).size != _screenSizeData) {
        // resolution changed

        _screenSizeData = MediaQuery.of(context).size;

        if (widget.autoSizing.headerSizeIsClosed ||
            widget.autoSizing.autoSizeCollapsed ||
            widget.autoSizing.autoSizeExpanded) {
          _headerCalculated = false;
          _collapsedCalculated = false;
          _contentCalculated = false;
          SchedulerBinding.instance.addPostFrameCallback((x) {
            _calculateHeights();

            // update durations again
            _controller._updateDurations();
            widget?.panelController?._updateDurations();
          });
        } else {
          SchedulerBinding.instance.addPostFrameCallback((x) {
            _calculateHeaderHeight();
            _collapsedCalculated = true;
            _contentCalculated = true;

            // update durations again
            _controller._updateDurations();
            widget?.panelController?._updateDurations();
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(SlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.snapPanel != widget.snapPanel) {
      _metadata.snapPanel = widget.snapPanel;
    }

    if (oldWidget.isDraggable != widget.isDraggable) {
      _metadata.isDraggable = widget.isDraggable;
    }

    if (oldWidget.snappingTriggerPercentage !=
        widget.snappingTriggerPercentage) {
      _metadata.snappingTriggerPercentage = widget.snappingTriggerPercentage;
    }

    if (oldWidget.duration != widget.duration) {
      _controller._updateDurations();
      widget?.panelController?._updateDurations();
    }

    if (oldWidget.isTwoStatePanel != widget.isTwoStatePanel) {
      if ((widget.isTwoStatePanel) && (_metadata.isCollapsed)) {
        _controller.expand();
      }
      _metadata.isTwoStatePanel = widget.isTwoStatePanel;
    }

    if ((!widget.autoSizing.headerSizeIsClosed) &&
        (!widget.autoSizing.autoSizeCollapsed) &&
        (!widget.autoSizing.autoSizeExpanded)) {
      // no auto sizing is applied
      if (oldWidget.size.closedHeight != widget.size.closedHeight) {
        if (_metadata.currentHeight < widget.size.closedHeight) {
          // if current height of panel is less than new height
          // animate then set

          _controller
              .setAnimatedPanelPosition(widget.size.closedHeight)
              .then((_) {
            _metadata.closedHeight = widget.size.closedHeight;
          });
        } else if ((_metadata.currentHeight > widget.size.closedHeight) &&
            (_metadata.isClosed)) {
          // if current height of panel is more than new height and panel is closed
          // set then animate

          _metadata.closedHeight = widget.size.closedHeight;
          _controller.setAnimatedPanelPosition(widget.size.closedHeight);
        } else {
          // just close the panel and set new value
          // set then animate

          _metadata.closedHeight = widget.size.closedHeight;
          if ((!_metadata.isExpanded) && (!_metadata.isCollapsed)) {
            // if panel is neither collapsed nor expanded
            _controller.setAnimatedPanelPosition(widget.size.closedHeight);
          }
        }
      }

      if (oldWidget.size.collapsedHeight != widget.size.collapsedHeight) {
        if ((_metadata.currentHeight < widget.size.collapsedHeight) &&
            (!_metadata.isClosed)) {
          // if current height of panel is less than new height and panel is not closed
          // animate then set

          _controller
              .setAnimatedPanelPosition(widget.size.collapsedHeight)
              .then((_) {
            _metadata.collapsedHeight = widget.size.collapsedHeight;
          });
        } else if ((_metadata.currentHeight > widget.size.collapsedHeight) &&
            (_metadata.isCollapsed)) {
          // if current height of panel is more than new height and panel is collapsed
          // set then animate

          _metadata.collapsedHeight = widget.size.collapsedHeight;
          _controller.setAnimatedPanelPosition(widget.size.collapsedHeight);
        } else {
          // set new value
          _metadata.collapsedHeight = widget.size.collapsedHeight;
          if ((!_metadata.isExpanded) && (!_metadata.isClosed)) {
            // if panel is neither closed nor expanded
            _controller.setAnimatedPanelPosition(widget.size.collapsedHeight);
          }
        }
      }

      if (oldWidget.size.expandedHeight != widget.size.expandedHeight) {
        if ((_metadata.currentHeight < widget.size.expandedHeight) &&
            _metadata.isExpanded) {
          // if current height of panel is less than new height and panel is expanded
          // set then animate

          _metadata.expandedHeight = widget.size.expandedHeight;
          _controller.setAnimatedPanelPosition(widget.size.expandedHeight);
        } else if (_metadata.currentHeight > widget.size.expandedHeight) {
          // if current height of panel is more than new height
          // animate then set

          _controller
              .setAnimatedPanelPosition(widget.size.expandedHeight)
              .then((_) {
            _metadata.expandedHeight = widget.size.expandedHeight;
          });
        } else {
          // set new value
          _metadata.expandedHeight = widget.size.expandedHeight;
          if ((!_metadata.isCollapsed) && (!_metadata.isClosed)) {
            // if panel is neither closed nor collapsed
            _controller.setAnimatedPanelPosition(widget.size.expandedHeight);
          }
        }
      }
    }

    Map<PanelDraggingDirection, double> allowedDraggingTill =
        _getAllowedDraggingTill(widget.allowedDraggingTill);

    if (!(MapEquality()
        .equals(oldWidget.allowedDraggingTill, allowedDraggingTill))) {
      _metadata.allowedDraggingTill = allowedDraggingTill;
    }

    // when something changes, calculate auto panel size
    SchedulerBinding.instance.addPostFrameCallback((x) {
      if (widget.autoSizing.headerSizeIsClosed ||
          widget.autoSizing.autoSizeCollapsed ||
          widget.autoSizing.autoSizeExpanded) {
        _headerCalculated = false;
        _collapsedCalculated = false;
        _contentCalculated = false;
        _calculateHeights();

        // update durations again
        _controller._updateDurations();
        widget?.panelController?._updateDurations();
      } else {
        _calculateHeaderHeight();
        _collapsedCalculated = true;
        _contentCalculated = true;

        // update durations again
        _controller._updateDurations();
        widget?.panelController?._updateDurations();
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Widget _headerAndPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // header
        widget.content.headerWidget.headerContent != null
            ? Offstage(
                offstage: (!_headerCalculated),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => _dragPanel(
                    _metadata,
                    delta: details.primaryDelta,
                    shouldListScroll: false,
                    isGesture: true,
                    dragFromBody: widget.backdropConfig.dragFromBody,
                    scrollContentSuper: () {},
                  ),
                  onVerticalDragEnd: (details) =>
                      _onPanelDragEnd(this, -details.primaryVelocity),
                  onTap: () => widget.content?.headerWidget?.onTap?.call(),
                  child: Container(
                    decoration: widget.content.headerWidget.decoration != null
                        ? BoxDecoration(
                            border:
                                widget.content.headerWidget.decoration.border,
                            borderRadius: widget
                                .content.headerWidget.decoration.borderRadius,
                            boxShadow: widget
                                .content.headerWidget.decoration.boxShadows,
                            color: widget.content.headerWidget.decoration
                                .backgroundColor,
                          )
                        : null,
                    child: Container(
                      height: widget.autoSizing.headerSizeIsClosed
                          ? _calculatedHeaderHeight
                          : min(_metadata.currentHeight * _metadata.totalHeight,
                              _calculatedHeaderHeight),
                      width: _screenSizeData.width -
                          (widget.content.headerWidget.decoration.margin == null
                              ? 0
                              : widget.content.headerWidget.decoration.margin
                                  .horizontal) -
                          (widget.content.headerWidget.decoration.padding ==
                                  null
                              ? 0
                              : widget.content.headerWidget.decoration.padding
                                  .horizontal),
                      child: widget.content.headerWidget.headerContent,
                    ),
                  ),
                ),
              )
            : Container(),

        // panel
        Expanded(
          child: Stack(
            children: <Widget>[
              // panelContent
              _contentCalculated
                  ? SizedBox.expand(
                      child: Container(
                        child: Opacity(
                          opacity: _getPanelOpacity(this),
                          child: widget.content
                              .panelContent(context, _scrollController),
                        ),
                      ),
                    )
                  : Container(),

              // collapsedContent
              _metadata.isTwoStatePanel
                  ? Container()
                  : Positioned(
                      top: 0.0,
                      width: _screenSizeData.width -
                          (widget.decoration.margin == null
                              ? 0
                              : widget.decoration.margin.horizontal) -
                          (widget.decoration.padding == null
                              ? 0
                              : widget.decoration.padding.horizontal),
                      child: Container(
                        child: _collapsedCalculated
                            ? GestureDetector(
                                onVerticalDragUpdate: (details) => _dragPanel(
                                  _metadata,
                                  delta: details.primaryDelta,
                                  shouldListScroll: false,
                                  isGesture: true,
                                  dragFromBody:
                                      widget.backdropConfig.dragFromBody,
                                  scrollContentSuper: () {},
                                ),
                                onVerticalDragEnd: (details) => _onPanelDragEnd(
                                    this, -details.primaryVelocity),
                                child: Container(
                                  height: widget.content.collapsedWidget
                                          .hideInExpandedOnly
                                      ? _metadata.collapsedHeight *
                                          _screenSizeData.height
                                      : _metadata.closedHeight *
                                          _screenSizeData.height,
                                  child: Opacity(
                                    opacity: _getCollapsedOpacity(this),
                                    child: IgnorePointer(
                                      ignoring: widget.content.collapsedWidget
                                              .hideInExpandedOnly
                                          ? _metadata.isExpanded
                                          : _metadata.isCollapsed,
                                      child: widget.content.collapsedWidget
                                              .collapsedContent ??
                                          Container(),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        // for calculating the size.

        widget.content.headerWidget.headerContent == null
            ? Container()
            : Offstage(
                child: Container(
                  key: _keyHeader,
                  decoration: widget.content.headerWidget.decoration != null
                      ? BoxDecoration(
                          border: widget.content.headerWidget.decoration.border,
                          borderRadius: widget
                              .content.headerWidget.decoration.borderRadius,
                          boxShadow:
                              widget.content.headerWidget.decoration.boxShadows,
                          color: widget
                              .content.headerWidget.decoration.backgroundColor,
                        )
                      : null,
                  child: Container(
                    child: widget.content.headerWidget.headerContent,
                  ),
                ),
              ),

        _contentCalculated
            ? Container()
            : Offstage(
                child: Container(
                    key: _keyContent,
                    child: widget.content
                            .panelContent(context, _scrollController) ??
                        Container()),
              ),

        (((widget.content?.collapsedWidget?.collapsedContent ?? null) ==
                    null) ||
                (_metadata.isTwoStatePanel))
            ? Container()
            : (_collapsedCalculated)
                ? Container()
                : Offstage(
                    child: Container(
                      key: _keyCollapsed,
                      child: widget.content.collapsedWidget.collapsedContent,
                    ),
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
                onVerticalDragUpdate: (details) => _dragPanel(
                  _metadata,
                  delta: details.primaryDelta,
                  shouldListScroll: false,
                  isGesture: true,
                  dragFromBody: widget.backdropConfig.dragFromBody,
                  scrollContentSuper: () {},
                ),
                onVerticalDragEnd: (details) =>
                    _onPanelDragEnd(this, -details.primaryVelocity),
                onTap: () => _handleBackdropTap(this),
                child: Opacity(
                  opacity: _getBackdropOpacityAmount(this),
                  child: Container(
                    height: _screenSizeData.height,
                    width: _screenSizeData.width,
                    // setting color null enables Gesture recognition when collapsed / closed
                    color: _getBackdropColor(this),
                  ),
                ),
              )
            : Container(),

        // the panel content
        Container(
          padding: widget.decoration.padding,
          margin: widget.decoration.margin,
          height: _metadata.currentHeight * _screenSizeData.height,
          decoration: widget.renderPanelBackground
              ? BoxDecoration(
                  border: widget.decoration.border,
                  borderRadius: widget.decoration.borderRadius,
                  boxShadow: widget.decoration.boxShadows,
                  color: widget.decoration.backgroundColor,
                )
              : null,
          child: _headerAndPanel(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _decidePop(this),
      child: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          _metadata.totalHeight =
              _metadata.expandedHeight * constraints.biggest.height;

          return _body();
        },
      ),
    );
  }
}
