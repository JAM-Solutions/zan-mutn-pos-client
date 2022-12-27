CREATE TABLE IF NOT EXISTS pos_transactions (
    id INTEGER PRIMARY KEY,
    trxNumber VARCHAR(100) NOT NULL,
    posDeviceId INTEGER NOT NULL,
    revenueSourceId INTEGER NOT NULL,
    gfsCode VARCHAR(100) NOT NULL,
    adminHierarchyId INTEGER NOT NULL,
    financialYearId INTEGER NOT NULL,
    amount DECIMAL NOT NULL,
    quantity INTEGER NOT NULL,
    taxPayerId INTEGER NOT NULL,
    cashPayerName VARCHAR(100),
    cashPayerAddress VARCHAR(100),
    receiptNumber VARCHAR(100) NOT NULL,
    transactionDate TIMESTAMP NOT NULL,
    isPrinted BOOLEAN NOT NULL,
    printError  VARCHAR(200)
)
