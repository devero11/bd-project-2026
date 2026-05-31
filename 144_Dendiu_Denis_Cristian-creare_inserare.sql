CREATE SEQUENCE seq_sucursala      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_client         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_tip_credit     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_proprietate    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_angajat        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_evaluator      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_cerere_credit  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_contract       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_credit         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_garantii       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_rapoarte       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_plata          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_grafic         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE client (
    client_id         NUMBER(13),
    tip_client        VARCHAR2(2) DEFAULT 'PF',
    nume_denumire     VARCHAR2(100) NOT NULL,
    cod_identificare  VARCHAR2(13) NOT NULL,
    adresa            VARCHAR2(200) NOT NULL,
    email             VARCHAR2(50),
    telefon           VARCHAR2(15) NOT NULL,
    venit_declarat    NUMBER(12,2),
    cont_iban         VARCHAR2(24) NOT NULL,
    data_inregistrare DATE DEFAULT SYSDATE NOT NULL,
    
    -- Constraints
    CONSTRAINT pk_client PRIMARY KEY (client_id),
    CONSTRAINT chk_tip_client CHECK (tip_client IN ('PF', 'PJ')),
    CONSTRAINT chk_venit_declarat CHECK (venit_declarat > 0),
    CONSTRAINT uq_cod_identificare UNIQUE (cod_identificare),
    CONSTRAINT uq_email UNIQUE (email),
    CONSTRAINT uq_cont_iban UNIQUE (cont_iban)
);

CREATE TABLE tip_credit (
    tip_id             NUMBER(5),
    nume_produs        VARCHAR2(50) NOT NULL,
    dobanda_referinta  NUMBER(4,2),
    perioada_max_luni  NUMBER(3) DEFAULT 360,
    comision_analiza   NUMBER(8,2) DEFAULT 0,
    moneda             VARCHAR2(3) DEFAULT 'RON',

    -- Constraints
    CONSTRAINT pk_tip_credit PRIMARY KEY (tip_id),
    CONSTRAINT uq_nume_produs UNIQUE (nume_produs),
    CONSTRAINT chk_dobanda_referinta CHECK (dobanda_referinta > 0),
    CONSTRAINT chk_perioada_max_luni CHECK (perioada_max_luni BETWEEN 6 AND 360),
    CONSTRAINT chk_comision_analiza CHECK (comision_analiza >= 0),
    CONSTRAINT chk_moneda CHECK (moneda IN ('RON', 'EUR', 'USD'))
);


CREATE TABLE proprietate (
    proprietate_id   NUMBER(10),
    nr_cadastral     VARCHAR2(20) NOT NULL,
    adresa           VARCHAR2(200) NOT NULL,
    tip_imobil       VARCHAR2(20),
    suprafata_utila  NUMBER(6,2),

    -- Constraints
    CONSTRAINT pk_proprietate PRIMARY KEY (proprietate_id),
    CONSTRAINT uq_nr_cadastral UNIQUE (nr_cadastral),
    CONSTRAINT chk_tip_imobil CHECK (tip_imobil IN ('Apartament', 'Casa', 'Teren')),
    CONSTRAINT chk_suprafata_utila CHECK (suprafata_utila > 0)
);

CREATE TABLE sucursala (
    sucursala_id   NUMBER(10),
    nume_sucursala VARCHAR2(50) NOT NULL,
    oras           VARCHAR2(50) NOT NULL,
    adresa         VARCHAR2(200),

    -- Constraints
    CONSTRAINT pk_sucursala PRIMARY KEY (sucursala_id),
    CONSTRAINT uq_nume_sucursala UNIQUE (nume_sucursala)
);

CREATE TABLE angajat (
    angajat_id   NUMBER(13),
    nume         VARCHAR2(50) NOT NULL,
    prenume      VARCHAR2(50) NOT NULL,
    cnp          VARCHAR2(13) NOT NULL,
    sucursala_id NUMBER(10) NOT NULL,

    -- Constraints
    CONSTRAINT pk_angajatii PRIMARY KEY (angajat_id),
    CONSTRAINT uq_angajatii_cnp UNIQUE (cnp),
    
    -- Foreign Keys
    CONSTRAINT fk_angajatii_sucursala FOREIGN KEY (sucursala_id) REFERENCES sucursala (sucursala_id)
);

