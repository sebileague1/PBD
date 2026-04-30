

-------------------------- VIZUALIZARE ----------------------------------

SELECT * FROM ADRESA;
SELECT * FROM CLIENTI;
SELECT * FROM CONTURI;
SELECT * FROM ARTICOLE_VESTIMENTARE; 
SELECT * FROM DETALII_COMANDA;
SELECT * FROM DETALII_CURIER;
SELECT * FROM CLIENTI_AR_VE_FK;


-- afiseaza numele, prenumele clientilor impreuna cu email-ul si numarul de telefon
SELECT 
    c.cod_client AS "Cod Client", 
    c.nume AS "Nume", 
    c.prenume AS "Prenume", 
    cont.email AS "Email", 
    cont.numar_telefon AS "Numar Telefon"
FROM 
    clienti c
JOIN 
    conturi cont ON c.cod_client = cont.cod_client;


-- afiseaza comenzile clientilor cu detalii de livrare
SELECT 
    c.cod_client AS "Cod Client", 
    c.nume || ' ' || c.prenume AS "Nume Client",
    dc.cod_comanda AS "Cod Comanda", 
    dc.data_plasare AS "Data Plasare", 
    dc.modalitate_plata AS "Modalitate Plata",
    dcur.data_ridicare AS "Data Ridicare",
    dcur.data_predare AS "Data Predare"
FROM 
    clienti c
JOIN 
    detalii_comanda dc ON c.cod_client = dc.cod_client
LEFT JOIN 
    detalii_curier dcur ON dc.cod_client = dcur.cod_client AND dc.cod_comanda = dcur.cod_comanda;


-- afiseaza articolele vestimentare si clientii care le au achizitionat
SELECT 
    av.cod_articol AS "Cod Articol", 
    av.firma AS "Firma", 
    av.tip AS "Tip",
    av.marime AS "Marime", 
    av.pret AS "Pret",
    c.cod_client AS "Cod Client",
    c.nume || ' ' || c.prenume AS "Nume Client"
FROM
    articole_vestimentare av
JOIN 
    clienti_ar_ve_fk cavf ON av.cod_articol = cavf.ar_ve_cod_articol
JOIN 
    clienti c ON cavf.clienti_cod_client = c.cod_client;


