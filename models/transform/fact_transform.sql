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
CAST(Date AS DATE) AS Date_id,
CAST(Temperature AS DECIMAL(18,2)) AS Store_temperature,
CAST(Fuel_Price AS DECIMAL(18,3)) AS Fuel_price,
CAST(MarkDown1 AS DECIMAL(18,2)) AS Markdown1,
CAST(MarkDown2 AS DECIMAL(18,2)) AS Markdown2,
CAST(MarkDown3 AS DECIMAL(18,2)) AS Markdown3,
CAST(MarkDown4 AS DECIMAL(18,2)) AS Markdown4,
CAST(MarkDown5 AS DECIMAL(18,2)) AS Markdown5,
CAST(CPI AS DECIMAL(18,7)) AS CPI,
CAST(Unemployment AS DECIMAL(18,3)) AS Unemployement,
CAST(IsHoliday AS BOOLEAN) AS Isholiday,
CAST(Store || '--' || Date AS STRING) AS primarykey,
CAST(INSERT_DTS AS DATETIME) AS Insert_date,
CURRENT_TIMESTAMP(6) AS Update_date
FROM {{ ref('fact_raw') }}

{% if is_incremental() %}
WHERE INSERT_DTS > (SELECT MAX(Insert_date) FROM {{this}})
{% endif %}
)

SELECT
*
FROM CTE1