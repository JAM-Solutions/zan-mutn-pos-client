CREATE TABLE IF NOT EXISTS revenue_sources (
    id INTEGER PRIMARY KEY,
    uuid VARCHAR(200) NOT NULL,
    name VARCHAR(200) NOT NULL,
    taxCollectorUuid VARCHAR(100) NOT NULL,
    gfsCode VARCHAR(100) NOT NULL,
    isMiscellaneous BOOLEAN NOT NULL,
    isActive BOOLEAN NOT NULL,
    penalty BOOLEAN,
    penaltyMode VARCHAR(100),
    unitCost DECIMAL,
    minimumAmount DECIMAL,
    maximumAmount DECIMAL,
    unitName VARCHAR(100),
    lastUpdate VARCHAR(20) NOT NULL,
    UNIQUE(name),
    UNIQUE(gfsCode),
    UNIQUE(uuid)
);
