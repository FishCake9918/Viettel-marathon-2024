use viettel_marathon_2024;

-- Thành tích vận động viên --
-- 1. Top 5 vận động viên theo từng category --
WITH merged AS (
    SELECT r.runner_name, r.Gender, res.ChipTime, '5K' AS category
    FROM runners_id r
    JOIN result_5k res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL

    UNION ALL

    SELECT r.runner_name, r.Gender, res.ChipTime, '10K' AS category
    FROM runners_id r
    JOIN result_10k res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL

    UNION ALL

    SELECT r.runner_name, r.Gender, res.ChipTime, 'Half Marathon' AS category
    FROM runners_id r
    JOIN result_half_marathon res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL
    
	UNION ALL

    SELECT r.runner_name, r.Gender, res.ChipTime, 'Marathon' AS category
    FROM runners_id r
    JOIN result_marathon res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL
    -- thêm các bảng khác nếu có
),
ranked AS (
    SELECT runner_name, Gender, category, ChipTime,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY ChipTime ASC) AS rn
    FROM merged
)
SELECT category, runner_name, Gender, ChipTime
FROM ranked
WHERE rn <= 3
ORDER BY category, rn;

-- thành tích trung bình của từng quốc gia trong category Marathon --
SELECT r.Country,
       COUNT(*) AS total_runners,
       AVG(TIME_TO_SEC(res.ChipTime)) AS avg_chip_seconds
FROM runners_id r
JOIN result_marathon res ON r.ID = res.ID
WHERE res.ChipTime IS NOT NULL
GROUP BY r.Country
ORDER BY avg_chip_seconds ASC;

-- thành tích trung bình của từng quốc gia trong từng category --
SELECT r.Country,
       COUNT(*) AS total_runners,
       AVG(TIME_TO_SEC(res.ChipTime)) AS avg_chip_seconds
FROM runners_id r
JOIN result_10k res ON r.ID = res.ID -- thay result_10k thành kết quả mong muốn
WHERE res.ChipTime IS NOT NULL
GROUP BY r.Country
ORDER BY avg_chip_seconds ASC;

-- so sánh elite với open theo từng category
WITH merged AS (
    SELECT r.Division, res.ChipTime, '5K' AS category
    FROM runners_id r
    JOIN result_5k res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL

    UNION ALL

    SELECT r.Division, res.ChipTime, '10K' AS category
    FROM runners_id r
    JOIN result_10k res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL

    UNION ALL

    SELECT r.Division, res.ChipTime, 'half_marathon' AS category
    FROM runners_id r
    JOIN result_half_marathon res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL

    UNION ALL

    SELECT r.Division, res.ChipTime, 'marathon' AS category
    FROM runners_id r
    JOIN result_marathon res ON r.ID = res.ID
    WHERE res.ChipTime IS NOT NULL
)
SELECT category,
       Division,
       COUNT(*) AS so_van_dong_vien,
       AVG(TIME_TO_SEC(ChipTime)) AS avg_chip_seconds,
       MIN(ChipTime) AS fastest_time
FROM merged
GROUP BY category, Division
ORDER BY category, Division;

-- liệt kê số lượng nam/nữ cho từng 5K, 10K, Half Marathon, Marathon.
SELECT '5K' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_5k res ON r.ID = res.ID
GROUP BY r.Gender

UNION ALL

SELECT '10K' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_10k res ON r.ID = res.ID
GROUP BY r.Gender

UNION ALL

SELECT 'Half Marathon' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_half_marathon res ON r.ID = res.ID
GROUP BY r.Gender

UNION ALL

SELECT 'Marathon' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_marathon res ON r.ID = res.ID
GROUP BY r.Gender
ORDER BY Category, runner_count DESC;

-- Số lần sponsor có VĐV lọt top 10
WITH ranked AS (
    SELECT s.SponsorName, res.ChipTime,
           ROW_NUMBER() OVER (PARTITION BY cat ORDER BY res.ChipTime ASC) AS rank_in_cat,
           cat
    FROM (
        SELECT r.ID, '5K' AS cat, res.ChipTime
        FROM runners_id r JOIN result_5k res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL

        UNION ALL
        SELECT r.ID, '10K' AS cat, res.ChipTime
        FROM runners_id r JOIN result_10k res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL

        UNION ALL
        SELECT r.ID, 'Half Marathon' AS cat, res.ChipTime
        FROM runners_id r JOIN result_half_marathon res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL

        UNION ALL
        SELECT r.ID, 'Marathon' AS cat, res.ChipTime
        FROM runners_id r JOIN result_marathon res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL
    ) AS res
    JOIN sponsorship sp ON res.ID = sp.RunnerID
    JOIN sponsors s ON sp.SponsorID = s.SponsorID
)
SELECT SponsorName, cat, COUNT(*) AS top10_count
FROM ranked
WHERE rank_in_cat <= 10
GROUP BY SponsorName, cat
ORDER BY cat, top10_count DESC;

