Use hw2;

CREATE TABLE IF NOT EXISTS opt_clients (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL
);

CREATE TABLE IF NOT EXISTS opt_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category ENUM('Category1', 'Category2', 'Category3', 'Category4', 'Category5') NOT NULL,
    description TEXT
);


CREATE TABLE IF NOT EXISTS opt_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    client_id CHAR(36),
    product_id INT,
    FOREIGN KEY (client_id) REFERENCES opt_clients(id),
    FOREIGN KEY (product_id) REFERENCES opt_products(id)
);

select
    (select CONCAT('air', ': ', cnt) from (select keyword, COUNT(*) as cnt -- Извлекает ключевое слово и подсчитывает, сколько раз оно встречается
           from (select p.product_name, 
                        case when p.description like '%air%' then 'air' when p.description like '%wife%' then 'wife'
                        end as keyword -- Это новый столбец, который будет содержать либо 'air', либо 'wife'.
                 from opt_products p join opt_orders o ON p.id = o.product_id -- Объединяет таблицы по id
                 where p.description like '%air%' or p.description like '%wife%') as sub1 -- фильтр и оставляет только дискр с air и wife
           where keyword = 'air'
           group by keyword) as sub2 -- Группируем результаты по ключевому слову 'air', чтобы подсчитать количество.
     where cnt = (select MAX(cnt) -- Находим количество продуктов со словом 'air'.
                  from (select COUNT(*) as cnt -- Подсчитываем количество продуктов со словом 'air'.
                        from (select p.product_name, 
                                     case when p.description like '%air%' then 'air' when p.description like '%wife%' then 'wife'
                                     end as keyword
                              from opt_products p
                              join opt_orders o on p.id = o.product_id  
                              where p.description like '%air%' or p.description like '%wife%') as sub3
                        where keyword = 'air'
                        group by keyword) as sub4)
     LIMIT 1) as min_cnt_air,

    (select CONCAT('wife', ': ', cnt) from (select keyword, COUNT(*) as cnt
           from (select p.product_name, 
                        case when p.description LIKE '%air%' THEN 'air' when p.description like '%wife%' then 'wife'
                        end as keyword
                 from opt_products p
                 join opt_orders o ON p.id = o.product_id 
                 where p.description like '%air%' or p.description like '%wife%') as sub1
           where keyword = 'wife'
           group by keyword) as sub2
  )
  

  
CREATE INDEX idx_opt_products 
ON opt_orders(product_id); 

with cte as ( -- Извлекаем записи продуктов, содержащие ключевые слова 'air' или 'wife'
    select p.id, p.product_name, p.description from opt_products p
    join opt_orders o on p.id = o.product_id -- Объединяем с таблицей по айди
    where p.description like '%air%' or p.description like '%wife%'), -- фильтруем
cnt_products as ( 
    select case when description like '%air%' then 'air' when description like '%wife%' then 'wife' end as keyword,
        COUNT(*) as cnt -- Подсчитываем количество таких записей
    from cte group by keyword
)
select 
    CONCAT('air', ': ', COALESCE(MAX(case when keyword = 'air' then cnt end), 0)) as cnt_air,
    CONCAT('wife', ': ', COALESCE(MAX(case when keyword = 'wife' then cnt end), 0)) as cnt_wife
from cnt_products;







-- --------------------------------------------------------------------------------------------------------------------------------

SELECT
    (SELECT CONCAT(product_name, ": ", cnt)
     FROM (SELECT product_name, COUNT(*) AS cnt
     	From ( Select p.product_id, p.description, p.product_name, o.product_id, p.id
           FROM opt_products p
           JOIN opt_orders o ON p.product_id = o.product_id 
           WHERE p.description LIKE '%air%' OR p.description LIKE '%wife%'
           GROUP BY p.product_name) AS sub2
     WHERE cnt = (SELECT MIN(cnt)
                  FROM (SELECT COUNT(*) AS cnt
                        FROM opt_products p
                        JOIN opt_orders o ON p.id = o.product_id  
                        WHERE p.description LIKE '%air%' OR p.description LIKE '%wife%'
                        GROUP BY p.product_name) AS sub4)
     LIMIT 1) AS min_cnt,

    (SELECT CONCAT(product_name, ": ", cnt)
     FROM (SELECT p.product_name, COUNT(*) AS cnt
     From (Select p.product_name, p.description, p.product_id, o.product_id
           FROM opt_products p
           JOIN opt_orders o ON p.product_id = o.product_id 
           WHERE p.description LIKE '%air%' OR p.description LIKE '%wife%'
           GROUP BY p.product_name
           ) AS sub2
     WHERE cnt = (SELECT MAX(cnt)
                  FROM (SELECT COUNT(*) AS cnt
                        FROM opt_products p
                        JOIN opt_orders o ON p.id = o.product_id  
                        WHERE p.description LIKE '%air%' OR p.description LIKE '%wife%'
                        GROUP BY p.product_name
                       ) AS sub4) LIMIT 1) AS max_cnt;

                      
                      
                      
                      


CREATE INDEX idx_opt_products 
ON opt_orders(product_id); 


with cte as (
    select id, product_name, description from opt_products
    where description like '%air%' or description like '%wife%'),

cnt_products as (
		select 
        case when description like '%air%' then 'air' when description like '%wife%' then 'wife' -- фильтрация
        end as keyword, COUNT(*) as cnt
    from cte 
    group by keyword)

select Max(case when keyword = 'air' then cnt end) AS cnt_air, MAX(case when keyword = 'wife' then cnt end) as cnt_wife  -- Шук макс знач cnt для продуктов  "air" и присваивает результат переменной cnt_air
from cnt_products; 



WITH cte AS (
    -- Извлекаем записи продуктов, содержащие ключевые слова 'air' или 'wife'
    SELECT p.id, p.product_name, p.description
    FROM opt_products p
    JOIN opt_orders o ON p.id = o.product_id
    WHERE p.description LIKE '%air%' OR p.description LIKE '%wife%'
),
cnt_products AS (
    -- Считаем количество продуктов с каждым ключевым словом
    SELECT 
        CASE 
            WHEN description LIKE '%air%' THEN 'air' 
            WHEN description LIKE '%wife%' THEN 'wife' 
        END AS keyword,
        COUNT(*) AS cnt
    FROM cte
    GROUP BY keyword
)
-- Объединяем результаты для вывода
SELECT 
    CONCAT('air', ': ', COALESCE(MAX(CASE WHEN keyword = 'air' THEN cnt END), 0)) AS cnt_air,
    CONCAT('wife', ': ', COALESCE(MAX(CASE WHEN keyword = 'wife' THEN cnt END), 0)) AS cnt_wife
FROM cnt_products;

