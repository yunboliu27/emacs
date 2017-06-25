;;; -*- lexical-binding: t -*-
;;; touch.el --- Touch input support

;; Copyright (C) 2017 Free Software Foundation, Inc.
;; Keywords: mouse touch
;; Package: emacs

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This mode enables the use of `touch gestures' on compatible
;; systems.

;; The available gestures are:
;;  * scroll/pan :: Scroll the buffer.
;;  * pinch :: Change the text scale factor.
;;  * rotate
;;  * swipe

;; Aside from scroll/pan, I'm not sure that it's worth having default
;; actions.  I can't think of any use for rotate, and swipe seems like
;; it would best be assigned to user actions.  Pinch is a natural for
;; resizing, but is `text scale' the right thing?

;;; Code:

(defvar touch-gesture-mode)

(defun touch-gesture--scroll (event)
  "Scroll up or down according to EVENT."
  (interactive (list last-input-event))
  ;;; FIXME: Handle horizontal scrolling too.  Scroll the window under
  ;;; the mouse pointer, not the last one selected.
  (let (;;(delta-x (caaddr event))
        (delta-y (cadr (caddr event)))
        (line-height (save-excursion
                       (goto-char (window-start))
                       (line-pixel-height))))
    (let ((num-lines (% (floor delta-y) line-height)))
      (if (not (= num-lines 0))
            (scroll-down num-lines)))))

(defun touch-gesture--pinch (event)
  "Increase or decrease the text scale according to EVENT."
  (interactive (list last-input-event))
  (let ((delta (caddr event)))
    (if (not (= delta 0))
        (text-scale-increase delta))))

(define-minor-mode touch-gesture-mode
  "Enable default actions for some touch gestures.

`touch-scroll' will act like a mouse-wheel, and scroll the
buffer.

`touch-pinch' will `zoom' in and out by changing the text-scale
factor.
"
  :init-value t
  :global t
  :group 'mouse
  (global-unset-key [touch-scroll])
  (when touch-gesture-mode
    (global-set-key [touch-scroll] 'touch-gesture--scroll)
    (global-set-key [touch-pinch] 'touch-gesture--pinch)))

;;; Compatibility entry point
;; preloaded ;;;###autoload
(defun touch-gesture-install (&optional uninstall)
  "Enable touch gesture support."
  (touch-gesture-mode (if uninstall -1 1)))

(provide 'touch)

;;; touch.el ends here
