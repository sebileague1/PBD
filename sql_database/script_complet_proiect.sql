SET DEFINE OFF;
SET SERVEROUTPUT ON;

PROMPT SCRIPT COMPLET PROIECT PBD - Magazin online cu articole vestimentare

PROMPT ============================================================
PROMPT Rulare sectiune: 00_drop_objects.sql
PROMPT ============================================================
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE pbd_drop_object(
    p_sql          IN VARCHAR2,
    p_ignored_code IN NUMBER
) IS
BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('Executat: ' || p_sql);
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE <> p_ignored_code THEN
            RAISE;
        END IF;
END;
/

BEGIN
    pbd_drop_object('DROP PROCEDURE pr_afiseaza_comenzi_client', -4043);
    pbd_drop_object('DROP FUNCTION fn_total_client', -4043);
    pbd_drop_object('DROP PACKAGE pkg_magazin_online', -4043);

    pbd_drop_object('DROP TABLE detalii_curier CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE comanda_articole CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE clienti_ar_ve_fk CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE detalii_comanda CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE conturi CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE articole_vestimentare CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE adresa CASCADE CONSTRAINTS PURGE', -942);
    pbd_drop_object('DROP TABLE clienti CASCADE CONSTRAINTS PURGE', -942);

    pbd_drop_object('DROP SEQUENCE seq_adresa', -2289);
    pbd_drop_object('DROP SEQUENCE seq_articole_vestimentare', -2289);
    pbd_drop_object('DROP SEQUENCE seq_clienti', -2289);
    pbd_drop_object('DROP SEQUENCE seq_detalii_comanda', -2289);
    pbd_drop_object('DROP SEQUENCE seq_detalii_curier', -2289);

    -- Secvente ramase din exportul initial al Data Modeler, daca au fost rulate.
    pbd_drop_object('DROP SEQUENCE adresa_cod_adresa_seq', -2289);
    pbd_drop_object('DROP SEQUENCE articole_vestimentare_cod_arti', -2289);
    pbd_drop_object('DROP SEQUENCE clienti_cod_client_seq', -2289);
    pbd_drop_object('DROP SEQUENCE clienti_ar_ve_fk_clienti_cod_c', -2289);
    pbd_drop_object('DROP SEQUENCE clienti_ar_ve_fk_ar_ve_cod_art', -2289);
    pbd_drop_object('DROP SEQUENCE detalii_comanda_cod_comanda', -2289);
    pbd_drop_object('DROP SEQUENCE detalii_comanda_cod_client_seq', -2289);
    pbd_drop_object('DROP SEQUENCE detalii_curier_cod_curier_seq', -2289);
    pbd_drop_object('DROP SEQUENCE detalii_curier_cod_client_seq', -2289);
    pbd_drop_object('DROP SEQUENCE detalii_curier_cod_comanda_seq', -2289);
END;
/

DROP PROCEDURE pbd_drop_object;

PROMPT Resetare finalizata.

PROMPT ============================================================
PROMPT Rulare sectiune: 01_schema.sql
PROMPT ============================================================
SET DEFINE OFF;

CREATE TABLE adresa (
    cod_adresa NUMBER(7) NOT NULL,
    strada     VARCHAR2(100) NOT NULL,
    oras       VARCHAR2(50) NOT NULL,
    judet      VARCHAR2(50) NOT NULL,
    zip_code   NUMBER(10) NOT NULL
)
LOGGING;

ALTER TABLE adresa ADD CONSTRAINT adresa_zip_code_ck
    CHECK (REGEXP_LIKE(TO_CHAR(zip_code), '^[0-9]{4,10}$'));

ALTER TABLE adresa ADD CONSTRAINT adresa_pk PRIMARY KEY (cod_adresa);

