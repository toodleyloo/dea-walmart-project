{{
config
(
materialized = "incremental",
incremental_strategy = "merge",
unique_key = "primarykey",
merge_exclude_columns = ["INSERT_DTS"],
schema = "TRANSFORM"
)
}}
 
WITH CTE1 AS
(
SELECT 
CAST(Store AS INT) AS Store_id,
CAST(Dept AS INT) AS Dept_id,
CAST(Date AS DATE) AS Date_id,
CAST(Weekly_Sales AS DECIMAL(18,2)) AS Store_Weekly_sales,
CAST(IsHoliday AS BOOLEAN) AS Isholiday,
CAST(Store || '-' || Dept || '-' || Date AS STRING) AS primarykey,
CAST(INSERT_DTS AS DATETIME) AS INSERT_DTS,
CURRENT_TIMESTAMP(6) AS UPDATE_DTS
FROM {{ ref('department_raw') }}

{% if is_incremental() %}
WHERE INSERT_DTS > (SELECT MAX(INSERT_DTS) FROM {{this}})
{% endif %}
)

SELECT
*
FROM CTE1