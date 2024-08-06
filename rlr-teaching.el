;;; rlr-teaching.                     -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Randy Ridenour

;; Author: Randy Ridenour <rlridenour@gmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a simple package containing functions that I use for creating beamer slides and handouts for class.

;;; Code:

;; Functions for creating handout, syllabus, and lecture files.

;; Create a handout in the currently visited directory.

(defun new-handout (name)
  (interactive "sName: ")

  ;; Create directory
  (make-directory name)

  ;; Create main org file
  (find-file (s-concat name "/" name "-handout.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/handout/handout.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" name "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create Canvas file
  (find-file (s-concat name "/canvas.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/handout/canvas.org")
  (save-buffer)
  (kill-buffer)

  ;; Create data file
  (find-file (s-concat name "/" name "-data.org"))
  (insert (s-concat "#+TITLE: \n#+AUTHOR: Dr. Randy Ridenour\n#+DATE: \n\n"))
  (save-buffer)
  )


;; Create a syllabus in the currently visited directory.

(defun new-syllabus (name)
  (interactive "sName: ")

  ;; Create directory
  (make-directory name)

  ;; Create main org file
  (find-file (s-concat name "/" name "-syllabus.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/syllabus/syllabus.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" name "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create Canvas file
  (find-file (s-concat name "/canvas.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/syllabus/canvas.org")
  (save-buffer)
  (kill-buffer)

  ;; Create data file
  (find-file (s-concat name "/" name "-data.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/syllabus/syllabus-data.org")
  (save-buffer)
  )


;; Create lecture slides and notes in the currently visited directory.

(defun new-lecture (name)
  (interactive "sName: ")

  ;; Create directory
  (make-directory name)

  ;; Create LaTeX Beamer org file
  (find-file (s-concat name "/" name "-slides.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/lecture/slides.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" name "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create notes org file
  (find-file (s-concat name "/" name "-notes.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/lecture/notes.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" name "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)
  
  ;; Create Canvas file
  (find-file (s-concat name "/canvas.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/lecture/canvas.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"canvas-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create data file
  (find-file (s-concat name "/" name "-data.org"))
  (insert (s-concat "#+startup: beamer\n#+TITLE: \n#+SUBTITLE: \n#+AUTHOR: Dr. Randy Ridenour\n#+BEAMER_HEADER: \\institute{Department of Philosophy}\n#+DATE: \n#+BEAMER_THEME: basicwhite[school,sections]\n#+OPTIONS: H:3\n\n"))
  (save-buffer)
  )


;; Compile the files.

;; Compile lecture slides.
(defun lecture-slides ()
  "publish org data file as beamer slides"
  (interactive)
  (save-buffer)
  (find-file "*-slides.org" t)
  (org-beamer-export-to-latex)
  (kill-buffer)
  (make-slides)
  (find-file "*-data.org" t))

(defun rlr/create-frametitle ()
  "Convert title to frametitle."
  (interactive)
  (goto-char 1)
  (while (ignore-errors
    	   (re-search-forward "begin{frame}.*]"))
    (insert "\n \\frametitle"))
  )

;; Compile lecture notes.
(defun lecture-notes ()
  "publish org data file as beamer notes"
  (interactive)
  (save-buffer)
  (find-file "*-notes.org" t)
  (org-beamer-export-to-latex)
  (kill-buffer)
  (find-file "*-notes.tex" t)
  (rlr/create-frametitle)
  (save-buffer)
  (kill-buffer)
  (make-notes)
  (find-file "*-data.org" t))

;; Copy HTML for Canvas pages
(defun canvas-copy ()
  "Copy html for canvas pages"
  (interactive)
  (save-buffer)
  (org-html-export-to-html)
  (shell-command "canvas")
  )

;; Compile Canvas HTML notes.
(defun canvas-notes ()
  "Copy HTML slide notes for Canvas"
  (interactive)
  (save-buffer)
  (shell-command "canvas-notes")
  (find-file "canvas.org")
  (canvas-copy)
  (kill-buffer)
  (delete-file "canvas-data.org"))

;; Compile handout
(defun make-handout ()
  "publish org data file as LaTeX handout and Canvas HTML"
  (interactive)
  (save-buffer)
  (find-file "*-handout.org" t)
  (rlr/org-mkpdf)
  (kill-buffer)
  (shell-command "canvas-notes")
  (find-file "canvas.org" t)
  (org-html-export-to-html)
  (shell-command "canvas")
  (kill-buffer)
  ;; (delete-file "canvas-data.org")
  (find-file "*-data.org" t))

;; Compile syllabus.
(defun make-syllabus ()
  "publish org data file as LaTeX syllabus and Canvas HTML"
  (interactive)
  (save-buffer)
  (find-file "*-syllabus.org" t)
  (rlr/org-mkpdf)
  (kill-buffer)
  (shell-command "canvas-notes")
  (find-file "canvas.org" t)
  (org-html-export-to-html)
  (shell-command "canvas")
  (kill-buffer)
  (delete-file "canvas-data.org")
  (find-file "*-data.org" t))


(provide 'rlr-teaching)
;;; rlr-teaching.el ends here
