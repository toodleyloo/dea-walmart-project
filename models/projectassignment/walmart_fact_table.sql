{{ config(materialized = "table", schema = "PROJECTASSIGNMENT") }}

select
    store_id,
    dept_id,
    date_id,
    store_weekly_sales,
    fuel_price,
    store_temperature,
    unemployement,
    cpi,
    markdown1, markdown2, markdown3, markdown4, markdown5,
    insert_date,
    update_date,
    dbt_valid_from as vrsn_start_date,
    dbt_valid_to   as vrsn_end_date     -- NULL = current version
from {{ ref('walmart_fact_snapshot') }}