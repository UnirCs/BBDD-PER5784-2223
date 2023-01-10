/* 
Optimización de consultas basada en índices
En este ejercicio crearemos uno o varios índices en una o varias tablas del Schema HR de Oracle para asegurar que los planes de ejecución que el SGBD realiza usan esos índices, mejorando el rendimiento de la consulta. Para ello:

Selecciona una o varias de las propuestas de índices de la Actividad Individual sobre índices que realizamos.
Ejecuta una consulta sin crear los índices, obteniendo el plan de ejecución de la misma. Recuerda que puedes obtener el plan de ejecución con EXPLAIN PLAN FOR
Crear el/los índice/s propuesto/s.
Ejecuta la misma consulta que en el paso 2, obteniendo el plan de ejecución y validando que el nuevo índice se está usando.

Entrega: Archivo SQL con el 1)código de la consulta a realizar y el 2)código para crear índices. Archivo TXT con el resultado de los planes de ejecución.

resultados de la salida en:    "resultado de los planes de ejecución.txt"
*/

/*1)  código de la consulta a realizar*/
  /*EXPLAIN PLAN FOR  select * from Jobs where MIN_SALARY>'8200';
  /*mostrar por pantalla ese plan de ejecucion*/
  /*SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

--
  EXPLAIN PLAN FOR  select * from Jobs where Job_title='Accounting Manager';
  /*mostrar por pantalla ese plan de ejecucion*/
  /*SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());*/
  
--
  EXPLAIN PLAN FOR  select * from employees where phone_number='515.123.8888';
  /*mostrar por pantalla ese plan de ejecucion*/
  SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY()); 
 
 
 /*EXPLAIN PLAN FOR select empes.phone_number, depts.* from employees empes, departments depts where empes.employee_id=depts.department_id ORDER BY phone_number;
 SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());*/
  
/*2) código para crear índices */

/*CREATE INDEX idx_unique1 ON Jobs(MIN_SALARY);     /*no se puede crear UNIQUE, ya que existen valores duplicados*/
/*drop index idx_unique1;*/

/*CREATE UNIQUE INDEX idx_unique2 ON Jobs(Job_title);*/

CREATE INDEX idx_unique2 ON employees(phone_number);    /*no se puede crear UNIQUE, ya que existen valores duplicados*/
drop index  idx_unique2;

 EXPLAIN PLAN FOR  select phone_number from employees where phone_number='515.123.8888';
  /*mostrar por pantalla ese plan de ejecucion*/
  SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());