GRANT CREATE ANY TRIGGER TO system;
GRANT RESOURCE TO system;

create table test_data 
( 
  id number NOT NULL PRIMARY KEY, 
  first_name varchar2(16), 
  last_name varchar2(24), 
  amount number(6,2), 
  purchase_date date
);

exec dbms_random.seed(42);

insert into test_data 
select 
  rownum, 
  initcap(dbms_random.string('l',dbms_random.value(2,16))), 
  initcap(dbms_random.string('l',dbms_random.value(2,24))), 
  round(dbms_random.value(1,1000),2), 
  to_date('01-JAN-2008', 'DD-MON-YYYY') + dbms_random.value(-100,100) 
from 
  (select level from dual connect by level <= 10000);
