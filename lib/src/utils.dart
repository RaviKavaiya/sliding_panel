part of sliding_panel;

void _animationListener(_SlidingPanelState panel, {bool isCollapsedAnimation}) {
  if (panel.widget.onPanelSlide != null) {
    if (panel._isTwoStatePanel) {
      panel.widget.onPanelSlide(panel._animFull.value);
    } else {
      if (isCollapsedAnimation) {
        panel.widget.onPanelSlide(panel._animCollapsed.value);
      } else {
        panel.widget.onPanelSlide(panel._animExpanded.value);
      }
    }
  }

  if (panel.widget.onPanelCollapsed != null) {
    if (!(panel._isTwoStatePanel)) {
      if ((!panel._animExpanded.isAnimating) &&
          (!panel._animCollapsed.isAnimating)) {
        if (panel._animCollapsed.value == 1.0 &&
            panel._animExpanded.value == 1.0) {
          panel.widget.onPanelCollapsed();
        }
      }
    }
  }

  if (panel.widget.onPanelClosed != null) {
    if (panel._isTwoStatePanel) {
      if (!(panel._animFull.isAnimating)) {
        if (panel._animFull.value == 0.0) {
          panel.widget.onPanelClosed();
        }
      }
    } else {
      if ((!panel._animExpanded.isAnimating) &&
          (!panel._animCollapsed.isAnimating)) {
        if (panel._animCollapsed.value == 0.0 &&
            panel._animExpanded.value == 1.0) {
          panel.widget.onPanelClosed();
        }
      }
    }
  }

  if (panel.widget.onPanelExpanded != null) {
    if (panel._isTwoStatePanel) {
      if (!(panel._animFull.isAnimating)) {
        if (panel._animFull.value == 1.0) {
          panel.widget.onPanelExpanded();
        }
      }
    } else {
      if ((!panel._animExpanded.isAnimating) &&
          (!panel._animCollapsed.isAnimating)) {
        if (panel._animCollapsed.value == 1.0 &&
            panel._animExpanded.value == 2.0) {
          panel.widget.onPanelExpanded();
        }
      }
    }
  }
}

Duration _extractCollapsedDuration(_SlidingPanelState panel) {
  double diffTotal = panel._expandedHeight - panel._closedHeight;
  double diffCollapsed = panel._collapsedHeight - panel._closedHeight;

  int dur = (((diffCollapsed * panel._duration.inMilliseconds) / diffTotal)
      .floor()
      .toInt());

  return Duration(milliseconds: (dur.abs()));
}

Duration _extractExpandedDuration(_SlidingPanelState panel) {
  double diffTotal = panel._expandedHeight - panel._closedHeight;
  double diffExpanded = panel._expandedHeight - panel._collapsedHeight;

  int dur = (((diffExpanded * panel._duration.inMilliseconds) / diffTotal)
      .floor()
      .toInt());

  return Duration(milliseconds: (dur.abs()));
}

double _getParallaxSlideAmount(_SlidingPanelState panel) {
  if (panel.widget.parallaxSlideAmount > 0.0 &&
      panel.widget.parallaxSlideAmount <= 1.0) {
    if (panel._isTwoStatePanel) {
      return (-((panel._animFull.value) *
          (panel._expandedHeight - panel._closedHeight) *
          panel.widget.parallaxSlideAmount));
    } else {
      return (-((((panel._animCollapsed.value) +
                  (panel._animExpanded.value - 1.0)) /
              2) *
          (panel._expandedHeight - panel._closedHeight) *
          panel.widget.parallaxSlideAmount));
    }
  }
  return 0;
}

double _getExpandedCurrentHeight(_SlidingPanelState panel) {
  return ((panel._animExpanded.value - 1.0) *
          (panel._expandedHeight - panel._collapsedHeight) +
      panel._collapsedHeight);
}

