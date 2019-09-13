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
