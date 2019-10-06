part of sliding_panel;

class _PanelAnimation {
  static AnimationController animation;
  static bool isCleared = true;

  static void clear() {
    if (!isCleared) {
      if (_PanelAnimation.animation != null) {
        _PanelAnimation.animation.stop();
        _PanelAnimation.animation.dispose();
        _PanelAnimation.animation = null;
      }
      isCleared = true;
    }
  }
}

class _PanelSnapData {
  _PanelScrollPosition scrollPos;
  double from, to, dragVelocity, flingVelocity;
  bool shouldPanelSnap;

  _PanelSnapData({
    @required this.scrollPos,
    @required this.dragVelocity,
  })  : shouldPanelSnap = false,
        flingVelocity = -2.0;

  void prepareSnapping() {
    bool twoStatePanel = scrollPos.metadata.isTwoStatePanel;

    double currentH = scrollPos.metadata.currentHeight;
    double closedH = scrollPos.metadata.closedHeight;
    double collapsedH = scrollPos.metadata.collapsedHeight;
    double expandedH = scrollPos.metadata.expandedHeight;

    from = scrollPos.metadata.currentHeight;
    to = from;

    Map<PanelDraggingDirection, double> allowedDraggingTill =
        scrollPos.metadata.allowedDraggingTill;

    PanelState toState = PanelState.indefinite;
    // initially, some other state

    shouldPanelSnap = false;
    flingVelocity = -2.0;

    if (twoStatePanel) {
      // two state panels only close and expand

      if (currentH >= closedH && currentH <= expandedH) {
        // there is no restriction for two-state panels
        shouldPanelSnap = true;

        if (dragVelocity > 0) {
          // swipe upside
          toState = PanelState.expanded;
        } else if (dragVelocity < 0) {
          // swipe downside
          toState = PanelState.closed;
        }
      } else {
        // nothing to do (snap : false)
        shouldPanelSnap = false;
        return;
      }
    } else {
      if (dragVelocity > 0) {
        // swipe upside

        if (currentH >= collapsedH) {
          if (currentH == expandedH) {
            return;
          }
          toState = PanelState.expanded;
        } else if (currentH >= closedH) {
          if (currentH == collapsedH) {
            return;
          }
          toState = PanelState.collapsed;
        } else {
          return;
        }
      } else if (dragVelocity < 0) {
        // swipe downside

        if (currentH <= collapsedH) {
          if (currentH == closedH) {
            return;
          }

          toState = PanelState.closed;
        } else if (currentH <= expandedH) {
          if (currentH == collapsedH) {
            return;
          }

          toState = PanelState.collapsed;
        } else {
          return;
        }
      }
    }

    switch (toState) {
      // decide panel height to be used
      case PanelState.closed:
        to = closedH;
        break;
      case PanelState.collapsed:
        to = collapsedH;
        break;
      case PanelState.expanded:
        to = expandedH;
        break;
      case PanelState.animating:
        return;
        break;
      case PanelState.indefinite:
        shouldPanelSnap = false;
        return;
        break;
    }

    if ((!(allowedDraggingTill.containsKey(PanelDraggingDirection.ALLOW))) &&
        (!twoStatePanel)) {
      // there is some restriction, not two-state panel
      if (to > from) {
        // swipe upside
        if (allowedDraggingTill.containsKey(PanelDraggingDirection.UP)) {
          // upside restriction
          to = min(allowedDraggingTill[PanelDraggingDirection.UP], to);
          if (from > to) return;
        }
      } else {
        // swipe downside
        if (allowedDraggingTill.containsKey(PanelDraggingDirection.DOWN)) {
          // downside restriction
          to = max(allowedDraggingTill[PanelDraggingDirection.DOWN], to);
          if (from < to) return;
        }
      }
    }

    if (to < from) {
      // flip if required
      double _temp = from;
      from = to;
      to = _temp;
    }

    if (from == to)
      shouldPanelSnap = false;
    else
      shouldPanelSnap = true;
  }

  void snapPanel() {
    if (shouldPanelSnap) {
      double currentH = scrollPos.metadata.currentHeight;
      double closedH = scrollPos.metadata.closedHeight;
      double expandedH = scrollPos.metadata.expandedHeight;

      _PanelAnimation.clear();

      _PanelAnimation.animation = AnimationController(
        vsync: scrollPos.context.vsync,
        lowerBound: from,
        upperBound: to,
      );

      void _tick() {
        scrollPos.metadata.currentHeight = _PanelAnimation.animation.value;
        // set panel's position
      }

      _PanelAnimation.animation.value = currentH;
      _PanelAnimation.animation.addListener(_tick);

      if (scrollPos.metadata.totalHeight != 0.0 &&
          scrollPos.metadata.totalHeight != double.infinity &&
          dragVelocity != 0) {
        // set flingVelocity

        flingVelocity = (dragVelocity /
            ((scrollPos.metadata.totalHeight * expandedH) -
                (scrollPos.metadata.totalHeight * closedH)));
      }

      // animate
      _PanelAnimation.isCleared = false;
      _PanelAnimation.animation.fling(velocity: flingVelocity);
    }
  }
}

