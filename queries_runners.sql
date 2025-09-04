-- 1. Liệt kê tất cả vận động viên với giới tính, hạng và quốc gia
SELECT runner_name, Gender, Division, Country
FROM runners_id;

-- 2. Tìm tất cả vận động viên đến từ Việt Nam tham gia cự ly Marathon
SELECT r.runner_name, r.Gender, r.Division, r.Country
FROM runners_id r
JOIN result_marathon m ON r.ID = m.ID
WHERE r.Country = 'VNM';

-- 3. Đếm số lượng vận động viên trong từng hạng
SELECT Division, COUNT(*) AS TotalRunners
FROM runners_id
GROUP BY Division;

-- 4. Top 5 thời gian về đích nhanh nhất ở 10K
SELECT r.runner_name, t.FinishTime
FROM runners_id r
JOIN result_10k t ON r.ID = t.ID
ORDER BY t.FinishTime ASC
LIMIT 5;

-- 5. Thời gian tốt nhất ở mốc 207k trong bán marathon
SELECT r.runner_name, h.point207k
FROM runners_id r
JOIN result_half_marathon h ON r.ID = h.ID
ORDER BY h.point207k ASC
LIMIT 1;

-- 6. Vận động viên có chip time marathon dưới 3 giờ
SELECT r.runner_name, m.ChipTime
FROM runners_id r
JOIN result_marathon m ON r.ID = m.ID
WHERE m.ChipTime < '03:00:00';

-- 7. Thời gian trung bình nam vs nữ ở 5K
SELECT r.Gender, AVG(TIME_TO_SEC(s.FinishTime)) / 60 AS AvgFinishTime_Minutes
FROM runners_id r
JOIN result_5k s ON r.ID = s.ID
GROUP BY r.Gender;

-- 8. Danh sách nhà tài trợ và tổng số tiền tài trợ
SELECT SponsorName, SUM(Amount) AS TotalSponsored
FROM sponsors
GROUP BY SponsorName;

-- 9. Vận động viên có nhiều hơn 1 nhà tài trợ và tier
SELECT r.runner_name, COUNT(s.SponsorID) AS TotalSponsors, GROUP_CONCAT(sp.Tier) AS SponsorTiers
FROM runners_id r
JOIN sponsorship s ON r.ID = s.RunnerID
JOIN sponsors sp ON s.SponsorID = sp.SponsorID
GROUP BY r.ID
HAVING COUNT(s.SponsorID) > 1;

-- 10. Nhà tài trợ bắt đầu từ năm 2020
SELECT DISTINCT sp.SponsorName, s.StartYear
FROM sponsors sp
JOIN sponsorship s ON sp.SponsorID = s.SponsorID
WHERE s.StartYear >= 2020;

-- 11. Quốc gia có nhiều vận động viên được tài trợ nhất
SELECT r.Country, COUNT(DISTINCT r.ID) AS TotalSponsoredRunners
FROM runners_id r
JOIN sponsorship s ON r.ID = s.RunnerID
GROUP BY r.Country
ORDER BY TotalSponsoredRunners DESC;

-- 12. Vận động viên, danh sách nhà tài trợ và thành tích tốt nhất
SELECT r.runner_name,
       GROUP_CONCAT(DISTINCT sp.SponsorName) AS Sponsors,
       LEAST(
         COALESCE(MIN(TIME_TO_SEC(res5.FinishTime)), 999999),
         COALESCE(MIN(TIME_TO_SEC(res10.FinishTime)), 999999),
         COALESCE(MIN(TIME_TO_SEC(reshm.FinishTime)), 999999),
         COALESCE(MIN(TIME_TO_SEC(resm.FinishTime)), 999999)
       ) AS BestFinishTime_Secs
FROM runners_id r
LEFT JOIN sponsorship s ON r.ID = s.RunnerID
LEFT JOIN sponsors sp ON s.SponsorID = sp.SponsorID
LEFT JOIN result_5k res5 ON r.ID = res5.ID
LEFT JOIN result_10k res10 ON r.ID = res10.ID
LEFT JOIN result_half_marathon reshm ON r.ID = reshm.ID
LEFT JOIN result_marathon resm ON r.ID = resm.ID
GROUP BY r.ID;

-- 13. Cự ly có nhiều người tham gia nhất
SELECT '5K' AS Race, COUNT(*) AS Total FROM result_5k
UNION ALL
SELECT '10K', COUNT(*) FROM result_10k
UNION ALL
SELECT 'Half Marathon', COUNT(*) FROM result_half_marathon
UNION ALL
SELECT 'Marathon', COUNT(*) FROM result_marathon
ORDER BY Total DESC;

-- 14. Trung bình số tiền tài trợ của elite vs open
SELECT r.Division, AVG(sp.Amount) AS AvgSponsoredAmount
FROM runners_id r
JOIN sponsorship s ON r.ID = s.RunnerID
JOIN sponsors sp ON s.SponsorID = sp.SponsorID
GROUP BY r.Division;

-- 15. Vận động viên tham gia nhiều hơn 1 cự ly
SELECT r.runner_name,
       (CASE WHEN res5.ID IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN res10.ID IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN reshm.ID IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN resm.ID IS NOT NULL THEN 1 ELSE 0 END) AS RacesJoined
FROM runners_id r
LEFT JOIN result_5k res5 ON r.ID = res5.ID
LEFT JOIN result_10k res10 ON r.ID = res10.ID
LEFT JOIN result_half_marathon reshm ON r.ID = reshm.ID
LEFT JOIN result_marathon resm ON r.ID = resm.ID
HAVING RacesJoined > 1;
