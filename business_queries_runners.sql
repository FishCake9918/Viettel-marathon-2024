-- 1. Sự phân bổ số lượng người tham gia theo cự ly và hạng – elite so với open
SELECT Division, '5K' AS Race, COUNT(*) AS Total
FROM runners_id r JOIN result_5k k ON r.ID = k.ID
GROUP BY Division
UNION ALL
SELECT Division, '10K', COUNT(*)
FROM runners_id r JOIN result_10k t ON r.ID = t.ID
GROUP BY Division
UNION ALL
SELECT Division, 'Half Marathon', COUNT(*)
FROM runners_id r JOIN result_half_marathon h ON r.ID = h.ID
GROUP BY Division
UNION ALL
SELECT Division, 'Marathon', COUNT(*)
FROM runners_id r JOIN result_marathon m ON r.ID = m.ID
GROUP BY Division;

-- 2. Thống kê thời gian trung bình theo quốc gia (mọi hạng)
SELECT r.Country, AVG(TIME_TO_SEC(m.FinishTime)) / 60 AS AvgFinishMin
FROM runners_id r
JOIN result_marathon m ON r.ID = m.ID
GROUP BY r.Country
ORDER BY AvgFinishMin ASC;

-- 3. Tỷ lệ hoàn thành giải chạy ở từng cự ly (giả định có bảng registrations)
SELECT Race, 
       COUNT(CASE WHEN Finished = 1 THEN 1 END) * 100.0 / COUNT(*) AS CompletionRate
FROM registrations
GROUP BY Race;

-- 4. So sánh thành tích giữa elite được tài trợ và elite không tài trợ
SELECT 
   CASE WHEN s.RunnerID IS NOT NULL THEN 'Sponsored' ELSE 'Not Sponsored' END AS EliteGroup,
   AVG(TIME_TO_SEC(m.FinishTime))/60 AS AvgFinishMin
FROM runners_id r
LEFT JOIN sponsorship s ON r.ID = s.RunnerID
JOIN result_marathon m ON r.ID = m.ID
WHERE r.Division = 'elite'
GROUP BY EliteGroup;

-- 5. Top 10% elite ở từng cự ly
SELECT r.runner_name, m.FinishTime
FROM runners_id r
JOIN result_marathon m ON r.ID = m.ID
WHERE r.Division = 'elite'
ORDER BY m.FinishTime ASC
LIMIT (SELECT CEIL(COUNT(*)*0.1) FROM runners_id r2 
       JOIN result_marathon m2 ON r2.ID = m2.ID
       WHERE r2.Division = 'elite');

-- 6. Nhà tài trợ chi nhiều nhất cho elite và phân tích nhóm tài trợ
SELECT sp.SponsorName, SUM(sp.Amount) AS TotalSponsored,
       GROUP_CONCAT(DISTINCT r.Country) AS Countries,
       GROUP_CONCAT(DISTINCT r.Gender) AS Genders
FROM sponsorship s
JOIN sponsors sp ON s.SponsorID = sp.SponsorID
JOIN runners_id r ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
GROUP BY sp.SponsorName
ORDER BY TotalSponsored DESC;

-- 7. Tổng số tiền tài trợ cho elite phân theo từng năm
SELECT s.StartYear, SUM(sp.Amount) AS TotalSponsored
FROM sponsorship s
JOIN sponsors sp ON s.SponsorID = sp.SponsorID
JOIN runners_id r ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
GROUP BY s.StartYear
ORDER BY s.StartYear;

-- 8. ROI tiềm năng: So sánh số tiền tài trợ với số lần elite xuất hiện trong top đầu
SELECT sp.SponsorName,
       SUM(sp.Amount) AS TotalSponsored,
       COUNT(CASE WHEN m.FinishTime <= '03:00:00' THEN 1 END) AS TopFinishes
