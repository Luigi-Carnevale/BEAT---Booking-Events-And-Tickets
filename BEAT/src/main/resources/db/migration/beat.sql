-- beat.sql (definitivo, unico)
-- MariaDB / InnoDB / utf8mb4
-- Crea lo schema completo BEAT da zero

-- 0) Database
CREATE DATABASE IF NOT EXISTS beat
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE beat;

-- 1) Reset (ATTENZIONE: cancella tabelle esistenti)
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS carrello_items;
DROP TABLE IF EXISTS carrelli;
DROP TABLE IF EXISTS recensioni;
DROP TABLE IF EXISTS pagamenti;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS prenotazioni;
DROP TABLE IF EXISTS eventi;
DROP TABLE IF EXISTS categorie;
DROP TABLE IF EXISTS luoghi;
DROP TABLE IF EXISTS utente_ruoli;
DROP TABLE IF EXISTS ruoli;
DROP TABLE IF EXISTS utenti;
DROP TABLE IF EXISTS indirizzi;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- 1) Indirizzi
-- =========================
CREATE TABLE indirizzi (
                           id_indirizzo BIGINT AUTO_INCREMENT PRIMARY KEY,
                           citta VARCHAR(100) NOT NULL,
                           provincia VARCHAR(50) NOT NULL,
                           cap CHAR(5) NOT NULL,
                           strada VARCHAR(255) NOT NULL,
                           n_civico INT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 2) Utenti
