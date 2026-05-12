:- dynamic(jumlahPemain/1).
:- dynamic(listpemain/4). /* (Id, Nama, ListKartu, ListWarna) */
:- dynamic(urutanGiliran/1). /* listID hasil urutan */ 
:- dynamic(top_card/2). /* Menandakan kartu apa yang paling atas */
:- dynamic(statusEfek/1). /* on/off untuk efek kartu +2/+4 */
:- dynamic(top_card_sebelumnya/2). /* Digunakan ketika implementasi tantang */
:- dynamic(urutantetap/2).
:- dynamic(poin/2).
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
    asserta(poin(Z1, 0)),
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
    assertz(urutantetap(R1,'kanan')),
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


reverse_list([], []).
reverse_list([H|T], R):-
    reverse_list(T, RT),
    append(RT, [H], R).

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


top_card_sebelumnya(a,b).

insert_head(H, [], [H]).
insert_head(H, T, [H|T]).

removeListIdx([_|T1], [_|T2], T1, T2, 0).
removeListIdx([H1|T1], [H2|T2], X, Y, Idx):-
    Idx>0,
    I is Idx-1,
    removeListIdx(T1, T2, X1, Y1, I),
    insert_head(H1,X1,X),
    insert_head(H2,Y1,Y).

cekKartuValid(K):-
    urutanGiliran(R1),
    get_element(R1, 0, C), listpemain(C, _, X, _),
    count(X,Sum),
    S is Sum+1,
    K<S,
    K>=1.

validasiwarna('merah').
validasiwarna('biru').
validasiwarna('kuning').
validasiwarna('hijau').
pilihWarna(Y, Z):-
    \+validasiwarna(Y),
    nl,
    write('Warna tidak valid, input lagi:'),
    read(Y1),
    pilihWarna(Y1, Z).
pilihWarna(Y, Y):-
    validasiwarna(Y).
    
cekAngka(X1,Y1):-
    number(X1),
    X1>=0,
    X1<10,
    putarGiliran,
    retract(top_card(_,_)),
    assertz(top_card(X1,Y1)),
    urutanGiliran(R2),
    get_element(R2, 0, C2), listpemain(C2, N2, _, _),
    write('Giliran '), write(N2), nl.
cekAngka(_,_).

cekSkip(X1,Y1):-
    X1 == 'skip',
    write('Pemain berikutnya kehilangan giliran.'), nl, nl,
    putarGiliran,
    putarGiliran,
    retract(top_card(_,_)),
    assertz(top_card(X1,Y1)),
    urutanGiliran(R2),
    get_element(R2, 0, C2), listpemain(C2, N2, _, _),
    write('Giliran '), write(N2), nl.
cekSkip(_,_).

cekReverse(X1,Y1):-
    X1 == 'reverse',
    urutantetap(R1,Arah),
    (Arah = 'kanan' -> Arah1 = 'kiri'; Arah1 = 'kanan'),
    retract(urutantetap(_,_)),
    asserta(urutantetap(R1,Arah1)),
    urutanGiliran([H|T]),
    reverse_list([H|T],R),
    retract(urutanGiliran(_)),
    assertz(urutanGiliran(R)),
    retract(top_card(_,_)),
    assertz(top_card(X1,Y1)),
    urutanGiliran(R2),
    get_element(R2, 0, C2), listpemain(C2, N2, _, _),
    write('Giliran '), write(N2), nl.
cekReverse(_,_).

cekWild(X1):-
    X1 == 'wild',
    write('Pilih warna: '),
    read(Y2),
    nl,
    pilihWarna(Y2,Y3),
    putarGiliran,
    retract(top_card(_,_)),
    assertz(top_card(X1,Y3)),
    urutanGiliran(R2),
    get_element(R2, 0, C2), listpemain(C2, N2, _, _),
    write('Giliran '), write(N2), nl.
cekWild(_).

cekDrawTwo(X1,Y1):-
    X1 == 'drawtwo',
    retract(statusEfek(_)),
    assertz(statusEfek(on)),
    putarGiliran,
    retract(top_card(_,_)),
    assertz(top_card(X1,Y1)),
    ambilKartu.
cekDrawTwo(_,_).

cekDrawFour(X1):-
    X1 == 'wilddrawfour',
    write('Pilih warna: '),
    read(Y2),
    nl,
    pilihWarna(Y2,Y3),
    retract(statusEfek(_)),
    assertz(statusEfek(on)),
    putarGiliran,
    retract(top_card(_,_)),
    assertz(top_card(X1,Y3)),
    urutanGiliran(R2),
    get_element(R2, 0, C2), listpemain(C2, N2, _, _),
    write('Giliran '), write(N2), nl.