FROM sponsors sp
JOIN sponsorship s ON sp.SponsorID = s.SponsorID
JOIN runners_id r ON r.ID = s.RunnerID
JOIN result_marathon m ON r.ID = m.ID
WHERE r.Division = 'elite'
GROUP BY sp.SponsorName;

-- 9. Phân tích danh mục nhà tài trợ theo tier
SELECT Tier, COUNT(DISTINCT SponsorID) AS NumSponsors,
       SUM(Amount) AS TotalSponsored
FROM sponsors
GROUP BY Tier;

-- 10. Bao nhiêu vận động viên elite nhận nhiều hơn một nhà tài trợ
SELECT r.runner_name, COUNT(s.SponsorID) AS TotalSponsors
FROM runners_id r
JOIN sponsorship s ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
GROUP BY r.ID
HAVING COUNT(s.SponsorID) > 1;

-- 11. Những cự ly thu hút nhiều tài trợ elite nhất
SELECT '5K' AS Race, COUNT(DISTINCT r.ID) AS SponsoredRunners
FROM runners_id r
JOIN result_5k k ON r.ID = k.ID
JOIN sponsorship s ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
UNION ALL
SELECT '10K', COUNT(DISTINCT r.ID)
FROM runners_id r
JOIN result_10k t ON r.ID = t.ID
JOIN sponsorship s ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
UNION ALL
SELECT 'Half Marathon', COUNT(DISTINCT r.ID)
FROM runners_id r
JOIN result_half_marathon h ON r.ID = h.ID
JOIN sponsorship s ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
UNION ALL
SELECT 'Marathon', COUNT(DISTINCT r.ID)
FROM runners_id r
JOIN result_marathon m ON r.ID = m.ID
JOIN sponsorship s ON r.ID = s.RunnerID
WHERE r.Division = 'elite';

-- 12. Vận động viên elite tham gia nhiều cự ly
SELECT r.runner_name,
       (CASE WHEN k.ID IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN t.ID IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN h.ID IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN m.ID IS NOT NULL THEN 1 ELSE 0 END) AS RacesJoined
FROM runners_id r
LEFT JOIN result_5k k ON r.ID = k.ID
LEFT JOIN result_10k t ON r.ID = t.ID
LEFT JOIN result_half_marathon h ON r.ID = h.ID
LEFT JOIN result_marathon m ON r.ID = m.ID
WHERE r.Division = 'elite'
HAVING RacesJoined > 1;

-- 13. Tương quan quốc gia, giới tính và thành tích elite
SELECT r.Country, r.Gender, AVG(TIME_TO_SEC(m.FinishTime))/60 AS AvgFinishMin
FROM runners_id r
JOIN result_marathon m ON r.ID = m.ID
WHERE r.Division = 'elite'
GROUP BY r.Country, r.Gender
ORDER BY AvgFinishMin ASC;

-- 14. Các năm tài trợ mạnh nhất và nhà tài trợ mới nổi
SELECT s.StartYear, sp.SponsorName, SUM(sp.Amount) AS TotalSponsored
FROM sponsorship s
JOIN sponsors sp ON s.SponsorID = sp.SponsorID
JOIN runners_id r ON r.ID = s.RunnerID
WHERE r.Division = 'elite'
GROUP BY s.StartYear, sp.SponsorName
ORDER BY s.StartYear DESC, TotalSponsored DESC;

-- 15. Dự báo: tăng 10% tài trợ Gold – nhóm elite hưởng lợi
SELECT r.Country, r.Gender, 'Marathon' AS Race, SUM(sp.Amount)*1.1 AS ProjectedSponsored
FROM sponsorship s
JOIN sponsors sp ON s.SponsorID = sp.SponsorID
JOIN runners_id r ON r.ID = s.RunnerID
JOIN result_marathon m ON r.ID = m.ID
WHERE r.Division = 'elite' AND sp.Tier = 'Gold'
GROUP BY r.Country, r.Gender
ORDER BY ProjectedSponsored DESC;
