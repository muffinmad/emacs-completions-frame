[![License GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/copyleft/gpl.html)
[![MELPA](https://melpa.org/packages/completions-frame-badge.svg)](https://melpa.org/#/completions-frame)

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

## Company

This package is mainly for those who prefer built-in `completion-at-point` for completions. Happy [company-mode](http://company-mode.github.io) users can take a look at [company-box](https://github.com/sebastiencs/company-box), [company-posframe](https://github.com/tumashu/company-posframe), etc. But `company-mode` users still may find this package useful: minibuffer completions are also shown in the child frame! Like this:

<p align="center">
  <img src="https://raw.githubusercontent.com/muffinmad/emacs-completions-frame/master/screenshots/eval-completions.png" width="640">
</p>

## Installation and usage

`completions-frame` is available on [MELPA](https://melpa.org/#/completions-frame).

Alternatively, you can download `completions-frame.el` and run:

<kbd>M-x</kbd> `package-install-file` <kbd>RET</kbd> `<path-to-completions-frame-el>` <kbd>RET</kbd>

<kbd>M-x</kbd> `completions-frame-mode` <kbd>RET</kbd>
