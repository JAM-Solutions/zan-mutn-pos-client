CREATE TABLE IF NOT EXISTS currencies (
    id INTEGER PRIMARY KEY,
    uuid VARCHAR(200) NOT NULL,
    name VARCHAR(200) NOT NULL,
    code VARCHAR(100),
    isDefault BIT,
    UNIQUE(name),
    UNIQUE(code),
    UNIQUE(uuid)
)
