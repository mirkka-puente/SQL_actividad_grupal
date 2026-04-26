


-- ============================================================
--  CREACIÓN DE TABLAS CON RESTRICCIONES 
-- ============================================================

CREATE DATABASE IF NOT EXISTS base_genomica;
USE base_genomica;


-- -----------------------------------------------------------
-- Tabla GEN
-- Restricciones:
--   · nombre  → NOT NULL + UNIQUE 
--   · descripcion → NOT NULL
-- -----------------------------------------------------------
CREATE TABLE GEN (
    id_gen            INT          AUTO_INCREMENT PRIMARY KEY,
    nombre            VARCHAR(100) NOT NULL UNIQUE,          
    descripcion       TEXT         NOT NULL,                 
    cromosoma         VARCHAR(10),
    posicion_inicio   INT,
    posicion_fin      INT
);


-- -----------------------------------------------------------
-- Tabla SECUENCIA
-- Restricciones:
--   · cadena_adn       → longitud entre 10 y 1000 caracteres (CHECK)
--   · posicion_relativa_gen → entero positivo (> 0) y NOT NULL (CHECK)
-- -----------------------------------------------------------
CREATE TABLE SECUENCIA (
    id_secuencia         INT  AUTO_INCREMENT PRIMARY KEY,
    id_gen               INT  NOT NULL,
    cadena_adn           TEXT NOT NULL,
    tipo                 ENUM('exon', 'intron', 'CDS', 'promotor', 'UTR') NOT NULL,
    posicion_relativa_gen INT  NOT NULL,

    CONSTRAINT fk_sec_gen   FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE,
    CONSTRAINT chk_adn_long CHECK (CHAR_LENGTH(cadena_adn) BETWEEN 10 AND 1000),  -- [10-1000] chrs
    CONSTRAINT chk_sec_pos  CHECK (posicion_relativa_gen > 0)                      -- Entero positivo > 0
);


-- -----------------------------------------------------------
-- Tabla VARIANTE
-- Restricciones:
--   · posicion_relativa_gen → entero positivo (> 0) y NOT NULL (CHECK)
--   · alelo_referencia / alelo_mutado → DEFAULT '-'
-- -----------------------------------------------------------
CREATE TABLE VARIANTE (
    id_variante           INT          AUTO_INCREMENT PRIMARY KEY,
    id_gen                INT          NOT NULL,
    posicion_relativa_gen INT          NOT NULL,
    alelo_referencia      VARCHAR(10)  DEFAULT '-',           
    alelo_mutado          VARCHAR(10)  DEFAULT '-',           
    tipo_variante         ENUM('SNP', 'insercion', 'delecion') NOT NULL,

    CONSTRAINT fk_var_gen   FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE,
    CONSTRAINT chk_var_pos  CHECK (posicion_relativa_gen > 0)  -- Entero positivo > 0
);


-- -----------------------------------------------------------
-- Tabla ANOTACION
-- -----------------------------------------------------------
CREATE TABLE ANOTACION (
    id_anotacion  INT  AUTO_INCREMENT PRIMARY KEY,
    id_gen        INT  NOT NULL,
    descripcion   TEXT,
    tipo_anotacion ENUM('funcional', 'clinica', 'estructural', 'expresion') NOT NULL,

    CONSTRAINT fk_ano_gen FOREIGN KEY (id_gen) REFERENCES GEN(id_gen) ON DELETE CASCADE
);


-- -----------------------------------------------------------
-- Tabla ESTUDIO
-- Restricciones:
--   · referencia → UNIQUE + formato aaaa/111  (CHECK con REGEXP)
-- -----------------------------------------------------------
CREATE TABLE ESTUDIO (
    id_estudio        INT          AUTO_INCREMENT PRIMARY KEY,
    titulo            VARCHAR(255) NOT NULL,
    fecha_publicacion DATE,
    referencia        VARCHAR(20)  NOT NULL UNIQUE,  

    -- Formato referencia: exactamente 4 letras, '/', 3 dígitos  →  aaaa/111
    CONSTRAINT chk_ref_formato CHECK (referencia REGEXP '^[A-Za-z]{4}/[0-9]{3}$')
);


-- -----------------------------------------------------------
-- Tabla puente ESTUDIO_GEN  (relación N:M entre ESTUDIO y GEN)
-- -----------------------------------------------------------
CREATE TABLE ESTUDIO_GEN (
    id_estudio INT NOT NULL,
    id_gen     INT NOT NULL,

    PRIMARY KEY (id_estudio, id_gen),
    CONSTRAINT fk_eg_estudio FOREIGN KEY (id_estudio) REFERENCES ESTUDIO(id_estudio) ON DELETE CASCADE,
    CONSTRAINT fk_eg_gen     FOREIGN KEY (id_gen)     REFERENCES GEN(id_gen)         ON DELETE CASCADE
);


