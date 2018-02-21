/* Formatted on 21/02/2018 03:01:26 a.m. (QP5 v5.300) */
-- Consultas 2.
 --6 Obtener los 10 productos menos vendidos y la cantidad de sus ventas en el ano 2015

  SELECT topquery.orders,
         topquery.product_id,
         prod.product_name,
         topquery.total
    FROM (SELECT ROW_NUMBER () OVER (ORDER BY TOTAL ASC) AS orders, subquery.*
            FROM (  SELECT in_in_q.product_id, SUM (in_in_q.QUANTITY) AS TOTAL
                      FROM (  SELECT op.product_id, op.quantity
                                FROM javier.orders ord
                                     INNER JOIN javier.order_product op
                                         ON op.order_id = ord.order_id
                               WHERE fecha < '01/01/2016' AND fecha > '31/12/2014'
                            ORDER BY op.product_id ASC) in_in_q
                  GROUP BY in_in_q.product_id) subquery) topquery
         INNER JOIN javier.product prod
             ON prod.product_id = topquery.PRODUCT_ID
   WHERE topquery.ORDERS < 11
ORDER BY topquery.orders ASC;



--7 Obtener al cliente con mas compras historicamente

SELECT outer_query.customer_id,
       cus.F_NAME,
       cus.L_NAME,
       outer_query.total_compras
  FROM (SELECT ROW_NUMBER () OVER (ORDER BY inner_query.total_compras DESC)
                   AS orden,
               inner_query.*
          FROM (  SELECT COUNT (order_id) AS total_compras, customer_id
                    FROM JAVIER.ORDERS ord
                GROUP BY customer_id
                ORDER BY total_compras DESC) inner_query) outer_query
       INNER JOIN javier.customer cus
           ON cus.customer_id = outer_query.customer_id
 WHERE outer_query.orden = 1;

--8 Calcular el envio de las ordenes tomando en cuenta el numero de compras del ano anterior:
--Si tiene menos de 2 compras usar el 15%
--Si tiene entre 2 y 4 compras usar el 10%
--Si tiene mas de 5 compras usar el 5%

--En el primero no calcule el precio total de las compras porque no especifica pero luego me di cuenta de que entonces no tiene sentido
-- lo del shipping porque literalmente no obtienes nada, entonces lo rehice bien abajo, creo... increiblemente ambos dan total de compras diferentes

  SELECT ou_q.customer_id,
         ou_q.total_compras,
         CASE
             WHEN total_compras < 2 THEN .15
             WHEN total_compras > 1 AND total_compras < 5 THEN .10
             ELSE .5
         END
             AS shipping
    FROM (  SELECT customer_id, COUNT (order_id) AS total_compras
              FROM (SELECT ord.CUSTOMER_ID, ord.order_id, ord.fecha
                      FROM JAVIER.ORDERS ord
                     WHERE fecha < '01/01/2018' AND fecha > '31/12/2016') in_q
          GROUP BY customer_id) ou_q
ORDER BY total_compras DESC;
--Este es el segundo. Nose cual de los dos esta bien pero ambos me muestran resultados diferentes.

  SELECT ou_q.F_name,
         ou_q.L_name,
         ou_q.customer_id,
         ou_q.total_compras,
         ou_q.subtotal,
         CASE
             WHEN total_compras < 2
             THEN
                 (.15 * ou_q.subtotal)
             WHEN total_compras > 1 AND total_compras < 5
             THEN
                 (.10 * ou_q.subtotal)
             ELSE
                 (.5 * ou_q.subtotal)
         END
             AS shipping
    FROM (  SELECT in_q.F_name,
                   in_q.l_name,
                   in_q.customer_id,
                   SUM (in_q.quantity * in_q.price) AS subtotal,
                   COUNT (in_q.order_id)        AS total_compras
              FROM (SELECT ORD.ORDER_ID,
                           ORD.FECHA,
                           cus.F_name,
                           cus.l_name,
                           prod.price,
                           op.quantity,
                           cus.customer_id
                      FROM javier.orders ord
                           INNER JOIN javier.order_product op
                               ON op.order_id = ord.order_id
                           INNER JOIN javier.product prod
                               ON prod.product_id = op.PRODUCT_ID
                           INNER JOIN javier.customer cus
                               ON cus.customer_id = ord.customer_id
                     WHERE fecha < '01/01/2018' AND fecha > '31/12/2016') in_q
          GROUP BY in_q.F_name, in_q.l_name, in_q.customer_id) ou_q
ORDER BY total_compras DESC