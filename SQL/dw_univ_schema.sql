-- ============================================================================
-- Project: University Mini Data Warehouse (dw_univ)
-- Author: Yassir Adila | BDIA2 | ENSA Tétouan
-- Description: DDL & Analytical queries for Star Schema DWH in PostgreSQL
-- ============================================================================

-- 1. Database Initialization
-- CREATE DATABASE dw_univ;
-- \c dw_univ;

-- Clean existing tables if needed (drop order respects foreign key constraints)
DROP TABLE IF EXISTS fact_examens CASCADE;
DROP TABLE IF EXISTS dim_cours CASCADE;
DROP TABLE IF EXISTS dim_etudiant CASCADE;

-- ============================================================================
-- 2. Dimension Tables
-- ============================================================================

-- Dimension: dim_etudiant
-- Stores clean demographic and identification data for students
CREATE TABLE dim_etudiant (
    id_etud SERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    sexe VARCHAR(1) CHECK (sexe IN ('M', 'F')),
    age INT CHECK (age > 17)
);

-- Dimension: dim_cours
-- Stores academic course catalog and requirements
CREATE TABLE dim_cours (
    id_cours SERIAL PRIMARY KEY,
    nom_cours VARCHAR(255) NOT NULL UNIQUE,
    type_cours VARCHAR(20) CHECK (type_cours IN ('Obligatoire', 'Optionnel'))
);

-- ============================================================================
-- 3. Fact Table
-- ============================================================================

-- Fact: fact_examens
-- Stores granular exam results and grades with foreign keys to dimensions
CREATE TABLE fact_examens (
    id_examen SERIAL PRIMARY KEY,
    id_etud INT NOT NULL,
    id_cours INT NOT NULL,
    note NUMERIC(5, 2) NOT NULL CHECK (note >= 0 AND note <= 20),
    reussi VARCHAR(3) CHECK (reussi IN ('Oui', 'Non')),
    date_examen DATE NOT NULL,
    CONSTRAINT fk_exam_etud FOREIGN KEY (id_etud)
        REFERENCES dim_etudiant(id_etud) ON DELETE CASCADE,
    CONSTRAINT fk_exam_cours FOREIGN KEY (id_cours)
        REFERENCES dim_cours(id_cours) ON DELETE CASCADE
);

-- Performance Indexes for OLAP / BI Querying
CREATE INDEX idx_fact_examens_etud ON fact_examens(id_etud);
CREATE INDEX idx_fact_examens_cours ON fact_examens(id_cours);
CREATE INDEX idx_fact_examens_date ON fact_examens(date_examen);

-- ============================================================================
-- 4. Verification & Analytical Queries
-- ============================================================================

-- Verification: Row Counts
-- SELECT 'dim_etudiant' AS table_name, COUNT(*) AS total_records FROM dim_etudiant
-- UNION ALL
-- SELECT 'dim_cours', COUNT(*) FROM dim_cours
-- UNION ALL
-- SELECT 'fact_examens', COUNT(*) FROM fact_examens;

-- KPI 1: Pass rate and average score per course
-- SELECT 
--     c.nom_cours,
--     c.type_cours,
--     COUNT(f.id_examen) AS total_exams,
--     ROUND(AVG(f.note), 2) AS moyenne_note,
--     COUNT(CASE WHEN f.reussi = 'Oui' THEN 1 END) AS total_reussis,
--     ROUND(COUNT(CASE WHEN f.reussi = 'Oui' THEN 1 END)::NUMERIC / COUNT(f.id_examen) * 100, 2) AS taux_reussite_pct
-- FROM fact_examens f
-- JOIN dim_cours c ON f.id_cours = c.id_cours
-- GROUP BY c.nom_cours, c.type_cours
-- ORDER BY moyenne_note DESC;

-- KPI 2: Performance by gender and age bracket
-- SELECT 
--     e.sexe,
--     COUNT(DISTINCT e.id_etud) AS nb_etudiants,
--     ROUND(AVG(f.note), 2) AS moyenne_generale,
--     ROUND(COUNT(CASE WHEN f.reussi = 'Oui' THEN 1 END)::NUMERIC / COUNT(f.id_examen) * 100, 2) AS taux_reussite_pct
-- FROM fact_examens f
-- JOIN dim_etudiant e ON f.id_etud = e.id_etud
-- GROUP BY e.sexe;
