
--------------------- VALIDARE -------------------------------------


-- Testare PK - cod_client
INSERT INTO clienti (cod_client, nume, prenume) 
VALUES (1, 'Popescu', 'Ion');  -- Ar trebui sa genereze automat un cod unic

-- Testare NOT NULL
INSERT INTO clienti (cod_client, nume) 
VALUES (1, 'Popescu');  -- Ar trebui sa dea eroare (lipsa prenume)

-- Testare validare email
INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('invalid-email', 'parola123', '0723456789', 1);  -- Ar trebui sa dea eroare

-- Testare unicitate email/telefon
INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('duplicat@email.com', 'parola1', '0723456789', 1);
INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('duplicat@email.com', 'parola2', '0723456788', 2);  -- Ar trebui sa dea eroare

-- Testare constrângeri pentru articole vestimentare
INSERT INTO articole_vestimentare (pret, marime, firma, tip)
VALUES (-50, 'XXXL', 'Necunoscut', 'pantaloni');  -- Ar trebui sa dea mai multe erori

-- Testare data comenzi (trigger)
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client)
VALUES (SYSDATE - 1, 'card', 1);  -- Ar trebui sa dea eroare (data in trecut)

-- Testare modalitate plata
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client)
VALUES (SYSDATE + 1, 'transfer', 1);  -- Ar trebui sa dea eroare

-- Testare data comenzi (trigger)
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client)
VALUES (SYSDATE - 1, 'card', 1);  -- Ar trebui sa dea eroare (data in trecut)

-- Testare modalitate plata
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client)
VALUES (SYSDATE + 1, 'transfer', 1);  -- Ar trebui sa dea eroare



----------------------------------------------------------


------ Verificari pentru adresa -----

-- Verifica daca exista duplicate in cod_adresa 
SELECT cod_adresa, COUNT(*)
FROM adresa
GROUP BY cod_adresa
HAVING COUNT(*) > 1;

-- Verifica daca toate valorile pentru zip_code respecta regula definita
SELECT * 
FROM adresa 
WHERE NOT REGEXP_LIKE(zip_code, '^[0-9]+$');


-- Verifica daca exista linii in care câmpurile strada, oras, judet, zip_code sunt NULL
SELECT * 
FROM adresa 
WHERE strada IS NULL OR oras IS NULL OR judet IS NULL OR zip_code IS NULL;



--------- Verificari pentru articole_vestimentare --------------

-- Verifica daca exista duplicate in cod_articol
SELECT cod_articol, COUNT(*)
FROM articole_vestimentare
GROUP BY cod_articol
HAVING COUNT(*) > 1;


-- Verifica daca exista articole cu un pret mai mic sau egal cu 0
SELECT * 
FROM articole_vestimentare
WHERE pret <= 0;

-- Verifica daca exista articole cu marimi care nu sunt in lista definita (L, M, S, XL, XXL)
SELECT * 
FROM articole_vestimentare
WHERE marime NOT IN ('L', 'M', 'S', 'XL', 'XXL');

-- Verifica daca exista articole cu tipuri care nu sunt in lista definita ('hanorac', 'incaltaminte', 'tricou')
SELECT * 
FROM articole_vestimentare
WHERE tip NOT IN ('hanorac', 'incaltaminte', 'tricou');




-------- Verificari pentru clienti ---------------

-- Verifica daca exista duplicate in cod_client
SELECT cod_client, COUNT(*)
FROM clienti
GROUP BY cod_client
HAVING COUNT(*) > 1;


-- Verifica daca exista clienti cu nume sau prenume NULL
SELECT * 
FROM clienti 
WHERE nume IS NULL OR prenume IS NULL;



-------------- Verificari pentru clienti_ar_ve_fk (Legatura dintre clienti si articole) ----------------

-- Verifica daca exista duplicate in combinatia clienti_cod_client si ar_ve_cod_articol
SELECT clienti_cod_client, ar_ve_cod_articol, COUNT(*)
FROM clienti_ar_ve_fk
GROUP BY clienti_cod_client, ar_ve_cod_articol
HAVING COUNT(*) > 1;


-- Verifica daca exista articole care nu au corespondenta in tabela articole_vestimentare
SELECT * 
FROM clienti_ar_ve_fk 
WHERE ar_ve_cod_articol NOT IN (SELECT cod_articol FROM articole_vestimentare);

-- Verifica daca exista clienti care nu au corespondenta in tabela clienti
SELECT * 
FROM clienti_ar_ve_fk 
WHERE clienti_cod_client NOT IN (SELECT cod_client FROM clienti);




----------------- Verificari pentru conturi ----------------------


-- Verifica daca exista duplicate in email sau numar_telefon
SELECT email, COUNT(*)
FROM conturi
GROUP BY email
HAVING COUNT(*) > 1;

SELECT numar_telefon, COUNT(*)
FROM conturi
GROUP BY numar_telefon
HAVING COUNT(*) > 1;


-- Verifica daca exista clienti care nu au corespondenta in tabela clienti
SELECT * 
FROM conturi 
WHERE cod_client NOT IN (SELECT cod_client FROM clienti);




----------------  Verificari pentru detalii_comanda ---------------------

-- Verifica daca exista duplicate in combinatia cod_client si cod_comanda
SELECT cod_client, cod_comanda, COUNT(*)
FROM detalii_comanda
GROUP BY cod_client, cod_comanda
HAVING COUNT(*) > 1;


-- Verifica daca exista clienti care nu au corespondenta in tabela clienti
SELECT * 
FROM detalii_comanda 
WHERE cod_client NOT IN (SELECT cod_client FROM clienti);



--------------- Verificari pentru detalii_curier ------------------


-- Verifica daca exista duplicate in combinatia cod_curier, cod_client si cod_comanda
SELECT cod_curier, cod_client, cod_comanda, COUNT(*)
FROM detalii_curier
GROUP BY cod_curier, cod_client, cod_comanda
HAVING COUNT(*) > 1;



-- Verifica daca exista clienti care nu au corespondenta in tabela clienti
SELECT * 
FROM detalii_curier 
WHERE cod_client NOT IN (SELECT cod_client FROM clienti);

-- Verifica daca exista comenzi care nu au corespondenta in tabela detalii_comanda
SELECT * 
FROM detalii_curier 
WHERE (cod_client, cod_comanda) NOT IN (SELECT cod_client, cod_comanda FROM detalii_comanda);



-- Testeaza trigger-ul pentru data_plasare din detalii_comanda
INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client)
VALUES (detalii_comanda_cod_comanda_seq.nextval, SYSDATE - 1, 'card', 1);  -- Ar trebui sa arunce eroare
