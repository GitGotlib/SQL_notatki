--tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00
/*
Z6.1 Npisać procedurę, która
wyszuka osoby z województwa o kodzie @kod_woj (parametr proc)
które nie pracowała w firmie o nazwie
@nazwa nvarchar(100) - kolejny parametr

Wykonać testy i uzasadnic porawność
*/
--Na początku zrobiłem CREATE Procedure a potem zamieniłem na alter po pierwszym uruchomieniu jak stworzyła się procedura (poniżej tak samo z proceduramy i funkcjami)
ALTER PROCEDURE dbo.OS_W_WOJ(@kod_woj nvarchar(3), @nazwa nvarchar(100))
AS
SELECT W.NAZWA, LEFT(O.ID_OSOBY, 4) AS ID_OSOBY, LEFT(O.IMIE, 15) AS IMIE, LEFT(O.NAZWISKO, 15) AS NAZWISKO
FROM OSOBY O
JOIN MIASTA M ON (O.ID_MIASTA = M. ID_MIASTA)
JOIN WOJ W ON (M.KOD_WOJ = W.KOD_WOJ)
WHERE (W.KOD_WOJ = @kod_woj) AND NOT EXISTS (
SELECT 1 
FROM ETATY EE
JOIN FIRMY FF ON (FF.ID_FIRMY = EE.ID_FIRMY)
WHERE O.ID_OSOBY = EE.ID_OSOBY AND FF.NAZWA LIKE @nazwa
)
GO

EXEC OS_W_WOJ @kod_woj = 'MAZ', @nazwa = '%LENOWO'

/*
**Po odjęciu poniższych SELECTów otrzymujemy taki sam wynik jak po wykonaniu SELECT do zadania
NAZWA                                              ID_OSOBY IMIE            NAZWISKO
-------------------------------------------------- -------- --------------- ---------------
MAZOWIECKIE                                        3        JAROSŁAW        KACZUR
MAZOWIECKIE                                        4        ALEKSANDR       CHAIENKO
MAZOWIECKIE                                        6        MARIUSZ         KOSSAKOWSKI

(3 rows affected)
*/
EXEC OS_W_WOJ @kod_woj = 'MAZ', @nazwa = '%DELL'
/*
NAZWA                                              ID_OSOBY IMIE            NAZWISKO
-------------------------------------------------- -------- --------------- ---------------
MAZOWIECKIE                                        2        ANNA            NOWAK
MAZOWIECKIE                                        3        JAROSŁAW        KACZUR
MAZOWIECKIE                                        5        HLIB            FILOBOK
MAZOWIECKIE                                        6        MARIUSZ         KOSSAKOWSKI

(4 rows affected)
*/
EXEC OS_W_WOJ @kod_woj = 'MAZ', @nazwa = '%SONY'
/*
NAZWA                                              ID_OSOBY IMIE            NAZWISKO
-------------------------------------------------- -------- --------------- ---------------
MAZOWIECKIE                                        2        ANNA            NOWAK
MAZOWIECKIE                                        4        ALEKSANDR       CHAIENKO
MAZOWIECKIE                                        5        HLIB            FILOBOK
MAZOWIECKIE                                        6        MARIUSZ         KOSSAKOWSKI

(4 rows affected)
*/
/*
** Ten SELECT wyszukuje pracowników z wybranego województwa w określonej firmie 
SELECT * 
FROM ETATY E
JOIN FIRMY F ON (F.ID_FIRMY = E.ID_FIRMY)
JOIN OSOBY OO ON (OO.ID_OSOBY = E.ID_OSOBY)
WHERE F.ID_FIRMY = 1
**
ID_ETATU    ID_OSOBY    ID_FIRMY    STANOWISKO                                                                                           PENSJA      OD         DO         ID_FIRMY    NAZWA                                              ID_MIASTA   KOD_POCZTOWY ULICA                                              ID_OSOBY    ID_MIASTA   imie                                               nazwisko
----------- ----------- ----------- ---------------------------------------------------------------------------------------------------- ----------- ---------- ---------- ----------- -------------------------------------------------- ----------- ------------ -------------------------------------------------- ----------- ----------- -------------------------------------------------- --------------------------------------------------
1           1           1           PROGRAMISTA                                                                                          6000        2010-05-01 NULL       1           FIRMA LENOWO                                       1           01-960       JANA_KASPROWICZA                                   1           1           JAN                                                KOWALSKI
4           2           1           PROJEKTANT                                                                                           6000        2008-07-01 NULL       1           FIRMA LENOWO                                       1           01-960       JANA_KASPROWICZA                                   2           1           ANNA                                               NOWAK
10          5           1           SEKRETARKA                                                                                           4000        2005-08-01 NULL       1           FIRMA LENOWO                                       1           01-960       JANA_KASPROWICZA                                   5           1           HLIB                                               FILOBOK
12          7           1           INŻYNIER                                                                                             6000        2000-09-01 NULL       1           FIRMA LENOWO                                       1           01-960       JANA_KASPROWICZA                                   7           3           MICHAŁ                                             WIŚNIEWSKI
** Ten SELECT wyszukuje wszystkich zamieszkających w wybranym województwie
SELECT *
FROM OSOBY O
JOIN MIASTA M ON (M.ID_MIASTA = O.ID_MIASTA)
JOIN WOJ W ON (W.KOD_WOJ = M.KOD_WOJ AND W.KOD_WOJ = 'MAZ')
**
ID_OSOBY    ID_MIASTA   imie                                               nazwisko                                           ID_MIASTA   KOD_WOJ NAZWA                                                                                                KOD_WOJ NAZWA
----------- ----------- -------------------------------------------------- -------------------------------------------------- ----------- ------- ---------------------------------------------------------------------------------------------------- ------- --------------------------------------------------
1           1           JAN                                                KOWALSKI                                           1           MAZ     WARSZAWA                                                                                             MAZ     MAZOWIECKIE
2           1           ANNA                                               NOWAK                                              1           MAZ     WARSZAWA                                                                                             MAZ     MAZOWIECKIE
3           1           JAROSŁAW                                           KACZUR                                             1           MAZ     WARSZAWA                                                                                             MAZ     MAZOWIECKIE
4           1           ALEKSANDR                                          CHAIENKO                                           1           MAZ     WARSZAWA                                                                                             MAZ     MAZOWIECKIE
5           1           HLIB                                               FILOBOK                                            1           MAZ     WARSZAWA                                                                                             MAZ     MAZOWIECKIE
6           2           MARIUSZ                                            KOSSAKOWSKI                                        2           MAZ     OSIECK                                                                                               MAZ     MAZOWIECKIE
7           3           MICHAŁ                                             WIŚNIEWSKI                                         3           MAZ     LEGIONOWO          
(4 rows affected)
*/
/*
Z6.2
Napisać funkcję, która dla parametrów
Nazwa z WOJ, nazwa z miasta, ulica z Firmy
stworzy napis( W:(nazwa z woj);M:(nazwa z miasta),UL:(ulica z firmy)

jak w FIRMY nie ma ULICA to porosze dodać
ALTER TABLE FIRMY ADD ULICA nvarchar(50) NOT NULL DEFAULT 'Pl.Politechniki'
i w paru firmach poustawiać wartości na inne

Napisać funkcję, która dla parametrów
id_firmy, nazwa
stworzy napis( ID:(id_firmy);FI:20liter_z_nazwa_firmy)
napis max 30 znaków
*/

