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

;; Set initial variable.

(defvar rlrt-filename)

;; Functions for creating handout, syllabus, and lecture files.

;; Convert title to filename string. Remove punctuation, one or two-letter words, and "the".

  (defun rlrt-make-filename (string)
    (s-downcase  (s-join "-" (s-split " " (replace-regexp-in-string "\\bthe \\b\\|\\band \\b\\|\\b[a-z]\\b \\|\\b[a-z][a-z]\\b \\|[[:punct:]]" "" string)))))

;; Create a handout in the currently visited directory.

(defun rlrt-new-handout (rlrt-title)
(interactive "sTitle: ")

;; Make filename
(setq rlrt-filename (rlrt-make-filename rlrt-title))

  ;; Create directory
  (make-directory rlrt-filename)

  ;; Create main org file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-handout.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/handout/handout.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" rlrt-filename "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create Canvas file
  (find-file (s-concat rlrt-filename "/canvas.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/handout/canvas.org")
  (save-buffer)
  (kill-buffer)

  ;; Create data file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-data.org"))
    (insert (s-concat "#+TITLE: " rlrt-title) ?\n"#+AUTHOR: Dr. Randy Ridenour" ?\n "#+DATE: "(format-time-string "%B %e, %Y")))


;; Create a syllabus in the currently visited directory.

(defun rlrt-new-syllabus (rlrt-title)
  (interactive "sTitle: ")

  ;; Make filename
(setq rlrt-filename (rlrt-make-filename rlrt-title))

  ;; Create directory
  (make-directory rlrt-filename)

  ;; Create main org file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-syllabus.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/syllabus/syllabus.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" rlrt-filename "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create Canvas file
  (find-file (s-concat rlrt-filename "/canvas.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/syllabus/canvas.org")
  (save-buffer)
  (kill-buffer)

  ;; Create data file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-data.org"))
  (insert (s-concat "#+TITLE: " rlrt-title) ?\n)
  (yas-expand-snippet (yas-lookup-snippet "syllabus")))



;; Create lecture slides and notes in the currently visited directory.

(defun rlrt-new-lecture (rlrt-title)
  (interactive "sTitle: ")

    ;; Make filename
(setq rlrt-filename (rlrt-make-filename rlrt-title))


  ;; Create directory
  (make-directory rlrt-filename)

  ;; Create LaTeX Beamer org file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-slides.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/lecture/slides.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" rlrt-filename "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)

  ;; Create notes org file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-notes.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/lecture/notes.org")
  (goto-char (point-max))
  (insert (s-concat "#+include: \"" rlrt-filename "-data.org\" :minlevel 1"))
  (save-buffer)
  (kill-buffer)
  
  ;; Create Canvas file
  (find-file (s-concat rlrt-filename "/canvas.org"))
  (insert-file-contents "~/.config/emacs/teaching-templates/lecture/canvas.org")
  (goto-char (point-max))
  (save-buffer)
  (kill-buffer)

  ;; Create data file
  (find-file (s-concat rlrt-filename "/" rlrt-filename "-data.org"))
  (insert (s-concat "#+TITLE: " rlrt-title) ?\n)
  (yas-expand-snippet (yas-lookup-snippet "beamer-data")))


;; Compile the files.

(defun make-slides ()
  (async-shell-command-no-window "mkslides"))

(defun make-notes ()
  (async-shell-command-no-window "mknotes"))

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
    (insert "\n \\frametitle")))

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
  (shell-command "canvas"))

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
  (delete-file "canvas-data.org")
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


;; Functions for adding arguments in standard form to Org documents.

(defun  create-args ()
  (interactive)
  (kill-ring-save (region-beginning) (region-end))
  (exchange-point-and-mark)
  (yas-expand-snippet (yas-lookup-snippet "arg-wrap-tex"))
  (previous-line)
  ;; (previous-line)
  (org-beginning-of-line)
  (forward-word)
  (forward-char)
  (forward-char)
  (insert "\\underline{")
  (org-end-of-line)
  (insert "}")
  (next-line)
  (org-beginning-of-line)
  (forward-word)
  (insert "[\\phantom{\\(\\therefore\\)}]")
  (next-line)
  (next-line)
  (org-return)
  (org-return)
  (org-yank)
  (exchange-point-and-mark)
  (yas-expand-snippet (yas-lookup-snippet "arg-wrap-html")))


