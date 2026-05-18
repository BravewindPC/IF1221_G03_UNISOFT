:- dynamic statusUni/2. /*(Id, on/off)*/
/*di awal kan gada yang uni, di input pemain kasih off dulu*/
/*modif mainkankartu*/

resetUni(Id) :- retract(statusUni(Id, _)), assertz(statusUni(Id, off)).
setUni(Id)   :- retract(statusUni(Id, _)), assertz(statusUni(Id, on)).

uni(_):- 
    statusEfek(on),
    write('Perintah tidak valid.'),
    !, 
    nl.

uni(K) :-
    \+cekKartuValid(K),
    write('Kartu tidak valid!'),
    !,
    nl.

uni(K) :-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, 0, C),
    listpemain(C, _, X, Y),
    cekKartuValid(K),
    Idx is K-1,
    get_element(X, Idx, X1),
    get_element(Y, Idx, Y1),
    \+cekKartu(A, B, X1, Y1),
    !,
    write('Kartu tidak valid!'),
    nl.

/*jumlah kartu =/= 2*/

uni(K) :-
    urutanGiliran(R1),
    get_element(R1, 0, C),
    listpemain(C, N, X, _),
    jumlahElemenList(X, Sum),
    Sum =\= 2,
    cekKartuValid(K),
    !,
    write('Perintah UNI tidak valid!'), nl,
    write(N), write(' mendapat penalti 1 kartu.'), nl,
    ambilKartu(C, 1).

uni(K) :-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, 0, C),
    listpemain(C, N, X, Y),
    Idx is K-1,
    get_element(X, Idx, X1),
    get_element(Y, Idx, Y1),
    cekKartu(A, B, X1, Y1),
    nl,
    write(N), write(' memainkan kartu: '),
    write(Y1), write('-'), write(X1),
    nl,
    write(N), write(' menyerukan UNI!'), nl, nl,
    removeListIdx(X, Y, X2, Y2, Idx),
    retract(listpemain(C, N, _, _)),
    assertz(listpemain(C, N, X2, Y2)),
    setUni(C),
    cekAngka(X1, Y1),
    cekSkip(X1, Y1),
    cekReverse(X1, Y1),
    cekDrawTwo(X1, Y1),
    cekWild(X1),
    cekDrawFour(X1),
    retract(top_card_sebelumnya(_, _)),
    assertz(top_card_sebelumnya(A, B)).


