part of sliding_panel;

class _PanelAnimation {
  static AnimationController? animation;
  static bool isCleared = true;

  static void clear() {
    if (!isCleared) {
      if (_PanelAnimation.animation != null) {
        _PanelAnimation.animation!.stop();
        _PanelAnimation.animation!.dispose();
        _PanelAnimation.animation = null;
      }
      isCleared = true;
    }
  }
}

class _PanelSnapData {
  _PanelScrollPosition? scrollPos;
  double? from, to, dragVelocity, flingVelocity;
  bool shouldPanelSnap;
  PanelSnapping snapping;

  _PanelSnapData({
    required this.scrollPos,
    required this.dragVelocity,
    required this.snapping,
  })   : shouldPanelSnap = false,
        flingVelocity = -2.0;

  void prepareSnapping() {
    bool twoStatePanel = scrollPos!.metadata!.isTwoStatePanel;

    double currentH = scrollPos!.metadata!.currentHeight;
    double closedH = scrollPos!.metadata!.closedHeight;
    double collapsedH = scrollPos!.metadata!.collapsedHeight;
    double expandedH = scrollPos!.metadata!.expandedHeight;

    from = scrollPos!.metadata!.currentHeight;
    to = from;

    PanelState toState = PanelState.indefinite;
    // initially, some other state

    shouldPanelSnap = false;

    if (twoStatePanel) {
      // two state panels only close and expand

      if (currentH >= closedH && currentH <= expandedH) {
        // there is no restriction for two-state panels
        shouldPanelSnap = true;

        if ((snapping == PanelSnapping.forced) &&
            (dragVelocity!.abs() == 0.1)) {
          // snap forcefully to a position
          if (currentH >= ((closedH + expandedH) / 2)) {
            // panel currently above middle point
            dragVelocity = dragVelocity!.abs();
            toState = PanelState.expanded;
          } else {
            toState = PanelState.closed;
          }
        } else {
          if (dragVelocity! > 0) {
            // swipe upside
            toState = PanelState.expanded;
          } else if (dragVelocity! < 0) {
            // swipe downside
            toState = PanelState.closed;
          }
        }
      } else {
        // nothing to do (snap : false)
        // or dismissed already
        shouldPanelSnap = false;
        return;
      }
    } else {
      if ((snapping == PanelSnapping.forced) && (dragVelocity!.abs() == 0.1)) {
        //snap forcefully to a position
        if (currentH == closedH ||
            currentH == collapsedH ||
            currentH == expandedH ||
            currentH == 0.0) {
          // if already in a state, or dismissed
          return;
        } else {
          if (currentH > collapsedH) {
            // panel on upper half
            if (currentH >= ((collapsedH + expandedH) / 2)) {
              // panel currently above middle point
              dragVelocity = dragVelocity!.abs();
              toState = PanelState.expanded;
            } else {
              toState = PanelState.collapsed;
            }
          } else {
            // panel on lower half
            if (currentH >= ((closedH + collapsedH) / 2)) {
              // panel currently above middle point
              dragVelocity = dragVelocity!.abs();
              toState = PanelState.collapsed;
            } else {
              toState = PanelState.closed;
            }
          }
        }
      } else {
        if (dragVelocity! > 0) {
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
        } else if (dragVelocity! < 0) {
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
      case PanelState.dismissed:
        shouldPanelSnap = false;
        return;
        break;
    }

    if (to! < from!) {
      // flip if required
      double? _temp = from;
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
      double currentH = scrollPos!.metadata!.currentHeight;
      double closedH = scrollPos!.metadata!.closedHeight;
      double expandedH = scrollPos!.metadata!.expandedHeight;

      _PanelAnimation.clear();

      _PanelAnimation.animation = AnimationController(
        vsync: scrollPos!.context.vsync,
        lowerBound: from!,
        upperBound: to!,
      );

      void _tick() {
        scrollPos!.metadata!.currentHeight = _PanelAnimation.animation!.value;
        // set panel's position
      }

      _PanelAnimation.animation!.value = currentH;
      _PanelAnimation.animation!.addListener(_tick);

      if (scrollPos!.metadata!.totalHeight != 0.0 &&
          scrollPos!.metadata!.totalHeight != double.infinity &&
          dragVelocity != 0) {
        // set flingVelocity

        flingVelocity = (dragVelocity! /
            ((scrollPos!.metadata!.totalHeight * expandedH) -
                (scrollPos!.metadata!.totalHeight * closedH)));
      }

      // animate
      _PanelAnimation.isCleared = false;
      _PanelAnimation.animation!
          .fling(velocity: flingVelocity!)
          .whenCompleteOrCancel(() {});
    }
  }
}

void _scrollPanel(
  _PanelScrollPosition scrollPos, {
  required double velocity,
}) {
  final Simulation simulation = ClampingScrollSimulation(
    position: scrollPos.metadata!.currentHeight,
    velocity: velocity,
    tolerance: scrollPos.physics.tolerance,
  );

  _PanelAnimation.clear();

  _PanelAnimation.animation =
      AnimationController.unbounded(vsync: scrollPos.context.vsync);

  double lastDelta = 0;

  void _tick() {
    final double currentDelta = _PanelAnimation.animation!.value - lastDelta;

    lastDelta = _PanelAnimation.animation!.value;

    scrollPos.metadata!.addPixels(currentDelta, shouldMultiply: false);

    if ((velocity > 0 && scrollPos.metadata!.isExpanded) ||
        (velocity < 0 && scrollPos.metadata!.isClosed)) {
      // after dragging, if start or end reached
      velocity = _PanelAnimation.animation!.velocity +
          (scrollPos.physics.tolerance.velocity *
              _PanelAnimation.animation!.velocity.sign);

      _PanelAnimation.animation!.stop();
    }
  }

  _PanelAnimation.isCleared = false;
  _PanelAnimation.animation
    ?..addListener(_tick)
    ..animateWith(simulation).whenCompleteOrCancel(() {});
}

Future<Null> _setPanelPosition(
  _SlidingPanelState panel, {
  required double to,
  required Duration? duration,
  bool shouldClamp = true,
}) async {
  _PanelScrollPosition scrollPos = panel._scrollController!._scrollPosition!;

  if (shouldClamp)
    to = to._safeClamp(scrollPos.metadata!.closedHeight,
        scrollPos.metadata!.expandedHeight) as double;

  double from = scrollPos.metadata!.currentHeight;

  if (from != to) {
    // if the panel is not having same height as requested

    _PanelAnimation.clear();

    _PanelAnimation.animation = AnimationController(
      vsync: scrollPos.context.vsync,
    );

    void _tick() {
      scrollPos.metadata!.currentHeight = _PanelAnimation.animation!.value;
    }

    _PanelAnimation.animation!.value = scrollPos.metadata!.currentHeight;
    _PanelAnimation.animation!.addListener(_tick);

    _PanelAnimation.isCleared = false;

    await _PanelAnimation.animation!.animateTo(
      to,
      curve: panel.widget.curve,
      duration: duration,
    );
  }
}

/// returns how much amount of the body part should scroll
/// up in pixels when the panel slides.
double _getParallaxSlideAmount(_SlidingPanelState panel) {
  final double amount =
      panel.widget.parallaxSlideAmount._safeClamp(0.0, 1.0) as double;
  final metadata = panel._metadata!;

  double position = panel._controller
      .percentPosition(metadata.closedHeight, metadata.expandedHeight);

  double coverage = metadata.totalHeight * metadata.expandedHeight;

  double parallax = (-(position * coverage * amount));

  return (parallax.isNaN ? 0.0 : parallax);
}

/// returns amount of opacity the backdrop should
/// apply when panel slides.
double _getBackdropOpacityAmount(_SlidingPanelState panel) {
  if (panel.widget.backdropConfig.effectInCollapsedMode) {
    double opacity = (panel._controller.percentPosition(
            panel._metadata!.closedHeight, panel._metadata!.expandedHeight) *
        panel.widget.backdropConfig.opacity);

    return (opacity.isNaN ? 0.0 : opacity);
  } else {
    if (panel._controller.currentPosition > panel._metadata!.collapsedHeight) {
      return (panel._controller.percentPosition(
              panel._metadata!.collapsedHeight,
              panel._metadata!.expandedHeight) *
          panel.widget.backdropConfig.opacity);
    }
    return 0.0;
  }
}

/// returns amount of color the backdrop should
/// apply when panel slides.
Color? _getBackdropColor(_SlidingPanelState panel) {
  if (panel.widget.backdropConfig.draggableInClosed) {
    // If closedHeight is not 0.0 and still currently it is,
    // that's a dismissed panel. Don't allow dragging in it.
    if ((panel._metadata!.currentHeight == 0.0) &&
        (panel._metadata!.closedHeight != 0.0)) return null;
    return panel.widget.backdropConfig.shadowColor;
  }

  if (panel.widget.backdropConfig.effectInCollapsedMode) {
    if (panel._controller.percentPosition(
            panel._metadata!.closedHeight, panel._metadata!.expandedHeight) <=
        0.0) return null;

    return panel.widget.backdropConfig.shadowColor;
  } else {
    if (panel._controller.currentPosition > panel._metadata!.collapsedHeight) {
      return panel.widget.backdropConfig.shadowColor;
    }
    return null;
  }
}

/// returns amount of opacity to be applied to panel when sliding.
double _getPanelOpacity(_SlidingPanelState panel) {
  if (panel._metadata!.isTwoStatePanel ||
      (panel.widget.content.collapsedWidget.collapsedContent == null)) {
    return 1.0;
  }

  if (panel.widget.content.collapsedWidget.hideInExpandedOnly) {
    return panel._controller.percentPosition(
        panel._metadata!.collapsedHeight, panel._metadata!.expandedHeight);
  } else {
    return panel._controller.percentPosition(
        panel._metadata!.closedHeight, panel._metadata!.collapsedHeight);
  }
}

/// returns amount of opacity to be applied to collapsed widget when sliding.
double _getCollapsedOpacity(_SlidingPanelState panel) {
  return (1.0 - _getPanelOpacity(panel));
}

void _dragPanel(
  _SlidingPanelState panel, {
  double? delta,
  bool? shouldListScroll,
  bool? isGesture,
  bool? dragFromBody,
  VoidCallback? scrollContentSuper,
}) {
  if ((panel._controller.currentState == PanelState.closed) &&
      (panel.widget.panelClosedOptions.detachDragging)) return;

  if (isGesture!) {
    // drag from body
    if (!dragFromBody!) {
      return;
    }

    panel._metadata!._isBodyDrag.value = true;
  } else {
    panel._metadata!._isBodyDrag.value = false;
  }
  // natural drag

  if (!shouldListScroll! &&
      (!(panel._metadata!.isClosed || panel._metadata!.isExpanded) ||
          (panel._metadata!.isClosed && delta! < 0) ||
          (panel._metadata!.isExpanded && delta! > 0))) {
    if (panel._metadata!.isDraggable) {
      if (panel._metadata!.snapping == PanelSnapping.disabled) {
        // dont multiply, otherwise panel will change states too fast
        panel._metadata!.addPixels(-delta!, shouldMultiply: false);
      } else {
        // snapping is true

        panel._metadata!.addPixels(-delta!, shouldMultiply: true);
      }
    } else {
      scrollContentSuper!();
    }
  } else {
    scrollContentSuper!();
  }
}

void _onPanelDragEnd(_SlidingPanelState panel, double primaryVelocity) {
  if (panel._scrollController?._scrollPosition == null) {
    return;
  } else {
    if (panel._metadata!.isDraggable &&
        panel.widget.backdropConfig.dragFromBody) {
      if (panel._metadata!.snapping == PanelSnapping.disabled) {
        // no panel snapping, just scroll the panel

        _scrollPanel(
          panel._scrollController!._scrollPosition!,
          velocity: primaryVelocity,
        );
      } else {
        // snap the panel

        double percent = ((panel._metadata!.totalHeight *
                panel._metadata!.snappingTriggerPercentage) /
            100);

        percent = percent._safeClamp(0.0, 750.0) as double;

        if (percent > 0.0) {
          if (primaryVelocity.abs() <= percent) {
            _scrollPanel(
              panel._scrollController!._scrollPosition!,
              velocity: primaryVelocity,
            );
            return;
          }
        }

        if ((primaryVelocity.abs() == 0.0) &&
            (panel._metadata!.snapping == PanelSnapping.forced)) {
          if (primaryVelocity.isNegative)
            primaryVelocity = -0.1;
          else
            primaryVelocity = 0.1;
        }

        _PanelSnapData snapData = _PanelSnapData(
          scrollPos: panel._scrollController!._scrollPosition,
          dragVelocity: primaryVelocity,
          snapping: panel.widget.snapping,
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
  if (panel._metadata!.isTwoStatePanel) {
    if (panel._metadata!.currentHeight > panel._metadata!.closedHeight &&
        panel.widget.backdropConfig.closeOnTap) panel._controller.close();
  } else {
    if (panel.widget.backdropConfig.effectInCollapsedMode) {
      if (panel._metadata!.currentHeight > panel._metadata!.collapsedHeight &&
          panel.widget.backdropConfig.collapseOnTap) {
        panel._controller.collapse();
        return;
      }
      if (panel._metadata!.currentHeight > panel._metadata!.closedHeight &&
          panel.widget.backdropConfig.closeOnTap) panel._controller.close();
    } else {
      if (panel._metadata!.currentHeight > panel._metadata!.collapsedHeight &&
          panel.widget.backdropConfig.collapseOnTap)
        panel._controller.collapse();
    }
  }
}

const Map<BackPressBehavior, BackPressBehavior>
    _twoStateValidBackPressBehavior = {
  BackPressBehavior.COLLAPSE_PERSIST: BackPressBehavior.PERSIST,
  BackPressBehavior.COLLAPSE_POP: BackPressBehavior.POP,
  BackPressBehavior.COLLAPSE_CLOSE_PERSIST: BackPressBehavior.CLOSE_PERSIST,
  BackPressBehavior.COLLAPSE_CLOSE_POP: BackPressBehavior.CLOSE_POP,
};

Future<bool> _decidePop(_SlidingPanelState panel) async {
  BackPressBehavior? behavior = panel.widget.backPressBehavior;
  PanelPoppingBehavior poppingBehavior = panel.widget.panelPoppingBehavior;

  if (panel._metadata!.isTwoStatePanel) {
    if (_twoStateValidBackPressBehavior.containsKey(behavior)) {
      // invalid behavior given, convert to a valid one.
      behavior = _twoStateValidBackPressBehavior[behavior];
    }
  }

  if (behavior == BackPressBehavior.POP) {
    if (panel.isModal) await panel._controller.dismiss();
    return true;
  } else if (behavior == BackPressBehavior.PERSIST) {
    return false;
  } else {
    //
    double currentHeight = panel._metadata!.currentHeight;
    double closedHeight = panel._metadata!.closedHeight;
    double collapsedHeight = panel._metadata!.collapsedHeight;

    if (behavior == BackPressBehavior.COLLAPSE_PERSIST) {
      if (currentHeight > collapsedHeight) {
        await panel._controller.collapse();
      }
      return false;
    } else if (behavior == BackPressBehavior.COLLAPSE_POP) {
      if (currentHeight > collapsedHeight) {
        await panel._controller.collapse();

        if (poppingBehavior == PanelPoppingBehavior.POP_IMMEDIATELY) {
          if (panel.isModal) await panel._controller.dismiss();

          return true;
        }
        return false;
      }
      if (panel.isModal) await panel._controller.dismiss();
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
          if (panel.isModal) await panel._controller.dismiss();

          return true;
        }
        return false;
      }
      if (panel.isModal) await panel._controller.dismiss();
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
      if (currentHeight == closedHeight) {
        if (panel.isModal) await panel._controller.dismiss();
        return true;
      }
      if (currentHeight > collapsedHeight) {
        await panel._controller.collapse();
        return false;
      }
      if (currentHeight > closedHeight && currentHeight <= collapsedHeight) {
        await panel._controller.close();

        if (poppingBehavior == PanelPoppingBehavior.POP_IMMEDIATELY) {
          if (panel.isModal) await panel._controller.dismiss();

          return true;
        }
      }

      return false;
    } else {
      return true;
    }
  }
}

InitialPanelState _decideInitStateForModal({required _PanelMetadata metadata}) {
  InitialPanelState decidedState = metadata.initialPanelState;

  if (decidedState == InitialPanelState.expanded) {
    // dont think about expanded
    return InitialPanelState.expanded;
  }

  if (decidedState == InitialPanelState.dismissed) {
    // dismissed is always considered as closed
    decidedState = InitialPanelState.closed;
  }

  if (metadata.isTwoStatePanel) {
    // handle cases for a two-state panel
    if (decidedState == InitialPanelState.closed) {
      if (metadata.closedHeight == 0.0) {
        // because it doesn't show anything
        return InitialPanelState.expanded;
      }
      // something can be shown in closed mode
      return InitialPanelState.closed;
    }
    if (decidedState == InitialPanelState.collapsed) {
      // two-state panels dont collapse
      return InitialPanelState.expanded;
    }
    // it should expand now
    return InitialPanelState.expanded;
  } else {
    if (decidedState == InitialPanelState.closed) {
      if (metadata.closedHeight == 0.0) {
        // because it doesn't show anything
        // just assume, it should collapse
        decidedState = InitialPanelState.collapsed;
      }
      // something can be shown in closed mode
      return InitialPanelState.closed;
    }
    if (decidedState == InitialPanelState.collapsed) {
      // collapse only if PanelCollapsedWidget given
      if (metadata.collapsedHeight == 0.0) {
        return InitialPanelState.expanded;
      }
      return InitialPanelState.collapsed;
    }
    // nothing left to check
    return InitialPanelState.expanded;
  }
}

extension _SafeClamping on num {
  /// Same as [num.clamp], but first argument doesn't
  /// need to be <= second number.
  num _safeClamp(num num1, num num2) =>
      num1 > num2 ? clamp(num2, num1) : clamp(num1, num2);
}
