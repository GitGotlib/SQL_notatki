--tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00
/*

Z4.1
największa pensja z etatów osób o imieniu na (wybrać literkę) z miasta o nazwie kończącego się na literkę (wybrać)

dodać taką samą pensję osobie o imieniu na inną literkę ale z tego samego miasta
i sprawdzić czy się nie pokaze
jak się pokaze to zapytanie jest zle
*/
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (2, 1, N'PROJEKTANT', 7300, N'2008-07-01', NULL);--DODANO TAKĄ SAMĄ PENSJE ANNIE NOWAK Z WARSZAWY
DECLARE @OS INT
DECLARE CC INSENSITIVE CURSOR FOR SELECT O.ID_OSOBY FROM OSOBY O JOIN MIASTA M ON (M.ID_MIASTA = O.ID_MIASTA) WHERE (O.IMIE LIKE 'J%') AND (M.NAZWA LIKE '%A')
OPEN CC
FETCH NEXT FROM CC INTO @OS
WHILE @@FETCH_STATUS = 0
BEGIN 
SELECT DISTINCT LEFT(O.IMIE, 20) AS IMIE, LEFT(O.NAZWISKO, 20) AS NAZWISKO, LEFT(M.NAZWA,20) AS MIASTO, MAX(E.PENSJA) AS MAX_PENSJA
				FROM OSOBY O
				JOIN ETATY E ON (@OS = E.ID_OSOBY)
				JOIN MIASTA M ON (M.ID_MIASTA = O.ID_MIASTA)
				WHERE @OS = O.ID_OSOBY 
				GROUP BY O.IMIE, O.NAZWISKO, M.NAZWA;
		
FETCH NEXT FROM CC INTO @OS
END 
CLOSE CC
DEALLOCATE CC

/*IMIE                 NAZWISKO             MIASTO               MAX_PENSJA
-------------------- -------------------- -------------------- -----------
JAN                  KOWALSKI             WARSZAWA             7300

(1 row affected)

IMIE                 NAZWISKO             MIASTO               MAX_PENSJA
-------------------- -------------------- -------------------- -----------
JAROSŁAW             KACZUR               WARSZAWA             5000

(1 row affected)
*/
/*
Z4.2
policzyć największą pensję w kazdej z firm tylko z aktualnych etatów
*/

DECLARE @F INT
DECLARE CC INSENSITIVE CURSOR FOR SELECT F.ID_FIRMY FROM FIRMY F 
OPEN CC
FETCH NEXT FROM CC INTO @F
WHILE @@FETCH_STATUS = 0
BEGIN
IF EXISTS (SELECT 1 FROM ETATY E WHERE E.ID_FIRMY = @F AND E.DO IS NULL)
BEGIN
SELECT MAX(E.PENSJA) AS MAX_PENSJA , LEFT(F.NAZWA,20) AS FIRMA
FROM FIRMY F 
JOIN ETATY E ON (E.ID_FIRMY = F.ID_FIRMY AND E.DO IS NULL)
WHERE F.ID_FIRMY = @F 
GROUP BY F.NAZWA
END
FETCH NEXT FROM CC INTO @F
END
CLOSE CC
DEALLOCATE CC 

/*
MAX_PENSJA  FIRMA
----------- --------------------
6000        FIRMA LENOWO

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
7000        FIRMA ASUS

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
7500        FIRMA DELL

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
7000        FIRMA SONY

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
5000        FIRMA SAMSUNG

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
3000        FIRMA TESLA

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
4000        FIRMA XIAOMI

(1 row affected)

MAX_PENSJA  FIRMA
----------- --------------------
6000        FIRMA APPLE

(1 row affected)
*/
/*
Z4.3
znalezc województwa w których nie ma firmy z etatem o pensji mniejszej niż X (wybrać)
*/

SELECT MIN(E.PENSJA) AS MIN_PENSJA, LEFT(W.NAZWA, 20) AS [WOJEWÓDZTWO]
FROM WOJ W
JOIN MIASTA M ON (M.KOD_WOJ = W.KOD_WOJ)
JOIN FIRMY F ON (F.ID_MIASTA = M.ID_MIASTA)
JOIN ETATY E ON (E.ID_FIRMY = F.ID_FIRMY)

WHERE NOT EXISTS (
SELECT *
FROM WOJ WW
JOIN MIASTA MM ON (MM.KOD_WOJ = WW.KOD_WOJ)
JOIN FIRMY FF ON (FF.ID_MIASTA = MM.ID_MIASTA)
JOIN ETATY EE ON (EE.ID_FIRMY = FF.ID_FIRMY AND EE.PENSJA < 4000)
WHERE W.KOD_WOJ = WW.KOD_WOJ
)
GROUP BY W.NAZWA
/*
MIN_PENSJA  WOJEWÓDZTWO
----------- --------------------
4000        PODLASKIE
6000        POMORSKIE      

(2 rows affected)
*/