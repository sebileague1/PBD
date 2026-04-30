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