CREATE TABLE clienti (
    cod_client NUMBER(10) NOT NULL,
    nume       VARCHAR2(30) NOT NULL,
    prenume    VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE clienti ADD CONSTRAINT clienti_pk PRIMARY KEY (cod_client);

CREATE TABLE conturi (
    email         VARCHAR2(40) NOT NULL,
    parola        VARCHAR2(50) NOT NULL,
    numar_telefon VARCHAR2(12) NOT NULL,
    cod_client    NUMBER(10) NOT NULL
)
LOGGING;

ALTER TABLE conturi ADD CONSTRAINT conturi_email_ck
    CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

ALTER TABLE conturi ADD CONSTRAINT conturi_telefon_ck
    CHECK (REGEXP_LIKE(numar_telefon, '^0[0-9]{9}$'));

ALTER TABLE conturi ADD CONSTRAINT conturi_parola_ck
    CHECK (LENGTH(parola) >= 6);

ALTER TABLE conturi ADD CONSTRAINT conturi_pk PRIMARY KEY (email);
ALTER TABLE conturi ADD CONSTRAINT conturi_client_uk UNIQUE (cod_client);
ALTER TABLE conturi ADD CONSTRAINT conturi_telefon_uk UNIQUE (numar_telefon);

CREATE TABLE articole_vestimentare (
    cod_articol NUMBER(10) NOT NULL,
    pret        NUMBER(8, 2) NOT NULL,
    marime      VARCHAR2(5) NOT NULL,
    firma       VARCHAR2(30) NOT NULL,
    tip         VARCHAR2(20) NOT NULL,
    stoc        NUMBER(5) DEFAULT 0 NOT NULL
)
LOGGING;

ALTER TABLE articole_vestimentare ADD CONSTRAINT articole_vestimentare_pret_ck
    CHECK (pret > 0);

ALTER TABLE articole_vestimentare ADD CONSTRAINT articole_vestimentare_stoc_ck
    CHECK (stoc >= 0);

ALTER TABLE articole_vestimentare ADD CONSTRAINT ar_ve_marime_ck
    CHECK (marime IN ('S', 'M', 'L', 'XL', 'XXL'));

ALTER TABLE articole_vestimentare ADD CONSTRAINT articole_vestimentare_tip_ck
    CHECK (tip IN ('hanorac', 'incaltaminte', 'tricou'));

ALTER TABLE articole_vestimentare ADD CONSTRAINT articole_vestimentare_pk
    PRIMARY KEY (cod_articol);

CREATE TABLE detalii_comanda (
    cod_comanda      NUMBER(10) NOT NULL,
    data_plasare     DATE NOT NULL,
    modalitate_plata VARCHAR2(10) NOT NULL,
    status_comanda   VARCHAR2(20) DEFAULT 'plasata' NOT NULL,
    cod_client       NUMBER(10) NOT NULL,
    cod_adresa       NUMBER(7) NOT NULL
)
LOGGING;

ALTER TABLE detalii_comanda ADD CONSTRAINT detalii_comanda_mod_plata_ck
    CHECK (modalitate_plata IN ('numerar', 'card'));

ALTER TABLE detalii_comanda ADD CONSTRAINT detalii_comanda_status_ck
    CHECK (status_comanda IN ('plasata', 'preluata', 'livrata', 'anulata'));

ALTER TABLE detalii_comanda ADD CONSTRAINT detalii_comanda_pk
    PRIMARY KEY (cod_client, cod_comanda);

ALTER TABLE detalii_comanda ADD CONSTRAINT detalii_comanda_cod_uk
    UNIQUE (cod_comanda);

CREATE TABLE detalii_curier (
    cod_curier    NUMBER(10) NOT NULL,
    data_ridicare DATE NOT NULL,
    data_predare  DATE NOT NULL,
    cod_client    NUMBER(10) NOT NULL,
    cod_comanda   NUMBER(10) NOT NULL
)
LOGGING;

ALTER TABLE detalii_curier ADD CONSTRAINT detalii_curier_pk
    PRIMARY KEY (cod_curier, cod_client, cod_comanda);

ALTER TABLE detalii_curier ADD CONSTRAINT detalii_curier_comanda_uk
    UNIQUE (cod_client, cod_comanda);

CREATE TABLE clienti_ar_ve_fk (
    clienti_cod_client NUMBER(10) NOT NULL,
    ar_ve_cod_articol  NUMBER(10) NOT NULL
)
LOGGING;

ALTER TABLE clienti_ar_ve_fk ADD CONSTRAINT clienti_ar_ve_fk_pk
    PRIMARY KEY (clienti_cod_client, ar_ve_cod_articol);

CREATE TABLE comanda_articole (
    cod_client  NUMBER(10) NOT NULL,
    cod_comanda NUMBER(10) NOT NULL,
    cod_articol NUMBER(10) NOT NULL,
    cantitate   NUMBER(5) NOT NULL,
    pret_unitar NUMBER(8, 2)
)
LOGGING;

ALTER TABLE comanda_articole ADD CONSTRAINT comanda_articole_cant_ck
    CHECK (cantitate > 0);

ALTER TABLE comanda_articole ADD CONSTRAINT comanda_articole_pret_ck
    CHECK (pret_unitar > 0);

ALTER TABLE comanda_articole ADD CONSTRAINT comanda_articole_pk
    PRIMARY KEY (cod_client, cod_comanda, cod_articol);

ALTER TABLE conturi ADD CONSTRAINT clienti_conturi_fk
    FOREIGN KEY (cod_client) REFERENCES clienti (cod_client);

ALTER TABLE detalii_comanda ADD CONSTRAINT clienti_detalii_comanda_fk
    FOREIGN KEY (cod_client) REFERENCES clienti (cod_client);

ALTER TABLE detalii_comanda ADD CONSTRAINT detalii_comanda_adresa_fk
    FOREIGN KEY (cod_adresa) REFERENCES adresa (cod_adresa);

ALTER TABLE detalii_curier ADD CONSTRAINT detalii_com_detalii_cur_fk
    FOREIGN KEY (cod_client, cod_comanda)
    REFERENCES detalii_comanda (cod_client, cod_comanda);

ALTER TABLE clienti_ar_ve_fk ADD CONSTRAINT clienti_ar_ve_fk_cli_fk
    FOREIGN KEY (clienti_cod_client) REFERENCES clienti (cod_client);

ALTER TABLE clienti_ar_ve_fk ADD CONSTRAINT clienti_ar_ve_fk_ar_ve_fk
    FOREIGN KEY (ar_ve_cod_articol) REFERENCES articole_vestimentare (cod_articol);

ALTER TABLE comanda_articole ADD CONSTRAINT comanda_articole_com_fk
    FOREIGN KEY (cod_client, cod_comanda)
    REFERENCES detalii_comanda (cod_client, cod_comanda);

ALTER TABLE comanda_articole ADD CONSTRAINT comanda_articole_art_fk
    FOREIGN KEY (cod_articol) REFERENCES articole_vestimentare (cod_articol);

CREATE SEQUENCE seq_adresa START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_clienti START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_articole_vestimentare START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_detalii_comanda START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_detalii_curier START WITH 100 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_adresa_bi
    BEFORE INSERT ON adresa
    FOR EACH ROW
    WHEN (new.cod_adresa IS NULL)
BEGIN
    SELECT seq_adresa.NEXTVAL
    INTO :new.cod_adresa
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_clienti_bi
    BEFORE INSERT ON clienti
    FOR EACH ROW
    WHEN (new.cod_client IS NULL)
BEGIN
    SELECT seq_clienti.NEXTVAL
    INTO :new.cod_client
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_articole_bi
    BEFORE INSERT ON articole_vestimentare
    FOR EACH ROW
    WHEN (new.cod_articol IS NULL)
BEGIN
    SELECT seq_articole_vestimentare.NEXTVAL
    INTO :new.cod_articol
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_detalii_comanda_bi
    BEFORE INSERT ON detalii_comanda
    FOR EACH ROW
    WHEN (new.cod_comanda IS NULL)
BEGIN
    SELECT seq_detalii_comanda.NEXTVAL
    INTO :new.cod_comanda
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_detalii_curier_bi
    BEFORE INSERT ON detalii_curier
    FOR EACH ROW
    WHEN (new.cod_curier IS NULL)
BEGIN
    SELECT seq_detalii_curier.NEXTVAL
    INTO :new.cod_curier
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER trg_comanda_cont_biu
    BEFORE INSERT OR UPDATE OF cod_client ON detalii_comanda
    FOR EACH ROW
DECLARE
    v_conturi NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_conturi
    FROM conturi
    WHERE cod_client = :new.cod_client;

    IF v_conturi = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se poate plasa comanda fara cont pentru client.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_curier_date_biu
    BEFORE INSERT OR UPDATE OF data_ridicare, data_predare, cod_client, cod_comanda
    ON detalii_curier
    FOR EACH ROW
DECLARE
    v_data_plasare detalii_comanda.data_plasare%TYPE;
BEGIN
    SELECT data_plasare
    INTO v_data_plasare
    FROM detalii_comanda
    WHERE cod_client = :new.cod_client
      AND cod_comanda = :new.cod_comanda;

    IF :new.data_ridicare < v_data_plasare THEN
        RAISE_APPLICATION_ERROR(-20002, 'Data ridicare nu poate fi inainte de data plasarii comenzii.');
    END IF;

    IF :new.data_predare < :new.data_ridicare THEN
        RAISE_APPLICATION_ERROR(-20003, 'Data predare nu poate fi inainte de data ridicarii.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Comanda inexistenta pentru curier.');
END;
/

CREATE OR REPLACE TRIGGER trg_curier_status_aiu
    AFTER INSERT OR UPDATE OF data_predare
    ON detalii_curier
    FOR EACH ROW
BEGIN
    UPDATE detalii_comanda
    SET status_comanda =
        CASE
            WHEN :new.data_predare <= SYSDATE THEN 'livrata'
            ELSE 'preluata'
        END
    WHERE cod_client = :new.cod_client
      AND cod_comanda = :new.cod_comanda
      AND status_comanda <> 'anulata';
END;
/

CREATE OR REPLACE TRIGGER trg_com_art_stoc_bi
    BEFORE INSERT ON comanda_articole
    FOR EACH ROW
DECLARE
    v_pret articole_vestimentare.pret%TYPE;
BEGIN
    SELECT pret
    INTO v_pret
    FROM articole_vestimentare
    WHERE cod_articol = :new.cod_articol;

    IF :new.pret_unitar IS NULL THEN
        :new.pret_unitar := v_pret;
    END IF;

    UPDATE articole_vestimentare
    SET stoc = stoc - :new.cantitate
    WHERE cod_articol = :new.cod_articol
      AND stoc >= :new.cantitate;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Stoc insuficient pentru articolul selectat.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'Articol inexistent.');
