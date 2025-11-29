SELECT
  SE.endpoint_name,
  DATE(EU.request_time) AS request_date,
  SUM(EU.input_character_count) AS total_input_character_count,
  SUM(EU.output_character_count) AS total_output_character_count,
  SUM(EU.input_token_count) AS total_input_token_count,
  SUM(EU.output_token_count) AS total_output_token_count
FROM system.serving.served_entities AS SE
INNER JOIN system.serving.endpoint_usage AS EU
  ON SE.served_entity_id = EU.served_entity_id
WHERE if(:workspace_id='<ALL WORKSPACES>', true, SE.workspace_id = :workspace_id)
  AND EU.request_time BETWEEN :start_date AND :end_date
GROUP BY SE.endpoint_name, DATE(EU.request_time)
HAVING
  SUM(EU.input_character_count) > 0
  OR SUM(EU.output_character_count) > 0
  OR SUM(EU.input_token_count) > 0
  OR SUM(EU.output_token_count) > 0
ORDER BY DATE(EU.request_time) DESC;