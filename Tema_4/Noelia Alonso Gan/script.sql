-- Punto 1: Establecer un grado de paralelismo (DoP) de nivel 3 para todas las tablas del Schema HR.
ALTER TABLE COUNTRIES PARALLEL 3;
ALTER TABLE DEPARTMENTS PARALLEL 3;
ALTER TABLE EMPLOYEES PARALLEL 3;
ALTER TABLE JOB_HISTORY PARALLEL 3;
ALTER TABLE JOBS PARALLEL 3;
ALTER TABLE LOCATIONS PARALLEL 3;
ALTER TABLE REGIONS PARALLEL 3;

-------------------------------------------------------------------------------------------------
-- Punto 2.1: Obtener el nombre de los managers de los empleados argentinos, alemanes, franceses o suizos.
EXPLAIN PLAN FOR
SELECT /*parallel(employees, 3)*/ employees.first_name
FROM employees
JOIN departments  ON employees.department_id = departments.department_id
JOIN locations ON departments.location_id = locations.location_id
JOIN countries ON locations.country_id = countries.country_id
WHERE countries.country_name IN ('Argentina', 'Germany', 'France', 'Switzerland') and departments.manager_id = employees.employee_id;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Resultado consulta:
-- Plan hash value: 2700848371
 
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                                | Name              | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                         |                   |     3 |   126 |     3   (0)| 00:00:01 |        |      |            |
-- |   1 |  PX COORDINATOR                          |                   |       |       |            |          |        |      |            |
-- |   2 |   PX SEND QC (RANDOM)                    | :TQ10000          |     3 |   126 |     3   (0)| 00:00:01 |  Q1,00 | P->S | QC (RAND)  |
-- |   3 |    NESTED LOOPS                          |                   |     3 |   126 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |   4 |     NESTED LOOPS                         |                   |    30 |   126 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |   5 |      NESTED LOOPS                        |                   |     3 |    84 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |   6 |       NESTED LOOPS                       |                   |     7 |   126 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |   7 |        PX BLOCK ITERATOR                 |                   |       |       |            |          |  Q1,00 | PCWC |            |
-- |   8 |         TABLE ACCESS FULL                | LOCATIONS         |    23 |   138 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |*  9 |        INDEX UNIQUE SCAN                 | COUNTRY_C_ID_PK   |     1 |    12 |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |* 10 |       TABLE ACCESS BY INDEX ROWID BATCHED| DEPARTMENTS       |     1 |    10 |     1   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |* 11 |        INDEX RANGE SCAN                  | DEPT_LOCATION_IX  |     4 |       |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |* 12 |      INDEX RANGE SCAN                    | EMP_DEPARTMENT_IX |    10 |       |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |* 13 |     TABLE ACCESS BY INDEX ROWID          | EMPLOYEES         |     1 |    14 |     1   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- -------------------------------------------------------------------------------------------------------------------------------------------
 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
 
--    9 - access("LOCATIONS"."COUNTRY_ID"="COUNTRIES"."COUNTRY_ID")
--        filter("COUNTRIES"."COUNTRY_NAME"='Argentina' OR "COUNTRIES"."COUNTRY_NAME"='France' OR 
--               "COUNTRIES"."COUNTRY_NAME"='Germany' OR "COUNTRIES"."COUNTRY_NAME"='Switzerland')
--   10 - filter("DEPARTMENTS"."MANAGER_ID" IS NOT NULL)
--   11 - access("DEPARTMENTS"."LOCATION_ID"="LOCATIONS"."LOCATION_ID")
--   12 - access("EMPLOYEES"."DEPARTMENT_ID"="DEPARTMENTS"."DEPARTMENT_ID")
--   13 - filter("DEPARTMENTS"."MANAGER_ID"="EMPLOYEES"."EMPLOYEE_ID")
 
-- Note
-- -----
--    - Degree of Parallelism is 3 because of table property
---------------------------------------------------------------------------------------------------


