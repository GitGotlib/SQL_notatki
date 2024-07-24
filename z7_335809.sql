--tu imie, nazwisko i numer albumu (dzien i godz zajec)  HLIB FILOBOK 335809 PONIEDZIAELEK 12:15-14:00

--sprawdzam czy istnieją i jeżeli tak to usuwam ich
IF EXISTS(
	SELECT 1 
	FROM sysobjects o
	WHERE o.[name] = N'ZAKUPY' AND 
	(OBJECTPROPERTY(O.[ID], 'IsUserTable') = 1)
)
BEGIN
	DROP TABLE ZAKUPY
END

IF EXISTS(
	SELECT 1 
	FROM sysobjects o
	WHERE o.[name] = N'SPRZED' AND 
	(OBJECTPROPERTY(O.[ID], 'IsUserTable') = 1)
)
BEGIN
	DROP TABLE SPRZED
END

IF EXISTS(
	SELECT 1 
	FROM sysobjects o
	WHERE o.[name] = N'MAGAZYN_PROD' AND 
	(OBJECTPROPERTY(O.[ID], 'IsUserTable') = 1)
)
BEGIN
	DROP TABLE MAGAZYN_PROD
END
GO
--tu tworze tablicy
CREATE TABLE DBO.MAGAZYN_PROD 
(
	NAZWA NVARCHAR(50) NOT NULL,
    ID_PROD INT NOT NULL IDENTITY CONSTRAINT PK_PROD PRIMARY KEY,
    LICZBA_ZAK INT NULL,
	LICZBA_DOSTEPNYCH INT NULL
)
GO
CREATE TABLE DBO.ZAKUPY 
(
    ID_ZAK INT NOT NULL IDENTITY CONSTRAINT PK_ZAK PRIMARY KEY,
	ID_PROD INT NOT NULL CONSTRAINT FK_ZAKUPY_PROD FOREIGN KEY REFERENCES MAGAZYN_PROD(ID_PROD),
	LICZBA INT NOT NULL,
)
GO
CREATE TABLE DBO.SPRZED
(
    ID_SPRZ INT NOT NULL IDENTITY CONSTRAINT PK_SPRZ PRIMARY KEY,
	ID_PROD INT NOT NULL CONSTRAINT FK_SPRZED_PROD FOREIGN KEY REFERENCES MAGAZYN_PROD(ID_PROD),
	LICZBA INT NOT NULL,
)
GO

--tutaj sprawdzam czy istnieje trigger TR_MAGAZYN_PROD_NULL i jeżeli tak to usuwam go a poniżej tworzę nowe
IF EXISTS (
	SELECT 1
	FROM sysobjects o
	WHERE o.[name] = 'TR_MAGAZYN_PROD_ZERO'
	AND (OBJECTPROPERTY(o.[ID], 'IsTrigger') = 1)
) 
BEGIN
	DROP TRIGGER DBO.TR_MAGAZYN_PROD_ZERO
END
GO
--domyślnie ustawiam 0 do nowego dostepnego i zakupionego artykulu
CREATE TRIGGER DBO.TR_MAGAZYN_PROD_ZERO ON MAGAZYN_PROD FOR INSERT
AS
	UPDATE MAGAZYN_PROD
	SET LICZBA_DOSTEPNYCH = 0, LICZBA_ZAK = 0
	FROM MAGAZYN_PROD M
	JOIN INSERTED I ON (I.ID_PROD = M.ID_PROD)
GO
IF EXISTS (
	SELECT 1
	FROM sysobjects o
	WHERE o.[name] = 'TR_MAGAZYN_PROD_WART_DOST'
	AND (OBJECTPROPERTY(o.[ID], 'IsTrigger') = 1)
) 
BEGIN
	DROP TRIGGER DBO.TR_MAGAZYN_PROD_WART_DOST