ALTER FUNCTION dbo.ADRES_FIRMY (@woj nvarchar(20), @miasto nvarchar(20), @ulica nvarchar(25))
RETURNS NVARCHAR(65)
AS
BEGIN 
	IF @woj IS NULL 
	RETURN N'NIEZNANE'
	IF @miasto IS NULL
	RETURN N'NIEZNANE'
	IF @ulica IS NULL
	RETURN N'NIEZNANE'
	
	RETURN N'W: '+@woj+N'; M: '+@miasto+N'; UL: '+@ulica
END
GO
--WYPISUJE WSZYSTKIE ADRESY FIRM Z WOJEWÓDZTWA MAZOWIECKIEGO
SELECT dbo.ADRES_FIRMY(W.NAZWA, M.NAZWA, F.ULICA) AS ADRES_FIRM_W_MAZOWIECKU
FROM FIRMY F
JOIN MIASTA M ON (M.ID_MIASTA = F.ID_MIASTA)
JOIN WOJ W ON (W.KOD_WOJ = M.KOD_WOJ AND W.KOD_WOJ = 'MAZ')

UPDATE FIRMY SET ULICA = N'JEROZOLIMSKA' WHERE ID_FIRMY = 5  --ZMIANA ULICY DLA FIRMY SAMSUNG Z PODNOSZE NA JEROZOLIMSKA
UPDATE FIRMY SET ULICA = N'MARSZAŁKOWSKA' WHERE ID_FIRMY = 3 --ZMIANA ULISY DLA FIRMY DELL Z ZGRUPOWANIE_KAMPINOS NA MARSZAŁKOWSKA
/*
ADRES_FIRM_W_MAZOWIECKU
-----------------------------------------------------------------
W: MAZOWIECKIE M: WARSZAWA UL: JANA_KASPROWICZA
W: MAZOWIECKIE M: WARSZAWA UL: ALEJA_ZJEDNOCZENIA
W: MAZOWIECKIE M: WARSZAWA UL: MARSZAŁKOWSKA
W: MAZOWIECKIE M: OSIECK UL: STRŻAŁKI
W: MAZOWIECKIE M: OSIECK UL: JEROZOLINSKA
W: MAZOWIECKIE M: LEGIONOWO UL: GORNA

(6 rows affected)
*/
/*
Napisać funkcję, która dla parametrów
id_firmy, nazwa
stworzy napis( ID:(id_firmy);FI:20liter_z_nazwa_firmy)
napis max 30 znaków
*/
/*
**Stworzyłem tu kolumnę z nazwą skróconą dla firm i poustawiałem im te nazwy
ALTER TABLE FIRMY ADD NAZWA_SKR nvarchar(3) NULL
GO
UPDATE FIRMY SET NAZWA_SKR = N'LEN' WHERE ID_FIRMY = 1
UPDATE FIRMY SET NAZWA_SKR = N'AS' WHERE ID_FIRMY = 2
UPDATE FIRMY SET NAZWA_SKR = N'DEL' WHERE ID_FIRMY = 3
UPDATE FIRMY SET NAZWA_SKR = N'SON' WHERE ID_FIRMY = 4
UPDATE FIRMY SET NAZWA_SKR = N'SAM' WHERE ID_FIRMY = 5
UPDATE FIRMY SET NAZWA_SKR = N'TES' WHERE ID_FIRMY = 6
UPDATE FIRMY SET NAZWA_SKR = N'MI' WHERE ID_FIRMY = 7
UPDATE FIRMY SET NAZWA_SKR = N'AP' WHERE ID_FIRMY = 8
UPDATE FIRMY SET NAZWA_SKR = N'MIC' WHERE ID_FIRMY = 9
*/
GO
ALTER FUNCTION DBO.ID_I_NAZWA_FIRMY (@IDF NVARCHAR(10), @NAZWA NVARCHAR(20))
RETURNS NVARCHAR(30)
AS
BEGIN
	IF @IDF IS NULL
	RETURN 'NIEZNANA' 
	IF @NAZWA IS NULL
	RETURN 'NIEZNANA'
	SET @NAZWA = LEFT(@NAZWA, 20)