CREATE TABLE cerere_credit (
    cerere_id       NUMBER(13),
    client_id       NUMBER(13) NOT NULL,
    tip_id          NUMBER(5) NOT NULL,
    angajat_id      NUMBER(13) NOT NULL,
    suma_solicitata NUMBER(12,2),
    data_depunere   DATE DEFAULT SYSDATE NOT NULL,
    status_cerere   VARCHAR2(20) DEFAULT 'In analiza',

    -- Constraints
    CONSTRAINT pk_cerere_credit PRIMARY KEY (cerere_id),
    CONSTRAINT chk_suma_solicitata CHECK (suma_solicitata > 0),
    CONSTRAINT chk_status_cerere CHECK (status_cerere IN ('In analiza', 'Aprobata', 'Respinsa')),
    
    -- Foreign Keys
    CONSTRAINT fk_cerere_client FOREIGN KEY (client_id) REFERENCES client (client_id),
    CONSTRAINT fk_cerere_tip FOREIGN KEY (tip_id) REFERENCES tip_credit (tip_id),
    CONSTRAINT fk_cerere_angajat FOREIGN KEY (angajat_id) REFERENCES angajat (angajat_id)
);
CREATE TABLE contract (
    contract_id     NUMBER(13),
    cerere_id       NUMBER(13) NOT NULL,
    nr_contract     VARCHAR2(20) NOT NULL,
    data_semnare    DATE NOT NULL,
    dobanda_finala  NUMBER(4,2),
    clauze_speciale VARCHAR2(1000),

    -- Constraints
    CONSTRAINT pk_contract PRIMARY KEY (contract_id),
    CONSTRAINT uq_nr_contract UNIQUE (nr_contract),
    CONSTRAINT chk_dobanda_finala CHECK (dobanda_finala > 0),

    CONSTRAINT uq_contract_cerere UNIQUE (cerere_id),
    
    -- Foreign Keys
    CONSTRAINT fk_contract_cerere FOREIGN KEY (cerere_id) REFERENCES cerere_credit (cerere_id)
);

CREATE TABLE credit (
    credit_id      NUMBER(13),
    contract_id    NUMBER(13) NOT NULL,
    sold_curent    NUMBER(12,2),
    data_acordare  DATE NOT NULL,
    stare_credit   VARCHAR2(15) DEFAULT 'Activ',

    -- Constraints
    CONSTRAINT pk_credit PRIMARY KEY (credit_id),
    CONSTRAINT chk_sold_curent CHECK (sold_curent >= 0),
    CONSTRAINT chk_stare_credit CHECK (stare_credit IN ('Activ', 'Inchis', 'Restant')),

    CONSTRAINT uq_credit_contract UNIQUE (contract_id),
    
    -- Foreign Keys
    CONSTRAINT fk_credit_contract FOREIGN KEY (contract_id) REFERENCES contract (contract_id)
    
);

CREATE TABLE garantii (
    garantie_id       NUMBER(13),
    credit_id         NUMBER(13) NOT NULL,
    proprietate_id    NUMBER(10) NOT NULL,
    valoare_acoperita NUMBER(12,2) NOT NULL,

    -- Constraints
    CONSTRAINT pk_garantii PRIMARY KEY (garantie_id),
    
    -- Foreign Keys
    CONSTRAINT fk_garantii_credit FOREIGN KEY (credit_id) REFERENCES credit (credit_id),
    CONSTRAINT fk_garantii_proprietate FOREIGN KEY (proprietate_id) REFERENCES proprietate (proprietate_id)
);



CREATE TABLE evaluator (
    evaluator_id   NUMBER(10),
    nume_evaluator VARCHAR2(100) NOT NULL,
    nr_autorizatie VARCHAR2(20) NOT NULL,
    specializare   VARCHAR2(50),

    -- Constraints
    CONSTRAINT pk_evaluator PRIMARY KEY (evaluator_id),
    CONSTRAINT uq_nr_autorizatie UNIQUE (nr_autorizatie)
);

