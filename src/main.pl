:- dynamic(jumlahPemain/1).
:- dynamic(listpemain/4). /* (Id, Nama, ListKartu, ListWarna) */
:- dynamic(urutanGiliran/1). /* listID hasil urutan */ 
:- dynamic(top_card/2). /* Menandakan kartu apa yang paling atas */
:- include('file1.pl').

get_element([Element|_], 0, Element).
get_element([_|Tail], Index, Element) :- Index > 0, NI is Index - 1, get_element(Tail, NI, Element).

cek_pemain(X, X) :- 
    X >= 2, 
    X =< 4, !.
cek_pemain(_, Y) :- 
    write('Mohon masukan angka antara 2-4: '),
    read(Z), nl,
    cek_pemain(Z, Y).

cek_nama(X, X) :- 
    \+ listpemain(_, X, _, _), !.
cek_nama(_, Y) :- 
    write('Nama sudah digunakan. Masukan nama lain: '),
    read(Z), nl,
    cek_nama(Z, Y).

input_pemain(-1, _).
input_pemain(X, Y) :- 
    X >= 0,
    write('Masukan nama pemain '),
    Y1 is Y - X,
    write(Y1),
    write(': '),
    read(Z),
    cek_nama(Z, Z1),
    assertz(listpemain(Y1, Z1, [], [])),
    X1 is X - 1,
    input_pemain(X1, Y).

buat_list(_, 0, []).
buat_list(X, X, [X|T]) :- 
    X > 0, 
    X1 is X - 1, 
    buat_list(X1, X1, T).

start_kartu(0).
start_kartu(XValid):-
    XValid > 0,
    listpemain(XValid, Nama, _, _),
    ambil_7_kali(KartuBaru, WarnaBaru, 7),
    retract(listpemain(XValid, Nama, _, _)),
    assertz(listpemain(XValid, Nama, KartuBaru, WarnaBaru)),
    X1 is XValid - 1,
    start_kartu(X1).

printurutan([T]) :- 
    listpemain(T, Nama, _, _), 
    write(Nama), 
    write('.'), nl.
printurutan([H|T]):- 
    listpemain(H, Nama, _, _),
    write(Nama),
    write(' - '),
    printurutan(T).

startGame :- 
    write('Masukan jumlah pemain: '), 
    read(X), 
    cek_pemain(X, XValid),
    nl,
    X1 is XValid - 1,
    input_pemain(X1, XValid),
    assertz(jumlahPemain(XValid)),
    buat_list(XValid, XValid, R), 
    permutation(R, R1), !, 
    assertz(urutanGiliran(R1)), 
    write('Urutan pemain: '), 
    printurutan(R1),
    start_kartu(XValid),
    write('Setiap pemain mendapatkan 7 kartu acak'), nl,
    ambil_kartu_top(A, B),
    assertz(top_card(A, B)),
    write('Kartu discard top: '), write(B), write('-'), write(A), nl,
    write('Giliran '), get_element(R1, 0, C), listpemain(C, N, _, _), write(N), write('.'),nl.

count([],0).
count([_|T], X) :- count(T, X1), X is X1 + 1.

cetakpemain(0).
cetakpemain(X):- 
    X > 0,
    X1 is X - 1,
    cetakpemain(X1),
    listpemain(X, Y, Z, _),
    write('Nama pemain '),
    write(X), write(': '), write(Y), nl,
    count(Z, N),
    write('Jumlah kartu : '), write(N), nl, nl.

cekInfo :-
    top_card(X, Y), !,
    write('Kartu discard top: '),
    write(X), write('-'), write(Y), write(.),nl,nl,
    write('Urutan pemain: '),
    urutanGiliran(Z),
    printurutan(Z), nl, nl,
    jumlahPemain(P),
    cetakpemain(P).



    
    

    