END;
/

CREATE OR REPLACE TRIGGER trg_com_art_stoc_bu
    BEFORE UPDATE OF cod_articol, cantitate, pret_unitar
    ON comanda_articole
    FOR EACH ROW
BEGIN
    UPDATE articole_vestimentare
    SET stoc = stoc + :old.cantitate
    WHERE cod_articol = :old.cod_articol;

    UPDATE articole_vestimentare
    SET stoc = stoc - :new.cantitate
    WHERE cod_articol = :new.cod_articol
      AND stoc >= :new.cantitate;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Stoc insuficient pentru actualizarea liniei de comanda.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_com_art_stoc_bd
    BEFORE DELETE ON comanda_articole
    FOR EACH ROW
BEGIN
    UPDATE articole_vestimentare
    SET stoc = stoc + :old.cantitate
    WHERE cod_articol = :old.cod_articol;
END;
/

PROMPT Schema creata cu succes.

PROMPT ============================================================
PROMPT Rulare sectiune: 02_insert_data.sql
PROMPT ============================================================
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

PROMPT ============================================================
PROMPT Rulare sectiune: 03_pachete_proceduri_functii.sql
PROMPT ============================================================
SET SERVEROUTPUT ON;
SET DEFINE OFF;

CREATE OR REPLACE PACKAGE pkg_magazin_online AS
    PROCEDURE adauga_client(
        p_nume          IN clienti.nume%TYPE,
        p_prenume       IN clienti.prenume%TYPE,
        p_email         IN conturi.email%TYPE,
        p_parola        IN conturi.parola%TYPE,
        p_numar_telefon IN conturi.numar_telefon%TYPE,
        p_cod_client    IN clienti.cod_client%TYPE DEFAULT NULL
    );

    PROCEDURE actualizeaza_client(
        p_cod_client IN clienti.cod_client%TYPE,
        p_nume       IN clienti.nume%TYPE,
        p_prenume    IN clienti.prenume%TYPE
    );

    PROCEDURE sterge_client(
        p_cod_client IN clienti.cod_client%TYPE
    );

    PROCEDURE adauga_adresa(
        p_strada     IN adresa.strada%TYPE,
        p_oras       IN adresa.oras%TYPE,
        p_judet      IN adresa.judet%TYPE,
        p_zip_code   IN adresa.zip_code%TYPE,
        p_cod_adresa OUT adresa.cod_adresa%TYPE
    );

    PROCEDURE adauga_articol(
        p_pret        IN articole_vestimentare.pret%TYPE,
        p_marime      IN articole_vestimentare.marime%TYPE,
        p_firma       IN articole_vestimentare.firma%TYPE,
        p_tip         IN articole_vestimentare.tip%TYPE,
        p_stoc        IN articole_vestimentare.stoc%TYPE,
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE DEFAULT NULL
    );

    PROCEDURE actualizeaza_stoc(
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE,
        p_stoc_nou    IN articole_vestimentare.stoc%TYPE
    );

    PROCEDURE sterge_articol(
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE
    );

    PROCEDURE plaseaza_comanda(
        p_cod_client       IN detalii_comanda.cod_client%TYPE,
        p_cod_adresa       IN detalii_comanda.cod_adresa%TYPE,
        p_cod_articol      IN comanda_articole.cod_articol%TYPE,
        p_cantitate        IN comanda_articole.cantitate%TYPE,
        p_modalitate_plata IN detalii_comanda.modalitate_plata%TYPE,
        p_data_plasare     IN detalii_comanda.data_plasare%TYPE,
        p_data_ridicare    IN detalii_curier.data_ridicare%TYPE,
        p_data_predare     IN detalii_curier.data_predare%TYPE,
        p_cod_comanda      OUT detalii_comanda.cod_comanda%TYPE
    );

    PROCEDURE anuleaza_comanda(
        p_cod_client  IN detalii_comanda.cod_client%TYPE,
        p_cod_comanda IN detalii_comanda.cod_comanda%TYPE
    );

    FUNCTION total_client(
        p_cod_client IN clienti.cod_client%TYPE
    ) RETURN NUMBER;

    FUNCTION stoc_articol(
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE
    ) RETURN NUMBER;

    PROCEDURE afiseaza_comenzi_client(
        p_cod_client IN clienti.cod_client%TYPE
    );

    PROCEDURE raport_stoc;