-- Punto 2.2 Obtener el nombre  de la región con más empleados.
EXPLAIN PLAN FOR
SELECT /*parallel(employees, 3)*/ regions.region_name, count(employees.employee_id) as totalEmpleados
from regions
join countries on regions.region_id=countries.region_id
join locations on countries.country_id = locations.country_id
join departments on locations.location_id=departments.location_id
join employees on departments.department_id = employees.department_id
group by regions.region_name
order by totalEmpleados desc
FETCH FIRST 1 ROWS ONLY;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Resultado consulta:
-- Plan hash value: 2707272301
 
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                               | Name              | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                        |                   |     1 |    53 |     9  (34)| 00:00:01 |        |      |            |
-- |   1 |  SORT ORDER BY                          |                   |     1 |    53 |     9  (34)| 00:00:01 |        |      |            |
-- |*  2 |   VIEW                                  |                   |     1 |    53 |     8  (25)| 00:00:01 |        |      |            |
-- |*  3 |    WINDOW SORT PUSHED RANK              |                   |     4 |   144 |     8  (25)| 00:00:01 |        |      |            |
-- |   4 |     PX COORDINATOR                      |                   |       |       |            |          |        |      |            |
-- |   5 |      PX SEND QC (RANDOM)                | :TQ10003          |     4 |   144 |     8  (25)| 00:00:01 |  Q1,03 | P->S | QC (RAND)  |
-- |*  6 |       WINDOW CHILD PUSHED RANK          |                   |     4 |   144 |     8  (25)| 00:00:01 |  Q1,03 | PCWP |            |
-- |   7 |        HASH GROUP BY                    |                   |     4 |   144 |     8  (25)| 00:00:01 |  Q1,03 | PCWP |            |
-- |   8 |         PX RECEIVE                      |                   |     4 |   144 |     8  (25)| 00:00:01 |  Q1,03 | PCWP |            |
-- |   9 |          PX SEND HASH                   | :TQ10002          |     4 |   144 |     8  (25)| 00:00:01 |  Q1,02 | P->P | HASH       |
-- |  10 |           HASH GROUP BY                 |                   |     4 |   144 |     8  (25)| 00:00:01 |  Q1,02 | PCWP |            |
-- |  11 |            NESTED LOOPS                 |                   |   106 |  3816 |     6   (0)| 00:00:01 |  Q1,02 | PCWP |            |
-- |* 12 |             HASH JOIN                   |                   |    27 |   891 |     6   (0)| 00:00:01 |  Q1,02 | PCWP |            |
-- |  13 |              PX RECEIVE                 |                   |    23 |   598 |     4   (0)| 00:00:01 |  Q1,02 | PCWP |            |
-- |  14 |               PX SEND HYBRID HASH       | :TQ10000          |    23 |   598 |     4   (0)| 00:00:01 |  Q1,00 | P->P | HYBRID HASH|
-- |  15 |                STATISTICS COLLECTOR     |                   |       |       |            |          |  Q1,00 | PCWC |            |
-- |* 16 |                 HASH JOIN               |                   |    23 |   598 |     4   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |  17 |                  NESTED LOOPS           |                   |    23 |   276 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |  18 |                   PX BLOCK ITERATOR     |                   |       |       |            |          |  Q1,00 | PCWC |            |
-- |  19 |                    TABLE ACCESS FULL    | LOCATIONS         |    23 |   138 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |* 20 |                   INDEX UNIQUE SCAN     | COUNTRY_C_ID_PK   |     1 |     6 |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |  21 |                  TABLE ACCESS FULL      | REGIONS           |     4 |    56 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
-- |  22 |              PX RECEIVE                 |                   |    27 |   189 |     2   (0)| 00:00:01 |  Q1,02 | PCWP |            |
-- |  23 |               PX SEND HYBRID HASH (SKEW)| :TQ10001          |    27 |   189 |     2   (0)| 00:00:01 |  Q1,01 | P->P | HYBRID HASH|
-- |  24 |                PX BLOCK ITERATOR        |                   |    27 |   189 |     2   (0)| 00:00:01 |  Q1,01 | PCWC |            |
-- |  25 |                 TABLE ACCESS FULL       | DEPARTMENTS       |    27 |   189 |     2   (0)| 00:00:01 |  Q1,01 | PCWP |            |
-- |* 26 |             INDEX RANGE SCAN            | EMP_DEPARTMENT_IX |     4 |    12 |     0   (0)| 00:00:01 |  Q1,02 | PCWP |            |
-- ------------------------------------------------------------------------------------------------------------------------------------------
 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
 
--    2 - filter("from$_subquery$_010"."rowlimit_$$_rownumber"<=1)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY COUNT() DESC )<=1)
--    6 - filter(ROW_NUMBER() OVER ( ORDER BY COUNT() DESC )<=1)
--   12 - access("LOCATIONS"."LOCATION_ID"="DEPARTMENTS"."LOCATION_ID")
--   16 - access("REGIONS"."REGION_ID"="COUNTRIES"."REGION_ID")
--   20 - access("COUNTRIES"."COUNTRY_ID"="LOCATIONS"."COUNTRY_ID")
--   26 - access("DEPARTMENTS"."DEPARTMENT_ID"="EMPLOYEES"."DEPARTMENT_ID")
 
-- Note
-- -----
--    - Degree of Parallelism is 3 because of table property

