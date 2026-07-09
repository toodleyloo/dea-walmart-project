{{
config
(
materialized = "incremental",
incremental_strategy = "merge",
unique_key = "primarykey",
merge_exclude_columns = ["Insert_date"],
schema = "TRANSFORM"
)
}}
 
WITH CTE1 AS
(
SELECT 
CAST(Store AS INT) AS Store_id,
CAST(Type AS STRING) AS Store_type,
CAST(Size AS INT) AS Store_size,
CAST(Store AS INT) AS primarykey,
CAST(INSERT_DTS AS DATETIME) AS Insert_date,
CURRENT_TIMESTAMP(6) AS Update_date
FROM {{ ref('stores_raw') }}

{% if is_incremental() %}
WHERE INSERT_DTS > (SELECT MAX(Insert_date) FROM {{this}})
{% endif %}
)

SELECT
*
FROM CTE1