CREATE TABLE rapoarte_evaluare (
    raport_id        NUMBER(13),
    proprietate_id   NUMBER(10) NOT NULL,
    evaluator_id     NUMBER(10) NOT NULL,
    valoare_estimata NUMBER(12,2),
    data_evaluare    DATE DEFAULT SYSDATE NOT NULL,

    -- Constraints
    CONSTRAINT pk_rapoarte_evaluare PRIMARY KEY (raport_id),
    CONSTRAINT chk_valoare_estimata CHECK (valoare_estimata > 0),
    
    -- Foreign Keys
    CONSTRAINT fk_raport_proprietate FOREIGN KEY (proprietate_id) REFERENCES proprietate (proprietate_id),
    CONSTRAINT fk_raport_evaluator FOREIGN KEY (evaluator_id) REFERENCES evaluator (evaluator_id)
);

CREATE TABLE plata (
    plata_id      NUMBER(13),
    credit_id     NUMBER(13) NOT NULL,
    suma_platita  NUMBER(10,2),
    data_plata    DATE DEFAULT SYSDATE NOT NULL,
    metoda_plata  VARCHAR2(20) DEFAULT 'Transfer',

    -- Constraints
    CONSTRAINT pk_plata PRIMARY KEY (plata_id),
    CONSTRAINT chk_suma_platita CHECK (suma_platita > 0),
    CONSTRAINT chk_metoda_plata CHECK (metoda_plata IN ('Transfer', 'Cash', 'Direct Debit')),
    
    -- Foreign Keys
    CONSTRAINT fk_plata_credit FOREIGN KEY (credit_id) REFERENCES credit (credit_id)
);

CREATE TABLE grafic_rambursare (
    rata_id        NUMBER(13),
    credit_id      NUMBER(13) NOT NULL,
    nr_rata        NUMBER(3),
    data_scadenta  DATE NOT NULL,
    valoare_rata   NUMBER(10,2),
    status_plata   VARCHAR2(15) DEFAULT 'Neachitat',

    -- Constraints
    CONSTRAINT pk_grafic_rambursare PRIMARY KEY (rata_id),
    CONSTRAINT chk_nr_rata CHECK (nr_rata >= 1 AND nr_rata <= 360),
    CONSTRAINT chk_valoare_rata CHECK (valoare_rata > 0),
    CONSTRAINT chk_status_plata_grafic CHECK (status_plata IN ('Neachitat', 'Achitat')),
    
    -- Foreign Keys
    CONSTRAINT fk_grafic_credit FOREIGN KEY (credit_id) REFERENCES credit (credit_id)
);

-- 1. SUCURSALA
INSERT INTO sucursala (sucursala_id, nume_sucursala, oras, adresa) VALUES
    (1, 'Sucursala Unirii', 'Bucuresti', 'Piata Unirii nr. 10, Sector 3');
INSERT INTO sucursala (sucursala_id, nume_sucursala, oras, adresa) VALUES
    (2, 'Sucursala Victoriei', 'Bucuresti', 'Calea Victoriei nr. 45, Sector 1');
INSERT INTO sucursala (sucursala_id, nume_sucursala, oras, adresa) VALUES
    (3, 'Sucursala Cluj Centru', 'Cluj-Napoca', 'Str. Eroilor nr. 22');
INSERT INTO sucursala (sucursala_id, nume_sucursala, oras, adresa) VALUES
    (4, 'Sucursala Timisoara Nord', 'Timisoara', 'Bd. Iosif Bulbuca nr. 18');
INSERT INTO sucursala (sucursala_id, nume_sucursala, oras, adresa) VALUES
    (5, 'Sucursala Iasi Copou', 'Iasi', 'Bd. Carol I nr. 11');


-- 2. CLIENT
INSERT INTO client (client_id, tip_client, nume_denumire, cod_identificare, adresa, email, telefon, venit_declarat, cont_iban, data_inregistrare) VALUES
    (1, 'PF', 'Ionescu Alexandru', '1850312034567', 'Str. Florilor nr. 3, Bucuresti', 'alex.ionescu@email.ro', '0722111222', 5200.00, 'RO49AAAA1B31007593840000', DATE '2022-03-15');
INSERT INTO client (client_id, tip_client, nume_denumire, cod_identificare, adresa, email, telefon, venit_declarat, cont_iban, data_inregistrare) VALUES
    (2, 'PF', 'Popescu Maria', '2900520089012', 'Bd. Decebal nr. 7, Cluj-Napoca', 'maria.popescu@email.ro', '0744333444', 4800.00, 'RO49BBBB1B31007593840001', DATE '2021-07-20');
