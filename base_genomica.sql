-- Creacion de la base de datos

CREATE DATABASE IF NOT EXISTS base_genomica;
USE base_genomica;


-- Tabla de genes

CREATE TABLE GEN (
    id_gen INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    cromosoma VARCHAR(10),
    posicion_inicio INT,
    posicion_fin INT
);


-- Tabla de secuencia

CREATE TABLE SECUENCIA (
    id_secuencia INT AUTO_INCREMENT PRIMARY KEY,
    id_gen INT NOT NULL,
    cadena_adn TEXT NOT NULL,
    tipo ENUM('exon', 'intron', 'CDS', 'promotor', 'UTR') NOT NULL,
    posicion_relativa_gen INT NOT NULL,
    
    FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE

);


-- Tabla de variante

CREATE TABLE VARIANTE (
    id_variante INT AUTO_INCREMENT PRIMARY KEY,
    id_gen INT NOT NULL,
    posicion_relativa_gen INT NOT NULL,
    alelo_referencia VARCHAR(10) DEFAULT '-',
    alelo_mutado VARCHAR(10) DEFAULT '-',
    tipo_variante ENUM('SNP', 'insercion', 'delecion') NOT NULL,
    
    FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE
);


-- Tabla de anotacion 

CREATE TABLE ANOTACION (
    id_anotacion INT AUTO_INCREMENT PRIMARY KEY,
    id_gen INT NOT NULL,
    descripcion TEXT,
    tipo_anotacion ENUM('funcional', 'clinica', 'estructural', 'expresion') NOT NULL,
    
    FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE
);


-- tabla de estudio

CREATE TABLE ESTUDIO (
    id_estudio INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    fecha_publicacion DATE,
    referencia VARCHAR(20) NOT NULL UNIQUE
);


-- Tabla de conexion 

CREATE TABLE ESTUDIO_GEN (
    id_estudio INT NOT NULL,
    id_gen INT NOT NULL,
    
    PRIMARY KEY (id_estudio, id_gen),
    FOREIGN KEY (id_estudio) REFERENCES ESTUDIO(id_estudio) ON DELETE CASCADE,
    FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE
);


-- Tabla de conexion

CREATE TABLE ESTUDIO_VARIANTE (
    id_estudio INT NOT NULL,
    id_variante INT NOT NULL,
    
    PRIMARY KEY (id_estudio, id_variante),
    FOREIGN KEY (id_estudio) REFERENCES ESTUDIO(id_estudio) ON DELETE CASCADE,
    FOREIGN KEY (id_variante) REFERENCES VARIANTE(id_variante) ON DELETE CASCADE
);

-- test si funciona
SHOW TABLES;

DESCRIBE GEN;
DESCRIBE SECUENCIA;
DESCRIBE VARIANTE;
DESCRIBE ANOTACION;
DESCRIBE ESTUDIO;
DESCRIBE ESTUDIO_GEN;
DESCRIBE ESTUDIO_VARIANTE;