-- Số lượng sponsor tham gia theo quốc gia
SELECT r.Country, COUNT(DISTINCT s.SponsorName) AS sponsor_count
FROM runners_id r
JOIN sponsorship sp ON r.ID = sp.RunnerID
JOIN sponsors s ON sp.SponsorID = s.SponsorID
WHERE r.Division = 'elite'
GROUP BY r.Country
ORDER BY sponsor_count DESC;


WITH ranked AS (
    SELECT s.SponsorName, res.ChipTime,
           ROW_NUMBER() OVER (PARTITION BY cat ORDER BY res.ChipTime ASC) AS rank_in_cat,
           cat
    FROM (
        SELECT r.ID, '5K' AS cat, res.ChipTime
        FROM runners_id r JOIN result_5k res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL

        UNION ALL
        SELECT r.ID, '10K' AS cat, res.ChipTime
        FROM runners_id r JOIN result_10k res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL

        UNION ALL
        SELECT r.ID, 'Half Marathon' AS cat, res.ChipTime
        FROM runners_id r JOIN result_half_marathon res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL

        UNION ALL
        SELECT r.ID, 'Marathon' AS cat, res.ChipTime
        FROM runners_id r JOIN result_marathon res ON r.ID = res.ID
        WHERE r.Division = 'elite' AND res.ChipTime IS NOT NULL
    ) AS res
    JOIN sponsorship sp ON res.ID = sp.RunnerID
    JOIN sponsors s ON sp.SponsorID = s.SponsorID
)
SELECT SponsorName, COUNT(*) AS podium_finishes
FROM ranked
WHERE rank_in_cat <= 3
GROUP BY SponsorName
ORDER BY podium_finishes DESC;

-- Xu hướng số lượng VĐV theo từng cự ly
SELECT '5K' AS Category, COUNT(*) AS runner_count
FROM result_5k
UNION ALL
SELECT '10K' AS Category, COUNT(*) AS runner_count
FROM result_10k
UNION ALL
SELECT 'Half Marathon' AS Category, COUNT(*) AS runner_count
FROM result_half_marathon
UNION ALL
SELECT 'Marathon' AS Category, COUNT(*) AS runner_count
FROM result_marathon;

-- Tỉ lệ nam/nữ tham gia ở mỗi cự ly
SELECT '5K' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_5k res ON r.ID = res.ID
GROUP BY r.Gender
UNION ALL
SELECT '10K' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_10k res ON r.ID = res.ID
GROUP BY r.Gender
UNION ALL
SELECT 'Half Marathon' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_half_marathon res ON r.ID = res.ID
GROUP BY r.Gender
UNION ALL
SELECT 'Marathon' AS Category, r.Gender, COUNT(*) AS runner_count
FROM runners_id r
JOIN result_marathon res ON r.ID = res.ID
GROUP BY r.Gender;

-- So sánh Elite vs Open (số lượng + thành tích trung bình)
WITH merged AS (
    SELECT r.Division, res.ChipTime, '5K' AS Category
    FROM runners_id r JOIN result_5k res ON r.ID = res.ID
    UNION ALL
    SELECT r.Division, res.ChipTime, '10K'
    FROM runners_id r JOIN result_10k res ON r.ID = res.ID
    UNION ALL
    SELECT r.Division, res.ChipTime, 'Half Marathon'
    FROM runners_id r JOIN result_half_marathon res ON r.ID = res.ID
    UNION ALL
    SELECT r.Division, res.ChipTime, 'Marathon'
    FROM runners_id r JOIN result_marathon res ON r.ID = res.ID
)
SELECT Category, Division,
       COUNT(*) AS runner_count,
       AVG(TIME_TO_SEC(ChipTime)) AS avg_chip_seconds
FROM merged
WHERE ChipTime IS NOT NULL
GROUP BY Category, Division
ORDER BY Category, Division;

