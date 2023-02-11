-- 1) Propuesta elegida: en la tabla EMPLOYEES se podría crear un índice sobre la columna SALARY 
-- 2) Ejecuta una consulta sin crear los índices, obteniendo el plan de ejecución de la misma. 
-- Recuerda que puedes obtener el plan de ejecución con `EXPLAIN PLAN FOR`
EXPLAIN PLAN FOR
SELECT salary
FROM employees 
WHERE salary = 9000;  
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- 3) Crear el/los índice/s propuesto/s.
CREATE INDEX EMP_SALARY_IX
ON EMPLOYEES(SALARY);

-- 4) Ejecuta la misma consulta que en el paso 2, obteniendo el plan de ejecución y validando 
-- que el nuevo índice se está usando.
EXPLAIN PLAN FOR
SELECT salary
FROM employees 
WHERE salary = 9000;  
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());