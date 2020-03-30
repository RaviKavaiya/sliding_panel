## [1.0.3] - March 30, 2020

- **New:** `useSafeArea` parameter, that allows you to wrap the panel inside the `SafeArea` parameter, in order to avoid notch and status bar of device!

- **Fix:** Opening/closing a modal panel several times caused the app to freeze, making it unable to interact with either the panel or the content. [#12](https://github.com/RaviKavaiya/sliding_panel/issues/12)

- **Fix:** An example caused height overflow.

- **Fix:** The panel did not remember previous position when device was rotated. Now, it remembers and animates correctly. Also, doesn't send duplicate events to listeners when such situation arises. Though this feature works for all types of panels, this is more effective when using `autoSizing`.

- **Deprecation:** The parameter `allowedDraggingTill` is now deprecated and should be avoided. It has some flaws that cause problems like panel not draggable, content not scrollable, etc. These issues won't be fixed and this feature may be removed in future releases. Apologies for that.

## [1.0.2] - March 25, 2020

- Fixed an issue that prevented the `headerContent` to take whole available Header width even if the `leading` was not specified. [#9](https://github.com/RaviKavaiya/sliding_panel/issues/9)

## [1.0.1] - January 24, 2020

`sliding_panel`'s first 2020 update comes with a bunch of changes, fixes and enhancements!

For migration to this version, visit the [**Migration guide**](https://github.com/RaviKavaiya/sliding_panel/wiki/Migration-guide).

### Dismissible panel:
- Now, the panel can be dismissed. Means, it can work as **4-state** panel, namely `expanded, collapsed, closed and dismissed`.
- As a part of this change, `PanelController.dismiss()`, `PanelState.dismissed` and `InitialPanelState.dismissed` were added.
- *This works for two-state panels also!*

***

### Modal panel:
- Use `SlidingPanel` *exactly* same as `showModalBottomSheet()`, by calling `showModalSlidingPanel()`. It pushes a new route, waits for a `Navigator.of(context).pop()`...
And guess what, you can also send results back, same as you did in `showModalBottomSheet()`!!!

***

### `PanelHeader` changes and improvements:
- PanelHeader is now rendered as a `SliverAppBar`! It has its own advantages.
- PanelHeader now also accepts a parameter: `options`, an instance of `PanelHeaderOptions`, specially meant to customize the header.

***

### `panelContent` changes:
- **Breaking change:** `PanelContent.panelContent` now only accepts a `List<Widget>`. To get access to `ScrollController`, grab that by `PanelController.scrollData.scrollController`.
- **Breaking change:** As part of above change, you DON'T have to attach the `ScrollController` yourself to any Widget. It is now done **automatically**.
- `panelContent` is now *cached*, so that it doesn't require parent to provide the same content twice due to `PanelAutoSizing`.

***

- **Breaking change:** `snapPanel` was removed. Instead, a new enum called `PanelSnapping` is introduced. (The parameter is now called `snapping`).
- **Breaking change:** In `PanelDecoration` , the `backgroundColor` defaults to the app's canvas color (i.e., `Theme.of(context).canvasColor`).
- **Breaking change:** The `Duration` is now calculated from `PanelState.dismissed` to `PanelState.expanded` instead of from `PanelState.closed` to `PanelState.expanded`.
- **Breaking change:** The `PanelController.popWithResult()` will `dismiss` the panel, instead of `close`. To avoid this, set `shouldCloseOnly` to `true`. (This also applies to a newly introduced `PanelController.popWithThrowResult()`).


- **Change:** Now, the PanelController doesn't throw error when it is re-assigned to different SlidingPanel. It simply ignores old one and points to new one.
- **Change:** `PanelCollapsedWidget` is now shown **below** the `PanelHeaderWidget`.
- **Refactor:** The code in `panel.dart` is refactored a lot. Now, it should be easy to understand.

***

- **Fix + improved:** `PanelAutoSizing` related bugs fixed (they were many), unnecessary calculations removed.
- **Fix:** For calculating various heights, 'Screen height (and width)' was used. Now, available 'Constrained height' is used, for more accurate calculation.
- **Fix:** A bug fixed that caused `double.infinity` or `double.NaN` when duration was being calculated.
- **Fix:** A bug fixed that caused `double.NaN` when backdrop opacity was being calculated.
- **Fix:** A bug fixed that caused `double.NaN` when panel's expanded height was being calculated.
- **Fix:** `Disposed with active ticker` bug fixed. (Was caused when panel is animating and route is popped.)
- **Fix:** The panel now remembers the position when device's resolution / orientation changes.
- **Fix:** A bug with `BackPressBehavior.COLLAPSE_CLOSE_POP` fixed.

***
 
- **New:** A whole new `Sliver` based layout, where the `PanelHeaderWidget` is a `SliverAppBar` and contents are inside `SliverList`.
- **New:** Call `rebuild()` on PanelController to recalculate the PanelSize again.
- **New:** New way to notify changes to the parent, using `throwResult()` and `popWithThrowResult()` which give results to `onThrowResult` callback.
- **New:** A new parameter called `useMinExpanded` available in `PanelAutoSizing`, so that `PanelSize.expandedHeight` also gets considered when calculating the height.
- **New:** A new parameter called `panelClosedOptions` available. Don't forget to check it out and decide what happens when the panel is closed.
- **New:** Now `PanelController.sizeData` gives two additional properties: `constrainedHeight` and `constrainedWidth`.
- **New:** New parameter: `animatedAppearing`. If true, the panel animates to `initialState`, initially.
- **New:** New parameter: `dragMultiplier`. Now decide the amount of the panel slides when user drags the panel.




## [0.7.0] - November 08, 2019

This release introduces below new features. There is no breaking change.

- **New:** Now you can specify panel's maximum width under different device orientations using `PanelMaxWidth` parameter.
- **New:** A new class `PanelFooterWidget` is added, so that you can give your panel a consistent bottom widget!
- **New:** A new class `PanelScrollData` is added, which is helpful to get current scrolling position of the panel.



## [0.5.0] - October 06, 2019

This package release introduces some API changes (majorly breaking changes) and a new underlying mechanism. Below are some of the changes. For complete list of changes and migration to this version, visit the [**Migration guide**](https://github.com/RaviKavaiya/sliding_panel/wiki/Migration-guide).

- **New:** Now specify what happens when user presses back button, using `BackPressBehavior` and `PanelPoppingBehavior`.
- **New:** Now you can specify the limit of user's dragging the panel, using `allowedDraggingTill` parameter.
- **New:** Now you can provide `Scrollable` element inside `panelContent`, so that the panel can be dragged and scrolled at the same time.
- **New:** `snappingTriggerPercentage` added, so that you have more control over panel snapping.
- **New:** A new class `PanelSizeData` is added (accessed from `PanelController`), which helps to get updated `PanelSize` parameters of this panel.
- When using `PanelAutoSizing`, you can not change values of `PanelSize` at runtime.
- `PanelController` also contains some new and breaking changes.
- `onPanelExpanded`, `onPanelCollapsed` and `onPanelClosed` are all combined in single : `onPanelStateChanged`.
- **Breaking change:** The `headerContent` is now moved to a separate `Widget` called `PanelHeaderWidget`.
- **Breaking change:** For `panelContent`, a new `typedef` is introduced, called `PanelBodyBuilder`.
- **Breaking change:** `PanelSize` class no longer accepts values in *pixels*. Only percentage values can be given from now.
- **New and Breaking change:** The `PanelState` : `animating` works in adifferent way and a new state `indefinite` added.



## [0.2.0] - September 13, 2019

Now, the package is updated with some improvements as below:

- The code is separated in multiple files for readability.
- Almost all the functions of PanelController return a `Future`, so that you can do some action afterwards.
- When a panel is visible, you can change the panel's height runtime and it will animate. (This feature is not stable).
- Now you can provide the height of the panel in percentage of the screen also.
- A persistent header widget can be provided.
- The panel's height can be automatically determined depending on content! (see `PanelAutoSizing` class for this).



## [0.1.0] - September 07, 2019

The initial release of the sliding_panel package. This includes below functions to the developers:

- A highly customisable Sliding panel
- Though many options available, it is made as easy as possible to tweak look and feel of the panel
- A panel can work as Three-state panel or traditional Two-state panel
- An easy to use PanelController, which helps getting current panel state and modifying its current state
- PanelController allows to animate the panel to arbitrary position
- Various callbacks that help getting current state of the panel
- Parallax and Backdrop effects on the panel
- Provide InitialPanelState property to decide how the panel is displayed initially 
- Also responds to user gestures
- Panel can return arbitrary values back to the parent