double _getCollapsedCurrentHeight(_SlidingPanelState panel) {
  return (panel._animCollapsed.value *
          (panel._collapsedHeight - panel._closedHeight) +
      panel._closedHeight);
}

double _getTwoStateHeight(_SlidingPanelState panel) {
  return (panel._animFull.value *
          (panel._expandedHeight - panel._closedHeight) +
      panel._closedHeight);
}

double _getBackdropOpacityAmount(_SlidingPanelState panel) {
  if (panel._isTwoStatePanel) {
    return ((panel._animFull.value) * panel.widget.backdropConfig.opacity);
  } else {
    double amount1 =
        ((((panel._animCollapsed.value) + (panel._animExpanded.value - 1.0)) /
                2) *
            panel.widget.backdropConfig.opacity);

    double amount2 = ((((panel._animExpanded.value - 1.0)) / 2) *
        panel.widget.backdropConfig.opacity);

    if (panel.widget.backdropConfig.effectInCollapsedMode) {
      return amount1;
    } else {
      if (panel._animExpanded.value > 1.0) {
        return amount2;
      } else {
        return 0.0;
      }
    }
  }
}

Color _getBackdropColor(_SlidingPanelState panel) {
  if (panel._isTwoStatePanel) {
    if (panel._animFull.value == 0.0)
      return null;
    else
      return panel.widget.backdropConfig.shadowColor;
  } else {
    if (panel.widget.backdropConfig.effectInCollapsedMode) {
      if (panel._animExpanded.value == 1.0 && panel._animCollapsed.value == 0.0)
        return null;
      else
        return panel.widget.backdropConfig.shadowColor;
    } else {
      if (panel._animExpanded.value > 1.0)
        return panel.widget.backdropConfig.shadowColor;
      else
        return null;
    }
  }
}

Future<Null> _closePanel(_SlidingPanelState panel) async {
  if (panel._isTwoStatePanel) {
    // Just directly close the panel
    if (panel._animFull.value != 0.0) {
      // Panel is not closed
      await panel._animFull.animateTo(0.0, curve: panel.widget.curve);
    }
  } else {
    if (panel._animExpanded.value == 2.0) {
      // Panel is expanded, first collapse it, then close
      if (!(panel._animExpanded.isAnimating)) {
        await panel._animExpanded.animateTo(1.0, curve: Curves.linear);
        await panel._animCollapsed.animateTo(0.0, curve: Curves.linear);
      }
    } else {
      // Panel is collapsed, just close it
      if (!(panel._animCollapsed.isAnimating)) {
        await panel._animCollapsed.animateTo(0.0, curve: panel.widget.curve);
      }
    }
  }
}

Future<Null> _collapsePanel(_SlidingPanelState panel) async {
  if (!(panel._isTwoStatePanel)) {
    // Two state panels don't collapse
    if (panel._animCollapsed.value == 1.0) {
      // Panel is already collapsed, maybe expanded
      if ((!panel._animExpanded.isAnimating) &&
          (panel._animExpanded.value != 1.0)) {
        // Panel is expanded, collapse it
        await panel._animExpanded.animateTo(1.0, curve: panel.widget.curve);
      }
    } else {
      // Panel is closed, collapse it
      if (!(panel._animCollapsed.isAnimating)) {
        await panel._animCollapsed.animateTo(1.0, curve: panel.widget.curve);

        if ((!panel._animExpanded.isAnimating) &&
            (panel._animExpanded.value != 1.0)) {
          // if, (rarely) panel is expanded, collapse it
          panel._animExpanded.value = 1.0;
        }
      }
    }
  }
}

