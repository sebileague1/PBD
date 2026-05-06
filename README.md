# PBD - Magazin online cu articole vestimentare

Studenti: Danalache Emanuel, Danalache Sebastian
Grupa: 1411A

## Descriere

Proiectul modeleaza si implementeaza baza de date pentru un magazin online cu articole vestimentare. Aplicatia gestioneaza clienti, conturi, adrese de livrare, articole, comenzi, linii de comanda si detalii de curier.

Resursa partajata folosita pentru tranzactii este stocul articolelor vestimentare. Cand se plaseaza o comanda, stocul produsului este blocat si scazut atomic; daca tranzactia primeste rollback, stocul revine automat.

Stadiu actual: proiectul este actualizat cu tabela `comanda_articole`, coloana `stoc` in `articole_vestimentare`, coloana `status_comanda` in `detalii_comanda`, legatura dintre comenzi si adrese, diagrame finale exportate si script DDL regenerat din Data Modeler fara erori.

## Contributii studenti

- Danalache Emanuel: modelarea bazei de date in Oracle SQL Developer Data Modeler, definirea tabelelor, cheilor primare, cheilor externe si constrangerilor functionale.
- Danalache Sebastian: dezvoltarea logicii stocate PL/SQL: pachetul `pkg_magazin_online`, procedura standalone `pr_afiseaza_comenzi_client`, functia standalone `fn_total_client`, triggerele de validare si scriptul de testare cu tranzactii.
- Contributie comuna: popularea datelor de test, verificarea scenariilor pozitive/negative si rularea finala a proiectului in SQL Developer.

## Continut proiect

| Fisier | Rol |
| --- | --- |
| `sql_database/sql_database.dmd` | Proiect Oracle SQL Developer Data Modeler |
| `sql_database/sql_database/` | Directorul Data Modeler asociat fisierului `.dmd` |
| `sql_database/Logical_final.png` | Diagrama logica finala |
| `sql_database/Relational_1_final.png` | Diagrama relationala finala |
| `sql_database/sql_database_generated_from_model.sql` | Script DDL regenerat din Data Modeler, fara erori de generare |
| `sql_database/00_drop_objects.sql` | Resetare obiecte pentru rulari repetate |
| `sql_database/01_schema.sql` | Script DDL: tabele, chei, constrangeri, secvente si triggere |
| `sql_database/02_insert_data.sql` | Date de test coerente |
| `sql_database/03_pachete_proceduri_functii.sql` | Pachet PL/SQL, procedura standalone si functie standalone |
| `sql_database/04_testare.sql` | Teste cu blocuri anonime, exceptii si tranzactii |
| `sql_database/run_all.sql` | Ruleaza proiectul complet in ordinea corecta |
| `sql_database/vizualizare.sql` | Interogari si rapoarte finale pentru verificarea datelor |
| `sql_database/script_complet_proiect.sql` | Script complet intr-un singur fisier: resetare, schema, date, logica stocata si teste |

Observatie: scriptul `sql_database_generated_from_model.sql` este scriptul obtinut din Data Modeler pentru schema relationala. Scriptul complet de proiect, cu pachete, proceduri, functii, triggere functionale si teste, este format din scripturile `00` - `04`, rulate prin `run_all.sql`.

## Ordine de rulare

In Oracle SQL Developer, deschide folderul `sql_database`, apoi ruleaza:

```sql
@run_all.sql
```

Daca rulezi manual, ordinea este:

```sql
@00_drop_objects.sql
@01_schema.sql
@02_insert_data.sql
@03_pachete_proceduri_functii.sql
@04_testare.sql
```

## Cerinte acoperite

- Modelare in Data Modeler: model logic, model relational, imagini exportate.
- Script DDL regenerat din Data Modeler dupa modificarile finale.
- DDL complet pentru tabele, chei primare, chei externe, constrangeri `CHECK`, `UNIQUE`, secvente si triggere.
- Date de test pentru toate tabelele.
- Pachet PL/SQL `pkg_magazin_online` cu proceduri de inserare, actualizare, stergere, plasare/anulare comanda, raportare si functii de calcul.
- Procedura standalone `pr_afiseaza_comenzi_client`.
- Functie standalone `fn_total_client`.
- Cursori expliciti in pachet pentru raportarea comenzilor si stocurilor.
- Exceptii controlate cu `RAISE_APPLICATION_ERROR`.
- Triggere pentru:
  - generare automata coduri;
  - interzicerea comenzilor fara cont;
  - validarea ordinii datelor plasare-ridicare-predare fara blocare fata de `SYSDATE`;
  - actualizarea automata a statusului comenzii;
  - scaderea si refacerea stocului la inserarea, actualizarea sau stergerea liniilor de comanda.
- Script de testare cu tranzactie clara: comanda scade stocul, `ROLLBACK` reface stocul, iar `COMMIT` confirma schimbarea.

## Elemente adaugate fata de modelul initial

- `stoc` in tabela `articole_vestimentare`, folosit ca resursa partajata.
- `status_comanda` in tabela `detalii_comanda`, pentru starea comenzii.
- `cod_adresa` / `adresa_cod_adresa` in `detalii_comanda`, pentru adresa de livrare.
- Tabela `comanda_articole`, pentru liniile unei comenzi: articol, cantitate si pret unitar.
- Relatiile `adresa -> detalii_comanda`, `detalii_comanda -> comanda_articole` si `articole_vestimentare -> comanda_articole`.
- Triggere pentru scaderea/refacerea stocului si pentru validarile functionale.
- Teste pentru rollback, commit, anulare comanda si erori controlate.

## Reguli functionale importante

- Nu se poate plasa o comanda pentru un client fara cont.
- Fiecare comanda are adresa de livrare.
- Modalitatea de plata este doar `numerar` sau `card`.
- Statusul comenzii este doar `plasata`, `preluata`, `livrata` sau `anulata`.
- Datele calendaristice pot fi in trecut sau in viitor, dar trebuie sa respecte ordinea logica: plasare <= ridicare <= predare.
- Stocul nu poate deveni negativ.
- Emailul, parola si numarul de telefon sunt validate prin constrangeri.
<<<<<<< HEAD

## Rezultate testare finala

Scriptul `run_all.sql` verifica urmatoarele scenarii:

- resetarea obiectelor existente si recrearea schemei;
- inserarea datelor de test;
- compilarea pachetului `pkg_magazin_online`, a procedurii `pr_afiseaza_comenzi_client` si a functiei `fn_total_client`;
- vizualizarea stocului prin cursor din pachet;
- operatii CRUD prin pachet;
- tranzactie cu `ROLLBACK`, unde stocul scade temporar si revine la valoarea initiala;
- tranzactie cu `COMMIT`, unde stocul ramane modificat;
- anularea comenzii, cu refacerea stocului;
- teste negative pentru stoc insuficient, date invalide, email invalid, comanda fara cont si date de curier invalide.
