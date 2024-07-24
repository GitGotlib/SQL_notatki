/* 
** tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00
** wkleic ogloszenie z isod (co trzeba zrobic)
/*
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
*/

IF OBJECT_ID('ETATY') IS NOT NULL
    DROP TABLE ETATY
GO

IF OBJECT_ID('FIRMY') IS NOT NULL
    DROP TABLE FIRMY
GO

IF OBJECT_ID('OSOBY') IS NOT NULL
    DROP TABLE OSOBY
GO

IF OBJECT_ID('MIASTA') IS NOT NULL
    DROP TABLE MIASTA
GO

IF OBJECT_ID('WOJ') IS NOT NULL
    DROP TABLE WOJ
GO

CREATE TABLE dbo.WOJ
(
    KOD_WOJ NCHAR(4) NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY,
    NAZWA NVARCHAR(50) NOT NULL
)
GO

INSERT INTO WOJ (KOD_WOJ, NAZWA) VALUES (N'MAZ', N'MAZOWIECKIE');
INSERT INTO WOJ (KOD_WOJ, NAZWA) VALUES (N'POD', N'PODLASKIE');
INSERT INTO WOJ (KOD_WOJ, NAZWA) VALUES (N'POM', N'POMORSKIE');
INSERT INTO WOJ (KOD_WOJ, NAZWA) VALUES (N'SL', N'SLASKIE');--nie ma miast

CREATE TABLE dbo.MIASTA
(
    ID_MIASTA INT NOT NULL IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY,
    KOD_WOJ NCHAR(4) NOT NULL CONSTRAINT FK_WOJ__MIASTA FOREIGN KEY REFERENCES WOJ(KOD_WOJ),
    NAZWA NVARCHAR(100) NOT NULL
)
GO


CREATE TABLE dbo.FIRMY
(
    ID_FIRMY INT NOT NULL IDENTITY CONSTRAINT PK_FIRMY PRIMARY KEY,
    NAZWA NVARCHAR(50) NOT NULL,
    ID_MIASTA INT NOT NULL CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY REFERENCES MIASTA(ID_MIASTA),
	KOD_POCZTOWY NVARCHAR(10) NOT NULL,
	ULICA NVARCHAR(50) NOT NULL
)
GO




CREATE TABLE dbo.OSOBY
(
    ID_OSOBY INT NOT NULL IDENTITY CONSTRAINT PK_OSOBY PRIMARY KEY,
    ID_MIASTA INT NOT NULL CONSTRAINT FK_OSOBY__MIASTA FOREIGN KEY REFERENCES MIASTA(ID_MIASTA),
    imie NVARCHAR(50) NOT NULL,
    nazwisko NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE dbo.ETATY
(
    ID_ETATU INT NOT NULL IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY,
    ID_OSOBY INT NOT NULL CONSTRAINT FK_ETATY_OSOBY FOREIGN KEY REFERENCES OSOBY(ID_OSOBY),
    ID_FIRMY INT NOT NULL CONSTRAINT FK_ETATY_FIRMY FOREIGN KEY REFERENCES FIRMY(ID_FIRMY),
	STANOWISKO NVARCHAR(100) NOT NULL,
	PENSJA INT NOT NULL,
	OD DATE NOT NULL,
	DO DATE NULL
)
GO

DECLARE @id_wa int, @id_os int, @id_le int, @id_bia int, @id_po int, @id_so int, @id_gda int, @id_gdy int
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'MAZ', N'WARSZAWA')
SET @id_wa = SCOPE_IDENTITY() 
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'MAZ', N'OSIECK')
SET @id_os = SCOPE_IDENTITY()
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'MAZ', N'LEGIONOWO')
SET @id_le = SCOPE_IDENTITY()
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'POD', N'BIAŁYSTOK')
SET @id_bia = SCOPE_IDENTITY()
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'POD', N'PODLASKI')--nie ma firmy
SET @id_po = SCOPE_IDENTITY()
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'POM', N'SOPOT')--nie ma ludzi
SET @id_so = SCOPE_IDENTITY()
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'POM', N'GDAŃSK')--nie ma firmy
SET @id_gda = SCOPE_IDENTITY()
INSERT INTO MIASTA (KOD_WOJ, NAZWA) VALUES (N'POM', N'GDYNIA')--nie ma ludzi
SET @id_gdy = SCOPE_IDENTITY()


