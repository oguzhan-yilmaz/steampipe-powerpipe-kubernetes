mod "local" {
  title = "steampipe"
}



dashboard "dashboard_tutorial" {
  title = "Dashboard Tutorial"
  text {
    value = "This will guide you through the key concepts of building your own dashboards."
  }
  table {
    title = "Deployments: Limits and Requests"
    width = 15
    query = query.deployments
  }
  // table {
  //   title = "VPA CPU + Memory"
  //   width = 15
  //   query = query.vpa_cpu_and_memory
  // }
  table {
    title = "VPA CPU"
    width = 15
    query = query.vpa_cpu_only
  }
  table {
    title = "VPA Memory"
    width = 15
    query = query.vpa_memory_only
  }
}
query "vpa_summary" {
  sql = <<-EOQ
    SELECT 
        namespace,
        name,
        container_recommendation ->> 'containerName' AS container_name,
        container_recommendation -> 'lowerBound' ->> 'cpu' AS lower_bound_cpu,
        container_recommendation -> 'target' ->> 'cpu' AS target_cpu,
        container_recommendation -> 'uncappedTarget' ->> 'cpu' AS uncapped_target_cpu,
        container_recommendation -> 'upperBound' ->> 'cpu' AS upper_bound_cpu,
        container_recommendation -> 'lowerBound' ->> 'memory' AS lower_bound_memory,
        container_recommendation -> 'target' ->> 'memory' AS target_memory,
        container_recommendation -> 'uncappedTarget' ->> 'memory' AS uncapped_target_memory,
        container_recommendation -> 'upperBound' ->> 'memory' AS upper_bound_memory
    FROM 
        kubernetes_verticalpodautoscaler,
        jsonb_array_elements(recommendation::jsonb -> 'containerRecommendations') AS container_recommendation;
  EOQ
}
query "deployments" {
  sql = <<-EOQ
    SELECT 
        namespace,
        name AS deployment_name,
        container->>'name' AS container_name,
        COALESCE(container->'resources'->'requests'->>'cpu', NULL) AS requests_cpu,
        COALESCE(container->'resources'->'limits'->>'cpu', NULL) AS limits_cpu,
        COALESCE(container->'resources'->'requests'->>'memory', NULL) AS requests_memory,
        COALESCE(container->'resources'->'limits'->>'memory', NULL) AS limits_memory
    FROM 
        kubernetes_deployment,
        jsonb_array_elements(template::jsonb->'spec'->'containers') AS container
    WHERE 
        template IS NOT NULL;
  EOQ
}
query "vpa_cpu_and_memory" {
  sql = <<-EOQ
    WITH deployment_data AS (
        SELECT 
            namespace,
            name AS deployment_name,
            container->>'name' AS container_name,
            COALESCE(container->'resources'->'limits'->>'cpu', NULL) AS limits_cpu,
            COALESCE(container->'resources'->'limits'->>'memory', NULL) AS limits_memory,
            COALESCE(container->'resources'->'requests'->>'cpu', NULL) AS requests_cpu,
            COALESCE(container->'resources'->'requests'->>'memory', NULL) AS requests_memory
        FROM 
            kubernetes_deployment,
            jsonb_array_elements(template::jsonb->'spec'->'containers') AS container
        WHERE 
            template IS NOT NULL
    ),
    recommendation_data AS (
        SELECT 
            namespace,
            name,
            container_recommendation ->> 'containerName' AS container_name,
            container_recommendation -> 'lowerBound' ->> 'cpu' AS lower_bound_cpu,
            container_recommendation -> 'lowerBound' ->> 'memory' AS lower_bound_memory,
            container_recommendation -> 'target' ->> 'cpu' AS target_cpu,
            container_recommendation -> 'target' ->> 'memory' AS target_memory,
            container_recommendation -> 'uncappedTarget' ->> 'cpu' AS uncapped_target_cpu,
            container_recommendation -> 'uncappedTarget' ->> 'memory' AS uncapped_target_memory,
            container_recommendation -> 'upperBound' ->> 'cpu' AS upper_bound_cpu,
            container_recommendation -> 'upperBound' ->> 'memory' AS upper_bound_memory
        FROM 
            kubernetes_verticalpodautoscaler,
            jsonb_array_elements(recommendation::jsonb -> 'containerRecommendations') AS container_recommendation
    )
    SELECT 
        d.namespace,
        d.deployment_name,
        d.container_name,
        d.requests_cpu,
        d.limits_cpu,
        r.lower_bound_cpu AS rec_lower_bound_cpu,
        r.target_cpu AS rec_target_cpu,
        -- r.uncapped_target_cpu AS rec_uncapped_target_cpu,
        r.upper_bound_cpu AS rec_upper_bound_cpu,
        d.requests_memory,
        d.limits_memory,
        r.lower_bound_memory AS rec_lower_bound_mem,
        r.target_memory AS rec_target_mem,
        -- r.uncapped_target_memory AS rec_uncapped_target_mem,
        r.upper_bound_memory AS rec_upper_bound_mem
    FROM 
        deployment_data d
    JOIN 
        recommendation_data r
    ON 
        d.namespace = r.namespace 
        AND d.container_name = r.container_name;
  EOQ
}
query "vpa_cpu_only" {
  sql = <<-EOQ
    WITH deployment_data AS (
        SELECT 
            namespace,
            name AS deployment_name,
            container->>'name' AS container_name,
            COALESCE(container->'resources'->'limits'->>'cpu', NULL) AS limits_cpu,
            COALESCE(container->'resources'->'limits'->>'memory', NULL) AS limits_memory,
            COALESCE(container->'resources'->'requests'->>'cpu', NULL) AS requests_cpu,
            COALESCE(container->'resources'->'requests'->>'memory', NULL) AS requests_memory
        FROM 
            kubernetes_deployment,
            jsonb_array_elements(template::jsonb->'spec'->'containers') AS container
        WHERE 
            template IS NOT NULL
    ),
    recommendation_data AS (
        SELECT 
            namespace,
            name,
            container_recommendation ->> 'containerName' AS container_name,
            container_recommendation -> 'lowerBound' ->> 'cpu' AS lower_bound_cpu,
            container_recommendation -> 'lowerBound' ->> 'memory' AS lower_bound_memory,
            container_recommendation -> 'target' ->> 'cpu' AS target_cpu,
            container_recommendation -> 'target' ->> 'memory' AS target_memory,
            container_recommendation -> 'uncappedTarget' ->> 'cpu' AS uncapped_target_cpu,
            container_recommendation -> 'uncappedTarget' ->> 'memory' AS uncapped_target_memory,
            container_recommendation -> 'upperBound' ->> 'cpu' AS upper_bound_cpu,
            container_recommendation -> 'upperBound' ->> 'memory' AS upper_bound_memory
        FROM 
            kubernetes_verticalpodautoscaler,
            jsonb_array_elements(recommendation::jsonb -> 'containerRecommendations') AS container_recommendation
    )
    SELECT 
        d.namespace AS "Namespace",
        d.deployment_name AS "Deployment",
        d.container_name AS "Container",
        d.requests_cpu AS "Real CPU Request",
        d.limits_cpu AS "Real CPU Limit",
        cpu_m2(d.requests_cpu) AS "CPU Request",
        cpu_m2(d.limits_cpu) AS "CPU Limit",
        cpu_m2(r.lower_bound_cpu) AS "Rec. Lower CPU",
        cpu_m2(r.target_cpu)  AS "Rec. Target CPU",
        -- cpu_m2(r.uncapped_target_cpu) AS rec_uncapped_target_cpu,
        cpu_m2(r.upper_bound_cpu) AS "Rec. Upper CPU"
    FROM 
        deployment_data d
    JOIN 
        recommendation_data r
    ON 
        d.namespace = r.namespace 
        AND d.container_name = r.container_name;
  EOQ
}
query "vpa_memory_only" {
  sql = <<-EOQ
    WITH deployment_data AS (
        SELECT 
            namespace,
            name AS deployment_name,
            container->>'name' AS container_name,
            COALESCE(container->'resources'->'limits'->>'cpu', NULL) AS limits_cpu,
            COALESCE(container->'resources'->'limits'->>'memory', NULL) AS limits_memory,
            COALESCE(container->'resources'->'requests'->>'cpu', NULL) AS requests_cpu,
            COALESCE(container->'resources'->'requests'->>'memory', NULL) AS requests_memory
        FROM 
            kubernetes_deployment,
            jsonb_array_elements(template::jsonb->'spec'->'containers') AS container
        WHERE 
            template IS NOT NULL
    ),
    recommendation_data AS (
        SELECT 
            namespace,
            name,
            container_recommendation ->> 'containerName' AS container_name,
            container_recommendation -> 'lowerBound' ->> 'cpu' AS lower_bound_cpu,
            container_recommendation -> 'lowerBound' ->> 'memory' AS lower_bound_memory,
            container_recommendation -> 'target' ->> 'cpu' AS target_cpu,
            container_recommendation -> 'target' ->> 'memory' AS target_memory,
            container_recommendation -> 'uncappedTarget' ->> 'cpu' AS uncapped_target_cpu,
            container_recommendation -> 'uncappedTarget' ->> 'memory' AS uncapped_target_memory,
            container_recommendation -> 'upperBound' ->> 'cpu' AS upper_bound_cpu,
            container_recommendation -> 'upperBound' ->> 'memory' AS upper_bound_memory
        FROM 
            kubernetes_verticalpodautoscaler,
            jsonb_array_elements(recommendation::jsonb -> 'containerRecommendations') AS container_recommendation
    )
    SELECT 
        d.namespace AS "Namespace",
        d.deployment_name AS "Deployment",
        d.container_name AS "Container",
        -- d.requests_memory AS "Real RAM Request",
        bytes_to_mi(memory_bytes(d.requests_memory)) AS "RAM Request",
        bytes_to_mi(memory_bytes(d.limits_memory)) AS "RAM Limit",
        bytes_to_mi(memory_bytes(r.lower_bound_memory)) AS "Rec: Lower RAM",
        bytes_to_mi(memory_bytes(r.target_memory)) AS "Rec: Target RAM",
        -- bytes_to_mi(memory_bytes(r.uncapped_target_memory)) AS rec_uncapped_target_mem,
        bytes_to_mi(memory_bytes(r.upper_bound_memory)) AS "Rec: Upper RAM"
    FROM 
        deployment_data d
    JOIN 
        recommendation_data r
    ON 
        d.namespace = r.namespace 
        AND d.container_name = r.container_name;
  EOQ
}