END pkg_magazin_online;
/

CREATE OR REPLACE PACKAGE BODY pkg_magazin_online AS
    e_stoc_insuficient EXCEPTION;
    e_date_invalide    EXCEPTION;

    PROCEDURE verifica_client(
        p_cod_client IN clienti.cod_client%TYPE
    ) IS
        v_dummy NUMBER;
    BEGIN
        SELECT 1
        INTO v_dummy
        FROM clienti
        WHERE cod_client = p_cod_client;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101, 'Clientul cu codul ' || p_cod_client || ' nu exista.');
    END verifica_client;

    PROCEDURE verifica_cont(
        p_cod_client IN clienti.cod_client%TYPE
    ) IS
        v_dummy NUMBER;
    BEGIN
        SELECT 1
        INTO v_dummy
        FROM conturi
        WHERE cod_client = p_cod_client;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20102, 'Clientul nu are cont si nu poate plasa comenzi.');
    END verifica_cont;

    PROCEDURE verifica_adresa(
        p_cod_adresa IN adresa.cod_adresa%TYPE
    ) IS
        v_dummy NUMBER;
    BEGIN
        SELECT 1
        INTO v_dummy
        FROM adresa
        WHERE cod_adresa = p_cod_adresa;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'Adresa cu codul ' || p_cod_adresa || ' nu exista.');
    END verifica_adresa;

    PROCEDURE adauga_client(
        p_nume          IN clienti.nume%TYPE,
        p_prenume       IN clienti.prenume%TYPE,
        p_email         IN conturi.email%TYPE,
        p_parola        IN conturi.parola%TYPE,
        p_numar_telefon IN conturi.numar_telefon%TYPE,
        p_cod_client    IN clienti.cod_client%TYPE DEFAULT NULL
    ) IS
        v_cod_client clienti.cod_client%TYPE;
    BEGIN
        v_cod_client := NVL(p_cod_client, seq_clienti.NEXTVAL);

        INSERT INTO clienti (cod_client, nume, prenume)
        VALUES (v_cod_client, p_nume, p_prenume);

        INSERT INTO conturi (email, parola, numar_telefon, cod_client)
        VALUES (p_email, p_parola, p_numar_telefon, v_cod_client);
    END adauga_client;

    PROCEDURE actualizeaza_client(
        p_cod_client IN clienti.cod_client%TYPE,
        p_nume       IN clienti.nume%TYPE,
        p_prenume    IN clienti.prenume%TYPE
    ) IS
    BEGIN
        verifica_client(p_cod_client);

        UPDATE clienti
        SET nume = p_nume,
            prenume = p_prenume
        WHERE cod_client = p_cod_client;
    END actualizeaza_client;

    PROCEDURE sterge_client(
        p_cod_client IN clienti.cod_client%TYPE
    ) IS
    BEGIN
        SAVEPOINT sp_sterge_client;
        verifica_client(p_cod_client);

        DELETE FROM detalii_curier
        WHERE cod_client = p_cod_client;

        DELETE FROM comanda_articole
        WHERE cod_client = p_cod_client;

        DELETE FROM detalii_comanda
        WHERE cod_client = p_cod_client;

        DELETE FROM clienti_ar_ve_fk
        WHERE clienti_cod_client = p_cod_client;

        DELETE FROM conturi
        WHERE cod_client = p_cod_client;

        DELETE FROM clienti
        WHERE cod_client = p_cod_client;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO sp_sterge_client;
            RAISE;
    END sterge_client;

    PROCEDURE adauga_adresa(
        p_strada     IN adresa.strada%TYPE,
        p_oras       IN adresa.oras%TYPE,
        p_judet      IN adresa.judet%TYPE,
        p_zip_code   IN adresa.zip_code%TYPE,
        p_cod_adresa OUT adresa.cod_adresa%TYPE
    ) IS
    BEGIN
        p_cod_adresa := seq_adresa.NEXTVAL;

        INSERT INTO adresa (cod_adresa, strada, oras, judet, zip_code)
        VALUES (p_cod_adresa, p_strada, p_oras, p_judet, p_zip_code);
    END adauga_adresa;

    PROCEDURE adauga_articol(
        p_pret        IN articole_vestimentare.pret%TYPE,
        p_marime      IN articole_vestimentare.marime%TYPE,
        p_firma       IN articole_vestimentare.firma%TYPE,
        p_tip         IN articole_vestimentare.tip%TYPE,
        p_stoc        IN articole_vestimentare.stoc%TYPE,
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE DEFAULT NULL
    ) IS
        v_cod_articol articole_vestimentare.cod_articol%TYPE;
    BEGIN
        v_cod_articol := NVL(p_cod_articol, seq_articole_vestimentare.NEXTVAL);

        INSERT INTO articole_vestimentare (cod_articol, pret, marime, firma, tip, stoc)
        VALUES (v_cod_articol, p_pret, p_marime, p_firma, p_tip, p_stoc);
    END adauga_articol;

    PROCEDURE actualizeaza_stoc(
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE,
        p_stoc_nou    IN articole_vestimentare.stoc%TYPE
    ) IS
    BEGIN
        UPDATE articole_vestimentare
        SET stoc = p_stoc_nou
        WHERE cod_articol = p_cod_articol;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20104, 'Articolul cu codul ' || p_cod_articol || ' nu exista.');
        END IF;
    END actualizeaza_stoc;

    PROCEDURE sterge_articol(
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE
    ) IS
        v_referinte NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_referinte
        FROM comanda_articole
        WHERE cod_articol = p_cod_articol;

        IF v_referinte > 0 THEN
            RAISE_APPLICATION_ERROR(-20105, 'Articolul exista pe comenzi si nu poate fi sters direct.');
        END IF;

        DELETE FROM clienti_ar_ve_fk
        WHERE ar_ve_cod_articol = p_cod_articol;

        DELETE FROM articole_vestimentare
        WHERE cod_articol = p_cod_articol;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20104, 'Articolul cu codul ' || p_cod_articol || ' nu exista.');
        END IF;
    END sterge_articol;

    PROCEDURE plaseaza_comanda(
        p_cod_client       IN detalii_comanda.cod_client%TYPE,
        p_cod_adresa       IN detalii_comanda.cod_adresa%TYPE,
        p_cod_articol      IN comanda_articole.cod_articol%TYPE,
        p_cantitate        IN comanda_articole.cantitate%TYPE,
        p_modalitate_plata IN detalii_comanda.modalitate_plata%TYPE,
        p_data_plasare     IN detalii_comanda.data_plasare%TYPE,
        p_data_ridicare    IN detalii_curier.data_ridicare%TYPE,
        p_data_predare     IN detalii_curier.data_predare%TYPE,
        p_cod_comanda      OUT detalii_comanda.cod_comanda%TYPE
    ) IS
        v_cod_comanda detalii_comanda.cod_comanda%TYPE;
        v_stoc        articole_vestimentare.stoc%TYPE;
        v_pret        articole_vestimentare.pret%TYPE;
    BEGIN
        SAVEPOINT sp_plaseaza_comanda;

        verifica_client(p_cod_client);
        verifica_cont(p_cod_client);
        verifica_adresa(p_cod_adresa);

        IF p_data_ridicare < p_data_plasare OR p_data_predare < p_data_ridicare THEN
            RAISE e_date_invalide;
        END IF;

        SELECT stoc, pret
        INTO v_stoc, v_pret
        FROM articole_vestimentare
        WHERE cod_articol = p_cod_articol
        FOR UPDATE;

        IF v_stoc < p_cantitate THEN
            RAISE e_stoc_insuficient;
        END IF;

        v_cod_comanda := seq_detalii_comanda.NEXTVAL;

        INSERT INTO detalii_comanda (
            cod_comanda,
            data_plasare,
            modalitate_plata,
            status_comanda,
            cod_client,
            cod_adresa
        )
        VALUES (
            v_cod_comanda,
            p_data_plasare,
            p_modalitate_plata,
            'plasata',
            p_cod_client,
            p_cod_adresa
        );

        INSERT INTO comanda_articole (
            cod_client,
            cod_comanda,
            cod_articol,
            cantitate,
            pret_unitar
        )
        VALUES (
            p_cod_client,
            v_cod_comanda,
            p_cod_articol,
            p_cantitate,
            v_pret
        );

        MERGE INTO clienti_ar_ve_fk dst
        USING (
            SELECT p_cod_client AS clienti_cod_client,
                   p_cod_articol AS ar_ve_cod_articol
            FROM dual
        ) src
        ON (
            dst.clienti_cod_client = src.clienti_cod_client
            AND dst.ar_ve_cod_articol = src.ar_ve_cod_articol
        )
        WHEN NOT MATCHED THEN
            INSERT (clienti_cod_client, ar_ve_cod_articol)
            VALUES (src.clienti_cod_client, src.ar_ve_cod_articol);

        INSERT INTO detalii_curier (
            cod_curier,
            data_ridicare,
            data_predare,
            cod_client,
            cod_comanda
        )
        VALUES (
            NULL,
            p_data_ridicare,
            p_data_predare,
            p_cod_client,
            v_cod_comanda
        );

        p_cod_comanda := v_cod_comanda;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK TO sp_plaseaza_comanda;
            RAISE_APPLICATION_ERROR(-20106, 'Articolul cu codul ' || p_cod_articol || ' nu exista.');
        WHEN e_stoc_insuficient THEN
            ROLLBACK TO sp_plaseaza_comanda;
            RAISE_APPLICATION_ERROR(-20107, 'Stoc insuficient pentru articolul ' || p_cod_articol || '.');
        WHEN e_date_invalide THEN
            ROLLBACK TO sp_plaseaza_comanda;
            RAISE_APPLICATION_ERROR(-20108, 'Datele comenzii nu respecta ordinea plasare-ridicare-predare.');
        WHEN OTHERS THEN
            ROLLBACK TO sp_plaseaza_comanda;
            RAISE;
    END plaseaza_comanda;

    PROCEDURE anuleaza_comanda(
        p_cod_client  IN detalii_comanda.cod_client%TYPE,
        p_cod_comanda IN detalii_comanda.cod_comanda%TYPE
    ) IS
    BEGIN
        SAVEPOINT sp_anuleaza_comanda;

        UPDATE detalii_comanda
        SET status_comanda = 'anulata'
        WHERE cod_client = p_cod_client
          AND cod_comanda = p_cod_comanda;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20109, 'Comanda nu exista.');
        END IF;

        DELETE FROM detalii_curier
        WHERE cod_client = p_cod_client
          AND cod_comanda = p_cod_comanda;

        DELETE FROM comanda_articole
        WHERE cod_client = p_cod_client
          AND cod_comanda = p_cod_comanda;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO sp_anuleaza_comanda;
            RAISE;
    END anuleaza_comanda;

    FUNCTION total_client(
        p_cod_client IN clienti.cod_client%TYPE
    ) RETURN NUMBER IS
        v_total NUMBER(12, 2);
    BEGIN
        verifica_client(p_cod_client);

        SELECT NVL(SUM(ca.cantitate * ca.pret_unitar), 0)
        INTO v_total
        FROM detalii_comanda dc
        JOIN comanda_articole ca
          ON ca.cod_client = dc.cod_client
         AND ca.cod_comanda = dc.cod_comanda
        WHERE dc.cod_client = p_cod_client
          AND dc.status_comanda <> 'anulata';

        RETURN v_total;
    END total_client;

    FUNCTION stoc_articol(
        p_cod_articol IN articole_vestimentare.cod_articol%TYPE
    ) RETURN NUMBER IS
        v_stoc articole_vestimentare.stoc%TYPE;
    BEGIN
        SELECT stoc
        INTO v_stoc
        FROM articole_vestimentare
        WHERE cod_articol = p_cod_articol;

        RETURN v_stoc;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20104, 'Articolul cu codul ' || p_cod_articol || ' nu exista.');
    END stoc_articol;

    PROCEDURE afiseaza_comenzi_client(
        p_cod_client IN clienti.cod_client%TYPE
    ) IS
        CURSOR c_comenzi IS
            SELECT dc.cod_comanda,
                   dc.data_plasare,
                   dc.modalitate_plata,
                   dc.status_comanda,
                   NVL(SUM(ca.cantitate * ca.pret_unitar), 0) AS total
            FROM detalii_comanda dc
            LEFT JOIN comanda_articole ca
              ON ca.cod_client = dc.cod_client
             AND ca.cod_comanda = dc.cod_comanda
            WHERE dc.cod_client = p_cod_client
            GROUP BY dc.cod_comanda,
                     dc.data_plasare,
                     dc.modalitate_plata,
                     dc.status_comanda
            ORDER BY dc.cod_comanda;
    BEGIN
        verifica_client(p_cod_client);
        DBMS_OUTPUT.PUT_LINE('Comenzi pentru clientul ' || p_cod_client || ':');

        FOR r IN c_comenzi LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Comanda ' || r.cod_comanda ||
                ' | data=' || TO_CHAR(r.data_plasare, 'YYYY-MM-DD HH24:MI') ||
                ' | plata=' || r.modalitate_plata ||
                ' | status=' || r.status_comanda ||
                ' | total=' || TO_CHAR(r.total, '9999990.00')
            );
        END LOOP;
    END afiseaza_comenzi_client;

    PROCEDURE raport_stoc IS
        CURSOR c_stoc IS
            SELECT cod_articol, firma, tip, marime, stoc
            FROM articole_vestimentare
            ORDER BY stoc ASC, cod_articol ASC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Raport stoc articole:');

        FOR r IN c_stoc LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Articol ' || r.cod_articol ||
                ' | ' || r.firma || ' ' || r.tip ||
                ' | marime=' || r.marime ||
                ' | stoc=' || r.stoc
            );
        END LOOP;
    END raport_stoc;
