CREATE TABLE IF NOT EXISTS marketing.marketing_qualified_leads (
    mql_id TEXT PRIMARY KEY,
    first_contact_date DATE,
    landing_page_id TEXT,
    origin TEXT
);
