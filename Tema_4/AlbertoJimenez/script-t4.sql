

 1a) Escribir consultas SQL que se realicen de forma paralela y ver su plan de ejecución:

EXPLAIN PLAN
FOR
SELECT /* parallel employees , 3 )*/ employee_id , department_name
FROM employees , departments
WHERE employees.employee_id = departments.department_id
ORDER BY employee_id;

/* result query:
100	Finance
110	Accounting
120	Treasury
130	Corporate Tax
140	Control And Credit
150	Shareholder Services
160	Benefits
170	Manufacturing
180	Construction
190	Contracting
200	Operations
*/

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY());

/*
Plan hash value: 903660287
 
----------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |    27 |   540 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                |               |    27 |   540 |     2   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS   |    27 |   432 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | DEPT_ID_PK    |    27 |       |     1   (0)| 00:00:01 |
|*  4 |   INDEX UNIQUE SCAN          | EMP_EMP_ID_PK |     1 |     4 |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMPLOYEES"."EMPLOYEE_ID"="DEPARTMENTS"."DEPARTMENT_ID")
*/
-----




1b) Establecer un grado de paralelismo (DoP) de nivel 3 para todas las tablas del Schema HR:

ALTER TABLE countries PARALLEL 3;
ALTER TABLE departments PARALLEL 3;
ALTER TABLE employees PARALLEL 3;
ALTER TABLE job_history PARALLEL 3;
ALTER TABLE jobs PARALLEL 3;
ALTER TABLE locations PARALLEL 3;
ALTER TABLE regions PARALLEL 3;

/*ej:   Table COUNTRIES alterado. */

2) Realizar las siguientes consultas de forma paralela y obtener su plan de ejecución:
– Obtener el nombre de los managers de los empleados argentinos, alemanes, franceses o suizos.
– Obtener el nombre de la región con más empleados.
-----

– Obtener el nombre de los managers de los empleados: argentinos, alemanes, franceses o suizos.

select * FROM employees;
select * FROM jobs;
select * FROM countries;
select * FROM departments;
select * FROM locations;

2a-EJ1:

EXPLAIN PLAN
FOR
select /* parallel (employees , 3 )*/ emples.first_name FROM employees emples where emples.department_id in(
select department_id/*, manager_id*/ FROM departments where location_id in(
select location_id FROM locations where country_id in (select country_id FROM countries where country_name in ('Argentina','Germany','France','Switzerland'))));

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY());

/*
Plan hash value: 2403437476
 
------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                          | Name             | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                   |                  |    77 |  1771 |     5   (0)| 00:00:01 |        |      |            |
|   1 |  PX COORDINATOR                    |                  |       |       |            |          |        |      |            |
|   2 |   PX SEND QC (RANDOM)              | :TQ10001         |    77 |  1771 |     5   (0)| 00:00:01 |  Q1,01 | P->S | QC (RAND)  |
|*  3 |    HASH JOIN SEMI BUFFERED         |                  |    77 |  1771 |     5   (0)| 00:00:01 |  Q1,01 | PCWP |            |
|   4 |     PX BLOCK ITERATOR              |                  |   107 |  1070 |     2   (0)| 00:00:01 |  Q1,01 | PCWC |            |
|   5 |      TABLE ACCESS FULL             | EMPLOYEES        |   107 |  1070 |     2   (0)| 00:00:01 |  Q1,01 | PCWP |            |
|   6 |     PX RECEIVE                     |                  |     8 |   104 |     3   (0)| 00:00:01 |  Q1,01 | PCWP |            |
|   7 |      PX SEND BROADCAST             | :TQ10000         |     8 |   104 |     3   (0)| 00:00:01 |  Q1,00 | P->P | BROADCAST  |
|   8 |       VIEW                         | VW_NSO_1         |     8 |   104 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|   9 |        NESTED LOOPS                |                  |     8 |   200 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  10 |         NESTED LOOPS               |                  |    28 |   200 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  11 |          NESTED LOOPS SEMI         |                  |     7 |   126 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  12 |           PX BLOCK ITERATOR        |                  |       |       |            |          |  Q1,00 | PCWC |            |
|  13 |            TABLE ACCESS FULL       | LOCATIONS        |    23 |   138 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|* 14 |           INDEX UNIQUE SCAN        | COUNTRY_C_ID_PK  |     1 |    12 |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|* 15 |          INDEX RANGE SCAN          | DEPT_LOCATION_IX |     4 |       |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  16 |         TABLE ACCESS BY INDEX ROWID| DEPARTMENTS      |     1 |     7 |     1   (0)| 00:00:01 |  Q1,00 | PCWP |            |
------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("EMPLES"."DEPARTMENT_ID"="DEPARTMENT_ID")
  14 - access("COUNTRY_ID"="COUNTRY_ID")
       filter("COUNTRY_NAME"='Argentina' OR "COUNTRY_NAME"='France' OR "COUNTRY_NAME"='Germany' OR 
              "COUNTRY_NAME"='Switzerland')
  15 - access("LOCATION_ID"="LOCATION_ID")
 
Note
-----
   - Degree of Parallelism is 3 because of table property
*/


