## [0.7.0] - October 06, 2019

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
