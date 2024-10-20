-- credits to David Gamba — https://www.davids-blog.gamba.ca/posts/steampipe-kubernetes.html

\pset pager 0

CREATE OR REPLACE FUNCTION cpu_convert(cpu TEXT)
    RETURNS BIGINT
    LANGUAGE plpgsql
AS $$
DECLARE
    v BIGINT;
BEGIN
    IF cpu LIKE '%m' THEN
        -- Convert from millicores
        SELECT
            CEIL(TRIM(TRAILING 'm' FROM cpu)::NUMERIC) INTO v;
    ELSIF cpu LIKE '%G' THEN
        -- Convert from gigabytes (G) to millicores
        SELECT
            CEIL(TRIM(TRAILING 'G' FROM cpu)::NUMERIC * 1000) INTO v; -- 1 G = 1000 millicores
    ELSE
        -- Convert from cores to millicores
        SELECT
            (cpu::NUMERIC * 1000) INTO v; -- 1 core = 1000 millicores
    END IF;

    RETURN v;
END;
$$;


CREATE OR REPLACE FUNCTION memory_bytes (memory text)
	RETURNS bigint
	LANGUAGE plpgsql
	AS $$
DECLARE
	v bigint;
BEGIN
	-- https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/
	-- base 10: m | "" | k | M | G | T | P | E
	-- base 2: Ki | Mi | Gi | Ti | Pi | Ei
	-- m fractions get rounded up
	CASE --
	WHEN memory LIKE '%m' THEN
		SELECT
			ceiling(trim(TRAILING 'm' FROM memory)::numeric / 1000) INTO v;
	WHEN memory LIKE '%k' THEN
		SELECT
			trim(TRAILING 'k' FROM memory)::numeric * 1000 INTO v;
	WHEN memory LIKE '%M' THEN
		SELECT
			trim(TRAILING 'M' FROM memory)::numeric * 1000_000 INTO v;
	WHEN memory LIKE '%G' THEN
		SELECT
			trim(TRAILING 'G' FROM memory)::numeric * 1000_000_000 INTO v;
	WHEN memory LIKE '%T' THEN
		SELECT
			trim(TRAILING 'T' FROM memory)::numeric * 1000_000_000_000 INTO v;
	WHEN memory LIKE '%P' THEN
		SELECT
			trim(TRAILING 'P' FROM memory)::numeric * 1000_000_000_000_000 INTO v;
	WHEN memory LIKE '%E' THEN
		SELECT
			trim(TRAILING 'E' FROM memory)::numeric * 1000_000_000_000_000 INTO v;
	WHEN memory LIKE '%Ki' THEN
		SELECT
			trim(TRAILING 'Ki' FROM memory)::numeric * 1024 INTO v;
	WHEN memory LIKE '%Mi' THEN
		SELECT
			trim(TRAILING 'Mi' FROM memory)::numeric * 1024 * 1024 INTO v;
	WHEN memory LIKE '%Gi' THEN
		SELECT
			trim(TRAILING 'Gi' FROM memory)::numeric * 1024 * 1024 * 1024 INTO v;
	WHEN memory LIKE '%Ti' THEN
		SELECT
			trim(TRAILING 'Ti' FROM memory)::numeric * 1024 * 1024 * 1024 * 1024 INTO v;
	WHEN memory LIKE '%Pi' THEN
		SELECT
			trim(TRAILING 'Pi' FROM memory)::numeric * 1024 * 1024 * 1024 * 1024 * 1024 INTO v;
	WHEN memory LIKE '%Ei' THEN
		SELECT
			trim(TRAILING 'Ei' FROM memory)::numeric * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 INTO v;
			--
			--
		ELSE
			SELECT
				memory::bigint INTO v;
	END CASE;
	RETURN v;
	END;
$$;


-- CREATE OR REPLACE FUNCTION bytes_to_mebib(bytes BIGINT)
-- RETURNS NUMERIC AS $$
-- BEGIN
--     IF bytes IS NULL THEN
--         RETURN NULL; -- Handle NULL input
--     END IF;
    
--     RETURN bytes / 1048576; -- 1 MiB = 1048576 bytes
-- END;
-- $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION bytes_to_mebi(bytes BIGINT)
RETURNS NUMERIC AS $$
BEGIN
    IF bytes IS NULL THEN
        RETURN NULL; -- Handle NULL input
    END IF;
    
    -- RETURN (bytes / 1048576)::TEXT || 'Mi'; -- Convert to text and append ' MiB'
    RETURN bytes / 1048576; -- Convert bytes to Mi
END;
$$ LANGUAGE plpgsql;


SELECT 'CPU Conversion Tests' AS "CPU Conversion Tests";

SELECT
    -- convert
    cpu_convert ('100m') AS "100m",
    cpu_convert ('256m') AS "256m",
    cpu_convert ('500m') AS "500m",
    cpu_convert ('1000m') AS "1000m",
    cpu_convert ('2000m') AS "2000m",
    cpu_convert ('1.5G') AS "1.5G",
    -- compare 
    cpu_convert ('100m')  = cpu_convert ('0.1G') AS "100m=0.1G",
    cpu_convert ('500m')  = cpu_convert ('0.5G') AS "500m=0.1G";

SELECT 'Memory to Bytes Conversion Tests' AS "Memory to Bytes Conversion Tests";

SELECT
    -- check conversions rates
    memory_bytes('1Mi') AS "1Mi",
    memory_bytes('1') AS "1",
    memory_bytes('1k') AS "1k",
    memory_bytes('1Ki') AS "1Ki",
    memory_bytes('1Mi') AS "1Mi",
    memory_bytes('1Gi') AS "1Gi";

SELECT
    -- check conversions
    memory_bytes('250Mi') AS "250Mi",
    memory_bytes('256Mi') AS "256Mi",
    memory_bytes('1k') AS "1k",
    memory_bytes('1Ki') AS "1Ki",
    memory_bytes('1Gi') AS "1Gi",
    memory_bytes('3000Mi') = 3145728000 AS "(3000Mi)=3145728000",
    memory_bytes('32k') = 32000 AS "(32k)=32000",
    memory_bytes('32Ki') = 32768 AS "(32Ki)=32768",
    memory_bytes('1Gi') = 1073741824 AS "(1Gi)=1073741824";


SELECT
    -- check for types
	memory_bytes('3m')     = 1 as subm,
	memory_bytes('3000m')  = 3 as m,
	memory_bytes('31750')  = 31750 AS empty,
	memory_bytes('32k')    = 32000 AS k,
	memory_bytes('32Ki')   = 32768 AS Ki,
	memory_bytes('10Mi')   = 10485760 AS Mi,
	memory_bytes('1.5Gi')  = 1610612736 AS Gi,
	memory_bytes('1.5Mi')  = 1572864 as fraction_Mi;



SELECT 'Memory Bytes to Milibyte(Mi) Conversion Tests' AS "Memory Bytes to Milibyte(Mi) Conversion Tests";

SELECT
    -- check conversions
    bytes_to_mebi(1073741824) AS "(1Gi)=1073741824b",
    bytes_to_mebi(512 * 1048576) AS "536870912b",
    bytes_to_mebi(256 * 1048576) AS "268435456b",
    bytes_to_mebi(10 * 1048576) AS "10485760",
    bytes_to_mebi(262144000)  = '250' AS "262144000=250Mi",
    bytes_to_mebi(268435456)  = '256' AS "268435456=256Mi=250Mb",
    bytes_to_mebi(1073741824) = '1024' AS "1073741824=1024Mi=1Gi";



