--tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00
/*
wkleić polecenia i pisac zapytania poproszę

Z3.1

pokazać firmy z województwa (wybrać)
w których nigdy nie pracowały osoby z miasta o nazwie
(wybrac nazwę)
*/

SELECT F.NAZWA, M.NAZWA AS MIASTO_FIRMY, M.KOD_WOJ AS KOD_WOJ
FROM FIRMY F
JOIN MIASTA M ON (F.ID_MIASTA = M.ID_MIASTA)
WHERE M.KOD_WOJ = 'MAZ' AND NOT EXISTS (
SELECT 1 FROM ETATY EO
JOIN OSOBY OO ON (OO.ID_OSOBY = EO.ID_OSOBY)
JOIN MIASTA MO ON (MO.ID_MIASTA = OO.ID_MIASTA) 
WHERE F.ID_FIRMY = EO.ID_FIRMY AND MO.ID_MIASTA = 2 --MIASTO OSIECK
)
/*WYNIK: NIE POKAZUJE FIRME TESLA KTÓRA ZNAJDUJE SIĘ W WOJ MAZOWIECKIM ALE W KTÓREJ JEST PRACOWNIK Z OSIECKU
NAZWA                                              MIASTO_FIRMY                                                                                         KOD_WOJ
-------------------------------------------------- ---------------------------------------------------------------------------------------------------- -------
FIRMA LENOWO                                       WARSZAWA                                                                                             MAZ 
FIRMA ASUS                                         WARSZAWA                                                                                             MAZ 
FIRMA DELL                                         WARSZAWA                                                                                             MAZ 
FIRMA SONY                                         OSIECK                                                                                               MAZ 
FIRMA SAMSUNG                                      OSIECK                                                                                               MAZ 

(5 rows affected)
*/
/*
Z3.2
Pokazać osoby które nigdy nie miały etatu na stanowisku (wybrać jakieś lub 2)
w firmach z województw (wybrać ze 2 nazwy)

Uzasadnić wynik, że faktycznie w tych WOJ są firmy
i faktycznie te osoby niepracowały nigdy w nich
*/
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES ( 4, 8, N'PROGRAMISTA', 6000, N'2010-05-01', NULL); --dodaje aktualny ETAT pracowniku Aleksandru Chaienko do firmy Apple w mieście Sopot województwa Pomorskiego jako programistę 
SELECT DISTINCT O.ID_MIASTA, O.imie, O.nazwisko, E.STANOWISKO
FROM OSOBY O
JOIN ETATY E ON (E.ID_OSOBY = O.ID_OSOBY)
WHERE (E.STANOWISKO = N'PROGRAMISTA' OR E.STANOWISKO = N'SPRZĄTAĆ' OR E.STANOWISKO = N'SEKRETARKA') 
AND NOT EXISTS (
    SELECT 1 
    FROM ETATY EW 
    JOIN FIRMY F ON (F.ID_FIRMY = EW.ID_FIRMY)
    JOIN MIASTA M ON (M.ID_MIASTA = F.ID_MIASTA)
    WHERE EW.ID_OSOBY = O.ID_OSOBY 
    AND (M.KOD_WOJ = 'POD' OR M.KOD_WOJ = 'POM')
)
/* W województwie Podlaskim jest tylko miasto Białystok które ma firmę Xiaomi a w województwie Pomorskim firmy Apple i Microsoft, gdzie ostatnia nie ma pracowników. 
W wyniku nie ma JAROSŁAW KACZUR który pracuje sprzątaczem w Xiaomi i innych firmach,
a także nie ma Aleksandra Chaienko który pracuje tylko w Apple programistą, a w Dell księgowym

ID_MIASTA   imie                                               nazwisko                                           STANOWISKO
----------- -------------------------------------------------- -------------------------------------------------- ----------------------------------------------------------------------------------------------------
1           HLIB                                               FILOBOK                                            SEKRETARKA
1           JAN                                                KOWALSKI                                           PROGRAMISTA

(2 rows affected)*/
/*
Z3.3
poszukać największą pensję w bazie i pokazać w jakiej firmie
i jaka osoba posiada
*/
--drop table #wynik
SELECT MAX(E.PENSJA) AS MAX_W_BAZIE 
INTO #WYNIK
FROM ETATY E

SELECT E.PENSJA AS MAKSYMALNA_PENSJA, O.imie AS IMIE, O.nazwisko AS NAZWISKO, F.NAZWA AS FIRMA
FROM ETATY E
JOIN #WYNIK W ON (W.MAX_W_BAZIE = E.PENSJA)
JOIN OSOBY O ON (O.ID_OSOBY = E.ID_OSOBY)
JOIN FIRMY F ON (F.ID_FIRMY = E.ID_FIRMY)

/* 
MAKSYMALNA_PENSJA IMIE                                               NAZWISKO                                           FIRMA
----------------- -------------------------------------------------- -------------------------------------------------- --------------------------------------------------
7500              MICHAŁ                                             WIŚNIEWSKI                                         FIRMA DELL

(1 row affected)
*/
/*
Z3.4
stworzyć tabelkę nowa_tab z kolumną kol1 nvarchar(100) not null
pod warunkiem ze takowej tabelki jeszcze nie ma
wstawic kilka wierszy i pokazać rekordy
*/
IF NOT EXISTS (
SELECT O.[ID], O.[NAME] 
FROM SYSOBJECTS O
WHERE (OBJECTPROPERTY(O.[ID],'ISUSERTABLE') = 1)
AND O.[NAME] = 'NOWA_TAB'
)
BEGIN CREATE TABLE DBO.NOWA_TAB
( KOL1 NVARCHAR(100) NOT NULL
)
END
GO
IF NOT EXISTS (SELECT * FROM NOWA_TAB)
BEGIN
INSERT INTO NOWA_TAB (KOL1) VALUES ('1_KOLUMNA'); 
INSERT INTO NOWA_TAB (KOL1) VALUES ('2_KOLUMNA'); 
INSERT INTO NOWA_TAB (KOL1) VALUES ('3_KOLUMNA'); 
INSERT INTO NOWA_TAB (KOL1) VALUES ('4_KOLUMNA'); 
END 
GO
SELECT * FROM NOWA_TAB

/*
KOL1
----------------------------------------------------------------------------------------------------
1_KOLUMNA
2_KOLUMNA
3_KOLUMNA
4_KOLUMNA

(4 rows affected)
*/
/*
Z3.5
Dodać kolummę nowa_kol DATETIME not null default GETDATE()
do tabelki nowa_tab
pod warunkiem,
ze w tej tabelce takiej kolumny jeszcze nie ma

wstawic kilka wierszy i pokazac rekordy
wstawiajać można ignorować nowa_kol - tam się dane wpiszą automatycznie

Pozdrawiam
Maciej
*/
IF NOT EXISTS (
SELECT O.[ID], O.[NAME] 
FROM SYSCOLUMNS O
WHERE O.[ID] = OBJECT_ID(N'NOWA_TAB') AND O.[NAME] = 'NOWA_KOL')
BEGIN
ALTER TABLE NOWA_TAB ADD NOWA_KOL DATETIME not null default GETDATE()
END 
GO
SELECT * FROM NOWA_TAB
/*
KOL1                                                                                                 NOWA_KOL
---------------------------------------------------------------------------------------------------- -----------------------
1_KOLUMNA                                                                                            2024-04-27 17:58:37.380
2_KOLUMNA                                                                                            2024-04-27 17:58:37.380
3_KOLUMNA                                                                                            2024-04-27 17:58:37.380
4_KOLUMNA                                                                                            2024-04-27 17:58:37.380

(4 rows affected)
*/