cekDrawFour(_).

cekKartu(A, B, _, Y1):-
    number(A),
    A>=0,
    A<10,
    B == Y1,
    !.
cekKartu(A, _, X1, _):-
    number(A),
    number(X1),
    A>=0,
    A<10,
    A =:= X1,
    !.

cekKartu(A, _, X1, _):-
    A == 'skip',
    A == X1,
    !.
cekKartu(A, B, _, Y1):-
    A == 'skip',
    B == Y1,
    !.

cekKartu(A, _, X1, _):-
    A == 'reverse',
    A == X1,
    !.
cekKartu(A, B, _, Y1):-
    A == 'reverse',
    B == Y1,
    !.

cekKartu(A, B, X1, Y1):-
    A == 'drawtwo',
    A \== X1,
    B == Y1,
    !.

cekKartu(A, B, X1, Y1):-
    A == 'wild',
    A \== X1,
    B == Y1,
    !.

cekKartu(A, B, X1, Y1):-
    A == 'wilddrawfour',
    A \== X1,
    B == Y1,
    !.

cekKartu(A, _, X1, _):-
    X1 == 'wild',
    A \== 'wild',
    !.

cekKartu(A, _, X1, _):-
    X1 == 'wilddrawfour',
    A \== 'wilddrawfour',
    !.


mainkanKartu(_):-
    statusEfek(on),
    write('Perintah tidak valid.'),
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
    get_element(R1, 0, C), listpemain(C, _, X, Y),
    cekKartuValid(K),
    Idx is K-1,
    get_element(X,Idx,X1),
    get_element(Y,Idx,Y1),
    \+cekKartu(A, B, X1, Y1),
    !,
    write('Kartu tidak valid!'),
    nl.
mainkanKartu(K):-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, 0, C), listpemain(C, N, X, Y),
    cekKartuValid(K),
    Idx is K-1,
    get_element(X,Idx,X1),
    get_element(Y,Idx,Y1),
    cekKartu(A, B, X1, Y1),
    nl,
    write(N), write(' memainkan kartu: '),
    write(Y1), write('-'), write(X1),
    nl, nl,
    removeListIdx(X, Y, X2, Y2, Idx),
    retract(listpemain(C,N,_,_)),
    assertz(listpemain(C,N,X2,Y2)),
    cekAngka(X1,Y1),
    cekSkip(X1,Y1),
    cekReverse(X1,Y1),
    cekDrawTwo(X1,Y1),
    cekWild(X1),
    cekDrawFour(X1),
    (count(X2, 0) -> endGame(C); true),
    retract(top_card_sebelumnya(_,_)),
    assertz(top_card_sebelumnya(A,B)).


listkosong([],[],1).
listkosong([_|_],[],0).
listkosong([],[_|_],0).
listkosong([_|_],[_|_],0).


ceksalah(1).
cekSemuaKartu(_,_,_,_,N,N):- !, ceksalah(0).
cekSemuaKartu(A,B,X,Y,Count,N):-
    get_element(X,Count,X1),
    get_element(Y,Count,Y1),
    \+cekKartu(A,B,X1,Y1),
    C1 is Count+1,
    cekSemuaKartu(A,B,X,Y,C1,N).
cekSemuaKartu(A,B,X,Y,Count,_):-
    get_element(X,Count,X1),
    get_element(Y,Count,Y1),
    cekKartu(A,B,X1,Y1),
    !.

cekMain(_,_,_,_,Out):-
    statusEfek(on),
    !,
    Out is 1.
cekMain(_,_,X,Y,Out):-
    listkosong(X,Y,1),
    !,
    Out is 1.
cekMain(A,B,X,Y,Out):-
    listkosong(X,Y,0),
    count(X,N),
    cekSemuaKartu(A,B,X,Y,0,N),
    !,
    write('1. mainkanKartu'), nl,
    Out is 2.
cekMain(_,_,_,_,Out):-
    Out is 1.

cekTantang(A, Count, Out):-
    A == 'wilddrawfour',
    statusEfek(on),
    !,
    write(Count), write('. tantang'), nl,
    Out is Count+1.
cekTantang(_,Count,Count).


cekUni(X,C, Out):-
    count(X,Sum),
    Sum =:= 2,
    !,
    write(C), write('. uni'), nl,
    Out is C+1.
