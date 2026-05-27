loadGame:-
    write('Masukkan nama file yang akan dimuat: '),
    read(Nama),
    name(Nama, NamaList),          
    gabung(NamaList, [46,116,120,116], FileList),
    name(FileName, FileList),
    baca_file(FileName).

baca_file(Link):-
    open(Link,read,Stream),
    read(Stream, urutan_pemain:X),
    read(Stream, giliran:Y),
    read(Stream, discard_top:_Z-A),
    read(Stream, warna_aktif:B),
    read(Stream, arah_permainan:Arah),
    read(Stream, status_UNI:ListUni),
    retractall(jumlahPemain(_)),
    count(X, N),
    asserta(jumlahPemain(N)),
    buat_list(N, N, R),

    retractall(urutantetap(_, _)),
    asserta(urutantetap(R, Arah)),

    retractall(urutanGiliran(_)),
    (Arah == 'kiri' -> reverse_list(R, Rbalik), asserta(urutanGiliran(Rbalik)); asserta(urutanGiliran(R))),
    
    reverse_list(X, RR),
    get_index(RR, Index, Y),
    Idx is Index + 1,
    
    atururutan(Idx),
    retractall(top_card(_,_)),
    retractall(top_card_sebelumnya(_,_)),
    asserta(top_card_sebelumnya(dummy, dummy)),
    asserta(top_card(A, B)),
    retractall(statusUni(_,_)),
    retractall(listpemain(_,_,_,_)),
    retractall(statusEfek(_)),
    asserta(statusEfek(off)),
    retractall(statusTantang(_)),
    asserta(statusTantang(0)),
    retractall(poin(_,_)),
    baca_kartu(N, Stream),
    setupUni(ListUni, X),
    close(Stream),
    write('Status permainan berhasil dimuat dari '), write(Link), write('.'), nl,
    write('Melanjutkan giliran '), write(Y), write('.').

setupUni(_, []).
setupUni(L, [H|T]):-
    listpemain(Id, H, _, _),
    (tidak_ada(H, L) -> asserta(statusUni(Id, off)); asserta(statusUni(Id, on))),
    setupUni(L, T).

tidak_ada(_, []).
tidak_ada(X, [H|T]) :-
    X \== H,
    tidak_ada(X, T).

atururutan(Y):-
    urutanGiliran([H|_]),
    H \== Y,
    putarGiliran,
    atururutan(Y).
atururutan(_).
    
get_index([Element|_], 0, Element).
get_index([_|Tail], Index, Element):-
    get_index(Tail, NewIndex, Element),
    Index is NewIndex + 1.

pisah([], [], []).
pisah([Warna-Nilai | T], [Nilai | TN], [Warna | TW]) :-
    pisah(T, TN, TW).

baca_kartu(0, _).
baca_kartu(N, Stream):-
    N > 0,
    N1 is N-1,
    baca_kartu(N1, Stream),
    read(Stream, kartu(Nama):K),
    pisah(K, TN, TW),
    asserta(poin(Nama, 0)),
    asserta(listpemain(N, Nama, TN, TW)).
    

