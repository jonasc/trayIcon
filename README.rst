========
trayIcon
========

A general purpose, lightweight tray notification program. It reads from
standard input and updates the tray icon accordingly.

Supported commands:

- icon <file>: sets the icon from file
- tooltip <text>: sets the tooltip text
- hide: hides the icon altogether
- reload: reload the icon

If trayIcon reads a line not beginning with one of the four keywords it treats
it as if the line had "tooltip " before it and sets the complete line as the
tooltip.