-- -----------------------------------------------------------
-- Tabla puente ESTUDIO_VARIANTE  (relación N:M entre ESTUDIO y VARIANTE)
-- -----------------------------------------------------------
CREATE TABLE ESTUDIO_VARIANTE (
    id_estudio  INT NOT NULL,
    id_variante INT NOT NULL,

    PRIMARY KEY (id_estudio, id_variante),
    CONSTRAINT fk_ev_estudio  FOREIGN KEY (id_estudio)  REFERENCES ESTUDIO(id_estudio)   ON DELETE CASCADE,
    CONSTRAINT fk_ev_variante FOREIGN KEY (id_variante) REFERENCES VARIANTE(id_variante) ON DELETE CASCADE
);


-- Verificación de creación
SHOW TABLES;
DESCRIBE GEN;
DESCRIBE SECUENCIA;
DESCRIBE VARIANTE;
DESCRIBE ANOTACION;
DESCRIBE ESTUDIO;
DESCRIBE ESTUDIO_GEN;
DESCRIBE ESTUDIO_VARIANTE;


-- ============================================================
-- INSERCIÓN DE DATOS
-- ============================================================
-- Se documentan:
--   A) Inserciones CORRECTAS (datos válidos que deben funcionar)
--   B) Inserciones INCORRECTAS (datos que violan restricciones
--      y deben generar error)
-- ============================================================


-- ============================================================
-- A) INSERCIONES CORRECTAS
-- ============================================================

-- -----------------------------------------------------------
-- Genes
-- -----------------------------------------------------------
INSERT INTO GEN (nombre, descripcion, cromosoma, posicion_inicio, posicion_fin)
VALUES ('BRCA1',
        'Gen supresor de tumores relacionado con cáncer de mama y ovario',
        '17', 43044295, 43125364);

INSERT INTO GEN (nombre, descripcion, cromosoma, posicion_inicio, posicion_fin)
VALUES ('TP53',
        'Gen supresor tumoral que codifica la proteína p53, regulador del ciclo celular',
        '17', 7668402, 7687550);

INSERT INTO GEN (nombre, descripcion, cromosoma, posicion_inicio, posicion_fin)
VALUES ('CFTR',
        'Gen relacionado con la fibrosis quística; codifica un canal de cloruro',
        '7', 117480025, 117668665);


-- -----------------------------------------------------------
-- Secuencias  (cadena_adn: entre 10 y 1000 caracteres, posicion > 0)
-- -----------------------------------------------------------
INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (1, 'ATGCTAGCTAGCTAGCTAGCATGC', 'exon', 1);

INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (1, 'GTATGCCCAAATTTGGGCCCAAA', 'intron', 25);

INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (2, 'CGATCGATCGATCGATCGATCGAT', 'CDS', 10);

INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (3, 'TTTTAAAACCCCGGGGTTTTAAAA', 'promotor', 5);


-- -----------------------------------------------------------
-- Variantes  
-- -----------------------------------------------------------
INSERT INTO VARIANTE (id_gen, posicion_relativa_gen, alelo_referencia, alelo_mutado, tipo_variante)
VALUES (1, 50, 'A', 'T', 'SNP');

INSERT INTO VARIANTE (id_gen, posicion_relativa_gen, alelo_referencia, alelo_mutado, tipo_variante)
VALUES (1, 120, 'GGT', '-', 'delecion');

INSERT INTO VARIANTE (id_gen, posicion_relativa_gen, alelo_referencia, alelo_mutado, tipo_variante)
VALUES (2, 75, '-', 'CAT', 'insercion');

-- Inserción usando el DEFAULT '-' en alelos 
INSERT INTO VARIANTE (id_gen, posicion_relativa_gen, tipo_variante)
VALUES (3, 30, 'SNP');


-- -----------------------------------------------------------
-- Anotaciones
-- -----------------------------------------------------------
INSERT INTO ANOTACION (id_gen, descripcion, tipo_anotacion)
VALUES (1, 'Implicado en la reparación del ADN de doble cadena por recombinación homóloga', 'funcional');

INSERT INTO ANOTACION (id_gen, descripcion, tipo_anotacion)
VALUES (1, 'Mutaciones en BRCA1 aumentan el riesgo de cáncer de mama hereditario', 'clinica');

INSERT INTO ANOTACION (id_gen, descripcion, tipo_anotacion)
VALUES (2, 'p53 actúa como factor de transcripción en respuesta al daño del ADN', 'funcional');

INSERT INTO ANOTACION (id_gen, descripcion, tipo_anotacion)
VALUES (3, 'Expresado principalmente en tejido epitelial pulmonar y pancreático', 'expresion');


-- -----------------------------------------------------------
-- Estudios  (referencia: exactamente 4 letras, '/', 3 dígitos)
-- -----------------------------------------------------------
INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Análisis genómico de BRCA1 en pacientes con cáncer de mama', '2022-06-15', 'BRCA/001');

INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Caracterización de variantes en TP53 en tumores colorrectales', '2021-03-22', 'TUMO/045');

INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Estudio funcional del gen CFTR en fibrosis quística', '2023-11-08', 'CFTR/112');


