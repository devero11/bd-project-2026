
-- OPERATIA 1 – UPDATE
-- Marcheaza ca Restant toate creditele care au cel putin
--  o rata neachitata cu scadenta depasita

UPDATE credit
SET stare_credit = 'Restant'
WHERE credit_id IN (
    SELECT DISTINCT credit_id
    FROM   grafic_rambursare
    WHERE  status_plata  = 'Neachitat'
      AND  data_scadenta < SYSDATE
);


-- OPERATIA 2 – UPDATE
-- Actualizeaza sold_curent al fiecarui credit
--  scazand totalul platilor deja inregistrate

UPDATE credit cr
SET sold_curent = cr.sold_curent - (
    SELECT NVL(SUM(p.suma_platita), 0)
    FROM   plata p
    WHERE  p.credit_id = cr.credit_id
)
WHERE EXISTS (
    SELECT 1
    FROM   plata p2
    WHERE  p2.credit_id = cr.credit_id
);


-- OPERATIA 3 – DELETE
-- Sterge cererile respinse ale clientilor care nu au
--  nicio alta cerere aprobata sau in analiza

DELETE FROM cerere_credit
WHERE status_cerere = 'Respinsa'
  AND client_id NOT IN (
      SELECT DISTINCT client_id
      FROM   cerere_credit
      WHERE  status_cerere IN ('Aprobata', 'In analiza')
  );


