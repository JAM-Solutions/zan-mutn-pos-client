CREATE TABLE IF NOT EXISTS pos_configurations (
    id INTEGER PRIMARY KEY,
    uuid VARCHAR(200) NOT NULL,
    offlineLimit double precision NOT NULL,
    amountLimit double precision NOT NULL,
    taxCollectorUuid VARCHAR(100) NOT NULL,
    lastUpdate VARCHAR(200) NOT NULL,
    UNIQUE(taxCollectorUuid),
    UNIQUE(uuid)
)
