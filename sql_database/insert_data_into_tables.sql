
-- insert into clienti

INSERT INTO clienti (cod_client, nume, prenume) VALUES (1, 'Victor', 'Eugen');

INSERT INTO clienti (cod_client, nume, prenume) VALUES (2, 'Ion', 'Badea');

INSERT INTO clienti (cod_client, nume, prenume) VALUES (3, 'Ursu', 'Nicolae');

INSERT INTO clienti (cod_client, nume, prenume) VALUES (4, 'Marin', 'Ana');

INSERT INTO clienti (cod_client, nume, prenume) VALUES (5, 'Vasilescu', 'George');

INSERT INTO clienti (cod_client, nume, prenume) VALUES (6, 'Popescu', 'Maria');


-- insert into conturi

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('eugen.victor@gmail.com', '12dsa34sad567', '0711265972', 1);

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('badea.ion@gmail.com', 'parola123', '0723456789', 2);    

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('nicolae.ursu@gmail.com', 'numistiiparola', '0710012272', 3);

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('ana.marin@gmail.com', 'parola456', '0734567890', 4);

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('george.vasilescu@gmail.com', 'parola789', '0745678901', 5);

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('maria.popescu@yahoo.com', 'securepassword123', '0767890123', 6);


-- insert into adresa

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code) VALUES (1, 'Strada Libertatii', 'Bucuresti', 'Bucuresti', 123456);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code) VALUES (2, 'Strada Independentei', 'Cluj-Napoca', 'Cluj', 400123);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code) VALUES (3, 'Strada Primaverii', 'Iasi', 'Iasi', 700100);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code) VALUES (4, 'Bulevardul Eroilor', 'Brasov', 'Brasov', 500025);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code) VALUES (5, 'Calea Dorobantilor', 'Constanta', 'Constanta', 900002);

INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code) VALUES (6, 'Strada Victoriei', 'Timisoara', 'Timis', 300456);


-- insert into articole_vestimentare

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (1, 120.50, 'M', 'Nike', 'tricou');

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (2, 200.00, 'L', 'Adidas', 'hanorac');

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (3, 150.75, 'S', 'Puma', 'incaltaminte');

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (4, 180.30, 'XL', 'Reebok', 'tricou');

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (5, 99.99, 'M', 'Zara', 'tricou');

INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (6, 250.00, 'XXL', 'UnderArmour', 'hanorac');


-- insert into detalii_comanda

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client) VALUES (1, TO_DATE('2025-01-10', 'YYYY-MM-DD'), 'numerar', 1);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client) VALUES (2, TO_DATE('2025-01-11', 'YYYY-MM-DD'), 'card', 2);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client) VALUES (3, TO_DATE('2025-01-12', 'YYYY-MM-DD'), 'numerar', 3);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client) VALUES (4, TO_DATE('2025-01-13', 'YYYY-MM-DD'), 'card', 4);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client) VALUES (5, TO_DATE('2025-01-14', 'YYYY-MM-DD'), 'numerar', 5);

INSERT INTO detalii_comanda (cod_comanda, data_plasare, modalitate_plata, cod_client) VALUES (6, TO_DATE('2025-01-15', 'YYYY-MM-DD'), 'card', 6);


-- insert into detalii_curier

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda) 
VALUES (1, TO_DATE('2025-01-11 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-14 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (2, TO_DATE('2025-01-12 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-15 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (3, TO_DATE('2025-01-13 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-16 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 3);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (4, TO_DATE('2025-01-14 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-17 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 4);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (5, TO_DATE('2025-01-15 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-18 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 5);

INSERT INTO detalii_curier (cod_curier, data_ridicare, data_predare, cod_client, cod_comanda)
VALUES (6, TO_DATE('2025-01-16 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-19 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, 6);


-- insert into clienti_ar_ve_fk

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (1, 1);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (2, 2);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (3, 3);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (4, 4);

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (5, 5); 

INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (6, 6);



SELECT * FROM ADRESA;
SELECT * FROM CLIENTI;
SELECT * FROM CONTURI;
SELECT * FROM ARTICOLE_VESTIMENTARE; 
SELECT * FROM DETALII_COMANDA;
SELECT * FROM DETALII_CURIER;
SELECT * FROM CLIENTI_AR_VE_FK;