(defun  create-tex-arg ()
  (interactive)
  (yas-expand-snippet (yas-lookup-snippet "arg-wrap-tex"))
  (previous-line)
  (previous-line)
  (forward-word)
  (forward-char)
  (forward-char)
  (insert "\\underline{")
  (org-end-of-line)
  (insert "}")
  (next-line)
  (org-beginning-of-line)
  (forward-word)
  (insert "[\\phantom{\\(\\therefore\\)}]")
  (next-line)
  (next-line)
  (org-return)
  (org-return))

;; Copy slide notes to handout notes.

(defun duplicate-slide-note ()
  (interactive)
  (search-backward ":END:")
  (next-line)
  (kill-ring-save (point)
    		  (progn
    		    (search-forward "** ")
    		    (beginning-of-line)
    		    (point))
    		  )
  (yas-expand-snippet (yas-lookup-snippet "beamer article notes"))
  (yank))

(defun duplicate-all-slide-notes ()
  (interactive)
  (save-excursion
    (end-of-buffer)
    (newline)
    (newline)
    ;; Need a blank slide at the end to convert the last note.
    (insert "** ")
    (beginning-of-buffer)
    (while (ignore-errors
    	     (search-forward ":BEAMER_ENV: note"))
      (next-line)
      (next-line)
      (kill-ring-save (point)
    		      (progn
    			(search-forward "** ")
    			(beginning-of-line)
    			(point))
    		      )
      (yas-expand-snippet (yas-lookup-snippet "beamer article notes"))
      (yank))
    ;; Delete the blank slide that was added earlier.
    (end-of-buffer)
    (search-backward "**")
    (kill-line)
    )
  (save-buffer))

(defun rlrt-new-article (rlrt-title)
  (interactive "sTitle: ")

  ;; Make filename
(setq rlrt-filename (rlrt-make-filename rlrt-title))

  ;; Create directory
  (make-directory rlrt-filename)

  
  (find-file (s-concat rlrt-filename "/" rlrt-filename ".org"))
  (insert (s-concat "#+TITLE: " rlrt-title) ?\n)
  (yas-expand-snippet (yas-lookup-snippet "rlrt-pdf-article")))

;; Function for converting Org mode files to QTI file for importing into Canvas using https://www.nyit.edu/its/canvas_exam_converter

(defun convert-qti-nyit ()
  (interactive)
  ;; Copy all to a temp buffer and set to text mode.
  (let ((old-buffer (current-buffer)))
    (with-temp-buffer
      (insert-buffer-substring old-buffer)
      (text-mode)
      ;; convert multiple correct answer and essay questions
      (beginning-of-buffer)
      (while (re-search-forward "-" nil t)
	(replace-match ""))
      ;; Change correct multiple answer options to "*"
      (beginning-of-buffer)
      (let ((case-fold-search nil))
	(while (re-search-forward "\[X\]" nil t)
	  (replace-match "*")))
      ;; Mark short answer responses with "**"
      (beginning-of-buffer)
      (while (re-search-forward "+" nil t)
	(replace-match "*"))
      ;; remove whitespace at beginning of lines
      (beginning-of-buffer)
      (while (re-search-forward "^\s-*" nil t)
	(replace-match ""))
      (beginning-of-buffer)
      (while (re-search-forward "\\([0-9]\\)" nil t)
	(replace-match "\n\\1"))
      ;; move correct answer symbol to beginning of line
      (beginning-of-buffer)
      (while (re-search-forward "\\(^.*\\)\\(\*$\\)" nil t)
	(replace-match "\*\\1"))
      (delete-trailing-whitespace)
      ;; delete empty line at end and beginning
      (end-of-buffer)
      (delete-char -1)
      (beginning-of-buffer)
      (kill-line)
      ;; Copy result to clipboard
      (clipboard-kill-ring-save (point-min) (point-max))
      )
    )
  (browse-url "https://www.nyit.edu/its/canvas_exam_converter")
  )

(provide 'rlr-teaching)
;;; rlr-teaching.el ends here