END
GO
--ten trigger sprawdza liczbę dostępnych towarów na 0 i na mniejszość od zakupionych
CREATE TRIGGER DBO.TR_MAGAZYN_PROD_WART_DOST ON MAGAZYN_PROD FOR UPDATE
AS
	IF EXISTS(
		SELECT 1
		FROM INSERTED I 
		WHERE I.LICZBA_DOSTEPNYCH > LICZBA_ZAK OR I.LICZBA_DOSTEPNYCH < 0
	)
	BEGIN
		PRINT N'Liczba dostępnych produktów przekracza liczbę zakupionych lub mniejsza od 0'
		ROLLBACK TRAN
	END
GO
IF EXISTS (
	SELECT 1
	FROM sysobjects o
	WHERE o.[name] = 'TR_ZAKUPY'
	AND (OBJECTPROPERTY(o.[ID], 'IsTrigger') = 1)
) 
BEGIN
	DROP TRIGGER DBO.TR_ZAKUPY
END
GO
--Trigger do aktualizacji zakupionych artykułów
CREATE TRIGGER DBO.TR_ZAKUPY ON ZAKUPY FOR INSERT, UPDATE, DELETE
AS  
	UPDATE MAGAZYN_PROD 
		SET LICZBA_ZAK = LICZBA_ZAK - X.LICZBA, LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH - X.LICZBA
		FROM MAGAZYN_PROD M
		JOIN (
			SELECT D.ID_PROD, SUM(D.LICZBA) AS LICZBA
			FROM DELETED D
			GROUP BY D.ID_PROD
		) X ON (M.ID_PROD = X.ID_PROD)

	UPDATE MAGAZYN_PROD 
		SET 
			LICZBA_ZAK = LICZBA_ZAK + X.LICZBA,
			LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH + X.LICZBA
		FROM MAGAZYN_PROD M
		JOIN (
			SELECT I.ID_PROD, SUM(I.LICZBA) AS LICZBA
			FROM INSERTED I
			GROUP BY I.ID_PROD
		) X ON (M.ID_PROD = X.ID_PROD)

GO
IF EXISTS (
	SELECT 1
	FROM sysobjects o
	WHERE o.[name] = 'WYD_Z_MAG'
	AND (OBJECTPROPERTY(o.[ID], 'IsTrigger') = 1)
) 
BEGIN
	DROP TRIGGER DBO.WYD_Z_MAG
END
GO
--Trigger do aktualizacji sprzedanych artykułów 
CREATE TRIGGER DBO.WYD_Z_MAG ON SPRZED FOR INSERT, UPDATE, DELETE
AS  
	UPDATE MAGAZYN_PROD 
		SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH - X.LICZBA
		FROM MAGAZYN_PROD M
		JOIN (
			SELECT I.ID_PROD, SUM(I.LICZBA) AS LICZBA
			FROM INSERTED I
			GROUP BY I.ID_PROD
		) X ON (M.ID_PROD = X.ID_PROD)

	UPDATE MAGAZYN_PROD 
		SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH + X.LICZBA
		FROM MAGAZYN_PROD M
		JOIN (
			SELECT D.ID_PROD, SUM(D.LICZBA) AS LICZBA
			FROM DELETED D
			GROUP BY D.ID_PROD
		) X ON (M.ID_PROD = X.ID_PROD)

GO
--dodaje jednocześnie do wszystkich tabel wiele rekordów 
INSERT INTO MAGAZYN_PROD (NAZWA) VALUES (N'IPHONE 12'), (N'IPHONE 13'), 
(N'IPHONE 14'), (N'IPHONE 15'), (N'IPHONE 16'), (N'XIAOMI 8'), 
(N'XIAOMI 9'), (N'XIAOMI 10'), (N'XIAOMI 11'), (N'XIAOMI 12')
INSERT INTO ZAKUPY (ID_PROD, LICZBA) VALUES (1,5), (2,3), (3,4), 
(4,3), (5,1), (6,10)
INSERT INTO SPRZED (ID_PROD, LICZBA) VALUES (1,3), (2,1), (3,3), 
(4,2), (5,0), (6,7)

