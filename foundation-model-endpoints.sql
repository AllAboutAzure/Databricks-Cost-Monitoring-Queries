WITH pricing AS (
  SELECT
    pricing.effective_list.default AS price,
    price_start_time,
    sku_name,
    COALESCE(price_end_time, NOW()) AS price_end_time
  FROM
    system.billing.list_prices p
),
filtered_data AS (
  SELECT
    --endpoint_name field was added in June 2024, previously it was null
    usage_metadata.endpoint_name AS endpoint_name,
    u.usage_quantity,
    price,
    u.workspace_id,
    DATE_FORMAT(usage_date, 'yyyy-MM') AS formatted_date,
    u.custom_tags,
    TRANSFORM(
      MAP_KEYS(u.custom_tags),
      (k, i) -> CONCAT(k, '=', MAP_VALUES(custom_tags) [i])
    ) AS key_value_tags
  FROM
    system.billing.usage u
    INNER JOIN pricing p ON p.sku_name = u.sku_name
    AND u.usage_start_time BETWEEN p.price_start_time
    AND p.price_end_time
  WHERE
    u.billing_origin_product = 'MODEL_SERVING'
    AND usage_type = "TOKEN"
    AND usage_date BETWEEN :start_date AND :end_date
    AND IF(:workspace_id='<ALL WORKSPACES>', TRUE, workspace_id = :workspace_id)
),
ppt_endpoint_data AS (
  SELECT
    endpoint_name,
    SUM(usage_quantity * price) AS total_dollar,
    formatted_date,
    ROW_NUMBER() OVER(
      PARTITION BY formatted_date
      ORDER BY
        SUM(usage_quantity * price) DESC
    ) AS RN
  FROM
    filtered_data
  --Apply tag filters
  WHERE
  (
    :tags = "include all tags"
    OR ARRAY_CONTAINS(key_value_tags, :tags)
    OR MAP_CONTAINS_KEY(custom_tags, :tags)
  )
  GROUP BY
    endpoint_name,
    formatted_date
)
SELECT
  *
FROM
  ppt_endpoint_data WHERE RN < 11