:- dynamic(jumlahPemain/1).
:- dynamic(listpemain/4). /* (Id, Nama, ListKartu, ListWarna) */
:- dynamic(urutanGiliran/1). /* listID hasil urutan */ 
:- dynamic(top_card/2). /* Menandakan kartu apa yang paling atas */
:- dynamic(statusEfek/1). /* on/off untuk efek kartu +2/+4 */
:- dynamic(statusTantang/1). /* 0: tidak melakukan tantang, 1: tantang gagal, 2: tantang berhasil
:- dynamic(urutantetap/2).
:- dynamic(top_card_sebelumnya/2). /* Digunakan ketika implementasi tantang */
:- dynamic(poin/2).
:- include('file1.pl').
:- include('file2.pl').
:- dynamic(statusUni/2). /*(Id, on/off)*/

resetUni(Id) :- retract(statusUni(Id, _)), assertz(statusUni(Id, off)), !.
resetUni(_).
setUni(Id)   :- retract(statusUni(Id, _)), assertz(statusUni(Id, on)).

statusEfek(off).

numberCek(0).
numberCek(1).
numberCek(2).
numberCek(3).
numberCek(4).
numberCek(5).
numberCek(6).
numberCek(7).
numberCek(8).
numberCek(9).

append_element([],E,[E]).
append_element([Head|Tail], Element, [Head|NewTail]):- append_element(Tail, Element, NewTail).


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
    assertz(statusUni(Y1, off)),
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
    write('.'), nl, !.
printurutan([H|T]):- 
    listpemain(H, Nama, _, _),
    write(Nama),
    write(' - '),
    printurutan(T), !.

startGame :- 
    write('Masukan jumlah pemain: '), 
    read(X), 
    cek_pemain(X, XValid),
    nl,
    X1 is XValid - 1,
    input_pemain(X1, XValid),
    assertz(jumlahPemain(XValid)),
    assertz(top_card_sebelumnya(a,b)),
    assertz(statusTantang(0)),
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
    statusTantang(0),
    urutanGiliran([X|_]),
    listpemain(X, _, _, _),
    top_card(Kartu, _),
    Kartu = drawtwo, !,
    ambilKartu(X, 2).

ambilKartu:-
    /*jika +4 maka ambil 4 kartu*/
    statusEfek(on),
    statusTantang(0),
    urutanGiliran([X|_]),
    listpemain(X, _, _, _),
    top_card(Kartu, _),
    Kartu = wilddrawfour, !,
    ambilKartu(X, 4).

ambilKartu:-
    statusEfek(on),
    statusTantang(1),
    !,
    urutanGiliran([X|_]),
    listpemain(X, _, _, _),
    ambilKartu(X, 6).

ambilKartu:-
    statusEfek(on),
    statusTantang(2),
    !,
    urutanGiliran([X|_]),
    listpemain(X, _, _, _),
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
    gabung(K_Lama, K_Baru, K_Total),
    gabung(W_Lama, W_Baru, W_Total),
    retract(listpemain(Id, Nama, K_Lama, W_Lama)),
    assertz(listpemain(Id, Nama, K_Total, W_Total)),
    resetUni(Id),
    matikan_status_efek,
    putarGiliran, 
    \+statusTantang(2),
    urutanGiliran(UrutanBaru),
    write('Urutan pemain: '),
    printurutan(UrutanBaru), nl,
    UrutanBaru = [NextId|_],
    listpemain(NextId, NamaNext, _, _),
    write('Giliran '), write(NamaNext), write('.'), nl.
ambilKartu(_,_):- !.

matikan_status_efek :- 
    statusEfek(on), 
    retract(statusEfek(on)), 
    assertz(statusEfek(off)), !.
matikan_status_efek.


reverse_list([], []).
reverse_list([H|T], R):-
    reverse_list(T, RT),
    append_element(RT, H, R).

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
    append_element(T, H, UrutanBaru),
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
    numberCek(X1),
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
    numberCek(A),
    A>=0,
    A<10,
    B == Y1,
    !.
cekKartu(A, _, X1, _):-
    numberCek(A),
    numberCek(X1),
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
    \+statusEfek(on),
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
    (count(X2, 0) -> endGame(C); 
        retract(top_card_sebelumnya(_,_)),
        assertz(top_card_sebelumnya(A,B))
    ).


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

ambilTail([],[]).
ambilTail([H],H).
ambilTail([_|T], Tail):-
    ambilTail(T,Tail).

removeTail([],[]).
removeTail([_],[]).
removeTail([H|T],[H|O1]):-
    removeTail(T,O1).
    
