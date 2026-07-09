{% macro copy_into_snowflake_walmart_stores(table_nm, stage_nm) %}

--Delete the data from the copy table before running the copy command
delete from {{var ('target_db') }}.{{var ('target_schema')}}.{{ table_nm }};

--Copy the data from the snowflake external stage to snowflake table
COPY INTO {{var ('target_db') }}.{{var ('target_schema')}}.{{ table_nm }}
FROM (
    SELECT 
    $1, $2, $3,
    CURRENT_TIMESTAMP AS INSERT_DTS
    FROM @{{ stage_nm }}
)
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')


{% endmacro %}


