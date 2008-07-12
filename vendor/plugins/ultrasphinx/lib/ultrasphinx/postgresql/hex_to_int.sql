
CREATE OR REPLACE FUNCTION hex_to_int(varchar) RETURNS int4 AS '
  DECLARE
    h alias for $1;
    exec varchar;
    curs refcursor;
    res int;
  BEGIN
    exec := ''SELECT x'''''' || h || ''''''::int4'';
    OPEN curs FOR EXECUTE exec;
    FETCH curs INTO res;
    CLOSE curs;
    return res;
  END;'
LANGUAGE 'plpgsql' IMMUTABLE STRICT;
