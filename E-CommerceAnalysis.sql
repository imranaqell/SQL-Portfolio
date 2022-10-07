#1. There is a giveaway going on, the prizes are said to be given to the first and latest customer.

SELECT 
    buyerid,
    shopid,
    MIN(order_time) AS first_order,
    MAX(order_time) AS last_order,
FROM order_tab
WHERE buyerid IS NOT NULL
GROUP BY buyerid, shopid
ORDER BY buyerid, shopid

#2. Buyer are given to customers who order an item twice or more in a month.

WITH order AS 
  (SELECT
    buyerid,
    DATE_TRUNC(date(order_time), month) AS month_order,
    COUNT(DISTINCT(buyerid)) AS count_order
  FROM order_tab
  WHERE buyer_id IS NOT NULL
  GROUP BY 1, 2
  ORDER BY 1, 2)

SELECT buyerid, month_order, count_order
FROM orders
WHERE count_order > 1

#3. First customer of each shop is awarded with a special discount coupon for several products.

WITH first_customer AS
  (SELECT 
    buyerid,
    shopid,
    order_time.
    RANK() OVER(PARTITION BY shopid 
                ORDER BY order_time DESC)
                AS ranks
  FROM order_tab
  WHERE buyerid IS NOT NULL
  GROUP BY 1, 2, 3
  ORDER BY 2)
  
SELECT buyerid, shopid, order_time
FROM first_customer
WHERE ranks = 1

#4. Top 10 buyers from Indonesia and Singapore by GMV.

WITH countries AS
  (SELECT 
    o.order_time AS order_time,
    o.gmv AS gmv,
    u.country AS country,
    RANK() OVER(PARTITION BY o.buyerid
                ORDER BY o.gmv DESC)
    AS ranks
  FROM order_tab o
  LEFT JOIN user_tab u
  ON o.buyerid = u.buyerid
  WHERE o.buyerid IS NOT NULL
  AND country IN ('ID', 'SG')
  GROUP BY 1, 2, 3, 4
  ORDER BY 3 DESC)

WITH GMV AS
  (SELECT
    buyerid,
    order_time,
    gmv,
    country,
    ROW_NUMBER() OVER(PARTITION BY country
                      ORDER BY gmv DESC)
    AS ranking
  FROM countries
  WHERE ranks = 1
  GROUP BY 1, 2, 3, 4
  ORDER BY 3 DESC)
SELECT buyerid, order_time, gmv, country
FROM GMV
WHERE ranking in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)  
