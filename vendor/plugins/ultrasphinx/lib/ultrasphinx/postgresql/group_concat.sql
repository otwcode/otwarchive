
/* 
 mysqlcompat-1.0b3
 public domain
 GROUP_CONCAT()
 Note: For DISTINCT and ORDER BY a subquery is required
*/

CREATE OR REPLACE FUNCTION _group_concat(text, text)
RETURNS text AS $$
  SELECT CASE
    WHEN $2 IS NULL THEN $1
    WHEN $1 IS NULL THEN $2
    ELSE $1 operator(pg_catalog.||) ' ' operator(pg_catalog.||) $2
  END
$$ IMMUTABLE LANGUAGE SQL;

DROP AGGREGATE IF EXISTS group_concat(text);

CREATE AGGREGATE group_concat (
	BASETYPE = text,
	SFUNC = _group_concat,
	STYPE = text
);

