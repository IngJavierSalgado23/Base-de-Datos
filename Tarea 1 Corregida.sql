--Se corrigio el ultimo ejercicio (5) que estaba erroneo
--1 Obtener la fecha y total de la compra mas reciente de cada cliente
select cus.f_name || ' '|| cus.l_name as cliente, ou_q.ultima_compra, in_q.order_id, in_q.total from (select max(fecha) as ultima_compra, customer_id from javier.orders group by customer_id) ou_q inner join 
(SELECT ord.order_id,
         ord.customer_id,
         fecha,
         SUM (quantity * price) total
    FROM javier.orders ord
         INNER JOIN javier.order_product op ON op.order_id = ord.order_id
         INNER JOIN javier.product prod ON prod.product_id = op.product_id
GROUP BY ord.order_id, ord.customer_id, fecha) in_q on in_q.fecha = ou_q.ultima_compra inner join javier.customer cus
on cus.customer_id = in_q.customer_id order by in_q.customer_id asc;

--2 Obtener a los clIEntes cuyo nombre contenga la letra H o apellido inicio con Z

  SELECT *
    FROM javier.customer
   WHERE LOWER (f_name) LIKE '%h%' OR l_name LIKE 'Z%'
ORDER BY l_name DESC;

-- 3 Mostrar los detalles de las ordenes y calcular el costo de envio de cada orden,tomando las siguientes consideraciones:
--10% del total cuando sea MENOR de 10000,
--8% del total cuando este entre 10,000 y 30.000
--5% del total cuando sea mayor a 30,000

SELECT in_q.order_id,
       in_q.customer_id,
       fecha,
       total,
       CASE
           WHEN total < 10000 THEN (in_q.total * .10)
           WHEN total > 10000 AND total < 30000 THEN (in_q.total * .08)
           ELSE (in_q.total * .05)
       END
           AS shipping
  FROM (  SELECT ord.order_id,
                 ord.customer_id,
                 fecha,
                 SUM (quantity * price) total
            FROM javier.orders ord
                 INNER JOIN javier.order_product op
                     ON op.order_id = ord.order_id
                 INNER JOIN javier.product prod
                     ON prod.product_id = op.product_id
        GROUP BY ord.order_id, ord.customer_id, fecha) in_q order by order_id asc;
--4 Obtener los productos con un costo mayor a 100

SELECT *
  FROM javier.product
 WHERE price > 100;

--5- Promedia el costo de todos los productos y obtener el PRODUCTO DE mayor costo

SELECT *
  FROM (SELECT ROW_NUMBER () OVER (ORDER BY price DESC) AS orders, prod.*
          FROM JAVIER.PRODUCT prod) ordenamientos
       INNER JOIN (SELECT AVG (PRICE) FROM JAVIER.PRODUCT) PROMEDIOS ON 1 = 1
 WHERE ORDERS = 1;