-- =========================
CREATE TABLE utenti (
                        id_utente BIGINT AUTO_INCREMENT PRIMARY KEY,

                        username VARCHAR(30) NOT NULL,
                        email VARCHAR(100) NOT NULL,
                        password_hash CHAR(60) NOT NULL,            -- BCrypt 60

                        nome VARCHAR(100) NOT NULL,
                        cognome VARCHAR(100) NULL,
                        recapito_telefonico CHAR(10) NULL,
                        descrizione TEXT NULL,
                        immagine_url VARCHAR(255) NULL,

                        indirizzo_id BIGINT NULL,

                        is_active TINYINT(1) NOT NULL DEFAULT 1,
                        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                        CONSTRAINT uq_utenti_username UNIQUE (username),
                        CONSTRAINT uq_utenti_email UNIQUE (email),

                        CONSTRAINT fk_utenti_indirizzo
                            FOREIGN KEY (indirizzo_id) REFERENCES indirizzi(id_indirizzo)
                                ON DELETE SET NULL
                                ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_utenti_indirizzo_id ON utenti(indirizzo_id);

-- =========================
-- 3) Ruoli + ponte (RBAC)
-- =========================
CREATE TABLE ruoli (
                       id_ruolo BIGINT AUTO_INCREMENT PRIMARY KEY,
                       nome VARCHAR(32) NOT NULL,
                       CONSTRAINT uq_ruoli_nome UNIQUE (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE utente_ruoli (
                              utente_id BIGINT NOT NULL,
                              ruolo_id BIGINT NOT NULL,
                              PRIMARY KEY (utente_id, ruolo_id),

                              CONSTRAINT fk_utente_ruoli_utente
                                  FOREIGN KEY (utente_id) REFERENCES utenti(id_utente)
                                      ON DELETE CASCADE
                                      ON UPDATE CASCADE,

                              CONSTRAINT fk_utente_ruoli_ruolo
                                  FOREIGN KEY (ruolo_id) REFERENCES ruoli(id_ruolo)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_utente_ruoli_ruolo_id ON utente_ruoli(ruolo_id);

-- Seed ruoli BEAT
INSERT INTO ruoli(nome) VALUES
                            ('CLIENTE'),
                            ('ORGANIZZATORE'),
                            ('ADMIN_CATALOGO'),
                            ('ADMIN_ORDINI'),
                            ('ADMIN_RUOLI');

-- =========================
-- 4) Luoghi (entità luogo con indirizzo)
-- =========================
CREATE TABLE luoghi (
                        id_luogo BIGINT AUTO_INCREMENT PRIMARY KEY,
                        nome VARCHAR(120) NOT NULL,
                        indirizzo_id BIGINT NOT NULL,

                        CONSTRAINT fk_luoghi_indirizzo
                            FOREIGN KEY (indirizzo_id) REFERENCES indirizzi(id_indirizzo)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_luoghi_indirizzo_id ON luoghi(indirizzo_id);

-- =========================
-- 5) Categorie
-- =========================
CREATE TABLE categorie (
                           id_categoria BIGINT AUTO_INCREMENT PRIMARY KEY,
                           nome VARCHAR(50) NOT NULL,
                           CONSTRAINT uq_categorie_nome UNIQUE (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed categorie (modificabili)
INSERT INTO categorie(nome) VALUES
                                ('CONCERTO'),
                                ('TEATRO'),
                                ('SPORT'),
                                ('MOSTRA'),
                                ('FIERA'),
                                ('ALTRO');

-- =========================
-- 6) Eventi
-- =========================
CREATE TABLE eventi (
                        id_evento BIGINT AUTO_INCREMENT PRIMARY KEY,

                        titolo VARCHAR(100) NOT NULL,
                        descrizione TEXT NULL,
                        protagonista VARCHAR(100) NULL,
                        immagine_url VARCHAR(255) NULL,

                        data_evento DATE NOT NULL,
                        ora_evento TIME NOT NULL,

                        luogo_id BIGINT NOT NULL,
                        categoria_id BIGINT NULL,

                        is_fair TINYINT(1) NOT NULL DEFAULT 0,

                        posti_totali INT NOT NULL,
                        posti_disponibili INT NOT NULL,

                        prezzo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
                        is_free TINYINT(1) NOT NULL DEFAULT 0,

                        organizzatore_id BIGINT NOT NULL,

                        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                        CONSTRAINT fk_eventi_luogo
                            FOREIGN KEY (luogo_id) REFERENCES luoghi(id_luogo)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE,

                        CONSTRAINT fk_eventi_categoria
                            FOREIGN KEY (categoria_id) REFERENCES categorie(id_categoria)
                                ON DELETE SET NULL
                                ON UPDATE CASCADE,

                        CONSTRAINT fk_eventi_organizzatore
                            FOREIGN KEY (organizzatore_id) REFERENCES utenti(id_utente)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_eventi_data ON eventi(data_evento);
CREATE INDEX ix_eventi_luogo_id ON eventi(luogo_id);
CREATE INDEX ix_eventi_categoria_id ON eventi(categoria_id);
CREATE INDEX ix_eventi_organizzatore_id ON eventi(organizzatore_id);

-- =========================
-- 7) Prenotazioni
-- =========================
CREATE TABLE prenotazioni (
                              id_prenotazione BIGINT AUTO_INCREMENT PRIMARY KEY,

                              utente_id BIGINT NOT NULL,
                              evento_id BIGINT NOT NULL,

                              quantita INT NOT NULL DEFAULT 1,
                              stato ENUM('CREATED','PAID','CANCELLED','FAILED') NOT NULL DEFAULT 'CREATED',

                              acquistata_il DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              codice_univoco VARCHAR(50) NOT NULL,

                              CONSTRAINT fk_prenotazioni_utente
                                  FOREIGN KEY (utente_id) REFERENCES utenti(id_utente)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,

                              CONSTRAINT fk_prenotazioni_evento
                                  FOREIGN KEY (evento_id) REFERENCES eventi(id_evento)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,

                              CONSTRAINT uq_prenotazioni_codice UNIQUE (codice_univoco)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_prenotazioni_utente_id ON prenotazioni(utente_id);
CREATE INDEX ix_prenotazioni_evento_id ON prenotazioni(evento_id);

-- =========================
-- 8) Ticket (1 per posto)
-- =========================
CREATE TABLE tickets (
                         id_ticket BIGINT AUTO_INCREMENT PRIMARY KEY,

                         prenotazione_id BIGINT NOT NULL,
                         ticket_code VARCHAR(64) NOT NULL,

                         stato ENUM('ISSUED','USED','CANCELLED') NOT NULL DEFAULT 'ISSUED',
                         emesso_il DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         usato_il DATETIME NULL DEFAULT NULL,

                         CONSTRAINT fk_tickets_prenotazione
                             FOREIGN KEY (prenotazione_id) REFERENCES prenotazioni(id_prenotazione)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE,

                         CONSTRAINT uq_tickets_code UNIQUE (ticket_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_tickets_prenotazione_id ON tickets(prenotazione_id);
CREATE INDEX ix_tickets_stato ON tickets(stato);

-- =========================
-- 9) Pagamenti
-- =========================
CREATE TABLE pagamenti (
                           id_pagamento BIGINT AUTO_INCREMENT PRIMARY KEY,

                           prenotazione_id BIGINT NOT NULL,

                           tipo ENUM('PAYMENT','REFUND') NOT NULL DEFAULT 'PAYMENT',
                           provider VARCHAR(30) NOT NULL DEFAULT 'MOCK',
                           transaction_id VARCHAR(100) NOT NULL,
                           importo DECIMAL(10,2) NOT NULL,

                           stato ENUM('CREATED','AUTHORIZED','CAPTURED','FAILED','REFUNDED') NOT NULL DEFAULT 'CREATED',

                           created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                           CONSTRAINT fk_pagamenti_prenotazione
                               FOREIGN KEY (prenotazione_id) REFERENCES prenotazioni(id_prenotazione)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE,

                           CONSTRAINT uq_pagamenti_transaction UNIQUE (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_pagamenti_prenotazione_id ON pagamenti(prenotazione_id);
CREATE INDEX ix_pagamenti_stato ON pagamenti(stato);

-- =========================
-- 10) Recensioni
-- =========================
CREATE TABLE recensioni (
                            id_recensione BIGINT AUTO_INCREMENT PRIMARY KEY,

                            utente_id BIGINT NOT NULL,
                            evento_id BIGINT NOT NULL,

                            rating TINYINT NOT NULL,
                            contenuto TEXT NULL,
                            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                            CONSTRAINT fk_recensioni_utente
                                FOREIGN KEY (utente_id) REFERENCES utenti(id_utente)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,

                            CONSTRAINT fk_recensioni_evento
                                FOREIGN KEY (evento_id) REFERENCES eventi(id_evento)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,

                            CONSTRAINT uq_recensioni_utente_evento UNIQUE (utente_id, evento_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_recensioni_evento_id ON recensioni(evento_id);
CREATE INDEX ix_recensioni_utente_id ON recensioni(utente_id);

-- =========================
-- 11) Carrello + righe
-- =========================
CREATE TABLE carrelli (
                          id_carrello BIGINT AUTO_INCREMENT PRIMARY KEY,

                          utente_id BIGINT NOT NULL,
                          stato ENUM('OPEN','CHECKED_OUT','ABANDONED') NOT NULL DEFAULT 'OPEN',

                          created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                          CONSTRAINT fk_carrelli_utente
                              FOREIGN KEY (utente_id) REFERENCES utenti(id_utente)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_carrelli_utente_id ON carrelli(utente_id);
CREATE INDEX ix_carrelli_stato ON carrelli(stato);

CREATE TABLE carrello_items (
                                carrello_id BIGINT NOT NULL,
                                evento_id BIGINT NOT NULL,

                                quantita INT NOT NULL DEFAULT 1,
                                prezzo_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,

                                PRIMARY KEY (carrello_id, evento_id),

                                CONSTRAINT fk_carrello_items_carrello
                                    FOREIGN KEY (carrello_id) REFERENCES carrelli(id_carrello)
                                        ON DELETE CASCADE
                                        ON UPDATE CASCADE,

                                CONSTRAINT fk_carrello_items_evento
                                    FOREIGN KEY (evento_id) REFERENCES eventi(id_evento)
                                        ON DELETE RESTRICT
                                        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_carrello_items_evento_id ON carrello_items(evento_id);