END pkg_magazin_online;
/

SHOW ERRORS PACKAGE pkg_magazin_online;
SHOW ERRORS PACKAGE BODY pkg_magazin_online;

CREATE OR REPLACE FUNCTION fn_total_client(
    p_cod_client IN clienti.cod_client%TYPE
) RETURN NUMBER IS
BEGIN
    RETURN pkg_magazin_online.total_client(p_cod_client);
END;
/

CREATE OR REPLACE PROCEDURE pr_afiseaza_comenzi_client(
    p_cod_client IN clienti.cod_client%TYPE
) IS
BEGIN
    pkg_magazin_online.afiseaza_comenzi_client(p_cod_client);
END;
/

SHOW ERRORS FUNCTION fn_total_client;
SHOW ERRORS PROCEDURE pr_afiseaza_comenzi_client;

PROMPT Pachetul, procedura si functia standalone au fost create.

PROMPT ============================================================
PROMPT Rulare sectiune: 04_testare.sql
PROMPT ============================================================
SET SERVEROUTPUT ON;
SET DEFINE OFF;

PROMPT ================= TESTE PROIECT PBD =================

BEGIN
    DBMS_OUTPUT.PUT_LINE('1. Vizualizare initiala prin cursor din pachet');
    pkg_magazin_online.raport_stoc;
    pr_afiseaza_comenzi_client(1);
    DBMS_OUTPUT.PUT_LINE('Total client 1 = ' || fn_total_client(1));
