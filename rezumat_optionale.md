# REZUMAT CERINTE OPTIONALE

PDF-ul proiectului este convertit din markdown si are probleme de formatare. Poate fi citit originalul pe repo-ul intregului proiect la https://github.com/devero11/bd-project-2026/tree/main

14. Am creat un view numit `v_performanta_sucursale` care aduna date din mai multe tabele (`sucursale`, `angajati`, `cereri`, `contracte` si `credite active`) ca sa arate performanta fiecarei sucursale. Ca operatie permisa, am facut o filtrare simpla pe acest view. Ca operatie nepermisa, am aratat ca nu putem sterge date direct din view, deoarece contine functii de agregare si bazei de date ii este imposibil sa stie ce rand exact din tabelele reale sa stearga

15. Am realizat interogarile cerute:  Un Outer Join pe 4 tabele ca sa afisez toti clientii si creditele lor, chiar si pe cei care nu au inca un credit aprobat.  Un Top-N pentru a gasi primii 3 evaluatori imobiliari in functie de valoarea rapoartelor facute.  O cerere de tip Division ca sa selectez creditele care au fost platite prin absolut toate metodele de plata disponibile.  

17.b  Am adaugat coloana `valoare_totala_proprietati` direct in tabelul `CREDIT` si am facut un script de UPDATE. Astfel, aplicatia nu mai trebuie sa faca join-uri intre 4 tabele de fiecare data cand vrea sa vada valoarea totala a garantiilor unui credit.  

18. Am dat un exemplu cu doua tranzactii care se bat pe acelasi credit: un angajat care citeste soldul si un client care face o plata in acelasi timp. Am explicat diferentele dintre Read Committed (unde angajatul vede schimbarile clientului daca acesta da COMMIT, deci apare problema de non-repeatable read) si Serializable (unde angajatul vede doar o "poza" a bazei de date de cand a inceput el tranzactia, fiind complet izolat de schimbarile clientului).
