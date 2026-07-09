{{
config
(
materialized = "incremental",
incremental_strategy = "append",
pre_hook = "{{ copy_into_snowflake_walmart_stores('stores_cp','WALMART_PROJECT.PUBLIC.STORES_STAGE') }}",
schema = "RAW"
)
}}

{% if is_incremental() %}
    {%- set max_date_query -%}
        SELECT COALESCE(MAX(INSERT_DTS), '1900-01-01'::TIMESTAMP) FROM {{ this }}
    {%- endset -%}

    {%- set max_date = run_query(max_date_query).columns[0][0] -%}
{% endif %}

WITH copy AS
(
SELECT 
*
FROM {{source('raw_copies','stores_cp')}}
{% if is_incremental() %}
WHERE INSERT_DTS > '{{ max_date }}'
{% endif %}
)

SELECT
*
FROM copy




