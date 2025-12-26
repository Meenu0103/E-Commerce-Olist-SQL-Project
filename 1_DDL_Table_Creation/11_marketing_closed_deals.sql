CREATE TABLE IF NOT EXISTS marketing.marketing_closed_deals (
    mql_id TEXT,
    seller_id TEXT,
    sdr_id TEXT,
    sr_id TEXT,
    won_date DATE,
    business_segment TEXT,
    business_type TEXT,
    lead_type TEXT,
    lead_behaviour_profile TEXT,
    has_company BOOLEAN,
    has_gtin BOOLEAN,
    average_stock TEXT,
    declared_product_catalog_size NUMERIC,
    declared_monthly_revenue NUMERIC
);
