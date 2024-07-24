/* 
** tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00
** wkleic ogloszenie z isod (co trzeba zrobic)

** Prosze wkleic do skryptu ogłoszenie
** Z2.1
** proszę dodać do tabeli miasta kolumne [data uzyskania praw miejskich]
** typu datetime NULL
** poustawiac wielu miastom tę danę
** UPDATE MIASTA SET [data uzyskania praw miejskich] = CONVERT(datetime, '1920130', 112) WHERE nazwa_skr = Tu_wstawiacie_jakis_id
** tak zeby minimum 50% miast miało tą daną wypełnioną
** wstawić kolumnę [od ilu lat prama miej] która wyliczy (virtualną)
** ile lat juz są te prawa miejskie. Załóżmy ze prawa są po 1930 r
** bo mogą być problemy z datami sprzed 1900 r
**
** zrobić zapytanie
** wszystkie miasta z 2 województw (wybrać dowolne 2)
** które mają prawa co najmniej X lat ale nie więcej jak Y lat
** proszę pamiętać o zapytaniach dla kolumn typu NULL
** trzeba sprawdzac najpierw czy nie ma tam NULL a potem
** dopiero porównywac wartości
**
** Z2.2
** zrobić zapytania pokazujące etaty
** dane etatu, nazwisko osoby, nazwa firmy, miast gdzie mieszka osoba, miasto gdzie znajduje się firma
** województwo miasta osoby
** województwo miasta firmy
** takie ze osoba mieszka w wojwodztwie W (proszę samemu kod wybrać)
** a firma jest w miescie X, które jest w innym województwie
** jak W
**
** jak nie ma takich rekordów toproszę uzupełnić dane
** aby się pojawiły, albo zmienić miasto osobie lub firmie
** UPDATE osoby SET id_miasta = xx_miasto WHERE id_osoby=Y
**
** Z2.3
** znależć miasta z województwa W
** których nazwa kończy się na (wybrać literkę)
** i gdzieś w środku nazwy województwa jest literka druga (wybrac jaką Państwo chcecie)
*/

--Z2.1

BEGIN
	ALTER TABLE MIASTA DROP COLUMN ILE_PRAWA_SA_LAT
	ALTER TABLE MIASTA DROP COLUMN UZYSKANIE_PRAW_MIEJSKICH
END
ALTER TABLE MIASTA ADD UZYSKANIE_PRAW_MIEJSKICH DATETIME NULL
GO

DECLARE @id_wa INT, @id_os INT, @id_le INT, @id_bia INT, @id_so INT
SELECT @id_wa = 1
UPDATE MIASTA SET UZYSKANIE_PRAW_MIEJSKICH = CONVERT(DATETIME, '19300120', 112) WHERE ID_MIASTA = @id_wa
SELECT @id_os = 2
UPDATE MIASTA SET UZYSKANIE_PRAW_MIEJSKICH = CONVERT(DATETIME, '19470815', 112) WHERE ID_MIASTA = @id_os
SELECT @id_le = 3
UPDATE MIASTA SET UZYSKANIE_PRAW_MIEJSKICH = CONVERT(DATETIME, '19750630', 112) WHERE ID_MIASTA = @id_le
SELECT @id_bia = 4
UPDATE MIASTA SET UZYSKANIE_PRAW_MIEJSKICH = CONVERT(DATETIME, '19831001', 112) WHERE ID_MIASTA = @id_bia
SELECT @id_so = 6
UPDATE MIASTA SET UZYSKANIE_PRAW_MIEJSKICH = CONVERT(DATETIME, '19700208', 112) WHERE ID_MIASTA = @id_so

ALTER TABLE MIASTA ADD ILE_PRAWA_SA_LAT AS DATEDIFF(YY, UZYSKANIE_PRAW_MIEJSKICH, GETDATE())
GO
SELECT MIASTA.* FROM MIASTA
/*ID_MIASTA   KOD_WOJ NAZWA                                                                                                UZYSKANIE_PRAW_MIEJSKICH ILE_PRAWA_SA_LAT
----------- ------- ---------------------------------------------------------------------------------------------------- ------------------------ ----------------
1           MAZ     WARSZAWA                                                                                             1930-01-20 00:00:00.000  94
2           MAZ     OSIECK                                                                                               1947-08-15 00:00:00.000  77
3           MAZ     LEGIONOWO                                                                                            1975-06-30 00:00:00.000  49
4           POD     BIAŁYSTOK                                                                                            1983-10-01 00:00:00.000  41
5           POD     PODLASKI                                                                                             NULL                     NULL
6           POM     SOPOT                                                                                                1970-02-08 00:00:00.000  54
7           POM     GDAŃSK                                                                                               NULL                     NULL
8           POM     GDYNIA                                                                                               NULL                     NULL

(8 rows affected)*/

SELECT * FROM MIASTA M WHERE (M.KOD_WOJ = 'MAZ' OR M.KOD_WOJ = 'POD') AND (M.ILE_PRAWA_SA_LAT IS NOT NULL AND M.ILE_PRAWA_SA_LAT > 20 AND M.ILE_PRAWA_SA_LAT < 50)
/*ID_MIASTA   KOD_WOJ NAZWA                                                                                                UZYSKANIE_PRAW_MIEJSKICH ILE_PRAWA_SA_LAT
----------- ------- ---------------------------------------------------------------------------------------------------- ------------------------ ----------------
3           MAZ     LEGIONOWO                                                                                            1975-06-30 00:00:00.000  49
4           POD     BIAŁYSTOK                                                                                            1983-10-01 00:00:00.000  41

(2 rows affected)*/

--Z2.2


