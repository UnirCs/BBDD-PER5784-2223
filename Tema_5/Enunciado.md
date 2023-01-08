# Optimización de consultas basada en índices

En este ejercicio crearemos uno o varios índices en una o varias tablas del Schema HR de Oracle para asegurar que los planes de ejecución que el SGBD realiza usan esos índices, mejorando el rendimiento de la consulta.
Para ello:

1) Selecciona una o varias de las propuestas de índices de la Actividad Individual sobre índices que realizamos.
2) Ejecuta una consulta sin crear los índices, obteniendo el plan de ejecución de la misma. Recuerda que puedes obtener el plan de ejecución con `EXPLAIN PLAN FOR`
3) Crear el/los índice/s propuesto/s.
4) Ejecuta la misma consulta que en el paso 2, obteniendo el plan de ejecución y validando que el nuevo índice se está usando.

Entrega: Archivo SQL con el código de la consulta a realizar y el código para crear índices. Archivo TXT con el resultado de los planes de ejecución.
