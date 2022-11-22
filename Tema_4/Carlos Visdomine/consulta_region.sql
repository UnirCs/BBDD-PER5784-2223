EXPLAIN PLAN FOR
select
    /*+ PARALLEL(3) */
    region.REGION_NAME
from regions region
where region.REGION_ID = (
        select tabla.zona_region
        from (
                select (count(empl.EMPLOYEE_ID)) as cuenta_empleados,
                    auxi.region as zona_region
                from
                    employees empl, (
                        SELECT
                            depar.DEPARTMENT_ID as departamento,
                            aux.region_id as region
                        from
                            DEPARTMENTS depar, (
                                SELECT
                                    loc.LOCATION_ID as locati,
                                    coun.region_id as region_id
                                from
                                    countries coun,
                                    locations loc
                                where
                                    loc.COUNTRY_ID = coun.COUNTRY_ID
                            ) aux
                        where
                            depar.LOCATION_ID = aux.locati
                    ) auxi
                where
                    empl.DEPARTMENT_ID = auxi.departamento
                group by
                    auxi.region
            ) tabla
        where
            tabla.cuenta_empleados = (
                select
                    MAX(empleado.total_region) as max_empleados
                from (
                        select (count(empl.EMPLOYEE_ID)) as total_region
                        from
                            employees empl, (
                                SELECT
                                    depar.DEPARTMENT_ID as departamento,
                                    aux.region_id as region
                                from
                                    DEPARTMENTS depar, (
                                        SELECT
                                            loc.LOCATION_ID as locati,
                                            coun.region_id as region_id
                                        from
                                            countries coun,
                                            locations loc
                                        where
                                            loc.COUNTRY_ID = coun.COUNTRY_ID
                                    ) aux
                                where
                                    depar.LOCATION_ID = aux.locati
                            ) auxi
                        where
                            empl.DEPARTMENT_ID = auxi.departamento
                        group by
                            auxi.region
                    ) empleado
            )
    );

select * from table(dbms_xplan.display);