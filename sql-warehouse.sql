SELECT
  t1.workspace_id,
  t2.workspace_name,
  t3.warehouse_name,
  t3.warehouse_type,
  t3.warehouse_size,
  SUM(t1.usage_quantity * list_prices.pricing.default) AS list_cost
FROM
  system.billing.usage t1
  INNER JOIN system.billing.list_prices list_prices
    ON t1.cloud = list_prices.cloud
    AND t1.sku_name = list_prices.sku_name
    AND t1.usage_start_time >= list_prices.price_start_time
    AND (t1.usage_end_time <= list_prices.price_end_time OR list_prices.price_end_time IS NULL)
  LEFT JOIN system.access.workspaces_latest t2
    ON t1.workspace_id = t2.workspace_id
  LEFT JOIN system.compute.warehouses t3
    ON t1.workspace_id = t3.workspace_id
    AND t1.usage_metadata.warehouse_id = t3.warehouse_id
WHERE
  t1.billing_origin_product = 'SQL'
  AND t1.usage_metadata.warehouse_id IS NOT NULL
  AND t1.usage_date BETWEEN :param_start_date AND :param_end_date
  AND if(:workspace_id='<ALL WORKSPACES>', true, t1.workspace_id = regexp_extract(:workspace_id, 'id: (\\d+)',1))
GROUP BY
  t1.workspace_id,
  t2.workspace_name,
  t3.warehouse_name,
  t3.warehouse_type,
  t3.warehouse_size
ORDER BY
  list_cost DESC