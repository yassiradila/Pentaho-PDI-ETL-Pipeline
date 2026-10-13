


--                           Yassir Adila / BDIA2 / ENSA Tétouan.


--                                 Le script SQL complet :


--Création de data warehouse:
CREATE DATABASE dw_univ;



--                                  Création des 3 Tables:


-- 1. dim_etudiant :

CREATE TABLE dim_etudiant (
    id_etud SERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    sexe VARCHAR(1) CHECK (sexe IN ('M','F')),
    age INT CHECK (age > 17)
);


-- 2. dim_cours :

CREATE TABLE dim_cours (
    id_cours SERIAL PRIMARY KEY,
    nom_cours VARCHAR(255) NOT NULL UNIQUE,
    type_cours VARCHAR(20) CHECK (type_cours IN ('Obligatoire','Optionnel'))
);


-- 3. fact_examens :

CREATE TABLE fact_examens (
    id_examen SERIAL PRIMARY KEY,
    id_etud INT NOT NULL,
    id_cours INT NOT NULL,
    note NUMERIC(5,2) NOT NULL,
    reussi VARCHAR(3) CHECK (reussi IN ('Oui','Non')),
    date_examen DATE NOT NULL,
    CONSTRAINT fk_exam_etud FOREIGN KEY (id_etud)
        REFERENCES dim_etudiant(id_etud),
    CONSTRAINT fk_exam_cours FOREIGN KEY (id_cours)
        REFERENCES dim_cours(id_cours)
);