void _scrollPanel(
  _PanelScrollPosition scrollPos, {
  double velocity,
  ValueChanged<double> ballisticEnd,
}) {
  final Simulation simulation = ClampingScrollSimulation(
    position: scrollPos.metadata.currentHeight,
    velocity: velocity,
    tolerance: scrollPos.physics.tolerance,
  );

  _PanelAnimation.clear();

  _PanelAnimation.animation =
      AnimationController.unbounded(vsync: scrollPos.context.vsync);

  double lastDelta = 0;

  void _tick() {
    final double currentDelta = _PanelAnimation.animation.value - lastDelta;

    lastDelta = _PanelAnimation.animation.value;

    scrollPos.metadata.addPixels(currentDelta);

    if ((velocity > 0 && scrollPos.metadata.isExpanded) ||
        (velocity < 0 && scrollPos.metadata.isClosed)) {
      // after dragging, if start or end reached
      velocity = _PanelAnimation.animation.velocity +
          (scrollPos.physics.tolerance.velocity *
              _PanelAnimation.animation.velocity.sign);

      ballisticEnd?.call(velocity);

      _PanelAnimation.animation.stop();
    }
  }

  _PanelAnimation.isCleared = false;
  _PanelAnimation.animation
    ..addListener(_tick)
    ..animateWith(simulation).whenCompleteOrCancel(() {});
}

Future<Null> _setPanelPosition(
  _SlidingPanelState panel, {
  @required double to,
  @required Duration duration,
}) async {
  _PanelScrollPosition scrollPos = panel._scrollController._scrollPosition;

  to = to.clamp(
      scrollPos.metadata.closedHeight, scrollPos.metadata.expandedHeight);

  double from = scrollPos.metadata.currentHeight;

  if (from != to) {
    // if the panel is not having same height as requested

    _PanelAnimation.clear();

    _PanelAnimation.animation = AnimationController(
      vsync: scrollPos.context.vsync,
    );

    void _tick() {
      scrollPos.metadata.currentHeight = _PanelAnimation.animation.value;
    }

    _PanelAnimation.animation.value = scrollPos.metadata.currentHeight;
    _PanelAnimation.animation.addListener(_tick);

    _PanelAnimation.isCleared = false;

    await _PanelAnimation.animation.animateTo(
      to,
      curve: panel.widget.curve,
      duration: duration,
    );
  }
}

/// returns how much amount of the body part should scroll up in pixels when the panel slides.
double _getParallaxSlideAmount(_SlidingPanelState panel) {
  double amount = panel.widget.parallaxSlideAmount.clamp(0.0, 1.0);
  if (amount > 0.0 && amount <= 1.0) {
    double position = panel._controller.percentPosition(
        panel._metadata.closedHeight, panel._metadata.expandedHeight);
    double expandedHeight =
        panel._metadata.totalHeight * panel._metadata.expandedHeight;
    double closedHeight =
        panel._metadata.totalHeight * panel._metadata.closedHeight;

    double parallax = (-(position *
        (expandedHeight - closedHeight) *
        panel.widget.parallaxSlideAmount));

    return (parallax.isNaN ? 0.0 : parallax);
  }
  return 0.0;
}

/// returns amount of opacity the backdrop should apply when panel slides.
double _getBackdropOpacityAmount(_SlidingPanelState panel) {
  if (panel.widget.backdropConfig.effectInCollapsedMode) {
    return (panel._controller.percentPosition(
            panel._metadata.closedHeight, panel._metadata.expandedHeight) *
        panel.widget.backdropConfig.opacity);
  } else {
    if (panel._controller.currentPosition > panel._metadata.collapsedHeight) {
      return (panel._controller.percentPosition(
              panel._metadata.collapsedHeight, panel._metadata.expandedHeight) *
          panel.widget.backdropConfig.opacity);
    }
    return 0.0;
  }
}

