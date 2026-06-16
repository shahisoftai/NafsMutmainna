-- =============================================================================
-- Heart OS v1 — DDL for the 14 core tables
-- =============================================================================
-- SQLite / Drift-compatible
-- All table names use snake_case
-- All column names use PascalCase (to match the existing seed files)
-- Foreign keys are declared with ON DELETE behaviour
-- Idempotent (CREATE TABLE IF NOT EXISTS)
-- =============================================================================

PRAGMA foreign_keys = ON;

-- =============================================================================
-- LAYER 1 — KNOWLEDGE (immutable, seed once)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- emotions (50 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emotions (
    Emotion_ID                          INTEGER PRIMARY KEY,
    Core_Emotion                        TEXT    NOT NULL,
    Arabic_Name                         TEXT    NOT NULL,
    Category                            TEXT    NOT NULL CHECK (Category IN ('Negative', 'Positive')),
    Description                         TEXT    NOT NULL,
    Common_Triggers                     TEXT    NOT NULL DEFAULT '',
    Primary_Negative_Attributes         TEXT    NOT NULL DEFAULT '',
    Secondary_Negative_Attributes       TEXT    NOT NULL DEFAULT '',
    Primary_Positive_Attributes         TEXT    NOT NULL DEFAULT '',
    Growth_Path                         TEXT    NOT NULL DEFAULT '',
    Dominant_Nafs_State                 TEXT    NOT NULL CHECK (Dominant_Nafs_State IN ('Ammarah', 'Lawwamah', 'Mulhamah', 'Mutmainnah')),
    Severity_Weight                     INTEGER NOT NULL CHECK (Severity_Weight BETWEEN 1 AND 10),
    Recommended_Attribute_Priority      TEXT    NOT NULL DEFAULT '',
    Recommended_Intervention_Type       TEXT    NOT NULL DEFAULT '',
    Recommended_Dua                     TEXT    NOT NULL DEFAULT '',
    Recommended_Allah_Names             TEXT    NOT NULL DEFAULT '',
    Recommended_Dhikr                   TEXT    NOT NULL DEFAULT '',
    Daily_Action                        TEXT    NOT NULL DEFAULT '',
    Related_Emotions                    TEXT    NOT NULL DEFAULT '',
    Related_Attribute_IDs               TEXT    NOT NULL DEFAULT '',
    Keywords                            TEXT    NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_emotions_category   ON emotions(Category);
CREATE INDEX IF NOT EXISTS idx_emotions_nafs       ON emotions(Dominant_Nafs_State);
CREATE INDEX IF NOT EXISTS idx_emotions_keywords   ON emotions(Keywords);

-- -----------------------------------------------------------------------------
-- attributes (200 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes (
    Attribute_ID                        INTEGER PRIMARY KEY,
    Attribute                           TEXT    NOT NULL,
    Arabic_Name                         TEXT    NOT NULL,
    Nature                              TEXT    NOT NULL CHECK (Nature IN ('Positive', 'Negative')),
    Definition                          TEXT    NOT NULL,
    Opposite_Trait                      TEXT    NOT NULL DEFAULT '',
    Opposite_Arabic_Name                TEXT    NOT NULL DEFAULT '',
    Keywords                            TEXT    NOT NULL DEFAULT '',
    Quran_Reference                     TEXT    NOT NULL DEFAULT '',
    Quran_Arabic                        TEXT    NOT NULL DEFAULT '',
    Quran_English                       TEXT    NOT NULL DEFAULT '',
    Quran_Urdu                          TEXT    NOT NULL DEFAULT '',
    Hadith_Reference                    TEXT    NOT NULL DEFAULT '',
    Hadith_Arabic                       TEXT    NOT NULL DEFAULT '',
    Hadith_Urdu                         TEXT    NOT NULL DEFAULT '',
    Quranic_Dua_Reference               TEXT    NOT NULL DEFAULT '',
    Quranic_Dua_Arabic                  TEXT    NOT NULL DEFAULT '',
    Quranic_Dua_Urdu                    TEXT    NOT NULL DEFAULT '',
    Prophetic_Dua_Reference             TEXT    NOT NULL DEFAULT '',
    Prophetic_Dua_Arabic                TEXT    NOT NULL DEFAULT '',
    Prophetic_Dua_Urdu                  TEXT    NOT NULL DEFAULT '',
    Relevant_Allah_Names                TEXT    NOT NULL DEFAULT '',
    Practical_Understanding             TEXT    NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_attributes_nature     ON attributes(Nature);
CREATE INDEX IF NOT EXISTS idx_attributes_opposite   ON attributes(Opposite_Trait);
CREATE INDEX IF NOT EXISTS idx_attributes_keywords   ON attributes(Keywords);

-- =============================================================================
-- LAYER 2 — GRAPH (immutable, seed once)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- emotion_attribute_links (~400 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emotion_attribute_links (
    Link_ID                             INTEGER PRIMARY KEY,
    Emotion_ID                          INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Attribute_ID                        INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
    Weight                              REAL    NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    Role                                TEXT    NOT NULL CHECK (Role IN ('Disease', 'Treatment', 'Core', 'Strengthens')),
    UNIQUE (Emotion_ID, Attribute_ID, Role)
);
CREATE INDEX IF NOT EXISTS idx_eal_emotion    ON emotion_attribute_links(Emotion_ID);
CREATE INDEX IF NOT EXISTS idx_eal_attribute  ON emotion_attribute_links(Attribute_ID);
CREATE INDEX IF NOT EXISTS idx_eal_role       ON emotion_attribute_links(Emotion_ID, Role);

-- -----------------------------------------------------------------------------
-- attribute_links (~400 rows) — THE HEART GRAPH
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attribute_links (
    Link_ID                             INTEGER PRIMARY KEY,
    Source_Attribute_ID                 INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
    Target_Attribute_ID                 INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
    Weight                              REAL    NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    Relationship                        TEXT    NOT NULL CHECK (Relationship IN ('Cure', 'Leads_To', 'Strengthens', 'Opposes')),
    UNIQUE (Source_Attribute_ID, Target_Attribute_ID, Relationship),
    CHECK (Source_Attribute_ID <> Target_Attribute_ID)
);
CREATE INDEX IF NOT EXISTS idx_al_source  ON attribute_links(Source_Attribute_ID);
CREATE INDEX IF NOT EXISTS idx_al_target  ON attribute_links(Target_Attribute_ID);
CREATE INDEX IF NOT EXISTS idx_al_rel     ON attribute_links(Source_Attribute_ID, Relationship);

-- -----------------------------------------------------------------------------
-- domains (10 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS domains (
    Domain_ID                           INTEGER PRIMARY KEY,
    Domain_Name                         TEXT    NOT NULL,
    Arabic_Name                         TEXT    NOT NULL,
    Description                         TEXT    NOT NULL DEFAULT ''
);

-- -----------------------------------------------------------------------------
-- domain_attribute_links (~600 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS domain_attribute_links (
    Link_ID                             INTEGER PRIMARY KEY,
    Domain_ID                           INTEGER NOT NULL REFERENCES domains(Domain_ID),
    Attribute_ID                        INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
    Weight                              REAL    NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    UNIQUE (Domain_ID, Attribute_ID)
);
CREATE INDEX IF NOT EXISTS idx_dal_domain     ON domain_attribute_links(Domain_ID);
CREATE INDEX IF NOT EXISTS idx_dal_attribute  ON domain_attribute_links(Attribute_ID);

-- -----------------------------------------------------------------------------
-- domain_emotion_links (~200 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS domain_emotion_links (
    Link_ID                             INTEGER PRIMARY KEY,
    Domain_ID                           INTEGER NOT NULL REFERENCES domains(Domain_ID),
    Emotion_ID                          INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Weight                              REAL    NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    UNIQUE (Domain_ID, Emotion_ID)
);
CREATE INDEX IF NOT EXISTS idx_del_domain  ON domain_emotion_links(Domain_ID);
CREATE INDEX IF NOT EXISTS idx_del_emotion ON domain_emotion_links(Emotion_ID);

-- =============================================================================
-- LAYER 3 — NAFS ENGINE (immutable, seed once)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- nafs_states (4 rows)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nafs_states (
    Nafs_ID                             INTEGER PRIMARY KEY,
    Name                                TEXT    NOT NULL UNIQUE
                                                 CHECK (Name IN ('Ammarah', 'Lawwamah', 'Mulhamah', 'Mutmainnah')),
    Arabic_Name                         TEXT    NOT NULL,
    Description                         TEXT    NOT NULL DEFAULT ''
);

-- -----------------------------------------------------------------------------
-- attribute_nafs_weights (200 rows, 1:1 with attributes)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attribute_nafs_weights (
    Attribute_ID                        INTEGER PRIMARY KEY REFERENCES attributes(Attribute_ID),
    Ammarah                             REAL    NOT NULL CHECK (Ammarah             BETWEEN 0 AND 100),
    Lawwamah                            REAL    NOT NULL CHECK (Lawwamah            BETWEEN 0 AND 100),
    Mulhamah                            REAL    NOT NULL CHECK (Mulhamah            BETWEEN 0 AND 100),
    Mutmainnah                          REAL    NOT NULL CHECK (Mutmainnah          BETWEEN 0 AND 100),
    CHECK (Ammarah + Lawwamah + Mulhamah + Mutmainnah BETWEEN 95 AND 105)
);

-- -----------------------------------------------------------------------------
-- emotion_nafs_weights (50 rows, 1:1 with emotions)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emotion_nafs_weights (
    Emotion_ID                          INTEGER PRIMARY KEY REFERENCES emotions(Emotion_ID),
    Ammarah                             REAL    NOT NULL CHECK (Ammarah             BETWEEN 0 AND 100),
    Lawwamah                            REAL    NOT NULL CHECK (Lawwamah            BETWEEN 0 AND 100),
    Mulhamah                            REAL    NOT NULL CHECK (Mulhamah            BETWEEN 0 AND 100),
    Mutmainnah                          REAL    NOT NULL CHECK (Mutmainnah          BETWEEN 0 AND 100),
    CHECK (Ammarah + Lawwamah + Mulhamah + Mutmainnah BETWEEN 95 AND 105)
);

-- =============================================================================
-- LAYER 4 — USER (mutable, the only layer that changes at runtime)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- checkins (1 per day per emotion)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS checkins (
    Checkin_ID                          INTEGER PRIMARY KEY AUTOINCREMENT,
    Date                                DATE    NOT NULL,
    Emotion_ID                          INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Intensity                           INTEGER NOT NULL DEFAULT 5
                                                 CHECK (Intensity BETWEEN 0 AND 10),
    Notes                               TEXT    NOT NULL DEFAULT '',
    UNIQUE (Date, Emotion_ID)
);
CREATE INDEX IF NOT EXISTS idx_checkins_date ON checkins(Date);

-- -----------------------------------------------------------------------------
-- detected_attributes (1–10 per day)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS detected_attributes (
    Record_ID                           INTEGER PRIMARY KEY AUTOINCREMENT,
    Date                                DATE    NOT NULL,
    Attribute_ID                        INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
    Score                               REAL    NOT NULL CHECK (Score BETWEEN 0.0 AND 1.0),
    UNIQUE (Date, Attribute_ID)
);
CREATE INDEX IF NOT EXISTS idx_da_date       ON detected_attributes(Date);
CREATE INDEX IF NOT EXISTS idx_da_attribute  ON detected_attributes(Attribute_ID);

-- -----------------------------------------------------------------------------
-- interventions_history (1 per recommendation shown)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS interventions_history (
    Record_ID                           INTEGER PRIMARY KEY AUTOINCREMENT,
    Date                                DATE    NOT NULL,
    Emotion_ID                          INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Attribute_ID                        INTEGER     DEFAULT NULL REFERENCES attributes(Attribute_ID),
    Intervention_Type                   TEXT    NOT NULL
                                                  CHECK (Intervention_Type IN ('Quran', 'Hadith', 'Dua', 'Allah_Names', 'Dhikr', 'Action')),
    Completed                           INTEGER NOT NULL DEFAULT 0 CHECK (Completed IN (0, 1)),
    Feedback                             TEXT    DEFAULT NULL
);
CREATE INDEX IF NOT EXISTS idx_ih_date         ON interventions_history(Date);
CREATE INDEX IF NOT EXISTS idx_ih_emotion      ON interventions_history(Emotion_ID);
CREATE INDEX IF NOT EXISTS idx_ih_attribute    ON interventions_history(Attribute_ID);
CREATE INDEX IF NOT EXISTS idx_ih_completed    ON interventions_history(Date, Completed);

-- -----------------------------------------------------------------------------
-- nafs_history (1 per day — the daily Nafs snapshot)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nafs_history (
    Record_ID                           INTEGER PRIMARY KEY AUTOINCREMENT,
    Date                                DATE    NOT NULL UNIQUE,
    Ammarah                             REAL    NOT NULL,
    Lawwamah                            REAL    NOT NULL,
    Mulhamah                            REAL    NOT NULL,
    Mutmainnah                          REAL    NOT NULL,
    CHECK (Ammarah + Lawwamah + Mulhamah + Mutmainnah BETWEEN 0.99 AND 1.01)
);
CREATE INDEX IF NOT EXISTS idx_nh_date ON nafs_history(Date);

-- -----------------------------------------------------------------------------
-- habits (user-defined, 0–10 per user)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS habits (
    Habit_ID                            INTEGER PRIMARY KEY AUTOINCREMENT,
    Name                                TEXT    NOT NULL,
    Category                            TEXT    NOT NULL
                                                 CHECK (Category IN ('Prayer', 'Quran', 'Dhikr', 'Charity', 'Exercise', 'Other')),
    UNIQUE (Name)
);

-- -----------------------------------------------------------------------------
-- habit_logs (1 per day per habit)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS habit_logs (
    Record_ID                           INTEGER PRIMARY KEY AUTOINCREMENT,
    Date                                DATE    NOT NULL,
    Habit_ID                            INTEGER NOT NULL REFERENCES habits(Habit_ID) ON DELETE CASCADE,
    Completed                           INTEGER NOT NULL DEFAULT 0 CHECK (Completed IN (0, 1)),
    UNIQUE (Date, Habit_ID)
);
CREATE INDEX IF NOT EXISTS idx_hl_date    ON habit_logs(Date);
CREATE INDEX IF NOT EXISTS idx_hl_habit   ON habit_logs(Habit_ID);

-- =============================================================================
-- TRIGGERS — keep the pipeline consistent
-- =============================================================================

-- When a checkin is inserted, recompute detected_attributes for that day+emotion
CREATE TRIGGER IF NOT EXISTS trg_checkin_insert
AFTER INSERT ON checkins
BEGIN
    INSERT INTO detected_attributes (Date, Attribute_ID, Score)
    SELECT NEW.Date,
           eal.Attribute_ID,
           eal.Weight * (NEW.Intensity / 10.0)
    FROM emotion_attribute_links eal
    WHERE eal.Emotion_ID = NEW.Emotion_ID
    ON CONFLICT (Date, Attribute_ID) DO UPDATE
    SET Score = MIN(1.0, detected_attributes.Score + excluded.Score);
END;

-- When a checkin is deleted, recompute detected_attributes for that day+emotion
CREATE TRIGGER IF NOT EXISTS trg_checkin_delete
AFTER DELETE ON checkins
BEGIN
    DELETE FROM detected_attributes
    WHERE Date = OLD.Date
      AND Attribute_ID IN (
          SELECT Attribute_ID FROM emotion_attribute_links
          WHERE Emotion_ID = OLD.Emotion_ID
      );
    -- Then re-insert from remaining checkins for that day
    INSERT INTO detected_attributes (Date, Attribute_ID, Score)
    SELECT OLD.Date,
           eal.Attribute_ID,
           eal.Weight * (c.Intensity / 10.0)
    FROM checkins c
    JOIN emotion_attribute_links eal ON eal.Emotion_ID = c.Emotion_ID
    WHERE c.Date = OLD.Date
    ON CONFLICT (Date, Attribute_ID) DO UPDATE
    SET Score = MIN(1.0, detected_attributes.Score + excluded.Score);
END;

-- =============================================================================
-- VIEWS — convenience queries
-- =============================================================================

-- The 15-day meter
CREATE VIEW IF NOT EXISTS v_meter_15day AS
WITH recent AS (
    SELECT Ammarah, Lawwamah, Mulhamah, Mutmainnah,
           CAST(julianday('now') - julianday(Date) AS REAL) AS days_ago
    FROM nafs_history
    WHERE Date >= date('now', '-15 day')
)
SELECT
    SUM(Ammarah    * (1.0 - days_ago * 0.8 / 14)) / SUM(1.0 - days_ago * 0.8 / 14) AS Ammarah,
    SUM(Lawwamah   * (1.0 - days_ago * 0.8 / 14)) / SUM(1.0 - days_ago * 0.8 / 14) AS Lawwamah,
    SUM(Mulhamah   * (1.0 - days_ago * 0.8 / 14)) / SUM(1.0 - days_ago * 0.8 / 14) AS Mulhamah,
    SUM(Mutmainnah * (1.0 - days_ago * 0.8 / 14)) / SUM(1.0 - days_ago * 0.8 / 14) AS Mutmainnah
FROM recent;

-- Top detected attributes for a given date
CREATE VIEW IF NOT EXISTS v_top_attributes_today AS
SELECT a.Attribute_ID, a.Attribute, a.Nature, da.Score
FROM detected_attributes da
JOIN attributes a ON a.Attribute_ID = da.Attribute_ID
WHERE da.Date = date('now')
ORDER BY da.Score DESC;

-- =============================================================================
-- LAYER 1 — KNOWLEDGE EXTENSION: HADEES & QURAN (immutable, seed once)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- hadees (~250 authentic hadees)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hadees (
    Hadees_ID                             INTEGER PRIMARY KEY,
    Arabic_Text                           TEXT    NOT NULL,
    English_Translation                   TEXT    NOT NULL,
    Urdu_Translation                      TEXT    NOT NULL,
    Source_Book                          TEXT    NOT NULL,
    Hadith_Number                        TEXT    NOT NULL,
    Grade                               TEXT    NOT NULL CHECK (Grade IN ('Sahih', 'Hasan', 'Hasan li-ghayrihi'))
);
CREATE INDEX IF NOT EXISTS idx_hadees_source ON hadees(Source_Book);
CREATE INDEX IF NOT EXISTS idx_hadees_grade ON hadees(Grade);

-- -----------------------------------------------------------------------------
-- quran_ayat (~250 authentic verses)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quran_ayat (
    Ayat_ID                               INTEGER PRIMARY KEY,
    Arabic_Text                           TEXT    NOT NULL,
    English_Translation                   TEXT    NOT NULL,
    Urdu_Translation                      TEXT    NOT NULL,
    Surah_Name                           TEXT    NOT NULL,
    Verse_Number                         INTEGER NOT NULL,
    Full_Reference                       TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_quran_surah ON quran_ayat(Surah_Name);

-- -----------------------------------------------------------------------------
-- emotion_hadees_links (~250 links, 3-7 per emotion)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emotion_hadees_links (
    Link_ID                               INTEGER PRIMARY KEY,
    Emotion_ID                             INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Hadees_ID                            INTEGER NOT NULL REFERENCES hadees(Hadees_ID),
    Weight                               REAL    NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    UNIQUE (Emotion_ID, Hadees_ID)
);
CREATE INDEX IF NOT EXISTS idx_ehl_emotion ON emotion_hadees_links(Emotion_ID);
CREATE INDEX IF NOT EXISTS idx_ehl_hadees ON emotion_hadees_links(Hadees_ID);

-- -----------------------------------------------------------------------------
-- emotion_quran_links (~250 links, 3-7 per emotion)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emotion_quran_links (
    Link_ID                               INTEGER PRIMARY KEY,
    Emotion_ID                             INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Ayat_ID                              INTEGER NOT NULL REFERENCES quran_ayat(Ayat_ID),
    Weight                               REAL    NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    UNIQUE (Emotion_ID, Ayat_ID)
);
CREATE INDEX IF NOT EXISTS idx_eql_emotion ON emotion_quran_links(Emotion_ID);
CREATE INDEX IF NOT EXISTS idx_eql_ayat ON emotion_quran_links(Ayat_ID);

-- =============================================================================
-- interventions_history EXTENSION (session-level tracking for randomization)
-- =============================================================================

ALTER TABLE interventions_history ADD COLUMN Session_ID TEXT NOT NULL DEFAULT '';
ALTER TABLE interventions_history ADD COLUMN Hadees_ID INTEGER REFERENCES hadees(Hadees_ID);
ALTER TABLE interventions_history ADD COLUMN Ayat_ID INTEGER REFERENCES quran_ayat(Ayat_ID);

CREATE INDEX IF NOT EXISTS idx_ih_session ON interventions_history(Session_ID);
CREATE INDEX IF NOT EXISTS idx_ih_hadees ON interventions_history(Hadees_ID);
CREATE INDEX IF NOT EXISTS idx_ih_ayat ON interventions_history(Ayat_ID);

-- =============================================================================
-- SEED ORDER (the application must follow this order on first launch)
-- =============================================================================
-- 1. nafs_states (no dependencies)
-- 2. emotions (no dependencies)
-- 3. attributes (no dependencies)
-- 4. domains (no dependencies)
-- 5. emotion_nafs_weights (depends on emotions)
-- 6. attribute_nafs_weights (depends on attributes)
-- 7. emotion_attribute_links (depends on emotions, attributes)
-- 8. attribute_links (depends on attributes)
-- 9. domain_attribute_links (depends on domains, attributes)
-- 10. domain_emotion_links (depends on domains, emotions)
-- 11. hadees (no dependencies)
-- 12. quran_ayat (no dependencies)
-- 13. emotion_hadees_links (depends on emotions, hadees)
-- 14. emotion_quran_links (depends on emotions, quran_ayat)
-- =============================================================================
