:- dynamic(jumlahPemain/1).
:- dynamic(listpemain/4). /* (Id, Nama, ListKartu, ListWarna) */
:- dynamic(urutanGiliran/1). /* listID hasil urutan */ 
kartu([0,1,2,3,4,5,6,7,8,9,'skip','reverse','drawtwo','wild','wilddrawfour'], ['merah','kuning','hijau','biru']).

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
    buat_list(XValid, XValid, R),
    permutation(R, R1),
    assertz(urutanGiliran(R1)),
    write('Urutan pemain: '),
    printurutan(R1).

    
    

    