Future<Null> _expandPanel(_SlidingPanelState panel) async {
  if (panel._isTwoStatePanel) {
    // Just directly expand the panel
    if (panel._animFull.value != 1.0) {
      // Panel is not expanded
      await panel._animFull.animateTo(1.0, curve: panel.widget.curve);
    }
  } else {
    if (panel._animCollapsed.value != 1.0) {
      // Panel is closed, first collapse it, then expand
      if (!(panel._animCollapsed.isAnimating)) {
        await panel._animCollapsed.animateTo(1.0, curve: Curves.linear);
        await panel._animExpanded.animateTo(2.0, curve: Curves.linear);
      }
    } else {
      // Panel is already collapsed, just expand it
      if (!(panel._animExpanded.isAnimating)) {
        await panel._animExpanded.animateTo(2.0, curve: panel.widget.curve);
      }
    }
  }
}

double _getCurrentPanelPosition(_SlidingPanelState panel) {
  if (panel._isTwoStatePanel) return panel._animFull.value;
  return panel._animExpanded.value > 1.0
      ? panel._animExpanded.value
      : panel._animCollapsed.value;
}

PanelState _getCurrentPanelState(_SlidingPanelState panel) {
  if (panel._isTwoStatePanel) {
    if (panel._animFull.isAnimating) return PanelState.animating;

    if (panel._animFull.value == 0.0) return PanelState.closed;

    if (panel._animFull.value == 1.0) return PanelState.expanded;
  } else {
    if (panel._animCollapsed.isAnimating || panel._animExpanded.isAnimating)
      return PanelState.animating;
    else {
      if (panel._animCollapsed.value == 0.0 && panel._animExpanded.value == 1.0)
        return PanelState.closed;

      if (panel._animCollapsed.value == 1.0 && panel._animExpanded.value == 1.0)
        return PanelState.collapsed;

      if (panel._animCollapsed.value == 1.0 && panel._animExpanded.value == 2.0)
        return PanelState.expanded;
    }
  }
  return PanelState.closed;
}

void _handleBackdropTap(_SlidingPanelState panel) {
  if (panel._isTwoStatePanel) {
    if (panel._animFull.value > 0.0 && panel.widget.backdropConfig.closeOnTap) {
      _closePanel(panel);
    }
  } else {
    if (panel.widget.backdropConfig.effectInCollapsedMode) {
      if (panel._animExpanded.value > 1.0 &&
          panel.widget.backdropConfig.collapseOnTap)
        _collapsePanel(panel);
      else if (panel.widget.backdropConfig.closeOnTap) _closePanel(panel);
    } else {
      if (panel._animExpanded.value > 1.0 &&
          panel.widget.backdropConfig.collapseOnTap) _collapsePanel(panel);
    }
  }
}

void _onPanelDrag(_SlidingPanelState panel, DragUpdateDetails details) {
  if (panel._isTwoStatePanel) {
    if (details.primaryDelta != 0) {
      if (details.primaryDelta < 0) {
        // swipe upside
        if (panel._animFull.value != 1.0) {
          // drag until fully expanded
          panel._animFull.value -= details.primaryDelta /
              (panel._expandedHeight - panel._closedHeight);
        }
      } else {
        // swipe downside
        if (panel._animFull.value != 0.0) {
          // drag until fully closed
          panel._animFull.value -= details.primaryDelta /
              (panel._expandedHeight - panel._closedHeight);
        }
      }
    }
  } else {
    if (details.primaryDelta != 0) {
      // actually swiped
      if (details.primaryDelta < 0) {
        // swipe upside
        if (panel._animExpanded.value != 2.0) {
          // panel is not fully expanded
          // otherwise no updation needed
          if (panel._animCollapsed.value < 1.0) {
            // panel is not open fully in collapsed mode
            panel._animCollapsed.value -= details.primaryDelta /
                (panel._collapsedHeight - panel._closedHeight);
          } else {
            // panel collapsed, now expand it
            panel._animExpanded.value -= details.primaryDelta /
                (panel._expandedHeight - panel._collapsedHeight);
          }
        }
      } else {
        // swipe downside
        if (panel._animCollapsed.value != 0.0) {
          // panel is not fully closed
          // otherwise no updation needed
          if (panel._animExpanded.value > 1.0) {
            // panel is not closed fully in expanded mode
            panel._animExpanded.value -= details.primaryDelta /
                (panel._expandedHeight - panel._collapsedHeight);
          } else {
            // panel collapsed, now close it
            panel._animCollapsed.value -= details.primaryDelta /
                (panel._collapsedHeight - panel._closedHeight);
          }
        }
      }
    }
  }
}

