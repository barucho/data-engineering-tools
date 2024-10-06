



```sql

SELECT DISTINCT
    CONCAT('SELECT * FROM ',
    db,'.',tb,' ORDER BY ',ndxcollist,';') SelectQueryToLoadCache
FROM (
    SELECT
        engine,table_schema db,table_name tb,index_name,
        GROUP_CONCAT(column_name ORDER BY seq_in_index) ndxcollist
    FROM (
        SELECT
            B.engine,A.table_schema,A.table_name,
            A.index_name,A.column_name,A.seq_in_index
        FROM
            information_schema.statistics A INNER JOIN
            (SELECT engine,table_schema,table_name
            FROM information_schema.tables
            WHERE engine = 'InnoDB') B
            USING (table_schema,table_name)
        WHERE
            B.table_schema NOT IN ('information_schema','mysql')
            AND A.index_type <> 'FULLTEXT'
        ORDER BY
            table_schema,table_name,index_name,seq_in_index
        ) A
    GROUP BY
        table_schema,table_name,index_name
) AA
ORDER BY
    engine DESC,db,tb
;

```