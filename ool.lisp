;;;; -*- Mode: Lisp -*-
;;;; Tropeano Pietro 829757
;;;; ool.lisp


;;;; "memoria" / locazione centralizzata

(defparameter memory (make-hash-table))


;;;; consente di definire una classe e la inserisce in "memoria"

(defun def-class (class-name parents &rest slot-value)
  (cond ((and (symbolp class-name) (listp parents))
         (let ((table (create-assoc slot-value)))
           (setf (gethash class-name memory)
                 (cons parents table)))
         class-name)
        (t (error "Error: invalid class"))))


;;;; consente di creare un'istanza di una classe

(defun new (class-name &rest slot-value)
  (cond ((and (symbolp class-name)
              (not (null (slot-exsist class-name
                                      (get-slot-names slot-value)))))
         (let ((table (create-assoc slot-value)))
           (cons class-name table )))
        (t (error "please, create a correct instance"))))


;;;; dato slot-name restituisce il valore dello slot corrispondente nella
;;;; istanza instance

(defun getv (instance slot-name)
  (cond ((null instance) (error "insert an instance"))
        ((null slot-name) (error "insert a slot-name"))
        ((not (null (assoc-exsist slot-name (cdr instance))))
         (get-assoc slot-name (cdr instance)))
        (t  (if (not (null (get-slot (car instance) slot-name)))
                (get-slot (car instance) slot-name)
              (error "this slot doesn't exsist")))))


;;;; getvx utilizza richiama semplicemente real-getvx

(defun getvx (instance &rest slot-names)
  (real-getvx instance slot-names))


;;;; real-getvx estrae il valore di una classe percorrendo una catena di
;;;; attributi

(defun real-getvx (instance slot-names)
  (cond ((null slot-names) nil)
        ((null (cdr slot-names)) (getv instance (car slot-names)))
        (t (real-getvx (getv
                        instance
                        (car slot-names))
                       (cdr slot-names)))))


;;;; process-method crea il metodo con nome method-name che funge da metodo
;;;; trampolino per richiamare la funzione associata ad uno slot di una
;;;; istanza e restituisce la funzione anonima che si ottiene grazie alla
;;;; eval della rewrite-method-code

(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
        (lambda (&rest args)
          (apply (getv (car args) method-name)  args)))
  (eval (rewrite-method-code method-name method-spec)))


;;;; a partire da una S-expression della forma '(' => <arglist> <fom>* ')'
;;;; lo riscrive aggiungendo il parametro this ad arglist e riscrive la
;;;; Sexp per essere formattata come una lambda

(defun rewrite-method-code (method-name method-spec)
  (append '(lambda)
          (list (append (list 'this) (car (cdr method-spec))))
          (cdr (cdr method-spec))))


;;;; get-slot-names recupera la chiave di ogni slot in una lista composta
;;;; da chiavi e valori alternati, esempio: 
;;;; (key0 value0 key1 value1 ... keyN valueN)

(defun get-slot-names (slot-values)
  (unless (null slot-values)
    (cons (car slot-values) (get-slot-names (cdr (cdr slot-values))))))


;;;; verifica che ogni elemento in slot-names sia presente nella lista
;;;; degli elementi della classe o dei suoi parents

(defun slot-exsist (class-name slot-names)
  (cond ((null slot-names) t)
        ((null (get-slot class-name (car slot-names))) 
         (error "the slot ~A~% doesn't exsist in this class" 
                (car slot-names)))
        ((not (null (get-slot class-name (car slot-names))))
         (slot-exsist class-name (cdr slot-names)))))


;;;; verifica che slot-name esista nella classe class-name o nei suoi parents

(defun get-slot (class-name slot-name)
  (cond ((null class-name) nil)
        ((null slot-name) nil)
        ((null (gethash class-name memory)) nil)
        ((null (get-assoc slot-name (cdr (gethash class-name memory))))
         (found (car (gethash class-name memory)) slot-name))
        (t (get-assoc slot-name (cdr (gethash class-name memory))))))


;;;; verifica che slot-name esista almeno in una delle classi della
;;;; lista class-names

(defun found (class-names slot-name)
  (cond ((null class-names) nil)
        ((null (get-slot (car class-names) slot-name))
         (found (rest class-names) slot-name))
        (t (get-slot (car class-names) slot-name))))


;;;; create-assoc associa chiave a valore (sia esso un metodo o meno)
;;;; qualora sia un metodo lo associa con la funzione anonima creata a
;;;; partire dal codice del metodo stesso

(defun create-assoc (list)
  (cond ((null list) NIL)
        ((null (cdr list)) (error "no slot-value for a slot"))
        ((not (symbolp (car list))) (error "a slot-name isn't a symbol"))
        (t   (if (is-a-method (car (cdr list)))
                 (append (list 
                          (cons (car list)
                                (process-method
                                 (car list)
                                 (car (cdr list)))))
                         (create-assoc (cdr (cdr list))))
               (append (list (cons (car list) (car (cdr list))))
                       (create-assoc (cdr (cdr list))))))))


;;;; verifica che slot sia un metodo o meno restituendo t se lo è
;;;; nil altrimenti

(defun is-a-method (slot)
  (if (listp slot)
      (if (eq '=> (car slot))
          (if (and (listp (car (cdr slot))) (listp (cddr slot)))
              t
            nil)
        nil)
    nil))


;;;; se viene trovata la chiave restituisce 
;;;; il valore corrispondente, altrimenti nil

(defun get-assoc (key list)
  (cond ((null key) NIL)
        ((null list) NIL)
        ((eq (car (car list)) key) (cdr (car list)))
        (t (get-assoc key (cdr list)))))


;;;; se viene trovata la chiave restituisce t, altrimenti nil
(defun assoc-exsist (key list)
  (cond ((null key) NIL)
        ((null list) NIL)
        ((eq (car (car list)) key) t)
        (t (assoc-exsist key (cdr list)))))


;;;; end of file -- ool.lisp
