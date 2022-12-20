CREATE TABLE IF NOT EXISTS revenue_sources (
    id INTEGER PRIMARY KEY,
    uuid VARCHAR(200) NOT NULL,
    name VARCHAR(200) NOT NULL,
    gfsCode VARCHAR(100) NOT NULL,
    isMiscellaneous BOOLEAN NOT NULL,
    isActive BOOLEAN NOT NULL,
    lastUpdate VARCHAR(20) NOT NULL,
    UNIQUE(name),
    UNIQUE(gfsCode),
    UNIQUE(uuid)
)
