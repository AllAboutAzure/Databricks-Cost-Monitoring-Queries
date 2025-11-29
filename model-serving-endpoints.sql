WITH pricing AS (
  select
    pricing.effective_list.default as price,
    price_start_time,
    sku_name,
    COALESCE(price_end_time, NOW()) as price_end_time
  from
    system.billing.list_prices p
),
endpoint_data AS (
  SELECT
    usage_quantity * price as cost,
    --endpoint_name field was added in June 2024, previously it was null
    IF(
      usage_metadata.endpoint_name IS NULL,
      'not populated',
      usage_metadata.endpoint_name
    ) AS endpoint_name,
    u.usage_quantity,
    u.usage_start_time,
    u.usage_date,
    u.usage_type,
    CASE
      WHEN u.usage_type = 'TOKEN' THEN 'PAY_PER_TOKEN'
      WHEN product_features ['serving_type'] = 'MODEL' THEN 'CPU_MODEL'
      ELSE product_features ['serving_type']
    END AS serving_type,
    u.custom_tags,
    TRANSFORM(
      MAP_KEYS(custom_tags),
      (k, i) -> CONCAT(k, '=', MAP_VALUES(custom_tags) [i])
    ) AS key_value_tags,
    u.workspace_id,
    u.usage_metadata,
    u.billing_origin_product
  FROM
    system.billing.usage u
    INNER JOIN pricing p ON p.sku_name = u.sku_name
    AND u.usage_start_time BETWEEN p.price_start_time AND p.price_end_time
    AND if(:workspace_id='<ALL WORKSPACES>', true, workspace_id = :workspace_id)
  WHERE
    u.billing_origin_product = 'MODEL_SERVING'
    AND usage_date BETWEEN :start_date AND :end_date
)
SELECT
  *
FROM
  endpoint_data
WHERE
  (
    :tags = "include all tags"
    OR ARRAY_CONTAINS(key_value_tags, :tags)
    OR MAP_CONTAINS_KEY(custom_tags, :tags)
  )