SET DEFINE OFF;

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
VALUES (1, 'Strada Libertatii 10', 'Bucuresti', 'Bucuresti', 123456);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
VALUES (2, 'Strada Independentei 7', 'Cluj-Napoca', 'Cluj', 400123);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
VALUES (3, 'Strada Primaverii 25', 'Iasi', 'Iasi', 700100);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
VALUES (4, 'Bulevardul Eroilor 3', 'Brasov', 'Brasov', 500025);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
VALUES (5, 'Calea Dorobantilor 42', 'Constanta', 'Constanta', 900002);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
VALUES (6, 'Strada Victoriei 18', 'Timisoara', 'Timis', 300456);

INSERT INTO clienti (cod_client, nume, prenume)
VALUES (1, 'Victor', 'Eugen');

INSERT INTO clienti (cod_client, nume, prenume)
VALUES (2, 'Badea', 'Ion');

INSERT INTO clienti (cod_client, nume, prenume)
VALUES (3, 'Ursu', 'Nicolae');

INSERT INTO clienti (cod_client, nume, prenume)
VALUES (4, 'Marin', 'Ana');

INSERT INTO clienti (cod_client, nume, prenume)
VALUES (5, 'Vasilescu', 'George');

INSERT INTO clienti (cod_client, nume, prenume)
VALUES (6, 'Popescu', 'Maria');

INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('eugen.victor@gmail.com', 'parola123', '0711265972', 1);

INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('badea.ion@gmail.com', 'parola123', '0723456789', 2);

INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('nicolae.ursu@gmail.com', 'numistiiparola', '0710012272', 3);

INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('ana.marin@gmail.com', 'parola456', '0734567890', 4);

INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('george.vasilescu@gmail.com', 'parola789', '0745678901', 5);

INSERT INTO conturi (email, parola, numar_telefon, cod_client)
VALUES ('maria.popescu@yahoo.com', 'secure123', '0767890123', 6);

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
VALUES (1, 120.50, 'M', 'Nike', 'tricou', 12);

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
VALUES (2, 200.00, 'L', 'Adidas', 'hanorac', 8);

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
VALUES (3, 150.75, 'S', 'Puma', 'incaltaminte', 10);

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
VALUES (4, 180.30, 'XL', 'Reebok', 'tricou', 7);

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
VALUES (5, 99.99, 'M', 'Zara', 'tricou', 15);

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
VALUES (6, 250.00, 'XXL', 'UnderArmour', 'hanorac', 5);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, status_comanda, cod_client, cod_adresa)
VALUES (1, TO_DATE('2026-04-10 10:15:00', 'YYYY-MM-DD HH24:MI:SS'), 'numerar', 'plasata', 1, 1);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, status_comanda, cod_client, cod_adresa)
VALUES (2, TO_DATE('2026-04-11 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'card', 'plasata', 2, 2);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, status_comanda, cod_client, cod_adresa)
VALUES (3, TO_DATE('2026-04-12 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'numerar', 'plasata', 3, 3);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, status_comanda, cod_client, cod_adresa)
VALUES (4, TO_DATE('2026-05-03 09:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'card', 'plasata', 4, 4);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, status_comanda, cod_client, cod_adresa)
VALUES (5, TO_DATE('2026-05-05 16:20:00', 'YYYY-MM-DD HH24:MI:SS'), 'numerar', 'plasata', 5, 5);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, status_comanda, cod_client, cod_adresa)
VALUES (6, TO_DATE('2026-05-07 13:10:00', 'YYYY-MM-DD HH24:MI:SS'), 'card', 'plasata', 6, 6);

INSERT INTO comanda_articole (cod_client, cod_comanda, cod_articol, cantitate)
VALUES (1, 1, 1, 2);

INSERT INTO comanda_articole (cod_client, cod_comanda, cod_articol, cantitate)
VALUES (2, 2, 2, 1);

INSERT INTO comanda_articole (cod_client, cod_comanda, cod_articol, cantitate)
VALUES (3, 3, 3, 1);

INSERT INTO comanda_articole (cod_client, cod_comanda, cod_articol, cantitate)
VALUES (4, 4, 4, 2);

INSERT INTO comanda_articole (cod_client, cod_comanda, cod_articol, cantitate)
VALUES (5, 5, 5, 3);

INSERT INTO comanda_articole (cod_client, cod_comanda, cod_articol, cantitate)
VALUES (6, 6, 6, 1);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (1, TO_DATE('2026-04-11 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2026-04-14 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (2, TO_DATE('2026-04-12 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2026-04-15 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (3, TO_DATE('2026-04-13 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2026-04-16 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 3);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (4, TO_DATE('2026-05-04 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2026-05-07 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 4);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (5, TO_DATE('2026-05-06 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2026-05-09 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 5);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (6, TO_DATE('2026-05-08 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2026-05-11 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, 6);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)
VALUES (1, 1);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)
VALUES (2, 2);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)
VALUES (3, 3);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)
VALUES (4, 4);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)
VALUES (5, 5);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)
VALUES (6, 6);

COMMIT;

PROMPT Date de test inserate cu succes.
