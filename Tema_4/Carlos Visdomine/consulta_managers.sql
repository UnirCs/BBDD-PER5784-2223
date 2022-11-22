EXPLAIN PLAN FOR
SELECT /*+ PARALLEL(3) */ empl.first_name as Nombre from employees empl where empl.EMPLOYEE_ID in (select depa.manager_id from departments depa WHERE depa.location_id in (select loc.location_id from locations loc where loc.COUNTRY_ID in
(select coun.country_id from countries coun where coun.country_name in ('Argentina','Germany','France','Switzerland'))));

select * from table(dbms_xplan.display);