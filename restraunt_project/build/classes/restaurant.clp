(import javax.swing.*)
(import java.awt.*)
(import java.awt.event.*)

(set-reset-globals FALSE)

(defglobal ?*crlf* = "
")


(deftemplate question
  (slot text)
  (slot type)
  (multislot valid)
  (slot ident))

(deftemplate answer
  (slot ident)
  (slot text))

(do-backward-chaining answer)


(defmodule app-rules)

(defrule app-rules::supply-answers
  (declare (auto-focus TRUE))
  (MAIN::need-answer (ident ?id))
  (not (MAIN::answer (ident ?id)))
  (not (MAIN::ask ?))
  =>
  (assert (MAIN::ask ?id))
  (return))


(defrule MAIN::how-salad
  (declare (auto-focus TRUE))
  (answer (ident people) (text yes))
  (answer (ident salad) (text no))
  =>
  (recommend-action "Iam soory for you salat is very good here")
  (halt))

(defrule MAIN::many-people
  (declare (auto-focus TRUE))
  (answer (ident people) (text no))
  (answer (ident salad) (text yes))
  =>
  (recommend-action "So how many people should we add the chairs?")
  (halt))

(defrule MAIN::no-pe-sa
  (declare (auto-focus TRUE))
  (answer (ident people) (text no))
  (answer (ident salad) (text no))
  =>
  (recommend-action "So how many people should we add the chairs?")
  (halt))

(defrule MAIN::check-heat
  (declare (auto-focus TRUE))
  (answer (ident people) (text yes))
  (answer (ident drinks) (text no))
  (answer (ident spices) (text yes))
  (answer (ident time) (text ?t))
  (test (< (integer ?t) 3))
  =>
  (assert (check paying))
  (recommend-action "i am sorry for you,drinks is cold here"))


(defrule MAIN::Ready
  (declare (auto-focus TRUE))
  (answer (ident people) (text yes))
  (answer (ident drinks) (text no))
  (answer (ident spices) (text yes))
  (answer (ident time) (text ?t))
  (test (>= (integer ?t) 3))
  =>
  (recommend-action "We will get everything ready")
  (halt))

(defrule MAIN::food-target
  (declare (auto-focus TRUE))
  (answer (ident people) (text yes))
  (answer (ident drinks) (text yes))
  (answer (ident target) (text bad))
  =>
  (recommend-action "Any notes to help develop ourselves")
  (halt))



(defrule MAIN::cash
  (declare (auto-focus TRUE))
  (answer (ident people) (text yes))
  (answer (ident drinks) (text yes))
  (answer (ident target) (text good))
  (answer (ident paying) (text yes))
  =>
  (recommend-action "have you go to cashier to pay")
  (halt))

(defrule MAIN::credit
  (declare (auto-focus TRUE))
  (answer (ident people) (text yes))
  (answer (ident drinks) (text yes))
  (answer (ident target) (text good))
  (answer (ident paying) (text no))
  =>
  (recommend-action "give me your credit card,sir")
  (halt))


  

(defrule MAIN::res-mode
  (declare (auto-focus TRUE))
  (explicit (answer (ident type) (text Other)))
  =>
  (recommend-action "we don't have other way")
  (halt))


(deffunction recommend-action (?action)
  "Give final instructions to the user"
  (call JOptionPane showMessageDialog ?*frame*
        (str-cat "I recommend that you " ?action)
        "Recommendation"
        (get-member JOptionPane INFORMATION_MESSAGE)))
  
(defadvice before halt (?*qfield* setText "Close window to exit"))


(defmodule ask)

(deffunction ask-user (?question ?type ?valid)
  "Set up the GUI to ask a question"
  (?*qfield* setText ?question)
  (?*apanel* removeAll)
  (if (eq ?type multi) then
    (?*apanel* add ?*acombo*)
    (?*apanel* add ?*acombo-ok*)
    (?*acombo* removeAllItems)
    (foreach ?item ?valid
             (?*acombo* addItem ?item))
    else
    (?*apanel* add ?*afield*)
    (?*apanel* add ?*afield-ok*)
    (?*afield* setText ""))
  (?*apanel* validate)
  (?*apanel* repaint))

(deffunction is-of-type (?answer ?type ?valid)
  "Check that the answer has the right form"
  (if (eq ?type multi) then
    (foreach ?item ?valid
             (if (eq (sym-cat ?answer) (sym-cat ?item)) then
               (return TRUE)))
    (return FALSE))
    
  (if (eq ?type number) then
    (return (is-a-number ?answer)))
    
  (return (> (str-length ?answer) 0)))

(deffunction is-a-number (?value)
  (try
   (integer ?value)
   (return TRUE)
   catch 
   (return FALSE)))

(defrule ask::ask-question-by-id
  "Given the identifier of a question, ask it"
  (declare (auto-focus TRUE))
  (MAIN::question (ident ?id) (text ?text) (valid $?valid) (type ?type))
  (not (MAIN::answer (ident ?id)))
  (MAIN::ask ?id)
  =>
  (ask-user ?text ?type ?valid)
  ((engine) waitForActivations))

(defrule ask::collect-user-input
  "Check an answer returned from the GUI, and optionally return it"
  (declare (auto-focus TRUE))
  (MAIN::question (ident ?id) (text ?text) (type ?type) (valid $?valid))
  (not (MAIN::answer (ident ?id)))
  ?user <- (user-input ?input)
  ?ask <- (MAIN::ask ?id)
  =>
  (if (is-of-type ?input ?type ?valid) then
    (retract ?ask ?user)
    (assert (MAIN::answer (ident ?id) (text ?input)))
    (return)
    else
    (retract ?ask ?user)
    (assert (MAIN::ask ?id))))

(defglobal ?*frame* = (new JFrame "restaurant Expert System"))
(?*frame* setDefaultCloseOperation (get-member JFrame EXIT_ON_CLOSE))
(?*frame* setSize 500 250)
(?*frame* setVisible TRUE)

(defglobal ?*qfield* = (new JTextArea 5 40))
(bind ?scroll (new JScrollPane ?*qfield*))
((?*frame* getContentPane) add ?scroll)
(?*qfield* setText "Please wait...")

(defglobal ?*apanel* = (new JPanel))
(defglobal ?*afield* = (new JTextField 40))
(defglobal ?*afield-ok* = (new JButton OK))

(defglobal ?*acombo* = (new JComboBox (create$ "yes" "no")))
(defglobal ?*acombo-ok* = (new JButton OK))

(?*apanel* add ?*afield*)
(?*apanel* add ?*afield-ok*)
((?*frame* getContentPane) add ?*apanel* (get-member BorderLayout SOUTH))
(?*frame* validate)
(?*frame* repaint)

(deffunction read-input (?EVENT)
  "An event handler for the user input field"
  (assert (ask::user-input (sym-cat (?*afield* getText)))))

(bind ?handler (new jess.awt.ActionListener read-input (engine)))
(?*afield* addActionListener ?handler)
(?*afield-ok* addActionListener ?handler)

(deffunction combo-input (?EVENT)
  "An event handler for the combo box"
  (assert (ask::user-input (sym-cat (?*acombo* getSelectedItem)))))

(bind ?handler (new jess.awt.ActionListener combo-input (engine)))
(?*acombo-ok* addActionListener ?handler)

(deffacts MAIN::question-data
  (question (ident type) (type multi) (valid restaurant delivery Other)
            (text "How do you want food to reach you?"))
  (question (ident people) (type multi) (valid yes no)
            (text "Are you coming alone?"))
  (question (ident salad) (type multi) (valid yes no)
            (text "Do you want to add salad to food?"))
  (question (ident drinks) (type multi) (valid yes no)
            (text "Do you want any drinks or soda?"))
  (question (ident spices) (type multi) (valid yes no)
            (text "Do you want any spices?"))
  (question (ident time) (type number) (valid)
            (text "What is the maximum time he wants food to reach you?"))
  (question (ident paying) (type multi) (valid yes no)
            (text "Will you pay cash?"))
  (question (ident target) (type multi) (valid good bad)
            (text "what's your feedback about our restaurant?"))
  (ask type))

  
(reset)
(run-until-halt)