SELECT DISTINCT * FROM MAGAZYN_PROD
SELECT DISTINCT * FROM ZAKUPY
SELECT DISTINCT * FROM SPRZED
/* Wygląd tablicy po tych insertach, widać że od razu dodaje się LICZBA_ZAK oraz dodaje się i odejmuje się LICZBA_DOSTEPNYCH
NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           5           2
IPHONE 13                                          2           3           2
IPHONE 14                                          3           4           1
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           1
XIAOMI 8                                           6           10          3
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)

ID_ZAK      ID_PROD     LICZBA
----------- ----------- -----------
1           1           5
2           2           3
3           3           4
4           4           3
5           5           1
6           6           10

(6 rows affected)

ID_SPRZ     ID_PROD     LICZBA
----------- ----------- -----------
1           1           3
2           2           1
3           3           3
4           4           2
5           5           0
6           6           7

(6 rows affected)
*/
INSERT INTO ZAKUPY (ID_PROD, LICZBA) VALUES (1,5), (1,3), (1,4), 
(1,3), (1,1), (1,10)
SELECT DISTINCT * FROM ZAKUPY
SELECT DISTINCT * FROM MAGAZYN_PROD
--Wstawienie wielu rekordów na raz dla tego samego id_tow, 
--wszystko poprawnie dodaje się automatycznie do tablicy 
--MAGAZYN_PROD
/*
ID_ZAK      ID_PROD     LICZBA
----------- ----------- -----------
1           1           5
2           2           3
3           3           4
4           4           3
5           5           1
6           6           10
7           1           5
8           1           3
9           1           4
10          1           3
11          1           1
12          1           10

(12 rows affected)

NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           31          28
IPHONE 13                                          2           3           2
IPHONE 14                                          3           4           1
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           1
XIAOMI 8                                           6           10          3
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)

*/
DELETE FROM ZAKUPY where ID_PROD = 1 and (ID_ZAK = 8 OR ID_ZAK = 9 OR ID_ZAK = 10) 
INSERT INTO ZAKUPY (ID_PROD, LICZBA) VALUES (2,5), (2,3), (2,4), 
(3,3), (2,1), (3,10)
SELECT DISTINCT * FROM ZAKUPY
SELECT DISTINCT * FROM MAGAZYN_PROD
/* Dla iphone 12 odjąłem 10 sztuk 28 - 4 -3-4 =18, wszystko odejmuje się i dodaje się 
ID_ZAK      ID_PROD     LICZBA
----------- ----------- -----------
1           1           5
2           2           3
3           3           4
4           4           3
5           5           1
6           6           10
7           1           5
11          1           1
12          1           10
13          2           5
14          2           3
15          2           4
16          3           3
17          2           1
18          3           10

(15 rows affected)

NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           21          18
IPHONE 13                                          2           16          15
IPHONE 14                                          3           17          14
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           1
XIAOMI 8                                           6           10          3
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)
*/
UPDATE ZAKUPY SET ID_PROD = 3 WHERE ID_ZAK = 12 OR ID_ZAK = 13 OR ID_ZAK = 14
SELECT DISTINCT * FROM ZAKUPY
SELECT DISTINCT * FROM MAGAZYN_PROD
/* Zostały zamienione towary dla id_zak 12, 13, 14
ID_ZAK      ID_PROD     LICZBA
----------- ----------- -----------
1           1           5
2           2           3
3           3           4
4           4           3
5           5           1
6           6           10
7           1           5
11          1           1
12          3           10
13          3           5
14          3           3
15          2           4
16          3           3
17          2           1
18          3           10

(15 rows affected)

NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           11          8
IPHONE 13                                          2           8           7
IPHONE 14                                          3           35          32
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           1
XIAOMI 8                                           6           10          3
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)
*/
--INSERT INTO SPRZED (ID_PROD, LICZBA) VALUES (1,3), (1,2), (1,5), (2, 3), (3,2), (3,3),(1,3),(5,1)
/* Przekroczyłem liczbę spredania towaru
Liczba dostępnych produktów przekracza liczbę zakupionych lub mniejsza od 0
Msg 3609, Level 16, State 1, Procedure WYD_Z_MAG, Line 4 [Batch Start Line 368]
The transaction ended in the trigger. The batch has been aborted.
*/
INSERT INTO SPRZED (ID_PROD, LICZBA) VALUES (1,3), (1,2), (2, 3), (3,2), (3,3),(1,3),(5,1)
SELECT DISTINCT * FROM MAGAZYN_PROD
SELECT DISTINCT * FROM SPRZED
/* IPHONE 12 8-3-2-3=0, 13: 7-3=4, 14: 32-5=27
NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           11          0
IPHONE 13                                          2           8           4
IPHONE 14                                          3           35          27
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           0
XIAOMI 8                                           6           10          3
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)

ID_SPRZ     ID_PROD     LICZBA
----------- ----------- -----------
1           1           3
2           2           1
3           3           3
4           4           2
5           5           0
6           6           7
7           1           3
8           1           2
9           2           3
10          3           2
11          3           3
12          1           3
13          5           1

(13 rows affected)
*/
DELETE FROM SPRZED WHERE (ID_PROD = 1 AND (ID_SPRZ = 7 or ID_SPRZ = 8)) OR (ID_PROD = 3 AND (ID_SPRZ = 10 or ID_SPRZ = 11))
SELECT DISTINCT * FROM MAGAZYN_PROD
SELECT DISTINCT * FROM SPRZED
/* usunęłem cztery rekordy i te wartości wrócili 12: 0+3+2=5, 14: 27+2+3=32
NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           11          5
IPHONE 13                                          2           8           4
IPHONE 14                                          3           35          32
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           0
XIAOMI 8                                           6           10          3
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)

ID_SPRZ     ID_PROD     LICZBA
----------- ----------- -----------
1           1           3
2           2           1
3           3           3
4           4           2
5           5           0
6           6           7
9           2           3
12          1           3
13          5           1

(9 rows affected)
*/
--UPDATE SPRZED SET ID_PROD = 2 WHERE ID_SPRZ = 5 OR ID_SPRZ = 6 OR ID_SPRZ = 9 OR ID_SPRZ = 12
/* Wynik błąd bo dla id2 przez ten update będzie sprzedano 13 sztuk z 4, czyli 4-13=-9
Zastrzeżenie od triggera:
Liczba dostępnych produktów przekracza liczbę zakupionych lub mniejsza od 0
Msg 3609, Level 16, State 1, Procedure WYD_Z_MAG, Line 4 [Batch Start Line 444]
The transaction ended in the trigger. The batch has been aborted.
*/
UPDATE SPRZED SET ID_PROD = 3 WHERE ID_SPRZ = 5 OR ID_SPRZ = 6 OR ID_SPRZ = 9 OR ID_SPRZ = 12
SELECT DISTINCT * FROM MAGAZYN_PROD
SELECT DISTINCT * FROM SPRZED
/* IPHONE 14: 32-13=19 wszystko poprawnie
NAZWA                                              ID_PROD     LICZBA_ZAK  LICZBA_DOSTEPNYCH
-------------------------------------------------- ----------- ----------- -----------------
IPHONE 12                                          1           11          8
IPHONE 13                                          2           8           7
IPHONE 14                                          3           35          19
IPHONE 15                                          4           3           1
IPHONE 16                                          5           1           0
XIAOMI 8                                           6           10          10
XIAOMI 9                                           7           0           0
XIAOMI 10                                          8           0           0
XIAOMI 11                                          9           0           0
XIAOMI 12                                          10          0           0

(10 rows affected)

ID_SPRZ     ID_PROD     LICZBA
----------- ----------- -----------
1           1           3
2           2           1
3           3           3
4           4           2
5           3           0
6           3           7
9           3           3
12          3           3
13          5           1

(9 rows affected)
*/