RETURN 'ID: '+@IDF+'; FI: '+@NAZWA
END
GO

SELECT DBO.ID_I_NAZWA_FIRMY(F.NAZWA_SKR, F.NAZWA) AS NAZWA_SKROCONA_I_NAZWA_FIRMY
FROM FIRMY F
WHERE F.ID_FIRMY = 3

/*
NAZWA_SKROCONA_I_NAZWA_FIRMY
------------------------------
ID: DEL; FI: FIRMA DELL

(1 row affected)
*/

/*
Z 6.3
wykorzystać obie funkcje w procedure pokazującej firmy
w 2 kolumnach (funkcje z 6.2)
a parametrem nazwa województwa gdzie są firmy
*/
GO
CREATE PROCEDURE DBO.POKAZ_FIRMY (@WOJ NVARCHAR(3))
AS

 IF @WOJ IS NULL
 RETURN N'NIE PODANO ARGUMENTU'
 SELECT DBO.ID_I_NAZWA_FIRMY(F.NAZWA_SKR, F.NAZWA) AS NAZWA_SKROCONA_I_NAZWA_FIRMY, dbo.ADRES_FIRMY(W.NAZWA, M.NAZWA, F.ULICA) AS ADRES_FIRM_W_MAZOWIECKU
 FROM FIRMY F
 JOIN MIASTA M ON (F.ID_MIASTA = M.ID_MIASTA)
 JOIN WOJ W ON (W.KOD_WOJ = M.KOD_WOJ AND W.KOD_WOJ = @WOJ)

GO

EXEC DBO.POKAZ_FIRMY @WOJ = 'MAZ'
/*
NAZWA_SKROCONA_I_NAZWA_FIRMY   ADRES_FIRM_W_MAZOWIECKU
------------------------------ -----------------------------------------------------------------
ID: LEN; FI: FIRMA LENOWO      W: MAZOWIECKIE M: WARSZAWA UL: JANA_KASPROWICZA
ID: AS; FI: FIRMA ASUS         W: MAZOWIECKIE M: WARSZAWA UL: ALEJA_ZJEDNOCZENIA
ID: DEL; FI: FIRMA DELL        W: MAZOWIECKIE M: WARSZAWA UL: MARSZAŁKOWSKA
ID: SON; FI: FIRMA SONY        W: MAZOWIECKIE M: OSIECK UL: STRŻAŁKI
ID: SAM; FI: FIRMA SAMSUNG     W: MAZOWIECKIE M: OSIECK UL: JEROZOLINSKA
ID: TES; FI: FIRMA TESLA       W: MAZOWIECKIE M: LEGIONOWO UL: GORNA

(6 rows affected)
*/