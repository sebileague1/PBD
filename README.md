# PBD - Magazin online cu articole vestimentare

Student: Danalache Emanuel, Danalache Sebastian
Grupa: 1411A

## Descriere

Proiectul modeleaza si implementeaza baza de date pentru un magazin online cu articole vestimentare. Aplicatia gestioneaza clienti, conturi, adrese de livrare, articole, comenzi, linii de comanda si detalii de curier.

Resursa partajata folosita pentru tranzactii este stocul articolelor vestimentare. Cand se plaseaza o comanda, stocul produsului este blocat si scazut atomic; daca tranzactia primeste rollback, stocul revine automat.

## Contributii studenti

- Danalache Emanuel: modelarea bazei de date in Oracle SQL Developer Data Modeler, definirea tabelelor, cheilor primare, cheilor externe si constrangerilor functionale.
- Danalache Sebastian: dezvoltarea logicii stocate PL/SQL: pachetul `pkg_magazin_online`, procedura standalone `pr_afiseaza_comenzi_client`, functia standalone `fn_total_client`, triggerele de validare si scriptul de testare cu tranzactii.
- Contributie comuna: popularea datelor de test, verificarea scenariilor pozitive/negative si rularea finala a proiectului in SQL Developer.

## Continut proiect

| Fisier | Rol |
| --- | --- |
| `sql_database/sql_database.dmd` | Proiect Oracle SQL Developer Data Modeler |
| `sql_database/Logical.png` | Diagrama logica |
| `sql_database/Relational_1.png` | Diagrama relationala |
| `sql_database/Logical_nou.pdf` | Diagrama logica exportata dupa modificarile finale |
| `sql_database/Relational_1_nou.pdf` | Diagrama relationala exportata dupa modificarile finale |
| `sql_database/00_drop_objects.sql` | Resetare obiecte pentru rulari repetate |
| `sql_database/01_schema.sql` | Script DDL: tabele, chei, constrangeri, secvente si triggere |
| `sql_database/02_insert_data.sql` | Date de test coerente |
| `sql_database/03_pachete_proceduri_functii.sql` | Pachet PL/SQL, procedura standalone si functie standalone |
| `sql_database/04_testare.sql` | Teste cu blocuri anonime, exceptii si tranzactii |
| `sql_database/run_all.sql` | Ruleaza proiectul complet in ordinea corecta |
| `sql_database/script_complet_proiect.sql` | Script complet intr-un singur fisier: resetare, schema, date, logica stocata si teste |

## Ordine recomandata de rulare

In Oracle SQL Developer, deschide folderul `sql_database`, apoi ruleaza:

```sql
@run_all.sql
```

Daca vrei sa rulezi manual, ordinea este:

```sql
@00_drop_objects.sql
@01_schema.sql
@02_insert_data.sql
@03_pachete_proceduri_functii.sql
@04_testare.sql
```

Pentru predare exista si varianta intr-un singur fisier:

```sql
@script_complet_proiect.sql
```

Activeaza `DBMS Output`, deoarece scriptul de testare afiseaza rezultatele procedurilor si tranzactiilor.

## Cerinte acoperite

- Modelare in Data Modeler: model logic, model relational, imagini exportate.
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

## Reguli functionale importante

- Nu se poate plasa o comanda pentru un client fara cont.
- Fiecare comanda are adresa de livrare.
- Modalitatea de plata este doar `numerar` sau `card`.
- Datele calendaristice pot fi in trecut sau in viitor, dar trebuie sa respecte ordinea logica: plasare <= ridicare <= predare.
- Stocul nu poate deveni negativ.
- Emailul, parola si numarul de telefon sunt validate prin constrangeri.

## Observatie pentru predare

Arhiva finala trebuie sa contina intregul folder al proiectului, inclusiv modelul `.dmd`, diagramele exportate si scripturile SQL.