END;
/

PROMPT -------- CRUD prin pachet: introducere, actualizare, stergere --------

DECLARE
    v_cod_adresa adresa.cod_adresa%TYPE;
BEGIN
    SAVEPOINT sp_crud;

    pkg_magazin_online.adauga_adresa(
        p_strada     => 'Strada Testarii 1',
        p_oras       => 'Bucuresti',
        p_judet      => 'Bucuresti',
        p_zip_code   => 101010,
        p_cod_adresa => v_cod_adresa
    );

    pkg_magazin_online.adauga_client(
        p_nume          => 'Client',
        p_prenume       => 'Test',
        p_email         => 'client.test@test.ro',
        p_parola        => 'parolaTest',
        p_numar_telefon => '0700000050',
        p_cod_client    => 50
    );

    pkg_magazin_online.actualizeaza_client(
        p_cod_client => 50,
        p_nume       => 'ClientActualizat',
        p_prenume    => 'Test'
    );

    pkg_magazin_online.adauga_articol(
        p_pret        => 75,
        p_marime      => 'M',
        p_firma       => 'TestBrand',
        p_tip         => 'tricou',
        p_stoc        => 3,
        p_cod_articol => 50
    );

    pkg_magazin_online.actualizeaza_stoc(50, 4);
    pkg_magazin_online.sterge_articol(50);
    pkg_magazin_online.sterge_client(50);

    DELETE FROM adresa
    WHERE cod_adresa = v_cod_adresa;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('CRUD pachet: OK');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_crud;
        DBMS_OUTPUT.PUT_LINE('CRUD pachet: eroare - ' || SQLERRM);
        RAISE;
