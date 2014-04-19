; cmt-region.l
;
; Copyright (c) 2014 Kentarou Hirano (a.k.a Kengpong)
;
; This software is released under the MIT License.
;
; http://opensource.org/licenses/mit-license.php

; ���[�W�������R�����g�A�E�g�^�A���R�����g����


; �R�����g�}�[�N�̓���/�O���ɃX�y�[�X������Ȃ�t�A����Ȃ��Ȃ�nil��ݒ肷��
(defvar *-let-inside-space-* t)
(defvar *-let-outside-space-* t)

; �R�����g�}�[�N�̓���/�O���ɓ����X�y�[�X�̐�
(defvar *-inside-space-width-* 1)
(defvar *-outside-space-width-* 2)

; �e���ꃂ�[�h�ɍ��킹���R�����g�}�[�N�i������j�̃e�[�u��
(defvar *-commentize-mode-table-* (make-hash-table :test #'equalp))

(setf (gethash 'lisp-interaction-mode *-commentize-mode-table-*) '(";" nil))
(setf (gethash 'lisp-mode *-commentize-mode-table-*) '(";" nil))
(setf (gethash 'c-mode *-commentize-mode-table-*) '("/*" "*/"))
(setf (gethash 'css-mode *-commentize-mode-table-*) '("/*" "*/"))
(setf (gethash 'py-mode *-commentize-mode-table-*) '("#" nil))
(setf (gethash 'python-mode *-commentize-mode-table-*) '("#" nil))
(setf (gethash 'bash-mode *-commentize-mode-table-*) '("#" nil))
(setf (gethash 'c++-mode *-commentize-mode-table-*) '("//" nil))
(setf (gethash 'java-mode *-commentize-mode-table-*) '("//" nil))
(setf (gethash 'javascript-mode *-commentize-mode-table-*) '("//" nil))
(setf (gethash 'basic-mode *-commentize-mode-table-*) '("'" nil))
(setf (gethash 'sql-mode *-commentize-mode-table-*) '("--" nil))
(setf (gethash 'html-mode *-commentize-mode-table-*) '("<!--" "-->"))
(setf (gethash 'pascal-mode *-commentize-mode-table-*) '("{" "}"))

(let ((start-is-not-bol)
      (start-is-tail-of-indent)
      (start-is-midpoint-of-indent)
      (end-is-not-eol)
      (cmtoutpoint)
      (top-line-number)
      (last-line-number))

  ; ���[�W�������̏󋵂�c������
  (defun -get-region-info- (start end)
    ; ���[�W�����擪
    (goto-char start)
    (setq start-is-not-bol (not (bolp)))
    (setq start-is-tail-of-indent (-is-indent-tail- start))
    (setq start-is-midpoint-of-indent (-is-midpoint-of-indent- start))

    ; ���[�W��������
    (goto-char end)
    (setq end-is-not-eol (not (eolp))))


  ; ���ݍs�̃C���f���g�̐[�������߂�B��s�������͋󔒕��������̍s�Ȃ�nil��Ԃ��B
  (defun -get-indent-width- ()
    ; ���ݍs����s�Ȃ�t��Ԃ�
    (defun -is-all-blank- ()
      (cond ((eolp) t)
          ((looking-at "[^ \t]") nil)
          (t (forward-char) (-is-all-blank-))))

      (goto-bol)
      (unless (-is-all-blank-) (current-column)))


  ; ���[�W�����̍ŏI�s�Ȃ�t�A�����łȂ����nil��Ԃ�
  (defun -is-lastline- ()
    (equal (current-line-number) last-line-number))


  ; ���[�W�����̊J�n�s�Ȃ�t�A�����łȂ����nil��Ԃ�
  (defun -is-topline- ()
    (equal (current-line-number) top-line-number))


  ; pnt���C���f���g�̖����i�s������A�Ȃ�󔒂ƕ����̋��E�A�������͍s���ɋ�
  ; �������j���𔻒f����B�C���f���g�̖����Ȃ�t�A�����łȂ����nil��Ԃ�
  (defun -is-indent-tail- (pnt)
    (save-excursion
      (goto-bol)
      (when (string-match "^[ \t]*$" (buffer-substring (point) pnt))
        t)))


  ; pnt���C���f���g�̒��ł����t�A�����łȂ����nil��Ԃ�
  ; pnt�ʒu�̍s����s�ł����nil��Ԃ�
  (defun -is-midpoint-of-indent- (pnt)
    (save-excursion
      (goto-char pnt)
      (loop
        (unless (looking-at "[ \t]+[^ \t]")
          (return nil))
        (backward-char)
        (when (bolp) (return t)))))


  ; ���[�h�ɍ������R�����g�A�E�g������̎擾
  (defun -get-cmt-letters- ()
    (let ((cmt-letters (gethash buffer-mode *-commentize-mode-table-*)))
      ; commentize-mode-table�ɖ������[�h�̏ꍇ��
      ; �v�����v�g�ŃR�����g�A�E�g��������͂�����
      ; default: nil
      (unless cmt-letters
        (let ((prompt1 "Letter(s) for comment start: ")
              (prompt2 "Letter(s) for comment end (default: nil): "))
          (setq cmt-letters
                (nconc (list (read-string prompt1))
                       (list (read-string prompt2))))))
      cmt-letters))


  ; �R�����g�A�E�g������̓���/�O���̃X�y�[�X������/���K�\������������
  (defun -get-spaces- (&optional (regexp nil))
    (let ((spclist nil))
      (dolist (spc-conds
               (list (list *-let-inside-space-* *-inside-space-width-*)
                     (list *-let-outside-space-* *-outside-space-width-*))
               spclist)
        (setq spclist
              (append spclist
                      (if (first spc-conds)
                          (list
                           (if regexp
                              (format nil "[ ]\\{~A\\}" (second spc-conds))
                             (make-sequence 'string (second spc-conds)
                                            :initial-element '#\ )))
                        (list "")))))))


  ; �R�����g�A�E�g�������u���ʒu�����߂�
  (defun -get-cmtoutpoint- ()
    (let ((indent-width)
          (indent-width-list))
        (goto-char (point-min))
        (setq top-line-number (current-line-number))
        (loop
          (setq indent-width-list
                (if (setq indent-width (-get-indent-width-))
                    (cons indent-width indent-width-list)
                  indent-width-list))
          (unless (forward-line) (return)))
        (setq last-line-number (current-line-number))
        (setq cmtoutpoint (reduce #'min indent-width-list))))


  ; �e�s�ɃR�����g�A�E�g�������u��
  (defun -put-cmtoutletters- (cmt-letters spaces)
    ; �R�����g�擪�̏���
    (when (first cmt-letters)
      (if (and (-is-topline-)
               start-is-not-bol)
            (loop
              (if (looking-at "[^ \t]")
                  (return)
                (forward-char)));)
        (goto-column cmtoutpoint))
      (unless (or (eolp) (looking-at "[ \t]*$"))
        (insert
         (concat
          (when (and start-is-not-bol
                     (-is-topline-)
                     (not start-is-tail-of-indent))
            (second spaces))
          (first cmt-letters) (first spaces)))))

    ; �R�����g�����̏���
    (when (second cmt-letters)
      (goto-eol)
      (when (and (-is-lastline-) end-is-not-eol)
        (backward-char)
        (loop
          (if (looking-at "[^ \t]")
              (progn
                (forward-char)
                (return))
            (backward-char))))
      (unless (or (bolp) (looking-at "^[ \t]*$"))
        (insert
         (concat (first spaces)
                 (second cmt-letters)
                 (when (and end-is-not-eol (-is-lastline-))
                   (second spaces))))))
    (when (forward-line) (-put-cmtoutletters- cmt-letters spaces)))


  ; ���[�W���������R�����g�A�E�g����
  (defun commentout-region ()
    (interactive)
    (let ((start (min (mark) (point)))
          (end (max (mark) (point)))
          (cmt-letters (-get-cmt-letters-))
          (spaces (-get-spaces-)))

      (save-excursion
        (-get-region-info- start end)
        (save-restriction
          ; ���[�W�������ɕҏW�͈͂�����
          (if (and start-is-not-bol start-is-midpoint-of-indent)
              (progn
                (goto-char start)
                (goto-bol)
                (narrow-to-region (point) end))
            (narrow-to-region start end))

          (-get-cmtoutpoint-)
          (goto-char (point-min))
          (-put-cmtoutletters- cmt-letters spaces)))))


  ; �R�����g�A�E�g�����񂪑��݂��邩�𔻒肷��
  ; �R�����g�A�E�g�����񂪂���Δ͈͂��������|�C���g������������X�g��Ԃ��B
  ; �������nil
  (defun -get-scan-range- (c-mark is-open)
    (if is-open (goto-eol) (goto-bol))
    (when (scan-buffer c-mark :reverse is-open :tail (not is-open))
      (list (point) (if is-open (progn (goto-bol) (point))
                      (progn (goto-eol) (point))))))


  ; �ł������i�͂ރX�^�C���̃R�����g�͍ł��O���j�̃R�����g�A�E�g���������肷��
  (defun -scan-outermost-cmtoutmark- (stmks uc-range)
    (let* ((c-mark (first stmks))
           (is-open (fourth stmks))
           (scan-range (-get-scan-range- c-mark is-open))
           (cnt-result (-scan-cmtoutmark- c-mark is-open)))
      (case (first cnt-result)
        (0 nil)
        (1 (append uc-range (list (second cnt-result))))
        (t (narrow-to-region (first scan-range) (second scan-range))
           (-scan-outermost-cmtoutmark- stmks scan-range)))))


  ; �R�����g�A�E�g�������T��
  (defun -scan-cmtoutmark- (c-mark is-open)
    (let ((goto-scan-start-point (if is-open #'goto-eol #'goto-bol))
          (go-next (if is-open #'backward-char #'forward-char))
          (stop-p (if is-open #'bolp #'eolp))
          (cnt 0)
          (pnt))
      (funcall goto-scan-start-point)
      (loop
        (when (looking-for c-mark)
          (setq cnt (1+ cnt))
          (setq pnt (point)))
        (unless (funcall go-next) (return)))
      (list cnt pnt)))


  ; �R�����g�A�E�g������̈ʒu���s�����𔻒肷��i�s���Ȃ�t�A�����Ȃ���nil��Ԃ��j
  (defun -is-line-end- (c-mark pnt)
    (goto-char pnt)
    (looking-at (format nil "~A$" c-mark)))


  ; �R�����g�A�E�g��������폜����
  (defun -delete-cmtoutmark- (stmks uncmt-info)
    (let* ((uncmt-pnt (third uncmt-info))
           (c-mark (regexp-quote (first stmks)))
           (l-spc (if (-is-indent-tail- uncmt-pnt)
                      nil (third stmks)))
           (r-spc (if (-is-line-end- c-mark uncmt-pnt)
                      nil (second stmks)))
           (is-open (fourth stmks))
           (cmt-regexp
            (concat l-spc (format nil "\\(~A\\)" c-mark) r-spc)))
      (save-restriction
        (narrow-to-region (first uncmt-info) (second uncmt-info))
        (dolist (dels (list (list cmt-regexp "\\1") (list c-mark "")))
          (goto-bol)
          (replace-buffer (first dels) (second dels) :regexp t)))
        ))


  ; �A���R�����g�i�R�����g�A�E�g���畜�A�j����
  (defun uncomment-region ()
    (interactive)
    (let* ((start (min (mark) (point)))
           (end (max (mark) (point)))
           (cmt-letters (-get-cmt-letters-))
           (spc-regexps (-get-spaces- t))
           (is-open (list t nil))
           (uncmt-info)
           (line-range)
           (set-of-marks (mapcar #'list
                                 cmt-letters
                                 spc-regexps
                                 (reverse spc-regexps)
                                 is-open)))

      (save-excursion
        (-get-region-info- start end)
        (save-restriction
          ; ���[�W�������ɕҏW�͈͂�����
          (if (and start-is-not-bol (not start-is-midpoint-of-indent))
              (progn
                (goto-char start)
                (goto-bol)
                (narrow-to-region (point) end))
            (narrow-to-region start end))
          (goto-char (point-min))

          (loop
            (save-restriction
              ; �ҏW�͈͐�������s����
              (setq line-range (list (progn (goto-bol) (point))
                                     (progn (goto-eol) (point))))
              (narrow-to-region (first line-range) (second line-range))
              (dolist (stmk set-of-marks)
                (when (first stmk)
                  (save-restriction
                    (setq uncmt-info
                          (-scan-outermost-cmtoutmark- stmk line-range))
                    (when uncmt-info
                      (-delete-cmtoutmark- stmk uncmt-info))))))
            (unless (next-line) (return))))
        )))
  )