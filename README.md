# SQL-Database-Schema-Design-Implementation 🗄️💾

[![Limbaj](https://img.shields.io/badge/Limbaj-SQL-informational)](https://en.wikipedia.org/wiki/SQL)
[![Modelare](https://img.shields.io/badge/Modelare-Relational%20%7C%20Logical-yellow)]()
[![Fișiere](https://img.shields.io/badge/Fi%C8%99iere-DDL%20%7C%20DML%20%7C%20Diagrams-lightgrey)]()

## 📝 Descriere Generală

Acest repository conține toate etapele de dezvoltare a unei baze de date relaționale, de la concepție (modelare logică) până la implementarea fizică (DDL) și operațiunile de bază (DML - inserare, interogare).

Proiectul este conceput pentru a demonstra cunoștințe în designul de baze de date, normalizare și manipularea datelor prin interogări SQL complexe.

### Conținutul Proiectului

* **Modelare:** Diagramele care ilustrează structura logică și relațională (ERD) a bazei de date.
* **Schema (DDL):** Scriptul SQL principal pentru crearea tabelelor și definirea tuturor constrângerilor (chei primare, chei străine, unicitate etc.).
* **Populare (DML):** Scripturi pentru inserarea datelor inițiale necesare funcționării sistemului.
* **Operațiuni Avansate:** Scripturi SQL demonstrative pentru validarea structurii și extragerea de informații complexe.

## 🏗️ Structura Bazei de Date (Diagrama Relațională)

Structura bazei de date este vizualizată prin diagrama relațională, care prezintă entitățile (tabelele) și relațiile dintre ele.



**Notă:** Diagramele detaliate (Logic și Relațional) se află în folderul `sql_database/`.

## ⚙️ Configurarea Bazei de Date

Pentru a implementa și a testa schema bazei de date, urmați pașii de mai jos. Fișierele SQL sunt scrise în dialect standard și ar trebui să fie compatibile cu majoritatea sistemelor de gestiune a bazelor de date (SGBD) populare (ex: Oracle, MySQL, PostgreSQL, SQL Server).

### 1. Precondiții

* Un **Sistem de Gestiune a Bazelor de Date (SGBD)** instalat (de exemplu, Oracle, MySQL, PostgreSQL).
* Un **client SQL** (de exemplu, SQL Developer, DBeaver, psql, MySQL Workbench).

### 2. Crearea Schemei și a Tabelelor

Creați structura completă a bazei de date (tabele, coloane, constrângeri) rulând scriptul DDL.

1.  Deschideți clientul SQL și conectați-vă la baza de date țintă.
2.  Încărcați și executați scriptul:
    ```sql
    sql_database/sql_database(generated code).sql
    ```
    Acest script conține comenzile `CREATE TABLE` și `ALTER TABLE` necesare.

### 3. Popularea Bazei de Date

Introduceți datele inițiale în tabelele nou create.

1.  Executați scriptul de inserare a datelor:
    ```sql
    sql_database/insert_data_into_tables.sql
    ```
    Acest script conține o serie de comenzi `INSERT INTO`.

## 📊 Scripturi de Interogare și Operațiuni

Proiectul include scripturi DML avansate pentru testarea și extragerea informațiilor din baza de date.

| Fișier | Tip | Descriere |
| :--- | :--- | :--- |
| `sql_database/validare.sql` | DML (Interogări) | Conține interogări complexe pentru validarea integrității datelor sau pentru verificări specifice pe schema de bază. |
| `sql_database/vizualizare.sql` | DML (Interogări) | Conține comenzi SQL, posibil vizualizări (`VIEW`) sau interogări cu `JOIN`-uri multiple, destinate extragerii de rapoarte sau date pentru afișare. |

Pentru a le rula, executați scriptul dorit direct în clientul SQL după ce baza de date a fost populată.