DECLARE @id_len int, @id_asu int, @id_del int, @id_son int, @id_sam int, @id_tes int, @id_xia int, @id_app int, @id_mic int
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA LENOWO', @id_wa, N'01-960', N'JANA_KASPROWICZA');
SET @id_len = SCOPE_IDENTITY() 
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA ASUS', @id_wa, N'00-660', N'ALEJA_ZJEDNOCZENIA');
SET @id_asu = SCOPE_IDENTITY() 
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA DELL', @id_wa, N'00-321', N'ZGRUPOWANIE_KAMPINOS');
SET @id_del = SCOPE_IDENTITY()
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA SONY', @id_os, N'03-532', N'STRŻAŁKI');
SET @id_son = SCOPE_IDENTITY()
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA SAMSUNG', @id_os, N'03-332', N'PODNOSZE');
SET @id_sam = SCOPE_IDENTITY()
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA TESLA', @id_le, N'07-819', N'GORNA');
SET @id_tes = SCOPE_IDENTITY()
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA XIAOMI', @id_bia, N'06-042', N'WOJSKOWA');
SET @id_xia = SCOPE_IDENTITY()
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA APPLE', @id_so, N'09-007', N'ALEJA_SOLIDARNOSCI');--nie ma pracowników
SET @id_app = SCOPE_IDENTITY()
INSERT INTO FIRMY (NAZWA, ID_MIASTA, KOD_POCZTOWY, ULICA) VALUES (N'FIRMA MICROSOFT', @id_gdy, N'09-529', N'KOŁOBRZESKA');--nie ma pracowników
SET @id_mic = SCOPE_IDENTITY()

DECLARE @id_jko int, @id_ano int, @id_jka int, @id_ach int, @id_hfi int, @id_mko int, @id_mwi int, @id_opt int, @id_kko int, @id_mli int, @id_mka int
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_wa, N'JAN', N'KOWALSKI');
SET @id_jko = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_wa, N'ANNA', N'NOWAK');
SET @id_ano = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_wa, N'JAROSŁAW', N'KACZUR');
SET @id_jka = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_wa, N'ALEKSANDR', N'CHAIENKO');
SET @id_ach = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_wa, N'HLIB', N'FILOBOK');
SET @id_hfi = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_os, N'MARIUSZ', N'KOSSAKOWSKI');--obecnie nie ma aktualnego etatu
SET @id_mko = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_le, N'MICHAŁ', N'WIŚNIEWSKI');
SET @id_mwi = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_bia, N'OLEKSANDRA', N'PTAK');--obecnie nie ma aktualnego etatu
SET @id_opt = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_po, N'KATARZYNA', N'KOWALCZYK');--nigdy nie pracował
SET @id_kko = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_gda, N'MARCIN', N'LIS');--nigdy nie pracował
SET @id_mli = SCOPE_IDENTITY() 
INSERT INTO OSOBY (ID_MIASTA, imie, nazwisko) VALUES (@id_gda, N'MARCIN', N'KACZUR');--nigdy nie pracował
SET @id_mka = SCOPE_IDENTITY() 


INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jko, @id_len, N'PROGRAMISTA', 6000, N'2010-05-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jko, @id_del, N'PROGRAMISTA', 7300, N'2014-10-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jko, @id_son, N'PROGRAMISTA', 7000, N'2016-06-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_ano, @id_len, N'PROJEKTANT', 6000, N'2008-07-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jka, @id_son, N'SPRZĄTAĆ', 4500, N'2013-02-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jka, @id_sam, N'SPRZĄTAĆ', 5000, N'2014-08-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jka, @id_tes, N'SPRZĄTAĆ', 3000, N'2017-02-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_jka, @id_xia, N'SPRZĄTAĆ', 4000, N'2019-05-31', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_ach, @id_del, N'KSIĘGOWY', 4500, N'2020-07-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_hfi, @id_len, N'SEKRETARKA', 4000, N'2005-08-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_mko, @id_tes, N'KSIĘGOWY', 4600, N'2017-06-01', N'2021-03-31');
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_mwi, @id_len, N'INŻYNIER', 6000, N'2000-09-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_mwi, @id_asu, N'INŻYNIER', 7000, N'2006-01-10', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_mwi, @id_del, N'INŻYNIER', 7500, N'2014-08-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_mwi, @id_son, N'INŻYNIER', 7000, N'2020-11-01', NULL);
INSERT INTO ETATY (ID_OSOBY, ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@id_opt, @id_tes, N'INFORMATYK', 5200, N'2010-04-01', N'2023-10-31');

SELECT WOJ.* FROM WOJ
SELECT MIASTA.* FROM MIASTA
SELECT FIRMY.* FROM FIRMY
SELECT OSOBY.* FROM OSOBY
SELECT ETATY.* FROM ETATY