reversePutarGiliran:-
    urutanGiliran(R1),
    ambilTail(R1,Tail),
    removeTail(R1,R2),
    insert_head(Tail,R2,R3),
    retract(urutanGiliran(_)),
    assertz(urutanGiliran(R3)).


perhitunganpoint_extra([], _).
perhitunganpoint_extra([A], Nama):-
    \+numberCek(A),
    (A == 'skip' -> A1 is 10; true),
    (A == 'reverse' -> A1 is 10; true),
    (A == 'drawtwo' -> A1 is 10; true),
    (A == 'wilddrawfour' -> A1 is 20; true),
    (A == 'wild' -> A1 is 20; true),
    write(A1), write(' = '),
    poin(Nama, X),
    write(X), write(' poin'), nl.
perhitunganpoint_extra([A], Nama):-
    numberCek(A),
    (A is 0 -> write(1); write(A)),
    write(' = '),
    poin(Nama, X),
    write(X), write(' poin').
perhitunganpoint_extra([A|B], Nama):-
    numberCek(A),
    (A is 0 -> write(1); write(A)),
    write(' + '),
    perhitunganpoint_extra(B, Nama).
perhitunganpoint_extra([A|B], Nama):-
    \+numberCek(A),
    (A == 'skip' -> A1 is 10; true),
    (A == 'reverse' -> A1 is 10; true),
    (A == 'drawtwo' -> A1 is 10; true),
    (A == 'wilddrawfour' -> A1 is 20; true),
    (A == 'wild' -> A1 is 20; true),
    write(A1), write(' + '),
    perhitunganpoint_extra(B, Nama).

perhitunganpoint([], [], Nama) :- 
    write('kartu habis = 0 poin'),
    asserta(poin(Nama, 0)).
perhitunganpoint([A],[B], Nama):-
    numberCek(A),
    write(A),
    write('-'),
    write(B),
    write(' = '),
    poin(Nama, X),
    (A is 0 -> X1 is X + 1; X1 is X + A),
    retract(poin(Nama,_)),
    asserta(poin(Nama,X1)).
perhitunganpoint([A],[B], Nama):-
    \+numberCek(A),
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
    numberCek(H),
    write(H), write('-'), write(A), 
    write(' + '),
    poin(Nama, X),
    (H is 0 -> X1 is X + 1; X1 is X + H),
    retract(poin(Nama,_)),
    asserta(poin(Nama,X1)),
    perhitunganpoint(T, B, Nama).
perhitunganpoint([H|T], [A|B], Nama):-
    \+numberCek(H),
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

mergesort([],[]).
mergesort([A],[A]).
mergesort([A,B|R],S):-   
    split([A,B|R],L1,L2),   
    mergesort(L1,S1),   
    mergesort(L2,S2),   
    merge(S1,S2,S).
split([],[],[]).
split([A],[A],[]).
split([A,B|R],[A|Ra],[B|Rb]):-   
    split(R,Ra,Rb).
merge(A,[],A).
merge([],B,B).
merge([A|Ra],[B|Rb],[A|M]):-   
    A =< B, 
    merge(Ra,[B|Rb],M).
merge([A|Ra],[B|Rb],[B|M]):-   
    A > B, 
    merge([A|Ra],Rb,M).

point_list(X, [X1]):- X is 1, !, listpemain(X, N, _, _), poin(N, P), X1 is P.
point_list(X, [A|B]):- 
    X > 1,
    listpemain(X, N, _, _),
    poin(N,P),
    A is P,
    X1 is X - 1,
    point_list(X1, B).

cetakpemenang(_, []).
cetakpemenang(X, [H|T]):-
    write(X), write('. '),
    poin(Nama, H),
    write(Nama), write(' '),
    write('('), write(H), write(' poin)'),nl,
    X1 is X + 1,
    cetakpemenang(X1, T).

endGame(X):-
    jumlahPemain(N),
    listpemain(X, N1, _, _),
    write('Permainan selesai! '),
    write(N1),
    write(' menghabiskan semua kartunya!'),nl,nl,
    write('Berikut perhitungan poin sisa kartu.'),nl,
    printpoint(N),
    point_list(N, Pl),
    mergesort(Pl,Plurut),nl,
    write('Urutan pemenang:'),nl,
    cetakpemenang(1,Plurut),nl,
    get_element(Plurut,0,Poin),
    poin(Pemenang,Poin),
    write('Selamat, '), write(Pemenang), write(' menjadi pemenang!'),nl.


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
    count(X, Sum),
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

