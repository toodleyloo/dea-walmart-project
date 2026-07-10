{{
  config(
    materialized = "incremental",
    incremental_strategy = "merge",
    unique_key = "Store_Date",
    merge_exclude_columns = ["insert_date", "date_id"],
    schema = "PROJECTASSIGNMENT"
  )
}}

with all_dates as (
    select store_date, isholiday, insert_date, update_date from {{ ref('fact_transform') }}
    union all
    select store_date, isholiday, insert_date, update_date from {{ ref('department_transform') }}
),

ranked as (
    select
        store_date,
        isholiday,
        insert_date,
        update_date,
        row_number() over (partition by store_date order by update_date desc) as rn
    from all_dates
    {% if is_incremental() %}
    where update_date > (select max(update_date) from {{ this }})
    {% endif %}
),

new_rows as (
    select store_date, isholiday, insert_date, update_date
    from ranked
    where rn = 1
)

select
    {% if is_incremental() %}
    (select coalesce(max(date_id), 0) from {{ this }}) +
    {% endif %}
    row_number() over (order by store_date) as date_id,
    store_date,
    isholiday,
    insert_date,
    update_date
from new_rows