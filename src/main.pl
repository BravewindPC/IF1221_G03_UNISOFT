:- dynamic(jumlahPemain/1).
:- dynamic(listpemain/4). /* (Id, Nama, ListKartu, ListWarna) */
:- dynamic(urutanGiliran/1). /* listID hasil urutan */ 
:- dynamic(top_card/2). /* Menandakan kartu apa yang paling atas */
:- dynamic(statusEfek/1). /* on/off untuk efek kartu +2/+4 */
:- include('file1.pl').
statusEfek(off).

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
    /*print */
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

ambilKartu:-
    /*liat kartu paling atas, kalo +2, ambil 2 kartu. perlu akses urutan turn dan tumpukan paling atas*/
    statusEfek(on),
    urutanGiliran([X|_]),
    listpemain(X, _, _, _),
    top_card(Kartu, _),
    Kartu = drawtwo, !,
    ambilKartu(X, 2).

ambilKartu:-
    /*jika +4 maka ambil 4 kartu*/
    statusEfek(on),
    urutanGiliran([X|_]),
    listpemain(X, _, _, _),
    top_card(Kartu, _),
    Kartu = wilddrawfour, !,
    ambilKartu(X, 4).

ambilKartu:- 
    /*jika bukan +2/+4 maka ambil 1 kartu*/
    urutanGiliran([X|_]), 
    listpemain(X, _, _, _),
    ambilKartu(X, 1).


ambilKartu(Id, JumlahKartu) :-
    listpemain(Id, Nama, K_Lama, W_Lama),
    ambilKartu(JumlahKartu, K_Baru, W_Baru),
    write(Nama), write(' mendapatkan '), write(JumlahKartu), write(' dengan rincian:'),
    printKartu(K_Baru, W_Baru), nl,
    append(K_Lama, K_Baru, K_Total),
    append(W_Lama, W_Baru, W_Total),
    retract(listpemain(Id, Nama, K_Lama, W_Lama)),
    assertz(listpemain(Id, Nama, K_Total, W_Total)),
    matikan_status_efek,
    putarGiliran, 
    urutanGiliran(UrutanBaru),
    write('Urutan pemain: '),
    printurutan(UrutanBaru), nl,
    UrutanBaru = [NextId|_],
    listpemain(NextId, NamaNext, _, _),
    write('Giliran '), write(NamaNext), write('.'), nl.

matikan_status_efek :- 
    statusEfek(on), 
    retract(statusEfek(on)), 
    assertz(statusEfek(off)), !.
matikan_status_efek.


ambilKartu(0, [], []) :- !.
ambilKartu(N, [K|SisaK], [W|SisaW]) :-
    N > 0,
    ambil_kartu_acak(K, W),
    N1 is N - 1,
    ambilKartu(N1, SisaK, SisaW).

printKartu([], []).
printKartu([K|SisaK], [W|SisaW]) :-
    write(W), write('-'), write(K),
    printKoma(SisaK),
    printKartu(SisaK, SisaW).
printKoma([_|_]) :- write(', ').
printKoma([]).

putarGiliran :-
    retract(urutanGiliran([H|T])),
    append(T, [H], UrutanBaru),
    assertz(urutanGiliran(UrutanBaru)).

lihatKartu :-
    urutanGiliran([IdPemain|_]),
    listpemain(IdPemain, _, ListKartu, ListWarna),
    write('Berikut kartu yang anda miliki.'), nl,
    tampilkanKartu(ListKartu, ListWarna, 1).

tampilkanKartu([], [], _).
tampilkanKartu([Kartu|TK], [Warna|TW], N) :-
    write(N), write('. '),
    write(Warna), write('-'), write(Kartu), nl,
    N1 is N + 1,
    tampilkanKartu(TK, TW, N1).