/// returns amount of color the backdrop should apply when panel slides.
Color _getBackdropColor(_SlidingPanelState panel) {
  if (panel.widget.backdropConfig.draggableInClosed) {
    return panel.widget.backdropConfig.shadowColor;
  }

  if (panel.widget.backdropConfig.effectInCollapsedMode) {
    if (panel._controller.percentPosition(
            panel._metadata.closedHeight, panel._metadata.expandedHeight) <=
        0.0) return null;

    return panel.widget.backdropConfig.shadowColor;
  } else {
    if (panel._controller.currentPosition > panel._metadata.collapsedHeight) {
      return panel.widget.backdropConfig.shadowColor;
    }
    return null;
  }
}

/// returns amount of opacity to be applied to panel when sliding.
double _getPanelOpacity(_SlidingPanelState panel) {
  if (panel._metadata.isTwoStatePanel ||
      (panel.widget.content.collapsedWidget.collapsedContent == null)) {
    return 1.0;
  }

  if (panel.widget.content.collapsedWidget.hideInExpandedOnly) {
    return panel._controller.percentPosition(
        panel._metadata.collapsedHeight, panel._metadata.expandedHeight);
  } else {
    return panel._controller.percentPosition(
        panel._metadata.closedHeight, panel._metadata.collapsedHeight);
  }
}

/// returns amount of opacity to be applied to collapsed widget when sliding.
double _getCollapsedOpacity(_SlidingPanelState panel) {
  return (1.0 - _getPanelOpacity(panel));
}

void _dragPanel(
  _PanelMetadata metadata, {
  double delta,
  bool shouldListScroll,
  bool isGesture,
  bool dragFromBody,
  VoidCallback scrollContentSuper,
}) {
  if (isGesture) {
    // drag from body
    if (!dragFromBody) {
      return;
    }
  }
  // natural drag

  if (!shouldListScroll &&
      (!(metadata.isClosed || metadata.isExpanded) ||
          (metadata.isClosed && delta < 0) ||
          (metadata.isExpanded && delta > 0))) {
    if (metadata.isDraggable) {
      if (!metadata.snapPanel) {
        metadata.addPixels(-delta);
      } else {
        // snapping is true

        if (metadata.allowedDraggingTill
            .containsKey(PanelDraggingDirection.ALLOW)) {
          // no restriction
          metadata.addPixels(-delta);
        } else {
          // some restriction

          if (delta < 0.0) {
            // swiping upside

            double temp = (((-delta) / metadata.totalHeight) *
                metadata.dragExpandedHeight);

            if (temp + metadata.currentHeight > metadata.dragExpandedHeight) {
              if (metadata.currentHeight != metadata.dragExpandedHeight) {
                metadata.currentHeight = metadata.dragExpandedHeight;
              }
              // just scroll inner content
              scrollContentSuper();
            } else {
              metadata.addPixels(-delta);

              if (metadata.currentHeight > metadata.dragExpandedHeight) {
                metadata.currentHeight = metadata.dragExpandedHeight;
              }
            }
          } else {
            // swiping downside

            double temp =
                ((delta / metadata.totalHeight) * metadata.dragClosedHeight);

            if (metadata.currentHeight - temp < metadata.dragClosedHeight) {
              if (metadata.currentHeight != metadata.dragClosedHeight) {
                metadata.currentHeight = metadata.dragClosedHeight;
              }
              // just scroll inner content
              scrollContentSuper();
            } else {
              metadata.addPixels(-delta);

              if (metadata.currentHeight < metadata.dragClosedHeight) {
                metadata.currentHeight = metadata.dragClosedHeight;
              }
            }
          }
        }
      }
    } else {
      scrollContentSuper();
    }
  } else {
    scrollContentSuper();
  }
}

void _onPanelDragEnd(_SlidingPanelState panel, double primaryVelocity) {
  if (panel?._scrollController?._scrollPosition == null) {
    return;
  } else {
    if (panel._metadata.isDraggable &&
        panel.widget.backdropConfig.dragFromBody) {
      if (!panel._metadata.snapPanel) {
        // no panel snapping, just scroll the panel

        _scrollPanel(
          panel._scrollController._scrollPosition,
          velocity: primaryVelocity,
        );
      } else {
        // snap the panel

        if (!((panel._metadata.allowedDraggingTill
                .containsKey(PanelDraggingDirection.DOWN)) ||
            (panel._metadata.allowedDraggingTill
                .containsKey(PanelDraggingDirection.UP)))) {
          double percent = ((panel._metadata.totalHeight *
                  panel._metadata.snappingTriggerPercentage) /
              100);

          percent = percent.clamp(0.0, 750.0);

          if (percent >= 0.0) {
            if (primaryVelocity.abs() <= percent) {
              _scrollPanel(
                panel._scrollController._scrollPosition,
                velocity: primaryVelocity,
              );
              return;
            }
          }
        }

        _PanelSnapData snapData = _PanelSnapData(
          scrollPos: panel._scrollController._scrollPosition,
          dragVelocity: primaryVelocity,
        );

        snapData.prepareSnapping();

        if (snapData.shouldPanelSnap) {
          snapData.snapPanel();
        }
      }
    }
  }
}