2a-EJ2: con manager_id

EXPLAIN PLAN
FOR
select /* parallel (employees , 3 )*/ emples.first_name FROM employees emples where emples.employee_id in(
select manager_id FROM departments where location_id in(
select location_id FROM locations where country_id in (select country_id FROM countries where country_name in ('Argentina','Germany','France','Switzerland'))));

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY());

/*
Plan hash value: 2403437476
 
------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                          | Name             | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                   |                  |     8 |   192 |     5   (0)| 00:00:01 |        |      |            |
|   1 |  PX COORDINATOR                    |                  |       |       |            |          |        |      |            |
|   2 |   PX SEND QC (RANDOM)              | :TQ10001         |     8 |   192 |     5   (0)| 00:00:01 |  Q1,01 | P->S | QC (RAND)  |
|*  3 |    HASH JOIN SEMI BUFFERED         |                  |     8 |   192 |     5   (0)| 00:00:01 |  Q1,01 | PCWP |            |
|   4 |     PX BLOCK ITERATOR              |                  |   107 |  1177 |     2   (0)| 00:00:01 |  Q1,01 | PCWC |            |
|   5 |      TABLE ACCESS FULL             | EMPLOYEES        |   107 |  1177 |     2   (0)| 00:00:01 |  Q1,01 | PCWP |            |
|   6 |     PX RECEIVE                     |                  |     8 |   104 |     3   (0)| 00:00:01 |  Q1,01 | PCWP |            |
|   7 |      PX SEND BROADCAST             | :TQ10000         |     8 |   104 |     3   (0)| 00:00:01 |  Q1,00 | P->P | BROADCAST  |
|   8 |       VIEW                         | VW_NSO_1         |     8 |   104 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|   9 |        NESTED LOOPS                |                  |     8 |   192 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  10 |         NESTED LOOPS               |                  |    28 |   192 |     3   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  11 |          NESTED LOOPS SEMI         |                  |     7 |   126 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  12 |           PX BLOCK ITERATOR        |                  |       |       |            |          |  Q1,00 | PCWC |            |
|  13 |            TABLE ACCESS FULL       | LOCATIONS        |    23 |   138 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|* 14 |           INDEX UNIQUE SCAN        | COUNTRY_C_ID_PK  |     1 |    12 |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|* 15 |          INDEX RANGE SCAN          | DEPT_LOCATION_IX |     4 |       |     0   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  16 |         TABLE ACCESS BY INDEX ROWID| DEPARTMENTS      |     1 |     6 |     1   (0)| 00:00:01 |  Q1,00 | PCWP |            |
------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("EMPLES"."EMPLOYEE_ID"="MANAGER_ID")
  14 - access("COUNTRY_ID"="COUNTRY_ID")
       filter("COUNTRY_NAME"='Argentina' OR "COUNTRY_NAME"='France' OR "COUNTRY_NAME"='Germany' OR 
              "COUNTRY_NAME"='Switzerland')
  15 - access("LOCATION_ID"="LOCATION_ID")
 
Note
-----
   - Degree of Parallelism is 3 because of table property
*/


2b– Obtener el nombre de la región con más empleados.

select * FROM employees;
select  emps.department_id FROM employees emps where department_id=50 ;  80
select * FROM regions;
select * FROM countries;
select * FROM locations;
select * FROM departments;

             
//departamento con mas empleados                    
select department_id,count(*) from employees group by department_id   

//departamento con mas empleados  
select aux.department_id
from employees,
(select department_id,count(*) as tot from employees group by department_id ) aux
where aux.tot=45  /*aux.department_id=50*/
group by aux.department_id


//departamento con mas empleados  
select aux.department_id
from employees,
(select department_id,count(*) as tot from employees group by department_id ) aux
where aux.tot= (select max(total.todos) from (select count(*) as todos from employees group by department_id ) total       /*=45*/)
group by aux.department_id


