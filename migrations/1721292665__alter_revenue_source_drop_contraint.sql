CREATE TABLE IF NOT EXISTS tmp_revenue_sources (
    id INTEGER,
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
    UNIQUE(name, taxCollectorUuid)
);

INSERT INTO tmp_revenue_sources (
    id,uuid,name,taxCollectorUuid,gfsCode,isMiscellaneous,isActive,penalty,penaltyMode,
    unitCost,minimumAmount,maximumAmount,unitName,lastUpdate)
SELECT
    id,uuid,name,taxCollectorUuid,gfsCode,isMiscellaneous,isActive,penalty,penaltyMode,
     unitCost,minimumAmount,maximumAmount,unitName,lastUpdate
FROM revenue_sources;

DROP TABLE revenue_sources;

ALTER TABLE tmp_revenue_sources RENAME TO revenue_sources;
