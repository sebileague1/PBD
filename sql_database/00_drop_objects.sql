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
