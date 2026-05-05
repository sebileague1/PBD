SET SERVEROUTPUT ON;

SELECT * FROM adresa ORDER BY cod_adresa;
SELECT * FROM clienti ORDER BY cod_client;
SELECT * FROM conturi ORDER BY cod_client;
SELECT * FROM articole_vestimentare ORDER BY cod_articol;
SELECT * FROM detalii_comanda ORDER BY cod_client, cod_comanda;
SELECT * FROM comanda_articole ORDER BY cod_client, cod_comanda, cod_articol;
SELECT * FROM detalii_curier ORDER BY cod_client, cod_comanda;
SELECT * FROM clienti_ar_ve_fk ORDER BY clienti_cod_client, ar_ve_cod_articol;

SELECT
    c.cod_client AS cod_client,
    c.nume || ' ' || c.prenume AS nume_client,
    co.email AS email,
    co.numar_telefon AS numar_telefon
FROM clienti c
JOIN conturi co
  ON co.cod_client = c.cod_client
ORDER BY c.cod_client;

SELECT
    dc.cod_comanda,
    dc.cod_client,
    c.nume || ' ' || c.prenume AS nume_client,
    a.oras || ', ' || a.strada AS adresa_livrare,
    dc.data_plasare,
    dcu.data_ridicare,
    dcu.data_predare,
    dc.modalitate_plata,
    dc.status_comanda,
    SUM(ca.cantitate * ca.pret_unitar) AS total_comanda
FROM detalii_comanda dc
JOIN clienti c
  ON c.cod_client = dc.cod_client
JOIN adresa a
  ON a.cod_adresa = dc.cod_adresa
LEFT JOIN detalii_curier dcu
  ON dcu.cod_client = dc.cod_client
 AND dcu.cod_comanda = dc.cod_comanda
LEFT JOIN comanda_articole ca
  ON ca.cod_client = dc.cod_client
 AND ca.cod_comanda = dc.cod_comanda
GROUP BY
    dc.cod_comanda,
    dc.cod_client,
    c.nume,
    c.prenume,
    a.oras,
    a.strada,
    dc.data_plasare,
    dcu.data_ridicare,
    dcu.data_predare,
    dc.modalitate_plata,
    dc.status_comanda
ORDER BY dc.cod_client, dc.cod_comanda;

SELECT
    ca.cod_comanda,
    ca.cod_client,
    av.cod_articol,
    av.firma,
    av.tip,
    av.marime,
    ca.cantitate,
    ca.pret_unitar,
    ca.cantitate * ca.pret_unitar AS valoare_linie,
    av.stoc AS stoc_ramas
FROM comanda_articole ca
JOIN articole_vestimentare av
  ON av.cod_articol = ca.cod_articol
ORDER BY ca.cod_client, ca.cod_comanda, av.cod_articol;

BEGIN
    pkg_magazin_online.raport_stoc;
END;
/
