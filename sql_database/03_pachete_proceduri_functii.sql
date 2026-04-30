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
