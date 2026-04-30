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
