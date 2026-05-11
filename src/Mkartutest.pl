:- dynamic(top_card_sebelumnya/2)


/*
Notes:
- append urutanSekarang(0,1) di startgame
- teks mainkanKartu belum pasti benar (kurang contoh)
- tantang belum diimplementasikan
*/


top_card_sebelumnya(a,b).
cekList(X1, Y1, [X1|_], [Y1|_], idx):- !.
cekList(X1,Y1, [], [], -1):- !.
cekList(X1, Y1, [H1|T1], [H2|T2], idx):-
    I is idx+1,
    cekList(X1, Y1, T1, T2, i).


removeListIdx([H1|T1], [H2|T2], T1, T2, 0):- !.
removeListIdx([H1|T1], [H2|T2], X, Y, idx):-
    I is idx-1,
    removeListIdx(T1, T2, X1, Y1, I),
    insert_head(H1,X1,X),
    insert_head(H2,Y1,Y).


cekKartuValid(K):-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, 0, C), listpemain(C, N, X, Y),
jumlahElemenList(X,S)
    K>=1,
    K<S.


cekAngka(X1):-
X1>0,
X1<10,
putarGiliran.
cekAngka(_).


cekSkip(X1):-
    X1 :== 'skip',
    putarGiliran,
    putarGiliran.
cekSkip(_).


cekReverse(X1):-
    X1 :== 'reverse',
    urutanGiliran([H|T]),
    reverse_list([H|T],R),
    retract(urutanGiliran(_|_)),
    appendx(urutanGiliran(R)).
cekReverse(_,_).


cekWild(X1,Y1):-
X1 :== ‘wild’,
write(‘Pilih warna’),
read(Y1),
putarGiliran.
cekWild(_,_).


cekDrawTwo(X1):-
    X1 :== 'drawtwo',
    retract(statusEfek(_)),
    appendx(statusEfek(on)),
    ambilKartu,
    putarGiliran.
cekDrawTwo(_).


cekDrawFour(X1,Y1):-
    X1 :== 'wilddrawfour',
    write(‘Pilih warna’),
    read(Y1),
    retract(statusEfek(_)),
    appendx(statusEfek(on)),
    putarGiliran.
cekDrawFour(_).


cekKartu(A, B, _, Y1):-
    A>0,
    A<10,
    B :== Y1,
    !.
cekKartu(A, B, X1, _):-
    A>0,
    A<10,
    A =:= X1,
    !.


cekKartu(A, _, X1, _):-
    A :== 'skip',
    A :== X1,
    !.
cekKartu(A, B, _, Y1):-
    A :== 'skip',
    B :== Y1,
    !.


cekKartu(A, _, X1, _):-
    A :== 'reverse',
    A :== X1,
    !.
cekKartu(A, B, _, Y1):-
    A :== 'reverse',
    B :== Y1,
    !.


cekKartu(A, B, X1, Y1):-
    A :== 'drawtwo'
    A /== X1,
    B :== Y1,
    !.


cekKartu(A, B, X1, Y1):-
    A :== 'wild',
    A /== X1,
    B :== Y1,
    !.


cekKartu(A, B, X1, Y1):-
    A :== 'wilddrawfour',
    A /== X1,
    B :== Y1,
    !.


cekKartu(A, _, X1, _):-
    X1 :== 'wild',
    A /== 'wild',
    !.


cekKartu(A, _, X1, _):-
    X1 :== 'wilddrawfour',
    A /== 'wilddrawfour',
    !.


mainkanKartu(_):-
statusEfek(on),
write(‘Perintah tidak valid.’),
!,
nl.
mainkanKartu(K):-
    \+cekKartuValid(K),
    write('Kartu tidak valid!'),
    !,
    nl.
mainkanKartu(K):-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, U1, C), listpemain(C, N, X, Y),
    cekKartuValid(K),
    get_element(X,K,X1),
    get_element(Y,K,Y1),
    \+cekKartu(A, B, X1, Y1, K, X, Y),
    !,
    write('Kartu tidak valid!'),
    nl.
mainkanKartu(K):-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, U1, C), listpemain(C, N, X, Y),
    cekKartuValid(K),
    get_element(X,K,X1),
    get_element(Y,K,Y1),
    cekKartu(A, B, X1, Y1),
    nl,
    write(N), write(' memainkan kartu:'),
    write(X1), write('-'), write(Y1),
    nl,
    removeListIdx(X, Y, X1, Y1, K).
    retract(listpemain(C,N,_,_)),
    appendx(listpemain(C,N,X,Y)),
    cekAngka(X1),
    cekSkip(X1),
    cekReverse(X1),
    cekDrawTwo(X1),
    cekWild(X1,Y1),
    cekDrawFour(X1,Y1),
    retract(top_card(_,_)),
    appendx(top_card(X1,Y1)),
    retract(top_card_sebelumnya(_,_)),
    appendx(top_card_sebelumnya(A,B)).
    


