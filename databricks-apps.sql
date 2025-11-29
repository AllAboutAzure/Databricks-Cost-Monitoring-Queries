SELECT 
  u.workspace_id,
  u.sku_name,
  u.usage_date,
  u.usage_metadata.app_name,
  ROUND(
    SUM(
      u.usage_quantity * p.pricing.effective_list.default
    ),
    2
  ) AS estimated_cost
FROM system.billing.usage u
JOIN system.billing.list_prices p
  ON u.sku_name = p.sku_name
  AND u.cloud = p.cloud
  AND u.usage_unit = p.usage_unit
  AND u.usage_end_time BETWEEN p.price_start_time AND COALESCE(p.price_end_time, DATE_ADD(current_date, 1))
WHERE if(:workspace_id='<ALL WORKSPACES>', true, u.workspace_id = regexp_extract(:workspace_id, 'id: (\\d+)',1))
  AND u.billing_origin_product = 'APPS'
  AND u.usage_date BETWEEN :param_start_date AND :param_end_date
GROUP BY u.workspace_id, u.sku_name, u.usage_date, u.usage_metadata.app_name