void _handleBackdropTap(_SlidingPanelState panel) {
  if (panel._metadata.isTwoStatePanel) {
    if (panel._metadata.currentHeight > panel._metadata.closedHeight &&
        panel.widget.backdropConfig.closeOnTap) panel._controller.close();
  } else {
    if (panel.widget.backdropConfig.effectInCollapsedMode) {
      if (panel._metadata.currentHeight > panel._metadata.collapsedHeight &&
          panel.widget.backdropConfig.collapseOnTap) {
        panel._controller.collapse();
        return;
      }
      if (panel._metadata.currentHeight > panel._metadata.closedHeight &&
          panel.widget.backdropConfig.closeOnTap) panel._controller.close();
    } else {
      if (panel._metadata.currentHeight > panel._metadata.collapsedHeight &&
          panel.widget.backdropConfig.collapseOnTap)
        panel._controller.collapse();
    }
  }
}

const Map<BackPressBehavior, BackPressBehavior>
    _twoStateValidBackPressBehavior = {
  BackPressBehavior.COLLAPSE_PERSIST: BackPressBehavior.PERSIST,
  BackPressBehavior.COLLAPSE_POP: BackPressBehavior.POP,
  BackPressBehavior.CLOSE_PERSIST: BackPressBehavior.PERSIST,
  BackPressBehavior.COLLAPSE_CLOSE_PERSIST: BackPressBehavior.PERSIST,
  BackPressBehavior.COLLAPSE_CLOSE_POP: BackPressBehavior.CLOSE_POP,
};

Future<bool> _decidePop(_SlidingPanelState panel) async {
  BackPressBehavior behavior = panel.widget.backPressBehavior;
  PanelPoppingBehavior poppingBehavior = panel.widget.panelPoppingBehavior;

  if (panel._metadata.isTwoStatePanel) {
    if (_twoStateValidBackPressBehavior.containsKey(behavior)) {
      // invalid behavior given, convert to a valid one.
      behavior = _twoStateValidBackPressBehavior[behavior];
    }
  }

  if (behavior == BackPressBehavior.POP) {
    return true;
  } else if (behavior == BackPressBehavior.PERSIST) {
    return false;
  } else {
    //
    double currentHeight = panel._metadata.currentHeight;
    double closedHeight = panel._metadata.closedHeight;
    double collapsedHeight = panel._metadata.collapsedHeight;

    if (behavior == BackPressBehavior.COLLAPSE_PERSIST) {
      if (currentHeight > collapsedHeight) {
        await panel._controller.collapse();
      }
      return false;
    } else if (behavior == BackPressBehavior.COLLAPSE_POP) {
      if (currentHeight > collapsedHeight) {
        await panel._controller.collapse();

        if (poppingBehavior == PanelPoppingBehavior.POP_IMMEDIATELY) {
          return true;
        }
        return false;
      }
      return true;
    } else if (behavior == BackPressBehavior.CLOSE_PERSIST) {
      if (currentHeight > closedHeight) {
        await panel._controller.close();
      }
      return false;
    } else if (behavior == BackPressBehavior.CLOSE_POP) {
      if (currentHeight > closedHeight) {
        await panel._controller.close();

        if (poppingBehavior == PanelPoppingBehavior.POP_IMMEDIATELY) {
          return true;
        }
        return false;
      }
      return true;
    } else if (behavior == BackPressBehavior.COLLAPSE_CLOSE_PERSIST) {
      if (currentHeight > collapsedHeight) {
        await panel._controller.collapse();
      } else if (currentHeight > closedHeight &&
          currentHeight <= collapsedHeight) {
        await panel._controller.close();
      }
      return false;
    } else if (behavior == BackPressBehavior.COLLAPSE_CLOSE_POP) {
      if (poppingBehavior == PanelPoppingBehavior.POP_IMMEDIATELY) {
        if (currentHeight > closedHeight) {
          await panel._controller.close();
        }
        return true;
      } else {
        if (currentHeight > collapsedHeight) {
          await panel._controller.collapse();
          return false;
        } else if (currentHeight > closedHeight &&
            currentHeight <= collapsedHeight) {
          await panel._controller.close();
          return false;
        }
        return true;
      }
    } else {
      return true;
    }
  }
}
