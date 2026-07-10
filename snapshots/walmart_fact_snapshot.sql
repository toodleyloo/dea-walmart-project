{% snapshot walmart_fact_snapshot %}
{{
  config(
    target_schema = 'SNAPSHOT',
    unique_key = 'primarykey',
    strategy = 'check',
    check_cols = [
      'store_weekly_sales','fuel_price','store_temperature',
      'unemployement','cpi','markdown1','markdown2',
      'markdown3','markdown4','markdown5'
    ]
  )
}}

select
    dep.store_id,
    dep.dept_id,
    dd.date_id,                         
    dep.store_weekly_sales,
    f.fuel_price,
    f.store_temperature,
    f.unemployement,                     -- keeping the doc's spelling
    f.cpi,
    f.markdown1, f.markdown2, f.markdown3, f.markdown4, f.markdown5,
    dep.primarykey,                       -- store--dept--date
    least(dep.insert_date, coalesce(f.insert_date, dep.insert_date)) as insert_date,
    greatest(dep.update_date, coalesce(f.update_date, dep.update_date)) as update_date
from {{ ref('department_transform') }} dep
left join {{ ref('fact_transform') }} f
    on  dep.store_id   = f.store_id
    and dep.store_date = f.store_date
inner join {{ ref('walmart_date_dim') }} dd    -- inner: never snapshot a NULL date_id
    on dep.store_date = dd.store_date
{% endsnapshot %}