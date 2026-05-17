read_line_manual(Stream, Line) :-
    baca_karakter(Stream, Line).

baca_karakter(Stream, []) :-
    at_end_of_stream(Stream).

baca_karakter(Stream, []) :-
    peek_char(Stream, '\n'),
    get_char(Stream, '\n').

baca_karakter(Stream, [C|Rest]) :-
    get_char(Stream, C),
    C \= '\n',
    baca_karakter(Stream, Rest).

baca_file :-
    open('p.txt', read, Stream),

    read_line_manual(Stream, L1),
    read_line_manual(Stream, L2),

    close(Stream),

    proses_urutan(L1, Players),
    proses_giliran(L2, Giliran),

    kapital_semua(Players, PlayersKapital),

    write('urutan_tetap('),
    write(PlayersKapital),
    write(', \'kanan\')'),
    nl,

    buat_urutan_giliran(PlayersKapital, Giliran, HasilGiliran),

    write('urutan_giliran('),
    write(HasilGiliran),
    write(')'),
    nl.

proses_urutan(Chars, Players) :-
    cari_kurung_buka(Chars, Isi),
    ambil_sampai_tutup(Isi, ListChars),
    pecah_koma(ListChars, Players).

cari_kurung_buka(['['|T], T).

cari_kurung_buka([_|T], Hasil) :-
    cari_kurung_buka(T, Hasil).

ambil_sampai_tutup([']'|_], []).

ambil_sampai_tutup([H|T], [H|Rest]) :-
    ambil_sampai_tutup(T, Rest).

pecah_koma([], []).

pecah_koma(List, [Atom|Rest]) :-
    ambil_sampai_koma(List, Nama, Sisa),
    name(Atom, Nama),
    lanjut_pecah(Sisa, Rest).

ambil_sampai_koma([], [], []).

ambil_sampai_koma([','|T], [], T).

ambil_sampai_koma([H|T], [H|Rest], Sisa) :-
    H \== (','),
    ambil_sampai_koma(T, Rest, Sisa).

lanjut_pecah([], []).

lanjut_pecah(Sisa, Rest) :-
    pecah_koma(Sisa, Rest).

proses_giliran(Chars, GiliranKapital) :-
    ambil_setelah_kolon(Chars, NamaChars),
    name(Nama, NamaChars),
    kapital_awal(Nama, GiliranKapital).

ambil_setelah_kolon([':'|T], T).

ambil_setelah_kolon([_|T], Hasil) :-
    ambil_setelah_kolon(T, Hasil).

kapital_semua([], []).

kapital_semua([H|T], [Hasil|Rest]) :-
    kapital_awal(H, Hasil),
    kapital_semua(T, Rest).

kapital_awal(Atom, Hasil) :-
    name(Atom, [Awal|Sisa]),
    huruf_besar(Awal, Besar),
    name(HasilAtom, [Besar|Sisa]),
    tambah_quote(HasilAtom, Hasil).

tambah_quote(Atom, Hasil) :-
    name(Atom, Chars),
    append_manual(['\''], Chars, Temp),
    append_manual(Temp, ['\''], Final),
    name(Hasil, Final).

buat_urutan_giliran(List, Giliran, Hasil) :-
    putar_sampai(List, Giliran, Hasil).

putar_sampai([Giliran|T], Giliran, [Giliran|T]).

putar_sampai([H|T], Giliran, Hasil) :-
    append_manual(T, [H], Baru),
    putar_sampai(Baru, Giliran, Hasil).


append_manual([], L, L).

append_manual([H|T], L, [H|R]) :-
    append_manual(T, L, R).

huruf_besar(a,'A').
huruf_besar(b,'B').
huruf_besar(c,'C').
huruf_besar(d,'D').
huruf_besar(e,'E').
huruf_besar(f,'F').
huruf_besar(g,'G').
huruf_besar(h,'H').
huruf_besar(i,'I').
huruf_besar(j,'J').
huruf_besar(k,'K').
huruf_besar(l,'L').
huruf_besar(m,'M').
huruf_besar(n,'N').
huruf_besar(o,'O').
huruf_besar(p,'P').
huruf_besar(q,'Q').
huruf_besar(r,'R').
huruf_besar(s,'S').
huruf_besar(t,'T').
huruf_besar(u,'U').
huruf_besar(v,'V').
huruf_besar(w,'W').
huruf_besar(x,'X').
huruf_besar(y,'Y').
huruf_besar(z,'Z').