EXPLAIN PLAN
FOR
select /* parallel (employees , 3 )*/ region_name FROM regions where region_id = (           /*Americas*/
    select region_id from countries where country_id = (      /*2*/
    select country_id from locations  where location_id = (   /*US*/
        select location_id from departments where department_id =(   /*1500*/
                      select aux.department_id
                            from employees,
                                (select department_id,count(*) as tot from employees group by department_id ) aux
                                where aux.tot= (select max(total.todos) from (select count(*) as todos from employees group by department_id ) total ) /*=45*/
                                group by aux.department_id
                    )  )));

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY());
/*
Plan hash value: 1249002675
 
-----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name            | Rows  | Bytes | Cost (%CPU)| Time     |    TQ  |IN-OUT| PQ Distrib |
-----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                 |     1 |    14 |     8  (13)| 00:00:01 |        |      |            |
|   1 |  TABLE ACCESS BY INDEX ROWID             | REGIONS         |     1 |    14 |     1   (0)| 00:00:01 |        |      |            |
|*  2 |   INDEX UNIQUE SCAN                      | REG_ID_PK       |     1 |       |     0   (0)| 00:00:01 |        |      |            |
|*  3 |    INDEX UNIQUE SCAN                     | COUNTRY_C_ID_PK |     1 |     6 |     0   (0)| 00:00:01 |        |      |            |
|   4 |     TABLE ACCESS BY INDEX ROWID          | LOCATIONS       |     1 |     6 |     1   (0)| 00:00:01 |        |      |            |
|*  5 |      INDEX UNIQUE SCAN                   | LOC_ID_PK       |     1 |       |     0   (0)| 00:00:01 |        |      |            |
|   6 |       TABLE ACCESS BY INDEX ROWID        | DEPARTMENTS     |     1 |     7 |     1   (0)| 00:00:01 |        |      |            |
|*  7 |        INDEX UNIQUE SCAN                 | DEPT_ID_PK      |     1 |       |     0   (0)| 00:00:01 |        |      |            |
|   8 |         HASH GROUP BY                    |                 |     1 |    16 |     5  (20)| 00:00:01 |        |      |            |
|   9 |          MERGE JOIN CARTESIAN            |                 |   107 |  1712 |     5  (20)| 00:00:01 |        |      |            |
|  10 |           VIEW                           |                 |     1 |    16 |     3  (34)| 00:00:01 |        |      |            |
|  11 |            PX COORDINATOR                |                 |       |       |            |          |        |      |            |
|  12 |             PX SEND QC (RANDOM)          | :TQ20001        |     1 |     3 |     3  (34)| 00:00:01 |  Q2,01 | P->S | QC (RAND)  |
|* 13 |              FILTER                      |                 |       |       |            |          |  Q2,01 | PCWC |            |
|  14 |               SORT GROUP BY              |                 |     1 |     3 |     3  (34)| 00:00:01 |  Q2,01 | PCWP |            |
|  15 |                PX RECEIVE                |                 |     1 |     3 |     3  (34)| 00:00:01 |  Q2,01 | PCWP |            |
|  16 |                 PX SEND HASH             | :TQ20000        |     1 |     3 |     3  (34)| 00:00:01 |  Q2,00 | P->P | HASH       |
|  17 |                  SORT GROUP BY           |                 |     1 |     3 |     3  (34)| 00:00:01 |  Q2,00 | PCWP |            |
|  18 |                   PX BLOCK ITERATOR      |                 |   107 |   321 |     2   (0)| 00:00:01 |  Q2,00 | PCWC |            |
|  19 |                    TABLE ACCESS FULL     | EMPLOYEES       |   107 |   321 |     2   (0)| 00:00:01 |  Q2,00 | PCWP |            |
|  20 |               SORT AGGREGATE             |                 |     1 |    13 |            |          |        |      |            |
|  21 |                PX COORDINATOR            |                 |       |       |            |          |        |      |            |
|  22 |                 PX SEND QC (RANDOM)      | :TQ10001        |     1 |    13 |            |          |  Q1,01 | P->S | QC (RAND)  |
|  23 |                  SORT AGGREGATE          |                 |     1 |    13 |            |          |  Q1,01 | PCWP |            |
|  24 |                   VIEW                   |                 |    11 |   143 |     3  (34)| 00:00:01 |  Q1,01 | PCWP |            |
|  25 |                    SORT GROUP BY         |                 |    11 |    33 |     3  (34)| 00:00:01 |  Q1,01 | PCWP |            |
|  26 |                     PX RECEIVE           |                 |    11 |    33 |     3  (34)| 00:00:01 |  Q1,01 | PCWP |            |
|  27 |                      PX SEND HASH        | :TQ10000        |    11 |    33 |     3  (34)| 00:00:01 |  Q1,00 | P->P | HASH       |
|  28 |                       SORT GROUP BY      |                 |    11 |    33 |     3  (34)| 00:00:01 |  Q1,00 | PCWP |            |
|  29 |                        PX BLOCK ITERATOR |                 |   107 |   321 |     2   (0)| 00:00:01 |  Q1,00 | PCWC |            |
|  30 |                         TABLE ACCESS FULL| EMPLOYEES       |   107 |   321 |     2   (0)| 00:00:01 |  Q1,00 | PCWP |            |
|  31 |           BUFFER SORT                    |                 |   107 |       |     5  (20)| 00:00:01 |        |      |            |
|  32 |            INDEX FULL SCAN               | EMP_EMAIL_UK    |   107 |       |     1   (0)| 00:00:01 |        |      |            |
-----------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("REGION_ID"= (SELECT "REGION_ID" FROM "COUNTRIES" "COUNTRIES" WHERE "COUNTRY_ID"= (SELECT "COUNTRY_ID" FROM 
              "LOCATIONS" "LOCATIONS" WHERE "LOCATION_ID"= (SELECT "LOCATION_ID" FROM "DEPARTMENTS" "DEPARTMENTS" WHERE "DEPARTMENT_ID"= 
              (SELECT "AUX"."DEPARTMENT_ID" FROM  (SELECT "DEPARTMENT_ID" "DEPARTMENT_ID",COUNT() "TOT" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY 
              "DEPARTMENT_ID" HAVING COUNT()= (SELECT MAX() FROM  (SELECT COUNT() "TODOS" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY 
              "DEPARTMENT_ID") "TOTAL")) "AUX","EMPLOYEES" "EMPLOYEES" GROUP BY "AUX"."DEPARTMENT_ID")))))
   3 - access("COUNTRY_ID"= (SELECT "COUNTRY_ID" FROM "LOCATIONS" "LOCATIONS" WHERE "LOCATION_ID"= (SELECT "LOCATION_ID" FROM 
              "DEPARTMENTS" "DEPARTMENTS" WHERE "DEPARTMENT_ID"= (SELECT "AUX"."DEPARTMENT_ID" FROM  (SELECT "DEPARTMENT_ID" 
              "DEPARTMENT_ID",COUNT() "TOT" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY "DEPARTMENT_ID" HAVING COUNT()= (SELECT MAX() FROM  (SELECT 
              COUNT() "TODOS" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY "DEPARTMENT_ID") "TOTAL")) "AUX","EMPLOYEES" "EMPLOYEES" GROUP BY 
              "AUX"."DEPARTMENT_ID"))))
   5 - access("LOCATION_ID"= (SELECT "LOCATION_ID" FROM "DEPARTMENTS" "DEPARTMENTS" WHERE "DEPARTMENT_ID"= (SELECT 
              "AUX"."DEPARTMENT_ID" FROM  (SELECT "DEPARTMENT_ID" "DEPARTMENT_ID",COUNT() "TOT" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY 
              "DEPARTMENT_ID" HAVING COUNT()= (SELECT MAX() FROM  (SELECT COUNT() "TODOS" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY 
              "DEPARTMENT_ID") "TOTAL")) "AUX","EMPLOYEES" "EMPLOYEES" GROUP BY "AUX"."DEPARTMENT_ID")))
   7 - access("DEPARTMENT_ID"= (SELECT "AUX"."DEPARTMENT_ID" FROM  (SELECT "DEPARTMENT_ID" "DEPARTMENT_ID",COUNT() "TOT" FROM 
              "EMPLOYEES" "EMPLOYEES" GROUP BY "DEPARTMENT_ID" HAVING COUNT()= (SELECT MAX() FROM  (SELECT COUNT() "TODOS" FROM "EMPLOYEES" 
              "EMPLOYEES" GROUP BY "DEPARTMENT_ID") "TOTAL")) "AUX","EMPLOYEES" "EMPLOYEES" GROUP BY "AUX"."DEPARTMENT_ID"))
  13 - filter(COUNT()= (SELECT MAX() FROM  (SELECT COUNT() "TODOS" FROM "EMPLOYEES" "EMPLOYEES" GROUP BY "DEPARTMENT_ID") 
              "TOTAL"))
 
Note
-----
   - Degree of Parallelism is 3 because of table property
*/