INSERT INTO client (client_id, tip_client, nume_denumire, cod_identificare, adresa, email, telefon, venit_declarat, cont_iban, data_inregistrare) VALUES
    (3, 'PJ', 'Tech Solutions SRL', '38574920', 'Calea Aradului nr. 55, Timisoara', 'contact@techsolutions.ro', '0256789012', 85000.00, 'RO49CCCC1B31007593840002', DATE '2020-11-01');
INSERT INTO client (client_id, tip_client, nume_denumire, cod_identificare, adresa, email, telefon, venit_declarat, cont_iban, data_inregistrare) VALUES
    (4, 'PF', 'Dumitru Radu', '1780908112233', 'Str. Pacurari nr. 14, Iasi', 'radu.dumitru@email.ro', '0733555666', 6100.00, 'RO49DDDD1B31007593840003', DATE '2023-01-10');
INSERT INTO client (client_id, tip_client, nume_denumire, cod_identificare, adresa, email, telefon, venit_declarat, cont_iban, data_inregistrare) VALUES
    (5, 'PJ', 'Construct Plus SA', '24681357', 'Str. Industriilor nr. 100, Brasov', 'office@constructplus.ro', '0268445566', 210000.00, 'RO49EEEE1B31007593840004', DATE '2019-06-05');


-- 3. TIP_CREDIT
INSERT INTO tip_credit (tip_id, nume_produs, dobanda_referinta, perioada_max_luni, comision_analiza, moneda) VALUES
    (1, 'Credit Imobiliar Standard', 5.25, 360, 500.00, 'RON');
INSERT INTO tip_credit (tip_id, nume_produs, dobanda_referinta, perioada_max_luni, comision_analiza, moneda) VALUES
    (2, 'Credit de Nevoi Personale', 9.90, 84, 200.00, 'RON');
INSERT INTO tip_credit (tip_id, nume_produs, dobanda_referinta, perioada_max_luni, comision_analiza, moneda) VALUES
    (3, 'Credit Auto', 7.50, 72, 150.00, 'RON');
INSERT INTO tip_credit (tip_id, nume_produs, dobanda_referinta, perioada_max_luni, comision_analiza, moneda) VALUES
    (4, 'Credit Ipotecar EUR', 3.75, 300, 400.00, 'EUR');
INSERT INTO tip_credit (tip_id, nume_produs, dobanda_referinta, perioada_max_luni, comision_analiza, moneda) VALUES
    (5, 'Linie de Credit IMM', 8.20, 120, 750.00, 'RON');


-- 4. PROPRIETATE
INSERT INTO proprietate (proprietate_id, nr_cadastral, adresa, tip_imobil, suprafata_utila) VALUES
    (1, 'CAD-BUC-001234', 'Str. Florilor nr. 3, ap. 5, Bucuresti', 'Apartament', 68.50);
INSERT INTO proprietate (proprietate_id, nr_cadastral, adresa, tip_imobil, suprafata_utila) VALUES
    (2, 'CAD-CLJ-005678', 'Str. Memorandumului nr. 8, Cluj-Napoca', 'Casa', 145.00);
INSERT INTO proprietate (proprietate_id, nr_cadastral, adresa, tip_imobil, suprafata_utila) VALUES
    (3, 'CAD-TIM-009012', 'Calea Sagului nr. 30, Timisoara', 'Apartament', 54.20);
INSERT INTO proprietate (proprietate_id, nr_cadastral, adresa, tip_imobil, suprafata_utila) VALUES
    (4, 'CAD-ISI-003456', 'Sos. Nationala nr. 120, Iasi', 'Teren', 500.00);
INSERT INTO proprietate (proprietate_id, nr_cadastral, adresa, tip_imobil, suprafata_utila) VALUES
    (5, 'CAD-BRV-007890', 'Str. Lunga nr. 200, Brasov', 'Casa', 210.00);


-- 5. ANGAJAT
INSERT INTO angajat (angajat_id, nume, prenume, cnp, sucursala_id) VALUES
    (1, 'Stanescu', 'Andrei', '1820415034521', 1);
INSERT INTO angajat (angajat_id, nume, prenume, cnp, sucursala_id) VALUES
    (2, 'Gheorghe', 'Elena', '2790320089034', 2);
INSERT INTO angajat (angajat_id, nume, prenume, cnp, sucursala_id) VALUES
    (3, 'Moldovan', 'Ciprian', '1880612112345', 3);
