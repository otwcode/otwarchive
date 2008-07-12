
/* Fake CRC32 */

CREATE OR REPLACE FUNCTION crc32(text)
RETURNS bigint AS $$
  DECLARE
    tmp bigint;
  BEGIN
    tmp = (hex_to_int(SUBSTRING(MD5($1) FROM 1 FOR 8))::bigint);
    IF tmp < 0 THEN
      tmp = 4294967296 + tmp;
    END IF;
    return tmp;
  END
$$ IMMUTABLE STRICT LANGUAGE plpgsql;
