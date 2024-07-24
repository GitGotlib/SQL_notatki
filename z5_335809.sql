--tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00
/*
Z5.1

Pokazać MAX pensję w każdym z miast ale tylko w tych w których średnia pensja (AVG) jest
pomiędzy A_MIN a A_MAX - proszę sobie wybrać
*/

DECLARE @M INT
DECLARE CC INSENSITIVE CURSOR FOR SELECT M.ID_MIASTA FROM MIASTA M 
OPEN CC
FETCH NEXT FROM CC INTO @M
WHILE @@FETCH_STATUS = 0
BEGIN
IF EXISTS
(SELECT AVG(E.PENSJA) AS SREDNIA_W_MIESCIE 
FROM MIASTA M
JOIN FIRMY F ON (F.ID_MIASTA = M.ID_MIASTA)
JOIN ETATY E ON (E.ID_FIRMY = F.ID_FIRMY)
WHERE M.ID_MIASTA = @M
GROUP BY M.NAZWA
HAVING AVG(E.PENSJA) < 7000 AND AVG(E.PENSJA) > 5000)-- OR AVG(E.PENSJA) IS NULL)
BEGIN
SELECT MAX(E.PENSJA) AS MAX_W_MIESCIE, AVG(E.PENSJA) AS SREDNIA_W_MIESCIE, LEFT(M.NAZWA,20) AS MIASTO
FROM MIASTA M
JOIN FIRMY F ON (F.ID_MIASTA = M.ID_MIASTA)
JOIN ETATY E ON (E.ID_FIRMY = F.ID_FIRMY)
WHERE M.ID_MIASTA = @M 
GROUP BY M.NAZWA
END
FETCH NEXT FROM CC INTO @M
END
CLOSE CC
DEALLOCATE CC 
GO
/*
MAX_W_MIESCIE SREDNIA_W_MIESCIE MIASTO
------------- ----------------- --------------------
7500          6290              WARSZAWA

(1 row affected)

MAX_W_MIESCIE SREDNIA_W_MIESCIE MIASTO
------------- ----------------- --------------------
7000          5875              OSIECK

(1 row affected)

MAX_W_MIESCIE SREDNIA_W_MIESCIE MIASTO
------------- ----------------- --------------------
6000          6000              SOPOT

(1 row affected)
*/
/*
Z5.2
Proszę pokazać które miasto ma najwięcej etatów w bazie
etaty osób mieszkających w miastach
Wymaga zapytania z grupowaniem i szukania po wyniku
*/

if object_id('tempdb..#O') is not null
	drop table #O
GO
SELECT E.ID_OSOBY, COUNT(E.ID_ETATU) AS LICZBA_ETATOW
INTO #O
	FROM ETATY E
	GROUP BY E.ID_OSOBY

SELECT M.*, #O.LICZBA_ETATOW
	FROM #O
	JOIN OSOBY O ON (#O.ID_OSOBY = O.ID_OSOBY)
	JOIN MIASTA M ON (M.ID_MIASTA = O.ID_MIASTA)
	WHERE #O.LICZBA_ETATOW = 
		(SELECT MAX(OM.LICZBA_ETATOW) AS MAX_LICZBA_ETATÓW
			FROM #O OM
		)
/*
(8 rows affected)
ID_MIASTA   KOD_WOJ NAZWA                                                                                                LICZBA_ETATOW
----------- ------- ---------------------------------------------------------------------------------------------------- -------------
1           MAZ     WARSZAWA                                                                                             7

(1 row affected)
*/
/*
Z5.3

Proszę dodać tabelę
CECHY (idc nchar(4) not null constraint PK_CECHY, opis nvarchar(100) not null)

Wpisac rekordy
N, Najlepszy
NZ, Największe zarobki
SK, Super koledzy
ŁP, Łatwe pieniądze
SA, Super Zespół
K, Kierownicze

i jeszcze ze 3

I stworzyć tabele ETATY_CECHY (id_etatu, idc)
obydwa jako klucze obce do tabel ETATY orac CECHY a klucz głowny jako para id_etatu, idc

Stworyć zapytanie pokazujące etaty mające cechy SK, ŁP, NZ - wszystkie trzy muszą mieć
Oraz etaty mające wszystkie powyższe (dodać ze 2) lub mniej
posortować w kolejności od etatów mających najwięcej wybranych cech

Pozdrawiam
Maciej
*/
IF OBJECT_ID('ETATY_CECHY') IS NOT NULL
    DROP TABLE ETATY_CECHY
GO
IF OBJECT_ID('CECHY') IS NOT NULL
    DROP TABLE CECHY
GO

CREATE TABLE dbo.CECHY
(
    IDC NCHAR(4) NOT NULL CONSTRAINT PK_CECHY PRIMARY KEY,
    OPIS NVARCHAR(100) NOT NULL
)
GO
CREATE TABLE dbo.ETATY_CECHY
(
    ID_ETATU INT NOT NULL CONSTRAINT FK_ETATY_CECHY_ETATY FOREIGN KEY REFERENCES ETATY(ID_ETATU),
    IDC NCHAR(4) NOT NULL CONSTRAINT FK_ETATY_CECHY_CECHY FOREIGN KEY REFERENCES CECHY(IDC),
	CONSTRAINT PK_ETATY_CECHY PRIMARY KEY (ID_ETATU, IDC)
)
GO
INSERT INTO CECHY (idc, opis) VALUES ('N', N'Najlepszy')
INSERT INTO CECHY (idc, opis) VALUES ('NZ', N'Największe zarobki')
INSERT INTO CECHY (idc, opis) VALUES ('SK', N'Super koledzy')
INSERT INTO CECHY (idc, opis) VALUES ('LP', N'Łatwe pieniądze')
INSERT INTO CECHY (idc, opis) VALUES ('SA', N'Super Zespół')
INSERT INTO CECHY (idc, opis) VALUES ('K', N'Kierownicze')
INSERT INTO CECHY (idc, opis) VALUES ('EG', N'Elastyczny grafik')
INSERT INTO CECHY (idc, opis) VALUES ('PD', N'Praca dodatkowa')
INSERT INTO CECHY (idc, opis) VALUES ('PS', N'Praca sezonowa')

INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'N')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'NZ')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'SK')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'LP')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'SA')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'K')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'EG')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'PD')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (1, 'PS')

INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'N')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'NZ')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'SK')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'LP')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'SA')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'K')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'EG')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'PD')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (4, 'PS')

INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (7, 'NZ')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (7, 'SK')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (7, 'LP')

INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (5, 'NZ')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (5, 'SK')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (5, 'LP')

INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (2, 'N')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (2, 'NZ')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (3, 'SK')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (12, 'LP')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (6, 'SA')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (8, 'K')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (9, 'EG')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (10, 'PD')
INSERT INTO ETATY_CECHY (ID_ETATU, IDC) VALUES (11, 'PS')

if object_id('tempdb..#C') is not null
	drop table #C
GO
CREATE TABLE #C (IDC NCHAR(4) NOT NULL)
INSERT INTO #C (IDC) VALUES ('SK')
INSERT INTO #C (IDC) VALUES ('LP')
INSERT INTO #C (IDC) VALUES ('NZ')
DECLARE @ILE_CECH INT
SELECT @ILE_CECH = COUNT(*) FROM #C

SELECT E.ID_ETATU, E.ID_FIRMY, COUNT(*) AS ILE_MA_WYM_CECH FROM ETATY E
JOIN ETATY_CECHY EC ON (EC.ID_ETATU = E.ID_ETATU)
JOIN #C C ON  (C.IDC = EC.IDC)
GROUP BY E.ID_ETATU, E.ID_FIRMY
HAVING COUNT(*) = 3
ORDER BY 3 DESC
GO

/*
ID_ETATU    ID_FIRMY    ILE_MA_WYM_CECH
----------- ----------- ---------------
1           1           3
4           1           3
5           4           3
7           6           3

(4 rows affected)
*/

if object_id('tempdb..#CC') is not null
	drop table #CC
GO
CREATE TABLE #CC (IDC NCHAR(4) NOT NULL)
INSERT INTO #CC (IDC) VALUES ('N')
INSERT INTO #CC (IDC) VALUES ('NZ')
INSERT INTO #CC (IDC) VALUES ('SK')
INSERT INTO #CC (IDC) VALUES ('LP')
INSERT INTO #CC (IDC) VALUES ('SA')
INSERT INTO #CC (IDC) VALUES ('K')
INSERT INTO #CC (IDC) VALUES ('EG')
INSERT INTO #CC (IDC) VALUES ('PD')
INSERT INTO #CC (IDC) VALUES ('PS')
DECLARE @ILE_CECH INT
SELECT @ILE_CECH = COUNT(*) FROM #CC

SELECT E.ID_ETATU, E.ID_FIRMY, COUNT(*) AS ILE_MA_WYM_CECH FROM ETATY E
JOIN ETATY_CECHY EC ON (EC.ID_ETATU = E.ID_ETATU)
JOIN #CC CC ON  (CC.IDC = EC.IDC)
GROUP BY E.ID_ETATU, E.ID_FIRMY
ORDER BY 3 DESC
GO
/*
ID_ETATU    ID_FIRMY    ILE_MA_WYM_CECH
----------- ----------- ---------------
1           1           9
4           1           9
5           4           3
7           6           3
2           3           2
3           4           1
6           5           1
8           7           1
9           3           1
10          1           1
11          6           1
12          1           1

(12 rows affected)
*/