INSERT INTO angajat (angajat_id, nume, prenume, cnp, sucursala_id) VALUES
    (4, 'Nistor', 'Ioana', '2950101223344', 4);
INSERT INTO angajat (angajat_id, nume, prenume, cnp, sucursala_id) VALUES
    (5, 'Barbu', 'Mihai', '1760830334455', 5);


-- 6. EVALUATOR
INSERT INTO evaluator (evaluator_id, nume_evaluator, nr_autorizatie, specializare) VALUES
    (1, 'Petrescu Valentin', 'ANEVAR-2019-0041', 'Imobile rezidentiale');
INSERT INTO evaluator (evaluator_id, nume_evaluator, nr_autorizatie, specializare) VALUES
    (2, 'Draghici Simona', 'ANEVAR-2020-0088', 'Terenuri si proprietati comerciale');
INSERT INTO evaluator (evaluator_id, nume_evaluator, nr_autorizatie, specializare) VALUES
    (3, 'Lungu Bogdan', 'ANEVAR-2018-0033', 'Imobile rezidentiale');
INSERT INTO evaluator (evaluator_id, nume_evaluator, nr_autorizatie, specializare) VALUES
    (4, 'Vasile Cristina', 'ANEVAR-2021-0115', 'Proprietati industriale');
INSERT INTO evaluator (evaluator_id, nume_evaluator, nr_autorizatie, specializare) VALUES
    (5, 'Manea George', 'ANEVAR-2017-0022', 'Imobile rezidentiale');


-- 7. CERERE_CREDIT  
INSERT INTO cerere_credit (cerere_id, client_id, tip_id, angajat_id, suma_solicitata, data_depunere, status_cerere) VALUES
    (1, 1, 1, 1, 280000.00, DATE '2024-01-15', 'Aprobata');
INSERT INTO cerere_credit (cerere_id, client_id, tip_id, angajat_id, suma_solicitata, data_depunere, status_cerere) VALUES
    (2, 2, 2, 2, 35000.00, DATE '2024-02-10', 'Aprobata');
INSERT INTO cerere_credit (cerere_id, client_id, tip_id, angajat_id, suma_solicitata, data_depunere, status_cerere) VALUES
    (3, 3, 5, 3, 150000.00, DATE '2024-03-05', 'Aprobata');
INSERT INTO cerere_credit (cerere_id, client_id, tip_id, angajat_id, suma_solicitata, data_depunere, status_cerere) VALUES
    (4, 4, 3, 4, 48000.00, DATE '2024-04-22', 'Respinsa');
INSERT INTO cerere_credit (cerere_id, client_id, tip_id, angajat_id, suma_solicitata, data_depunere, status_cerere) VALUES
    (5, 5, 4, 5, 500000.00, DATE '2024-05-18', 'Aprobata');


-- 8. CONTRACT
INSERT INTO cerere_credit (cerere_id, client_id, tip_id, angajat_id, suma_solicitata, data_depunere, status_cerere) VALUES
    (6, 2, 4, 1, 75000.00, DATE '2024-06-01', 'Aprobata');

INSERT INTO contract (contract_id, cerere_id, nr_contract, data_semnare, dobanda_finala, clauze_speciale) VALUES
    (1, 1, 'CTR-2024-000001', DATE '2024-01-25', 5.50, 'Rambursare anticipata permisa fara penalitati dupa 12 luni.');
INSERT INTO contract (contract_id, cerere_id, nr_contract, data_semnare, dobanda_finala, clauze_speciale) VALUES
    (2, 2, 'CTR-2024-000002', DATE '2024-02-18', 9.90, NULL);
INSERT INTO contract (contract_id, cerere_id, nr_contract, data_semnare, dobanda_finala, clauze_speciale) VALUES
    (3, 3, 'CTR-2024-000003', DATE '2024-03-12', 8.20, 'Linie reinnoibila anual. Garantie colaterala obligatorie.');
INSERT INTO contract (contract_id, cerere_id, nr_contract, data_semnare, dobanda_finala, clauze_speciale) VALUES
    (4, 5, 'CTR-2024-000004', DATE '2024-05-28', 3.80, 'Denominat EUR. Asigurare proprietate obligatorie pe toata perioada.');
INSERT INTO contract (contract_id, cerere_id, nr_contract, data_semnare, dobanda_finala, clauze_speciale) VALUES
    (5, 6, 'CTR-2024-000005', DATE '2024-06-10', 3.75, 'Clauza de revizuire a dobanzii la fiecare 5 ani.');


