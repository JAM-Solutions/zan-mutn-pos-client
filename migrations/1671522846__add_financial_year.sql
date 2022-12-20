CREATE TABLE IF NOT EXISTS financial_years (
    id INTEGER PRIMARY KEY,
    uuid VARCHAR(200) NOT NULL,
    name VARCHAR(50) NOT NULL,
    startDate VARCHAR(20) NOT NULL,
    endDate VARCHAR(20) NOT NULL,
    isCurrent BOOLEAN NOT NULL,
    lastUpdate VARCHAR(20) NOT NULL,
    UNIQUE(name),
    UNIQUE(isCurrent),
    UNIQUE(uuid)
)
