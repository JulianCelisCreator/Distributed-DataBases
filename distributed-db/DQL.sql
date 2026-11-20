select e.nombre as "top 10", sum(ra.precio) as "Cantidad Ganada"
from estudiante e
join registro_actividad ra on ra.estudiante_id = e.id_estudiante
group by e.nombre 
order by "Cantidad Ganada" desc
limit 10;

-- Top 10 estudiantes con más tiempo invertido en actividades

select e.nombre as "top 10", sum(ra.duracion ) as "Tiempo (min)"
from estudiante e
left join registro_actividad ra on ra.estudiante_id = e.id_estudiante
group by e.nombre 
order by "Tiempo (min)" desc
limit 10;

-- Top 10 estudiantes que más ganan más dinero por minuto

select e.nombre as "top 10", trunc((sum(ra.precio)/sum(ra.duracion )), 2) as "Ganancia"
from estudiante e
left join registro_actividad ra on ra.estudiante_id = e.id_estudiante
group by e.nombre 
order by "Ganancia" desc
limit 10;


-- Top 5 estudiantes más camelladores por tiempo y dinero

select e.nombre, COUNT(ra.recompensa_id) as "actividades", SUM(ra.duracion)
from estudiante e
join registro_actividad ra on e.id_estudiante = ra. estudiante_id
group by e.nombre 
order by "actividades" desc
limit 5;


-- Estudiantes Según dinero recaudado SIN CTE 

select e.nombre, sum(ra.precio) as precio,
case 
	when sum(ra.precio) >= 0 and sum(ra.precio) <= 10000 then 'sangano'
	when sum(ra.precio) > 10000  and sum(ra.precio) <= 100000 then 'Pa algo sirvio'
	when sum(ra.precio) > 100000 and sum(ra.precio) <= 500000 then 'Ese es el esclavo que necesito'
	when sum(ra.precio) > 500000 then 'Ingeniero Senior'
end
from estudiante e
join registro_actividad ra on e.id_estudiante = ra. estudiante_id
group by e.nombre
order by "precio" DESC;

-- Estudiantes Según dinero recaudado CON CTE
with Clasificador as (
select e.nombre, sum(ra.precio) as precio,
case 
	when sum(ra.precio) >= 0 and sum(ra.precio) <= 10000 then 'sangano'
	when sum(ra.precio) > 10000  and sum(ra.precio) <= 100000 then 'Pa algo sirvio'
	when sum(ra.precio) > 100000 and sum(ra.precio) <= 500000 then 'Ese es el esclavo que necesito'
	when sum(ra.precio) > 500000 then 'Ingeniero Senior'
end as clasificacion
from estudiante e
join registro_actividad ra on e.id_estudiante = ra. estudiante_id
group by e.nombre)
select distinct (c.nombre), c.precio ,c.clasificacion 
from Clasificador c
order by c.precio DESC;



-- Top 10 estudiantes más vagos

select e.nombre as "top 10 vagos", coalesce(trunc((sum(ra.precio)/sum(ra.duracion )), 2),0) as "Ganancia"
from estudiante e
left join registro_actividad ra on ra.estudiante_id = e.id_estudiante
group by e.nombre 
order by "Ganancia" asc
limit 10;