END;
/

PROMPT -------- Tranzactie cu rollback: stocul scade si revine --------

DECLARE
    v_cod_comanda  detalii_comanda.cod_comanda%TYPE;
    v_stoc_initial NUMBER;
    v_stoc_dupa    NUMBER;
BEGIN
    v_stoc_initial := pkg_magazin_online.stoc_articol(1);
    SAVEPOINT sp_tranzactie_rollback;

    pkg_magazin_online.plaseaza_comanda(
        p_cod_client       => 1,
        p_cod_adresa       => 1,
        p_cod_articol      => 1,
        p_cantitate        => 2,
        p_modalitate_plata => 'card',
        p_data_plasare     => SYSDATE,
        p_data_ridicare    => SYSDATE + 1,
        p_data_predare     => SYSDATE + 3,
        p_cod_comanda      => v_cod_comanda
    );

    v_stoc_dupa := pkg_magazin_online.stoc_articol(1);
    DBMS_OUTPUT.PUT_LINE('Comanda temporara: ' || v_cod_comanda);
    DBMS_OUTPUT.PUT_LINE('Stoc initial=' || v_stoc_initial || ', dupa comanda=' || v_stoc_dupa);

    ROLLBACK TO sp_tranzactie_rollback;
    DBMS_OUTPUT.PUT_LINE('Dupa ROLLBACK stoc=' || pkg_magazin_online.stoc_articol(1));
