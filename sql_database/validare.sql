

--------------------------- VALIDARE -------------------------------



----------------- Verificari pentru clienti ---------------

-- verifica restrictia de cheie primara pentru cod_client din tabela clienti
-- unique constraint (BD099.CLIENTI_PK) violated
INSERT INTO clienti (cod_client, nume, prenume) VALUES (1, 'Manuel', 'Darian');

INSERT INTO clienti (cod_client, nume, prenume) VALUES (1, 'Francesco', 'Frant');


-- verifica daca exista clienti cu nume sau prenume NULL
-- These objects cannot accept NULL values. Reservable columns cannot accept NULL values.
INSERT INTO clienti (cod_client, nume, prenume) VALUES (7, '', '');




----------------- Verificari pentru conturi ----------------------

-- testare validare numar_telefon
-- check constraint (BD099.SYS_C001832188) violated
INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('eugen.victor@gmail.com', '12dsa34sad567', '071sad', 1);   


-- testare validare email
-- check constraint (BD099.SYS_C001832187) violated
INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('emailincorect.com', 'parola123', '0723456789', 1); 


-- testare unicitate email/telefon
-- unique constraint (BD099.CONTURI__IDX) violated
INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('duplicat@email.com', 'parola1', '0723456789', 1);

INSERT INTO conturi (email, parola, numar_telefon, cod_client) VALUES ('duplicat@email.com', 'parola2', '0723456788', 2);




--------------- Verificari pentru adresa ------------------

-- cod postal invalid (litere)
-- ORA-01722: invalid number
INSERT INTO adresa (strada, oras, judet, zip_code) VALUES ('Strada Libertatii', 'Cluj-Napoca', 'Cluj', '400AB');


-- campuri obligatorii goale
-- These objects cannot accept NULL values. Reservable columns cannot accept NULL values.
INSERT INTO adresa (strada, oras, judet, zip_code) VALUES ('', '', '', 0);




--------- Verificari pentru articole_vestimentare --------------

-- testare constrangeri pentru articole vestimentare
-- check constraint (BD099.ARTICOLE_VESTIMENTARE_TIP_CK) violated
INSERT INTO articole_vestimentare (pret, marime, firma, tip)VALUES (-50, 'XXXL', 'Necunoscut', 'pantaloni');  


-- pret invalid
-- ORA-02290: check constraint (BD099.ARTICOLE_VESTIMENTARE_PRET_CK) violated
INSERT INTO articole_vestimentare (pret, marime, firma, tip)VALUES (-50, 'XXL', 'Nike', 'hanorac');  


-- tip articol invalid
-- ORA-02290: check constraint (BD099.ARTICOLE_VESTIMENTARE_TIP_CK) violated
INSERT INTO articole_vestimentare (pret, marime, firma, tip) VALUES (75, 'L', 'Puma', 'geaca');




----------------  Verificari pentru detalii_comanda ---------------------

-- testare data comenzi (trigger)
-- SQL Error: ORA-20001: Data invalida: 10.12.2024 22:39:26 trebuie sa fie mai mare decat data curenta. 
-- ORA-06512: at "BD099.TRG_DETALII_COMANDA_DATA_PLASARE", line 4
-- ORA-04088: error during execution of trigger 'BD099.TRG_DETALII_COMANDA_DATA_PLASARE'
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client) VALUES (SYSDATE - 1, 'card', 1);  


-- testare modalitate plata
-- ORA-02290: check constraint (BD099.DETALII_COMANDA_MOD_PLATA_CK) violated
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client) VALUES (SYSDATE + 1, 'transfer', 1);  


-- testare data comenzi in trecut (trigger)
-- ORA-20001: Data invalida: 10.12.2024 22:41:08 trebuie sa fie mai mare decat data curenta.
-- ORA-06512: at "BD099.TRG_DETALII_COMANDA_DATA_PLASARE", line 4
-- ORA-04088: error during execution of trigger 'BD099.TRG_DETALII_COMANDA_DATA_PLASARE'
INSERT INTO detalii_comanda (data_plasare, modalitate_plata, cod_client) VALUES (SYSDATE - 1, 'card', 1);




--------------- Verificari pentru detalii_curier ------------------


-- verificare data ridicare si predare in viitor (Trg_detalii_curier_data_ridicare si Trg_detalii_curier_data_predare)
INSERT INTO detalii_curier (data_ridicare, data_predare, cod_client, cod_comanda) VALUES (SYSDATE - 1, SYSDATE - 1, 1, 1); 


-- verificare relatie cu detalii_comanda (cheie externa)
-- trebuie sa existe o comanda valida pentru clientul specificat inainte de a putea insera in detalii_curier
-- ORA-02291: integrity constraint (BD099.DETALII_COM_DETALII_CU_FK) violated - parent key not found
INSERT INTO detalii_curier (data_ridicare, data_predare, cod_client, cod_comanda) VALUES (SYSDATE + 10, SYSDATE + 15, 9999, 9999); 



-------------- Verificari pentru clienti_ar_ve_fk (Legatura dintre clienti si articole) ----------------


-- verificare existenta client, clientul cu codul 9999 nu exista
-- ORA-02291: integrity constraint (BD099.CLIENTI_AR_VE_FK_CLI_FK) violated - parent key not found
INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol)  VALUES (9999, 1); 


-- verificare existenta articol vestimentar, articolul cu cod 9999 nu exista
-- ORA-02291: integrity constraint (BD099.CLIENTI_AR_VE_FK_AR_VE_FK) violated - parent key not found
INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (1, 9999); 


-- verificare unicitate pereche client-articol
-- Inserează prima data
-- ORA-00001: unique constraint (BD099.CLIENTI_PK) violated
INSERT INTO clienti (cod_client, nume, prenume) VALUES (100, 'Test', 'Client');
-- ORA-00001: unique constraint (BD099.AR_VE_COD_ARTICOL_UK) violated
INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip) VALUES (100, 50.00, 'M', 'Nike', 'tricou');
-- ORA-00001: unique constraint (BD099.CLIENTI_AR_VE_FK_PK) violated
INSERT INTO clienti_ar_ve_fk (clienti_cod_client, ar_ve_cod_articol) VALUES (100, 100);


