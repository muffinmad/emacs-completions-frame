# emacs-completions-frame
Show \*Completions\* buffer in child frame.

Basically it's the function for `display-buffer-alist` with some child frame's position and size manipulation:
- Completions frame placed near the point;
- It is placed above or below point depending on completions frame height and available space around the point;
- Initial frame width is set to 1 so completion list is arranged in single column. This behavior can be configured via `completions-frame-width` variable.

## How it looks like

<p align="center">
  <img src="https://raw.githubusercontent.com/muffinmad/emacs-completions-frame/master/screenshots/completions-frame.png" width="640">
</p>

## Installation and usage

Download `completions-frame.el` and run:

<kbd>M-x</kbd> `package-install-file` <kbd>RET</kbd> `<path-to-completions-frame-el>` <kbd>RET</kbd>

<kbd>M-x</kbd> `completions-frame-mode` <kbd>RET</kbd>
