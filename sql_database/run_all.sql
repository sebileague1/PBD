SET DEFINE OFF;
SET SERVEROUTPUT ON;

PROMPT 1/5 Resetare obiecte existente
@@00_drop_objects.sql

PROMPT 2/5 Creare schema
@@01_schema.sql

PROMPT 3/5 Inserare date de test
@@02_insert_data.sql

PROMPT 4/5 Creare pachet, proceduri si functii
@@03_pachete_proceduri_functii.sql

PROMPT 5/5 Rulare teste
@@04_testare.sql

PROMPT Proiect rulat complet.
