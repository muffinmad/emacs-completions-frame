;;; completions-frame.el --- Show completions in child frame -*- lexical-binding: t -*-

;; Copyright (C) 2020 Andrii Kolomoiets

;; Author: Andrii Kolomoiets <andreyk.mad@gmail.com>
;; Keywords: frames
;; URL: https://github.com/muffinmad/emacs-completions-frame
;; Package-Version: 1.0
;; Package-Requires: ((emacs "26.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Show completions in child frame.

;;; Code:

(defgroup completions-frame nil
  "Show completions in child frame."
  :group 'completion)

(defcustom completions-frame-color-shift-step 27
  "Shift each of RGB channels of background color by this value.
Background color is \"moved\" towards foreground color of selected frame
to determine background color of completions frame."
  :type 'integer)

(defcustom completions-frame-focus 'original
  "Which frame should take focus once completions frame is shown."
  :type '(choice (const :tag "Do nothing" nil)
                 (const :tag "Select completions frame" completions)
                 (const :tag "Select original frame" original)))

(defvar completions-frame-frame nil)

(defun completions-frame--shift-color (from to &optional by)
  "Move color FROM towards TO by BY.  If BY is ommited, `mini-frame-color-shift-step' is used."
  (let ((f (ash from -8))
        (by (or by completions-frame-color-shift-step)))
    (cond
     ((> from to) (- f by))
     ((< from to) (+ f by))
     (t f))))

(defun completions-frame-get-background-color (&optional frame)
  "Calculate background color for minibuffer frame from FRAME."
  (let* ((params (frame-parameters frame))
         (bg (color-values (alist-get 'background-color params)))
         (fg (color-values (alist-get 'foreground-color params))))
    (format "#%02x%02x%02x"
            (completions-frame--shift-color (car bg) (car fg))
            (completions-frame--shift-color (cadr bg) (cadr fg))
            (completions-frame--shift-color (caddr bg) (caddr fg)))))

(defun completions-frame-hide (&optional frame force)
  "Call `make-frame-invisible' with FRAME and FORCE and FRAME's parent frame."
  (make-frame-invisible frame force)
  (select-frame-set-input-focus (frame-parameter frame 'parent-frame)))

(defun completions-frame-setup ()
  "Completion setup hook.  Set completions frame size and position."
  (when (and (frame-live-p completions-frame-frame)
             (frame-visible-p completions-frame-frame))
    (let* ((comp-window (frame-selected-window completions-frame-frame))
           (host-frame (frame-parameter completions-frame-frame 'parent-frame))
           (host-window (frame-selected-window host-frame))
           (point-pos (pos-visible-in-window-p (window-point host-window) host-window t))
           (host-edges (window-edges host-window nil nil t))
           (host-frame-w (frame-inner-width host-frame))
           (host-frame-h (frame-inner-height host-frame))
           (comp-edges (window-edges comp-window t nil t))
           (comp-border (frame-internal-border-width completions-frame-frame))
           (comp-left (frame-parameter completions-frame-frame 'left))
           (comp-size (window-text-pixel-size comp-window t t host-frame-w nil t))
           (comp-w (car comp-size))
           (comp-h (+ comp-border
                      (cdr comp-size)))
           (point-y (+ (cadr point-pos)
                       (cadr host-edges)))
           (point-yb (+ point-y (frame-char-height)))
           (avail-top point-y)
           (avail-bot (- host-frame-h point-yb))
           (ch (min comp-h (max avail-top avail-bot)))
           (cw (min comp-w host-frame-w))
           (place-bottom (<= ch avail-bot))
           (ct (max 0
                    (if place-bottom
                        point-yb
                      (- point-y ch))))
           (ch (- ch (* (if place-bottom 1 2) comp-border)))
           (left (cond
                  ((> (+ cw (- (caddr comp-edges) (car comp-edges))) host-frame-w) 0)
                  ((> (+ comp-left (+ cw (- (cadr comp-edges) (car comp-edges)))) host-frame-w) -1)
                  (t comp-left))))
      (modify-frame-parameters
       completions-frame-frame
       `((top . ,ct)
         (left . ,left)
         (width . ,(if (> (+ cw (- (caddr comp-edges) (car comp-edges)))
                          host-frame-w)
                       1.0
                     `(text-pixels . ,cw)))
         (height . (text-pixels . ,ch))))
      (when completions-frame-focus
        (select-frame-set-input-focus
         (if (eq completions-frame-focus 'completions)
             completions-frame-frame
           host-frame))))))

(defun completions-frame-display (buffer alist)
  "Display completions BUFFER in child frame.
Create frame if needed and set initial frame parameters.
ALIST is passed to `window--display-buffer'"
  (let* ((parent-frame-parameters `((parent-frame . ,(selected-frame))))
         (show-parameters `((height . 1)
                            (width . 1)
                            (background-color . ,(completions-frame-get-background-color)))))
    (if (frame-live-p completions-frame-frame)
        (modify-frame-parameters completions-frame-frame parent-frame-parameters)
      (setq completions-frame-frame
            (make-frame (append '((visibility . nil)
                                  (auto-hide-function . completions-frame-hide)
                                  (user-position . t)
                                  (user-size . t)
                                  (keep-ratio . t)
                                  (minibuffer . nil)
                                  (undecorated . t)
                                  (internal-border-width . 3)
                                  (drag-internal-border . t)
                                  (drag-with-mode-line . t)
                                  (drag-with-header-line . t)
                                  (top-visible . 1)
                                  (bottom-visible . 1))
                                parent-frame-parameters
                                show-parameters)))
      (set-face-background 'fringe nil completions-frame-frame))
    (let ((completion-window (frame-selected-window completions-frame-frame)))
      (modify-frame-parameters
       completions-frame-frame
       ;; set `left' earlier to minimize frame repositioning
       (append `((left . ,(max (car (window-edges nil nil nil t))
                               (+ (car (pos-visible-in-window-p (window-point) nil t))
                                  (car (window-edges nil t nil t))
                                  (- (car (window-edges completion-window t nil t)))))))
               show-parameters))
      (window--display-buffer buffer completion-window 'frame alist))))

(defconst completions-frame--display-buffer-entry
  '("\\(\\*\\(Ido \\)?Completions\\)\\|\\(\\*Isearch completions\\)\\*" completions-frame-display)
  "Entry for `display-buffer-alist'.")

;;;###autoload
(define-minor-mode completions-frame-mode
  "Show completions in child frame."
  :global t
  (cond
   (completions-frame-mode
    (add-to-list 'display-buffer-alist completions-frame--display-buffer-entry)
    (add-hook 'temp-buffer-window-show-hook #'completions-frame-setup)
    (add-hook 'completion-setup-hook #'completions-frame-setup))
   (t
    (setq display-buffer-alist (delete completions-frame--display-buffer-entry display-buffer-alist))
    (remove-hook 'temp-buffer-window-show-hook #'completions-frame-setup)
    (remove-hook 'completion-setup-hook #'completions-frame-setup)
    (when (frame-live-p completions-frame-frame)
      (delete-frame completions-frame-frame)))))

(provide 'completions-frame)

;;; completions-frame.el ends here