-- -----------------------------------------------------------
-- Relaciones ESTUDIO_GEN
-- -----------------------------------------------------------
INSERT INTO ESTUDIO_GEN (id_estudio, id_gen) VALUES (1, 1);  -- BRCA/001 estudia BRCA1
INSERT INTO ESTUDIO_GEN (id_estudio, id_gen) VALUES (2, 2);  -- TUMO/045 estudia TP53
INSERT INTO ESTUDIO_GEN (id_estudio, id_gen) VALUES (3, 3);  -- CFTR/112 estudia CFTR
INSERT INTO ESTUDIO_GEN (id_estudio, id_gen) VALUES (1, 2);  -- BRCA/001 también estudia TP53


-- -----------------------------------------------------------
-- Relaciones ESTUDIO_VARIANTE
-- -----------------------------------------------------------
INSERT INTO ESTUDIO_VARIANTE (id_estudio, id_variante) VALUES (1, 1);  -- BRCA/001 → variante 1
INSERT INTO ESTUDIO_VARIANTE (id_estudio, id_variante) VALUES (1, 2);  -- BRCA/001 → variante 2
INSERT INTO ESTUDIO_VARIANTE (id_estudio, id_variante) VALUES (2, 3);  -- TUMO/045 → variante 3


-- Verificar que los datos se insertaron correctamente
SELECT * FROM GEN;
SELECT * FROM SECUENCIA;
SELECT * FROM VARIANTE;
SELECT * FROM ANOTACION;
SELECT * FROM ESTUDIO;
SELECT * FROM ESTUDIO_GEN;
SELECT * FROM ESTUDIO_VARIANTE;


-- ============================================================
-- B) INSERCIONES INCORRECTAS (deben generar ERROR)
-- Cada una viola una restricción específica del modelo.
-- ============================================================

-- -----------------------------------------------------------
-- ERROR 1: cadena_adn demasiado corta (< 10 caracteres)
-- Restricción violada: CHECK chk_adn_long (BETWEEN 10 AND 1000)
-- -----------------------------------------------------------
INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (1, 'ATGC', 'exon', 1);



-- -----------------------------------------------------------
-- ERROR 2: cadena_adn demasiado larga (> 1000 caracteres)
-- Restricción violada: CHECK chk_adn_long (BETWEEN 10 AND 1000)
-- -----------------------------------------------------------

INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (1, REPEAT('ATGC', 251), 'exon', 1);



-- -----------------------------------------------------------
-- ERROR 3: posicion_relativa_gen negativa en SECUENCIA
-- Restricción violada: CHECK chk_sec_pos (posicion_relativa_gen > 0)
-- -----------------------------------------------------------

INSERT INTO SECUENCIA (id_gen, cadena_adn, tipo, posicion_relativa_gen)
VALUES (1, 'ATGCTAGCTAGCTAGC', 'intron', -5);



-- -----------------------------------------------------------
-- ERROR 4: posicion_relativa_gen igual a 0 en VARIANTE
-- Restricción violada: CHECK chk_var_pos (posicion_relativa_gen > 0)
-- -----------------------------------------------------------

INSERT INTO VARIANTE (id_gen, posicion_relativa_gen, alelo_referencia, alelo_mutado, tipo_variante)
VALUES (1, 0, 'A', 'T', 'SNP');



-- -----------------------------------------------------------
-- ERROR 5: nombre del gen es NULL
-- Restricción violada: NOT NULL en columna 'nombre'
-- -----------------------------------------------------------

INSERT INTO GEN (nombre, descripcion, cromosoma)
VALUES (NULL, 'Gen sin nombre asignado', '1');



-- -----------------------------------------------------------
-- ERROR 6: descripción del gen es NULL
-- Restricción violada: NOT NULL en columna 'descripcion'
-- -----------------------------------------------------------

INSERT INTO GEN (nombre, descripcion, cromosoma)
VALUES ('GENNULO', NULL, '5');



-- -----------------------------------------------------------
-- ERROR 7: referencia de estudio con formato incorrecto
-- Restricción violada: CHECK chk_ref_formato (REGEXP '^[A-Za-z]{4}/[0-9]{3}$')
-- -----------------------------------------------------------

INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Estudio con referencia mal formada', '2023-01-01', '1234/abc');



-- -----------------------------------------------------------
-- ERROR 8: referencia con número de letras incorrecto (solo 3)
-- Restricción violada: CHECK chk_ref_formato
-- -----------------------------------------------------------

INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Otro estudio inválido', '2023-05-10', 'GEN/001');



-- -----------------------------------------------------------
-- ERROR 9: nombre de gen duplicado (violación de UNIQUE)
-- Restricción violada: UNIQUE KEY en columna 'nombre'
-- -----------------------------------------------------------

INSERT INTO GEN (nombre, descripcion, cromosoma)
VALUES ('BRCA1', 'Intento de insertar un gen con nombre ya existente', '17');



-- -----------------------------------------------------------
-- ERROR 10: referencia de estudio duplicada (violación de UNIQUE)
-- Restricción violada: UNIQUE KEY en columna 'referencia'
-- -----------------------------------------------------------

INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Estudio duplicado', '2024-01-01', 'BRCA/001');

