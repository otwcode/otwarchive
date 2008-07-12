
/* http://osdir.com/ml/db.postgresql.admIN/2003-08/msg00057.html */

CREATE OR REPLACE FUNCTION MAKE_CONCAT_WS() RETURNS text AS '
declare
  v_args int := 32;
  v_first text := ''CREATE OR REPLACE FUNCTION CONCAT_WS(text,text,text) RETURNS text AS ''''SELECT CASE WHEN $1 IS NULL THEN NULL WHEN $3 IS NULL THEN $2 ELSE $2 || $1 || $3 END'''' LANGUAGE sql IMMUTABLE'';
  v_part1 text := ''CREATE OR REPLACE FUNCTION CONCAT_WS(text,text'';
  v_part2 text := '') RETURNS text AS ''''SELECT CONCAT_WS($1,CONCAT_WS($1,$2'';
  v_part3 text := '')'''' LANGUAGE sql IMMUTABLE'';  
  v_sql text;
  
BEGIN
  EXECUTE v_first;
  FOR i IN 4 .. v_args loop
    v_sql := v_part1;
    FOR j IN 3 .. i loop
      v_sql := v_sql || '',text'';
    END loop;

    v_sql := v_sql || v_part2;

    FOR j IN 3 .. i - 1 loop
      v_sql := v_sql || '',$'' || j::text;
    END loop;
    v_sql := v_sql || ''),$'' || i::text;

    v_sql := v_sql || v_part3;
    EXECUTE v_sql;
  END loop;
  RETURN ''OK'';
END;
' LANGUAGE 'plpgsql';

SELECT MAKE_CONCAT_WS();