listkosong([],[],1).
listkosong([_|_],[],0).
listkosong([],[_|_],0).
listkosong([_|_],[_|_],0).


jumlahElemenList([],0).
jumlahElemenList([H|T],Sum):-
    Sum is S1+1,
    jumlahElemenList(T,S1).


cekSemuaKartu(_,_,_,_,N,N).
cekSemuaKartu(A,B,X,Y,Count,N):-
getElement(X,Count,X1),
getElement(Y,Count,Y1),
cekKartu(A,B,X1,Y1),
C1 is Count+1,
cekSemuaKartu(A,B,X,Y,C1,N).
cekSemuaKartu(A,B,X,Y,Count,N):-
getElement(X,Count,X1),
getElement(Y,Count,Y1),
\+cekKartu(A,B,X1,Y1),
!,
fail.




cekMain(_,_,_,Count):
    statusEfek(on),
    !,
    Count is 1.
cekMain(_,X,Y,Count):-
    listkosong(X,Y,K),
    K =:= 1,
    !,
    Count is 1.
cekMain(_,X,Y,Count):-
    listkosong(X,Y,K),
    K =:= 0,
    cekSemuaKartu(X,Y),
    !,
    write('1. mainKartu'), nl,
    Count is 2.
cekMain(_,_,_,_):-
    Count is 1.


cekTantang(A, Count):-
    A :== 'wilddrawfour',
    write(Count), write('. tantang'), nl,
    Count is Count+1.
cekTangkap(_,_).


cekUni(X,Count):-
    jumlahElemenList(X,Sum),
    Sum =:= 2,
    write(Count), write('. Uni'),
    Count is Count+1.
cekUni(_,_).


cekTangkap(_,N,_,N):- !.
cekTangkap(I,Count,N):-
    urutanGiliran(R1),
    get_element(R1, I, C), listpemain(C, N, X, _),
    jumlahElemenList(X, Sum),
    Sum =:= 1,
    !,
    write(Count), write('. tangkap').
cekTangkap(I,Count,N):-
    I1 is I+1,
    cekTangkap(I1,Count,N).


lihatCommand:-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, 0, C), listpemain(C, N, X, Y),
    cekMain(A,X,Y,Count),
    write(Count), write('. ambilKartu'), nl,
    Count is Count+1,
    cekTantang(A, Count),
    cekUni(X,Count),
    jumlahPemain(N),
    cekTangkap(0,Count,N),
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl
    write('3. cekInfo'), nl.


/*
cekKartuSaja(_,_,_,_,[],[]): !, fail.
cekKartuSaja(A, B, X1, Y1, X, Y):-
    A>0,
    A<10,
    B :== Y1,
    !.
cekKartuSaja(A, B, X1, Y1, X, Y):-
    A>0,
    A<10,
    A =:= X1,
    !.


cekKartuSaja(A, B, X1, Y1, X, Y):-
    A :== 'skip',
    A :== X1,
    !.
cekKartuSaja(A, B, X1, Y1, X, Y):-
    A :== 'skip',
    B :== Y1,
    !.


cekKartuSaja(A, B, X1, Y1, X, Y):-
    A :== 'reverse',
    A :== X1,
    !.
cekKartuSaja(A, B, X1, Y1, X, Y):-
    A :== 'reverse',
    B :== Y1,
    !.


cekKartuSaja(A, B, X1, Y1, X, Y):-
    A :== 'drawtwo'
    A /== X1,
    B :== Y1,
    !.


cekKartuSaja(A, B, X1, Y1, X, Y):-
    A :== 'wild',
    A /== X1,
    B :== Y1,
    !.


cekKartuSaja(A, B, X1, Y1, [H1|T1], [H2|T2]):-
    cekKartuSaja(A, B, H1, H2, idx, T1, T2).


get_head([H|T],H).


tantangan(C,D,X1,Y1,X,Y):-
    \+cekKartuSaja(C,D,X1,Y1,X,Y),
    ambilKartu.
tantangan(C,D,X1,Y1,X,Y):-
    cekKartuSaja(C,D,X1,Y1,X,Y),
    ambilKartu.


tantang:-
    urutanGiliran(R1),
    urutanSekarang(U1, Rot),
    jumlahPemain(N),
    U2 is U1-Rot mod N,
    top_card(A, _),
    top_card_sebelumnya(C,D),
    get_element(R1, U2, C), listpemain(C, N, X, Y),
    get_head(X,X1),
    get_head(Y,Y1).
    A :== 'wilddrawfour',
    write('Tantangan dilakukan!'),
    nl,
    nl,
    write('Memeriksa kartu '), write(N),
    tantangan(C,D,X1,Y1,X,Y),


*/





