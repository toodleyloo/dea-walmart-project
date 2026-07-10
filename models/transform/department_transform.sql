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
CAST(Dept AS INT) AS Dept_id,
CAST(Date AS DATE) AS Store_Date,
CAST(Weekly_Sales AS DECIMAL(18,2)) AS Store_Weekly_sales,
CAST(IsHoliday AS INT) AS Isholiday,
CAST(Store || '--' || Dept || '--' || Date AS STRING) AS primarykey,
CAST(INSERT_DTS AS DATETIME) AS Insert_date,
CURRENT_TIMESTAMP(6) AS Update_date
FROM {{ ref('department_raw') }}

{% if is_incremental() %}
WHERE INSERT_DTS > (SELECT MAX(Insert_date) FROM {{this}})
{% endif %}
)

SELECT
*
FROM CTE1