tantangan(A1,B1,X,Y,N):-
    \+cekSemuaKartu(A1,B1,X,Y,0,N),
    write('Tantangan gagal. '), nl,
    retract(statusTantang(_)),
    assertz(statusTantang(1)),
    ambilKartu,
    retract(statusTantang(_)),
    assertz(statusTantang(0)).
tantangan(A1,B1,X,Y,N):-
    cekSemuaKartu(A1,B1,X,Y,0,N),
    write('Tantangan berhasil. '), nl,
    retract(statusTantang(_)),
    assertz(statusTantang(2)),
    reversePutarGiliran,
    ambilKartu,
    putarGiliran,
    retract(statusTantang(_)),
    assertz(statusTantang(0)),
    urutanGiliran(R1),
    get_element(R1, 0, C), listpemain(C, N1, _, _),
    write('Giliran '), write(N1).
tantang:-
    statusEfek(off),
    write('Tantang tidak bisa dilakukan.').
tantang:-
    statusEfek(on),
    top_card(A, _),
    A \== 'wilddrawfour',
    write('Tantang tidak bisa dilakukan.').
tantang:-
    statusEfek(on),
    top_card(A, _),
    A == 'wilddrawfour',
    urutanGiliran(R1),
    top_card_sebelumnya(A1,B1),
    jumlahPemain(N),
    N1 is N-1,
    get_element(R1, N1, C), listpemain(C, N2, X, Y),
    write('Tantangan dilakukan!'),
    nl,
    nl,
    write('Memeriksa kartu '), write(N2), nl,
    count(X,N3),
    tantangan(A1,B1,X,Y,N3).

simpan_kartu([A],[B], Stream):-
    write(Stream, B), write(Stream,'-'), write(Stream,A).
simpan_kartu([A|C],[B|D], Stream):-
    write(Stream, B), write(Stream,'-'), write(Stream,A), write(Stream,','),
    simpan_kartu(C, D, Stream).

simpan_pemain(0, _).
simpan_pemain(N, Stream):-
    N > 0,
    N1 is N - 1,
    simpan_pemain(N1, Stream),
    listpemain(N, Nama, K, W),
    write(Stream, 'kartu('), write(Stream,'\''), write(Stream, Nama), write(Stream,'\''), write(Stream,'):['), 
    simpan_kartu(K, W, Stream),
    write(Stream,']'), write(Stream,'.'), nl(Stream).

list_nama([A],Stream):-
    listpemain(A,B,_,_),
    write(Stream,'\''), write(Stream, B), write(Stream,'\'').
list_nama([A|B],Stream):-
    listpemain(A,C,_,_),
    write(Stream, '\''), write(Stream, C), write(Stream,'\','),
    list_nama(B, Stream).

gabung([], L, L).
gabung([H|T], L2, [H|L3]) :-
    gabung(T, L2, L3).

list_uni(_, 0, _).
list_uni(N, K, Stream):-
    (
        statusUni(K, on) ->
            (
                N =:= 1 -> write(Stream, ',') ; true
            ),
            listpemain(K, Nama, _, _),
            write(Stream, '\''), write(Stream, Nama), write(Stream, '\''),
            N1 is 1
        ;
            N1 is N
    ),
    K1 is K - 1,
    list_uni(N1, K1, Stream).

tangkap(_) :-
    statusEfek(on),
    write('Perintah tidak valid.'), nl, !.

tangkap(NamaTarget) :-
    \+listpemain(_, NamaTarget, _, _),
    write('Pemain tidak ditemukan.'), nl, !.

tangkap(NamaTarget) :-
    urutanGiliran([IdSaya|_]),
    listpemain(IdSaya, NamaTarget, _, _),
    write('Tidak bisa menangkap diri sendiri.'), nl, !.

tangkap(NamaTarget) :-
    listpemain(IdTarget, NamaTarget, KartuTarget, _),
    count(KartuTarget, JumlahKartu),
    statusUni(IdTarget, StatusUni),
    JumlahKartu =:= 1,
    StatusUni == off,
    !,
    write(NamaTarget), write(' tertangkap tidak menyerukan UNI.'), nl,
    write(NamaTarget), write(' mendapatkan 2 kartu penalti.'), nl,
    ambilKartu(IdTarget, 2).

tangkap(_) :-
    urutanGiliran([IdSaya|_]),
    listpemain(IdSaya, NamaSaya, _, _),
    write('Tuduhan salah! '),
    write(NamaSaya), write(' mendapat 1 kartu penalti.'), nl,
    ambilKartu(IdSaya, 1).


saveGame:-
    statusEfek(on), !,
    write('Perintah ini tidak dapat dilakukan').