void _onPanelDragEnd(_SlidingPanelState panel, DragEndDetails details) {
  int minFlingVelocityNeeded = 300;

  if (panel._isTwoStatePanel) {
    // don't do anything if panel is animating
    if (panel._animFull.isAnimating) return;

    if (details.velocity.pixelsPerSecond.dy.abs() >= minFlingVelocityNeeded) {
      // swipe speed more than desired
      double visualVelocity = -details.velocity.pixelsPerSecond.dy /
          (panel._expandedHeight - panel._closedHeight);

      if (panel.widget.snapPanel) {
        panel._animFull.fling(velocity: visualVelocity);
      } else {
        panel._animFull.animateTo(panel._animFull.value + visualVelocity * 0.16,
            curve: panel.widget.curve);
      }
    } else {
      if (panel.widget.snapPanel) {
        if (panel._animFull.value > 0.5)
          _expandPanel(panel);
        else
          _closePanel(panel);
      }
    }
  } else {
    // don't do anything if panel is animating
    if (panel._animCollapsed.isAnimating || panel._animExpanded.isAnimating)
      return;

    if (details.velocity.pixelsPerSecond.dy.abs() >= minFlingVelocityNeeded) {
      // swipe speed more than desired

      double visualVelocity;

      if (panel._animExpanded.value > 1.0 && panel._animExpanded.value < 2.0) {
        // expanded state needs update
        visualVelocity = -details.velocity.pixelsPerSecond.dy /
            (panel._expandedHeight - panel._collapsedHeight);
      } else {
        // collapsed state needs update
        visualVelocity = -details.velocity.pixelsPerSecond.dy /
            (panel._collapsedHeight - panel._closedHeight);
      }

      if (panel.widget.snapPanel) {
        if (panel._animExpanded.value > 1.0 &&
            panel._animExpanded.value < 2.0) {
          panel._animExpanded.fling(velocity: visualVelocity);
        } else {
          panel._animCollapsed.fling(velocity: visualVelocity);
        }
      } else {
        if (panel._animExpanded.value > 1.0 &&
            panel._animExpanded.value < 2.0) {
          panel._animExpanded.animateTo(
              panel._animExpanded.value + visualVelocity * 0.16,
              curve: panel.widget.curve);
        } else {
          panel._animCollapsed.animateTo(
              panel._animCollapsed.value + visualVelocity * 0.16,
              curve: panel.widget.curve);
        }
      }
    } else {
      if (panel.widget.snapPanel) {
        if (((panel._animCollapsed.value == 0.0) ||
            (panel._animCollapsed.value == 1.0))) {
          // Panel is either fully collapsed or fully closed, so just check about expansion
          if ((panel._animExpanded.value > 1.5) &&
              (panel._animExpanded.value < 2.0)) {
            // swiped more than half of expanded panel, but not expanded fully
            _expandPanel(panel);
          } else if ((panel._animExpanded.value <= 1.5) &&
              (panel._animExpanded.value > 1.0)) {
            // swiped less than half of expanded panel, but not collapsed fully
            _collapsePanel(panel);
          }
        } else {
          // Panel needs to be either closed or collapsed
          if ((panel._animCollapsed.value > 0.5) &&
              (panel._animCollapsed.value < 1.0)) {
            // swiped more than half of collapsed panel, but not collapsed fully
            _collapsePanel(panel);
          } else if ((panel._animCollapsed.value <= 0.5) &&
              (panel._animCollapsed.value > 0.0)) {
            // swiped less than half of collapsed panel, but not closed fully
            _closePanel(panel);
          }
        }
      }
    }
  }
}
