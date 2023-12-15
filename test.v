Theorem neg_conj_distr:
    forall P Q,
    (~ P) /\ (~ Q) -> ~ (P /\ Q).
Proof.
    intros. destruct H.
    intro. destruct H1. contradiction.
Qed.

Theorem neg_exists_conj_distr:
    forall (X : Type) (P Q : X -> Prop),
    (~ exists x, P x) /\ (~ exists y, Q y) -> ~ (exists x y, P x /\ Q y).
Proof.
    intros. destruct H. intro.
    apply H. repeat destruct H1. now exists x.
Qed.
