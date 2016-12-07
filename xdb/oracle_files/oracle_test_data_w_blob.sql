GRANT CREATE ANY TRIGGER TO system;
GRANT RESOURCE TO system;

create table test_data 
( 
 id number NOT NULL PRIMARY KEY, 
 logo blob,
 first_name varchar2(16), 
 last_name varchar2(24), 
 amount number(6,2), 
 modify_date date
 );

-- ### Funtion for generating data ###
-- CREATE OR REPLACE FUNCTION CONCAT_BLOB(A IN BLOB, B IN BLOB) RETURN BLOB IS
-- C BLOB;
-- BEGIN
-- dbms_lob.createtemporary(c, TRUE);
-- DBMS_LOB.APPEND(c, A);
-- DBMS_LOB.APPEND(c, B);
-- RETURN c;
-- END;
-- 
-- exec dbms_random.seed(42);
-- 
-- declare
-- v_clob        clob;
-- v_blob        blob;
-- v_dest_offset integer := 1;
-- v_src_offset  integer := 1;
-- v_warn        integer;
-- v_ctx         integer := dbms_lob.default_lang_ctx;
-- begin
-- for idx in 1..5
-- loop
-- v_clob := v_clob || dbms_random.string('x', 20000);
-- end loop;
-- dbms_lob.createtemporary( v_blob, false );
-- dbms_lob.converttoblob(v_blob,
--     v_clob,
--     dbms_lob.lobmaxsize,
--     v_dest_offset,
--     v_src_offset,
--     dbms_lob.default_csid,
--     v_ctx,
--     v_warn);
-- 
-- insert into test_data (id, logo, first_name, last_name, amount, modify_date)
--   select rownum+10000, v_blob,
--   initcap(dbms_random.string('l',dbms_random.value(2,16))), 
--   initcap(dbms_random.string('l',dbms_random.value(2,24))), 
--   round(dbms_random.value(1,1000),2), 
--   to_date('01-JAN-2008', 'DD-MON-YYYY') + dbms_random.value(-100,100)
--   from dual
--   connect by level <=10;
--   end;
-- /
