-- Информация о сумме товаров заказанных под каждого клиента
select
	customers.name,
	sum(order_product.quantity * product.price)
from
	sales.customers customers
	left join sales.orders orders on customers.id = orders.customer_id
	left join sales.order_product order_product on orders.id = order_product.order_id
	left join sales.product product on order_product.product_id = product.id
GROUP BY
	customers.name
ORDER BY
	customers.name
;


-- Иерархический список категорий с подсчётом дочерних элементов
WITH RECURSIVE
	deepest_nodes as (
		SELECT
			id,
			parent_id,
			name,
			0 as multiplier
		FROM
			sales.categories t1
		WHERE
			NOT EXISTS (
				SELECT
					id
				FROM
					sales.categories
				WHERE
					parent_id = t1.id
			)
		UNION ALL
		SELECT
			cat.id,
			cat.parent_id,
			cat.name,
			1 as multiplier
		FROM
			sales.categories cat
			inner join deepest_nodes on cat.id = deepest_nodes.parent_id
	),
	nomenclature as (
		select
			parent_id,
			id,
			name,
			multiplier * count(*) as counting
		from
			deepest_nodes
		GROUP BY
			parent_id,
			id,
			name,
			multiplier
	),
	tree as (
		select
			parent_id,
			id,
			name,
			counting,
			0 lev,
			name::text as path_
		from
			nomenclature
		where
			parent_id is null
		UNION ALL
		select
			n.parent_id,
			n.id,
			n.name,
			n.counting,
			tree.lev + 1,
			tree.path_ || n.name
		from
			nomenclature n
			inner join tree on n.parent_id = tree.id
	)
select
	repeat(chr(160), lev * 4) || name as hierarchical_name,
	counting
from
	tree
order by
	path_
;