GO
/*  TABELA WOJEWÓDZTW
KOD_WOJ NAZWA_WOJ
------- --------------------
MAZ     MAZOWIECKIE
POD     PODLASKIE
POM     POMORSKIE
SL      SLASKIE

(4 rows affected)
*/
/* TABELA MIAST Z KODEM WOJEWÓDZTWA
ID_MIASTA   KOD_WOJ NAZWA
----------- ------- ----------------------------------------------------------------------------------------------------
1           MAZ     WARSZAWA
2           MAZ     OSIECK
3           MAZ     LEGIONOWO
4           POD     BIAŁYSTOK
5           POD     PODLASKI
6           POM     SOPOT
7           POM     GDAŃSK
8           POM     GDYNIA

(8 rows affected)
*/
/*  TABELA FIRM Z ID_MIAST I ADRESEM
ID_FIRMY    NAZWA                                              ID_MIASTA   KOD_POCZTOWY ULICA
----------- -------------------------------------------------- ----------- ------------ --------------------------------------------------
1           FIRMA LENOWO                                       1           01-960       JANA_KASPROWICZA
2           FIRMA ASUS                                         1           00-660       ALEJA_ZJEDNOCZENIA
3           FIRMA DELL                                         1           00-321       ZGRUPOWANIE_KAMPINOS
4           FIRMA SONY                                         2           03-532       STRŻAŁKI
5           FIRMA SAMSUNG                                      2           03-332       PODNOSZE
6           FIRMA TESLA                                        3           07-819       GORNA
7           FIRMA XIAOMI                                       4           06-042       WOJSKOWA
8           FIRMA APPLE                                        6           09-007       ALEJA_SOLIDARNOSCI
9           FIRMA MICROSOFT                                    8           09-529       KOŁOBRZESKA

(9 rows affected)
*/
/* TABELA LUDZI Z ID_MIAST
ID_OSOBY    ID_MIASTA   imie                                               nazwisko
----------- ----------- -------------------------------------------------- --------------------------------------------------
1           1           JAN                                                KOWALSKI
2           1           ANNA                                               NOWAK
3           1           JAROSŁAW                                           KACZUR
4           1           ALEKSANDR                                          CHAIENKO
5           1           HLIB                                               FILOBOK
6           2           MARIUSZ                                            KOSSAKOWSKI
7           3           MICHAŁ                                             WIŚNIEWSKI
8           4           OLEKSANDRA                                         PTAK
9           5           KATARZYNA                                          KOWALCZYK
10          7           MARCIN                                             LIS
11          7           MARCIN                                             KACZUR

(11 rows affected)
*/
/* TABELA ETATÓW PRACOWNIKÓW Z ID_OSOBY I ID_FIRMY W KTÓRYCH PRACUJĄ LUB PRACOWALI
ID_ETATU    ID_OSOBY    ID_FIRMY    STANOWISKO                                                                                           PENSJA      OD              DO
----------- ----------- ----------- ---------------------------------------------------------------------------------------------------- ----------- --------------- ---------------
1           1           1           PROGRAMISTA                                                                                          6000        2010-05-01      NULL
2           1           3           PROGRAMISTA                                                                                          7300        2014-10-01      NULL
3           1           4           PROGRAMISTA                                                                                          7000        2016-06-01      NULL
4           2           1           PROJEKTANT                                                                                           6000        2008-07-01      NULL
5           3           4           SPRZĄTAĆ                                                                                             4500        2013-02-01      NULL
6           3           5           SPRZĄTAĆ                                                                                             5000        2014-08-01      NULL
7           3           6           SPRZĄTAĆ                                                                                             3000        2017-02-01      NULL
8           3           7           SPRZĄTAĆ                                                                                             4000        2019-05-31      NULL
9           4           3           KSIĘGOWY                                                                                             4500        2020-07-01      NULL
10          5           1           SEKRETARKA                                                                                           4000        2005-08-01      NULL
11          6           6           KSIĘGOWY                                                                                             4600        2017-06-01      2021-03-31
12          7           1           INŻYNIER                                                                                             6000        2000-09-01      NULL
13          7           2           INŻYNIER                                                                                             7000        2006-01-10      NULL
14          7           3           INŻYNIER                                                                                             7500        2014-08-01      NULL
15          7           4           INŻYNIER                                                                                             7000        2020-11-01      NULL
16          8           6           INFORMATYK                                                                                           5200        2010-04-01      2023-10-31

(16 rows affected)
*/