SELECT  E.*, O.NAZWISKO AS NAZWISKO, F.NAZWA AS FIRMA, MO.NAZWA AS MIASTO_OSOBY, MF.NAZWA AS MIASTO_FIRMY , WO.NAZWA AS WOJEWODZTWO_OSOBY, WF.NAZWA AS WOJEWODZTWO_FIRMY
FROM ETATY E, OSOBY O, FIRMY F, MIASTA MO, MIASTA MF, WOJ WO, WOJ WF 
WHERE  (E.ID_OSOBY = O.ID_OSOBY) AND (E.ID_FIRMY = F.ID_FIRMY) 
AND (MO.ID_MIASTA = O.ID_MIASTA) AND (MF.ID_MIASTA = F.ID_MIASTA)
AND (MO.KOD_WOJ = WO.KOD_WOJ) AND (MF.KOD_WOJ = WF.KOD_WOJ)

/*ID_ETATU    ID_OSOBY    ID_FIRMY    STANOWISKO                                                                                           PENSJA      OD         DO         NAZWISKO                                           FIRMA                                              MIASTO_OSOBY                                                                                         MIASTO_FIRMY                                                                                         WOJEWODZTWO_OSOBY                                  WOJEWODZTWO_FIRMY
----------- ----------- ----------- ---------------------------------------------------------------------------------------------------- ----------- ---------- ---------- -------------------------------------------------- -------------------------------------------------- ---------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------- -------------------------------------------------- --------------------------------------------------
1           1           1           PROGRAMISTA                                                                                          6000        2010-05-01 NULL       KOWALSKI                                           FIRMA LENOWO                                       WARSZAWA                                                                                             WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
2           1           3           PROGRAMISTA                                                                                          7300        2014-10-01 NULL       KOWALSKI                                           FIRMA DELL                                         WARSZAWA                                                                                             WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
3           1           4           PROGRAMISTA                                                                                          7000        2016-06-01 NULL       KOWALSKI                                           FIRMA SONY                                         WARSZAWA                                                                                             OSIECK                                                                                               MAZOWIECKIE                                        MAZOWIECKIE
4           2           1           PROJEKTANT                                                                                           6000        2008-07-01 NULL       NOWAK                                              FIRMA LENOWO                                       WARSZAWA                                                                                             WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
5           3           4           SPRZĄTAĆ                                                                                             4500        2013-02-01 NULL       KACZUR                                             FIRMA SONY                                         WARSZAWA                                                                                             OSIECK                                                                                               MAZOWIECKIE                                        MAZOWIECKIE
6           3           5           SPRZĄTAĆ                                                                                             5000        2014-08-01 NULL       KACZUR                                             FIRMA SAMSUNG                                      WARSZAWA                                                                                             OSIECK                                                                                               MAZOWIECKIE                                        MAZOWIECKIE
7           3           6           SPRZĄTAĆ                                                                                             3000        2017-02-01 NULL       KACZUR                                             FIRMA TESLA                                        WARSZAWA                                                                                             LEGIONOWO                                                                                            MAZOWIECKIE                                        MAZOWIECKIE
8           3           7           SPRZĄTAĆ                                                                                             4000        2019-05-31 NULL       KACZUR                                             FIRMA XIAOMI                                       WARSZAWA                                                                                             BIAŁYSTOK                                                                                            MAZOWIECKIE                                        PODLASKIE
9           4           3           KSIĘGOWY                                                                                             4500        2020-07-01 NULL       CHAIENKO                                           FIRMA DELL                                         WARSZAWA                                                                                             WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
10          5           1           SEKRETARKA                                                                                           4000        2005-08-01 NULL       FILOBOK                                            FIRMA LENOWO                                       WARSZAWA                                                                                             WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
11          6           6           KSIĘGOWY                                                                                             4600        2017-06-01 2021-03-31 KOSSAKOWSKI                                        FIRMA TESLA                                        OSIECK                                                                                               LEGIONOWO                                                                                            MAZOWIECKIE                                        MAZOWIECKIE
12          7           1           INŻYNIER                                                                                             6000        2000-09-01 NULL       WIŚNIEWSKI                                         FIRMA LENOWO                                       LEGIONOWO                                                                                            WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
13          7           2           INŻYNIER                                                                                             7000        2006-01-10 NULL       WIŚNIEWSKI                                         FIRMA ASUS                                         LEGIONOWO                                                                                            WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
14          7           3           INŻYNIER                                                                                             7500        2014-08-01 NULL       WIŚNIEWSKI                                         FIRMA DELL                                         LEGIONOWO                                                                                            WARSZAWA                                                                                             MAZOWIECKIE                                        MAZOWIECKIE
15          7           4           INŻYNIER                                                                                             7000        2020-11-01 NULL       WIŚNIEWSKI                                         FIRMA SONY                                         LEGIONOWO                                                                                            OSIECK                                                                                               MAZOWIECKIE                                        MAZOWIECKIE
16          8           6           INFORMATYK                                                                                           5200        2010-04-01 2023-10-31 PTAK                                               FIRMA TESLA                                        BIAŁYSTOK                                                                                            LEGIONOWO                                                                                            PODLASKIE                                          MAZOWIECKIE

(16 rows affected)
*/

--Z2.3


INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'MAZ', N'OSTROLEKA')
SELECT W.NAZWA, M.NAZWA FROM WOJ W, MIASTA M WHERE (W.KOD_WOJ = 'MAZ') AND (M.KOD_WOJ = W.KOD_WOJ) AND (M.NAZWA LIKE '%S%A')

/*NAZWA                                              NAZWA
-------------------------------------------------- ----------------------------------------------------------------------------------------------------
MAZOWIECKIE                                        WARSZAWA
MAZOWIECKIE                                        OSTROLEKA

(2 rows affected)
*/