END;
/

PROMPT -------- Tranzactie cu commit si anulare: resursa partajata este stocul --------

DECLARE
    v_cod_comanda detalii_comanda.cod_comanda%TYPE;
BEGIN
    pkg_magazin_online.plaseaza_comanda(
        p_cod_client       => 2,
        p_cod_adresa       => 2,
        p_cod_articol      => 2,
        p_cantitate        => 1,
        p_modalitate_plata => 'numerar',
        p_data_plasare     => SYSDATE,
        p_data_ridicare    => SYSDATE + 1,
        p_data_predare     => SYSDATE + 2,
        p_cod_comanda      => v_cod_comanda
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Comanda confirmata: ' || v_cod_comanda);
    DBMS_OUTPUT.PUT_LINE('Stoc articol 2 dupa COMMIT=' || pkg_magazin_online.stoc_articol(2));

    pkg_magazin_online.anuleaza_comanda(2, v_cod_comanda);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Comanda anulata; stoc articol 2 dupa anulare=' || pkg_magazin_online.stoc_articol(2));
END;
/

PROMPT -------- Teste negative controlate: exceptii, constrangeri si triggere --------

DECLARE
    v_cod_comanda detalii_comanda.cod_comanda%TYPE;
BEGIN
    SAVEPOINT sp_stoc_insuficient;

    pkg_magazin_online.plaseaza_comanda(
        p_cod_client       => 1,
        p_cod_adresa       => 1,
        p_cod_articol      => 1,
        p_cantitate        => 999,
        p_modalitate_plata => 'card',
        p_data_plasare     => SYSDATE,
        p_data_ridicare    => SYSDATE + 1,
        p_data_predare     => SYSDATE + 2,
        p_cod_comanda      => v_cod_comanda
    );
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_stoc_insuficient;
        DBMS_OUTPUT.PUT_LINE('OK stoc insuficient: ' || SQLERRM);
END;
/

DECLARE
    v_cod_comanda detalii_comanda.cod_comanda%TYPE;
BEGIN
    SAVEPOINT sp_date_invalide;

    pkg_magazin_online.plaseaza_comanda(
        p_cod_client       => 1,
        p_cod_adresa       => 1,
        p_cod_articol      => 1,
        p_cantitate        => 1,
        p_modalitate_plata => 'card',
        p_data_plasare     => SYSDATE + 2,
        p_data_ridicare    => SYSDATE + 1,
        p_data_predare     => SYSDATE + 3,
        p_cod_comanda      => v_cod_comanda
    );
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_date_invalide;
        DBMS_OUTPUT.PUT_LINE('OK date invalide: ' || SQLERRM);
END;
/

BEGIN
    SAVEPOINT sp_email_invalid;

    INSERT INTO conturi (email, parola, numar_telefon, cod_client)
    VALUES ('email-invalid', 'parola123', '0700000099', 1);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_email_invalid;
        DBMS_OUTPUT.PUT_LINE('OK email invalid: ' || SQLERRM);
END;
/

BEGIN
    SAVEPOINT sp_fara_cont;

    INSERT INTO clienti (cod_client, nume, prenume)
    VALUES (77, 'Fara', 'Cont');

    INSERT INTO detalii_comanda (
        cod_comanda,
        data_plasare,
        modalitate_plata,
        status_comanda,
        cod_client,
        cod_adresa
    )
    VALUES (777, SYSDATE, 'card', 'plasata', 77, 1);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_fara_cont;
        DBMS_OUTPUT.PUT_LINE('OK trigger cont lipsa: ' || SQLERRM);
END;
/

BEGIN
    SAVEPOINT sp_curier_invalid;

    INSERT INTO detalii_comanda (
        cod_comanda,
        data_plasare,
        modalitate_plata,
        status_comanda,
        cod_client,
        cod_adresa
    )
    VALUES (778, SYSDATE + 5, 'card', 'plasata', 1, 1);

    INSERT INTO detalii_curier (
        cod_curier,
        data_ridicare,
        data_predare,
        cod_client,
        cod_comanda
    )
    VALUES (778, SYSDATE + 4, SYSDATE + 6, 1, 778);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_curier_invalid;
        DBMS_OUTPUT.PUT_LINE('OK trigger date curier: ' || SQLERRM);
END;
/

PROMPT -------- Interogari finale pentru verificare --------

SELECT * FROM clienti ORDER BY cod_client;
SELECT * FROM conturi ORDER BY cod_client;
SELECT * FROM adresa ORDER BY cod_adresa;
SELECT * FROM articole_vestimentare ORDER BY cod_articol;
SELECT * FROM detalii_comanda ORDER BY cod_client, cod_comanda;
SELECT * FROM comanda_articole ORDER BY cod_client, cod_comanda, cod_articol;
SELECT * FROM detalii_curier ORDER BY cod_client, cod_comanda;

PROMPT Testare finalizata.