saveGame:-
    jumlahPemain(N),
    write('Masukkan nama file penyimpanan: '),
    read(Nama),
    name(Nama, NamaList),          
    gabung(NamaList, [46,116,120,116], FileList),
    name(FileName, FileList),      
    open(FileName, write, Stream),
    write(Stream, 'urutan_pemain:['),
    urutantetap(X, Y),
    list_nama(X, Stream),
    write(Stream,'].'),nl(Stream),
    urutanGiliran([H|_]),
    listpemain(H, Nama2,_,_),
    write(Stream, 'giliran:'), write(Stream,'\''), write(Stream,Nama2),  write(Stream,'\''), write(Stream,'.'),nl(Stream),
    top_card(A, B),
    ((A == wild ; A == wilddrawfour) -> C = hitam; C = B),
    write(Stream,'discard_top:'), write(Stream,C), write(Stream,'-'),write(Stream,A),write(Stream,'.'),nl(Stream),
    write(Stream, 'warna_aktif:'), write(Stream,B), write(Stream,'.'),nl(Stream),
    write(Stream, 'arah_permainan:'), write(Stream, Y),write(Stream,'.'), nl(Stream),
    write(Stream,'status_UNI:['),
    list_uni(0, N, Stream),
    write(Stream,'].'),nl(Stream),
    simpan_pemain(N, Stream),
    close(Stream),
    write('Status permainan berhasil disimpan ke '),
    write(FileName),
    write('.'),
    nl.
    
semuaSatuKartu(0).
semuaSatuKartu(N) :-
    N > 0,
    listpemain(N, _, Kartu, _),
    count(Kartu, 1),
    N1 is N - 1,
    semuaSatuKartu(N1).

pilihIdAcak(N, Id) :-
    N1 is N + 1,
    random(1, N1, Id).

pilihPemainAcakDenganKartu(N, Id) :-
    pilihIdAcak(N, Id),
    listpemain(Id, _, Kartu, _),
    count(Kartu, J),
    J > 1, !.
pilihPemainAcakDenganKartu(N, Id) :-
    pilihPemainAcakDenganKartu(N, Id).

pilihPemainAcakSelain(N, IdKecuali, Id) :-
    pilihIdAcak(N, Id),
    Id =\= IdKecuali, !.
pilihPemainAcakSelain(N, IdKecuali, Id) :-
    pilihPemainAcakSelain(N, IdKecuali, Id).

pindahKartu(IdAsal, IdTujuan, Idx) :-
    listpemain(IdAsal,   NamaAsal,   KAsal,   WAsal),
    listpemain(IdTujuan, NamaTujuan, KTujuan, WTujuan),
    get_element(KAsal, Idx, Kartu),
    get_element(WAsal, Idx, Warna),
    removeListIdx(KAsal, WAsal, KAsalBaru, WAsalBaru, Idx),
    retract(listpemain(IdAsal, NamaAsal, _, _)),
    assertz(listpemain(IdAsal, NamaAsal, KAsalBaru, WAsalBaru)),
    append_element(KTujuan, Kartu, KTujuanBaru),
    append_element(WTujuan, Warna, WTujuanBaru),
    retract(listpemain(IdTujuan, NamaTujuan, _, _)),
    assertz(listpemain(IdTujuan, NamaTujuan, KTujuanBaru, WTujuanBaru)),
    write('Kartu '), write(Warna), write('-'), write(Kartu),
    write(' milik '), write(NamaAsal),
    write(' berpindah ke tangan '), write(NamaTujuan), write('!'), nl.
godsHand :-
    jumlahPemain(N),
    semuaSatuKartu(N), !,
    write('Semua pemain hanya memiliki 1 kartu, WOWOK tidak mau ikut campur.'), nl.
godsHand :-
    random(0, 100, Roll),
    Roll >= 20, !,
    write('Hmmm.. mungkin kamu adalah ANTEK ASING sehingga WOWOK tidak berkehendak untuk membantumu.'), nl.
godsHand :-
    jumlahPemain(N),
    write('WOWOK telah berkehendak.'), nl,
    pilihPemainAcakDenganKartu(N, IdAsal),
    listpemain(IdAsal, _, KAsal, _),
    count(KAsal, JmlKartu),
    random(0, JmlKartu, IdxKartu),
    pilihPemainAcakSelain(N, IdAsal, IdTujuan),
    pindahKartu(IdAsal, IdTujuan, IdxKartu),
    putarGiliran,
    urutanGiliran([NextId|_]),
    listpemain(NextId, NamaNext, _, _),
    write('Giliran '), write(NamaNext), write('.'), nl.


wowoksHand :- write('yu no boll'), nl, godsHand.