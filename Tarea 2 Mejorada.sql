/* Formatted on 26/02/2018 04:46:25 p.m. (QP5 v5.300) */
 --6 Obtener los 10 productos menos vendidos y la cantidad de sus ventas en el ano 2015
--Todas las ordenes del 2015 y el total de ventas

SELECT prod.product_id, total_ventas, product_name
  FROM (SELECT in_q.product_id,
               total_ventas,
               ROW_NUMBER () OVER (ORDER BY in_q.total_ventas ASC) orden
          FROM (  SELECT op.product_id, SUM (quantity) total_ventas
                    FROM javier.orders ord
                         INNER JOIN javier.order_product op
                             ON op.order_id = ord.order_id
                   WHERE EXTRACT (YEAR FROM fecha) = 2015
                GROUP BY op.product_id) in_q) ou_q
       INNER JOIN javier.product prod ON prod.product_id = ou_q.product_id
 WHERE orden < 11;

 --7 Obtener al cliente con mas compras historicamente

SELECT cus.customer_id, f_name || ' ' || l_name AS cliente, total_ordenes
  FROM (SELECT ROW_NUMBER () OVER (ORDER BY total_ordenes DESC) orden,
               total_ordenes,
               customer_id
          FROM (  SELECT customer_id, COUNT (order_id) AS total_ordenes
                    FROM javier.orders
                GROUP BY customer_id)) ou_q
       INNER JOIN javier.customer cus ON cus.customer_id = ou_q.customer_id
 WHERE orden = 1;

--8 Calcular el envio de las ordenes tomando en cuenta el numero de compras del ano anterior:
--Si tiene menos de 2 compras usar el 15%
--Si tiene entre 2 y 4 compras usar el 10%
--Si tiene mas de 5 compras usar el 5%


  SELECT in_q.customer_id,
         cus.f_name || ' ' || cus.l_name AS cliente,
         total_ventas,
         total,
         CASE
             WHEN total_ventas < 2 THEN total * .15
             WHEN total_ventas > 1 AND total_ventas < 3 THEN total * .1
             ELSE total * .05
         END
             AS shipping
    FROM (  SELECT customer_id, SUM (quantity * price) AS total
              FROM javier.orders ord
                   INNER JOIN javier.order_product op
                       ON op.order_id = ord.ORDER_ID
                   INNER JOIN javier.product prod
                       ON prod.product_id = op.product_id
             WHERE EXTRACT (YEAR FROM fecha) = '2017'
          GROUP BY customer_id
          ORDER BY customer_id ASC) in_q
         INNER JOIN (  SELECT customer_id, COUNT (ord.order_id) AS total_ventas
                         FROM javier.orders ord
                        WHERE EXTRACT (YEAR FROM fecha) = 2017
                     GROUP BY customer_id) ou_q
             ON ou_q.customer_id = in_q.customer_id
         INNER JOIN javier.customer cus ON cus.customer_id = in_q.customer_id
ORDER BY total_ventas DESC;