{{
  config(
    materialized = "incremental",
    incremental_strategy = "merge",
    unique_key = "primarykey",
    merge_exclude_columns = ["insert_date"],
    schema = "PROJECTASSIGNMENT"
  )
}}

with ranked1 as (
    select
        store_id,
        dept_id,
        insert_date,
        update_date,
        row_number() over (partition by store_id, dept_id order by update_date desc) as rn
    from {{ ref('department_transform') }}
),

latest_rows1 as (
    select store_id, dept_id, insert_date, update_date, cast(store_id || '--' || dept_id as string) as primarykey
    from ranked1
    where rn = 1
),

ranked2 as (
    select
        store_id,
        store_type,
        store_size,
        insert_date,
        update_date,
        row_number() over (partition by store_id, store_type order by update_date desc) as rn
    from {{ ref('stores_transform') }}
),

latest_rows2 as (
    select store_id, store_type, store_size, insert_date, update_date
    from ranked2
    where rn = 1
),

working1 as (
    select
        latest_rows1.store_id,
        latest_rows1.dept_id,
        latest_rows1.primarykey,
        latest_rows2.store_type,
        latest_rows2.store_size,
        least(latest_rows1.insert_date, coalesce(latest_rows2.insert_date, latest_rows1.insert_date)) as insert_date,
        greatest(latest_rows1.update_date, coalesce(latest_rows2.update_date, latest_rows1.update_date)) as update_date
    from latest_rows1
    left join latest_rows2
        on latest_rows1.store_id=latest_rows2.store_id
)
    
select * from working1
    {% if is_incremental() %}
    where update_date > (select max(update_date) from {{ this }})
    {% endif %}







