CREATE TABLE IF NOT EXISTS pos_configurations (
    id INTEGER PRIMARY KEY,
    uuid VARCHAR(200) NOT NULL,
    offlineLimit double precision NOT NULL,
    amountLimit double precision NOT NULL,
    posDeviceId integer NOT NULL,
    posDeviceName VARCHAR(200) NOT NULL,
    UNIQUE(posDeviceId),
    UNIQUE(uuid)
)