cekUni(_,C,C).


cekTangkap(O2):-
    \+statusEfek(on),
    write(O2), write('. tangkap'), nl.
cekTangkap(_):-
    statusEfek(on).

lihatCommand:-
    urutanGiliran(R1),
    top_card(A, B),
    get_element(R1, 0, C), listpemain(C, _, X, Y),
    nl,
    write('Aksi utama yang tersedia:'), nl,
    cekMain(A,B,X,Y,Count),
    write(Count), write('. ambilKartu'), nl,
    C1 is Count+1,
    cekTantang(A, C1, O1),
    cekUni(X,O1,O2),
    cekTangkap(O2),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

perhitunganpoint_extra([], _).
perhitunganpoint_extra([A], Nama):-
    \+number(A),
    (A == 'skip' -> A1 is 10; true),
    (A == 'reverse' -> A1 is 10; true),
    (A == 'drawtwo' -> A1 is 10; true),
    (A == 'wilddrawfour' -> A1 is 20; true),
    (A == 'wild' -> A1 is 20; true),
    write(A1), write(' = '),
    poin(Nama, X),
    write(X), write(' poin'), nl.
perhitunganpoint_extra([A], Nama):-
    number(A),
    write(A), write(' = '),
    poin(Nama, X),
    write(X), write(' poin').
perhitunganpoint_extra([A|B], Nama):-
    number(A),
    write(A), write(' + '),
    perhitunganpoint_extra(B, Nama).
perhitunganpoint_extra([A|B], Nama):-
    \+number(A),
    (A == 'skip' -> A1 is 10; true),
    (A == 'reverse' -> A1 is 10; true),
    (A == 'drawtwo' -> A1 is 10; true),
    (A == 'wilddrawfour' -> A1 is 20; true),
    (A == 'wild' -> A1 is 20; true),
    write(A1), write(' + '),
    perhitunganpoint_extra(B, Nama).

perhitunganpoint([], [], Nama) :- 
    write('kartu habis = 0 point'),
    asserta(poin(Nama, 0)).
perhitunganpoint([A],[B], Nama):-
    number(A),
    write(A),
    write('-'),
    write(B),
    write(' = '),
    poin(Nama, X),
    X1 is X + A,
    retract(poin(Nama,_)),
    asserta(poin(Nama,X1)).
perhitunganpoint([A],[B], Nama):-
    \+number(A),
    (A == 'skip' -> A1 is 10; true),
    (A == 'reverse' -> A1 is 10; true),
    (A == 'drawtwo' -> A1 is 10; true),
    (A == 'wilddrawfour' -> A1 is 20; true),
    (A == 'wild' -> A1 is 20; true),
    write(A),
    write('-'),
    write(B),
    write(' = '),
    poin(Nama, X),
    X1 is X + A1,
    retract(poin(Nama,_)),
    asserta(poin(Nama,X1)).
perhitunganpoint([H|T], [A|B], Nama):-
    number(H),
    write(H), write('-'), write(A), 
    write(' + '),
    poin(Nama, X),
    X1 is X + H,
    retract(poin(Nama,_)),
    asserta(poin(Nama,X1)),
    perhitunganpoint(T, B, Nama).
perhitunganpoint([H|T], [A|B], Nama):-
    \+number(H),
    (H == 'skip' -> A1 is 10; true),
    (H == 'reverse' -> A1 is 10; true),
    (H == 'drawtwo' -> A1 is 10; true),
    (H == 'wilddrawfour' -> A1 is 20; true),
    (H == 'wild' -> A1 is 20; true),
    write(H), write('-'), write(A), 
    write(' + '),
    poin(Nama, X),
    X1 is X + A1,
    retract(poin(Nama,_)),
    asserta(poin(Nama,X1)),
    perhitunganpoint(T, B, Nama).

printpoint(0).
printpoint(Id):-
    Id > 0,
    Id1 is Id - 1,
    printpoint(Id1),
    listpemain(Id, Nama, Kartu, Warna),
    write(Nama), write(': '),
    perhitunganpoint(Kartu, Warna, Nama),
    perhitunganpoint_extra(Kartu, Nama), nl.

endGame(X):-
    jumlahPemain(N),
    listpemain(X, N1, _, _),
    write('Permainan selesai! '),
    write(N1),
    write(' menghabiskan semua kartunya!'),nl,nl,
    write('Berikut perhitungan poin sisa kartu.'),nl,
    printpoint(N).



