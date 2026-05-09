kartu([0,1,2,3,4,5,6,7,8,9,'skip','reverse','drawtwo','wild','wilddrawfour'], ['merah','kuning','hijau','biru']).
get([Element|_], 0, Element).
get([_|Tail], Index, Element) :- Index > 0, NI is Index - 1, get(Tail, NI, Element).

ambil_kartu_acak(X, Y):- random(0, 15, P), kartu(A, B), get(A, P, X), X = 'wild', !, Y = 'hitam'.
ambil_kartu_acak(X, Y):- random(0, 15, P), kartu(A, B), get(A, P, X), X = 'wilddrawfour', !, Y = 'hitam'.
ambil_kartu_acak(X, Y) :- random(0, 15, P), random(0, 4, Q), kartu(A, B), get(A, P, X), get(B, Q, Y).

ambil_kartu_top(X,Y) :- random(0, 10, P), random(0, 4, Q), kartu(A, B), get(A, P, X), get(B, Q, Y).

ambil_7_kali([], [], 0).
ambil_7_kali([H|T], [A|B], N) :-
    N > 0,
    ambil_kartu_acak(H, A),
    N1 is N - 1,
    ambil_7_kali(T, B, N1).