-- 9. CREDIT
INSERT INTO credit (credit_id, contract_id, sold_curent, data_acordare, stare_credit) VALUES
    (1, 1, 275840.00, DATE '2024-02-01', 'Activ');
INSERT INTO credit (credit_id, contract_id, sold_curent, data_acordare, stare_credit) VALUES
    (2, 2, 33200.00, DATE '2024-02-20', 'Activ');
INSERT INTO credit (credit_id, contract_id, sold_curent, data_acordare, stare_credit) VALUES
    (3, 3, 147500.00, DATE '2024-03-15', 'Activ');
INSERT INTO credit (credit_id, contract_id, sold_curent, data_acordare, stare_credit) VALUES
    (4, 4, 498000.00, DATE '2024-06-01', 'Activ');
INSERT INTO credit (credit_id, contract_id, sold_curent, data_acordare, stare_credit) VALUES
    (5, 5, 74100.00, DATE '2024-06-12', 'Activ');


-- 10. RAPOARTE_EVALUARE 
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (1,  1, 1, 320000.00, DATE '2024-01-10');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (2,  2, 2, 480000.00, DATE '2024-01-11');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (3,  3, 3, 195000.00, DATE '2024-02-05');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (4,  4, 2, 85000.00,  DATE '2024-03-01');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (5,  5, 4, 950000.00, DATE '2024-05-20');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (6,  1, 3, 315000.00, DATE '2024-06-15');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (7,  2, 5, 490000.00, DATE '2024-06-20'); 
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (8,  3, 1, 200000.00, DATE '2024-07-01');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (9,  4, 5, 88000.00,  DATE '2024-07-10');
INSERT INTO rapoarte_evaluare (raport_id, proprietate_id, evaluator_id, valoare_estimata, data_evaluare) VALUES
    (10, 5, 1, 960000.00, DATE '2024-07-15');


-- 11. GARANTII 
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (1,  1, 1, 280000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (2,  1, 2, 100000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (3,  2, 3, 35000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (4,  3, 4, 85000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (5,  3, 5, 65000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (6,  4, 5, 500000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (7,  4, 2, 200000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (8,  5, 1, 74000.00);
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (9,  5, 3, 30000.00);  
INSERT INTO garantii (garantie_id, credit_id, proprietate_id, valoare_acoperita) VALUES
    (10, 2, 4, 10000.00);   


-- 12. PLATA 
INSERT INTO plata (plata_id, credit_id, suma_platita, data_plata, metoda_plata) VALUES
    (1, 1, 1580.00, DATE '2024-03-01', 'Direct Debit');
INSERT INTO plata (plata_id, credit_id, suma_platita, data_plata, metoda_plata) VALUES
    (2, 2, 620.00,  DATE '2024-03-20', 'Transfer');
INSERT INTO plata (plata_id, credit_id, suma_platita, data_plata, metoda_plata) VALUES
    (3, 3, 2100.00, DATE '2024-04-15', 'Direct Debit');
INSERT INTO plata (plata_id, credit_id, suma_platita, data_plata, metoda_plata) VALUES
    (4, 4, 3850.00, DATE '2024-07-01', 'Transfer');
INSERT INTO plata (plata_id, credit_id, suma_platita, data_plata, metoda_plata) VALUES
    (5, 5, 950.00,  DATE '2024-07-12', 'Cash');


-- 13. GRAFIC_RAMBURSARE 
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (1,  1, 1, DATE '2024-03-01', 1580.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (2,  1, 2, DATE '2024-04-01', 1580.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (3,  1, 3, DATE '2024-05-01', 1580.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (4,  1, 4, DATE '2024-06-01', 1580.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (5,  1, 5, DATE '2024-07-01', 1580.00, 'Neachitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (6,  2, 1, DATE '2024-03-20', 620.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (7,  2, 2, DATE '2024-04-20', 620.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (8,  2, 3, DATE '2024-05-20', 620.00, 'Achitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (9,  2, 4, DATE '2024-06-20', 620.00, 'Neachitat');
INSERT INTO grafic_rambursare (rata_id, credit_id, nr_rata, data_scadenta, valoare_rata, status_plata) VALUES
    (10, 2, 5, DATE '2024-07-20', 620.00, 'Neachitat');


