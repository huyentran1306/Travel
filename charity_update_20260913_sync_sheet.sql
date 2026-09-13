-- ================================================================
-- 🌟 GIEO NẮNG 2026 - SCRIPT UPDATE RIÊNG: ĐỒNG BỘ GOOGLE SHEET
-- ================================================================
-- Ngày tạo: 13/09/2026
-- Nguồn dữ liệu: https://docs.google.com/spreadsheets/u/0/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview
-- Mục đích:
--   1. Cập nhật số lượng em nhỏ thành 340 em
--   2. Bổ sung người góp tiền mặt: Ú (500.000đ)
--   3. Bổ sung hiện vật: c. Phượng Lucy (Gấu bông), Bùi Thị Loan (3 thùng sữa)
--   4. Cập nhật số tiền thực chi & người mua cho toàn bộ 32 khoản chi (status = 'DONE')
--   5. Báo cáo đối soát (Tổng thu: 42.393.800đ, Thực chi: 35.043.000đ, Tồn quỹ: 7.350.800đ)
--
-- HƯỚNG DẪN: Copy toàn bộ script này và bấm RUN trong Supabase SQL Editor
-- ================================================================

-- 1. CẬP NHẬT CẤU HÌNH (340 EM)
INSERT INTO charity_settings (key, value)
VALUES ('children_count', '340')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now();


-- 2. THÊM KHOẢN GÓP TIỀN MẶT MỚI (Ú - 500.000đ)
INSERT INTO charity_fund_entries (charity_id, type, donor_name, content, amount, date, status, note)
SELECT 'GN2026', 'INCOME', 'Ú', 'Ú', 500000, '2026-08-01', 'DONE', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM charity_fund_entries 
    WHERE charity_id = 'GN2026' AND type = 'INCOME' AND donor_name = 'Ú'
);


-- 3. CẬP NHẬT HIỆN VẬT MỚI
-- 3.1 c. Phượng Lucy - Gấu bông
INSERT INTO charity_donations (charity_id, donor_name, item_name, status, date)
SELECT 'GN2026', 'c. Phượng Lucy', 'Gấu bông', 'RECEIVED', '2026-08-01'
WHERE NOT EXISTS (
    SELECT 1 FROM charity_donations 
    WHERE charity_id = 'GN2026' AND donor_name = 'c. Phượng Lucy' AND item_name = 'Gấu bông'
);

-- 3.2 Bùi Thị Loan - 3 thùng sữa
INSERT INTO charity_donations (charity_id, donor_name, item_name, quantity, unit, status, date)
SELECT 'GN2026', 'Bùi Thị Loan', 'Sữa', 3, 'thùng', 'RECEIVED', '2026-08-01'
WHERE NOT EXISTS (
    SELECT 1 FROM charity_donations 
    WHERE charity_id = 'GN2026' AND donor_name = 'Bùi Thị Loan'
);

-- 3.3 Chuẩn hóa tên c. Trâm -> c. Trâm Võ - b.Hải
UPDATE charity_donations 
SET donor_name = 'c. Trâm Võ - b.Hải' 
WHERE charity_id = 'GN2026' AND donor_name = 'c. Trâm';


-- 4. CẬP NHẬT TOÀN BỘ CÁC KHOẢN THỰC CHI (STATUS = 'DONE')

-- 4.1 Quà cho trẻ (20.678.000 đ)
UPDATE charity_fund_entries 
SET actual_amount = 7965000, status = 'DONE', note = 'c.Loan góp 3 thùng -> mua 27 thùng (295k/thùng); Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Sữa (%';

UPDATE charity_fund_entries 
SET actual_amount = 5133000, status = 'DONE', note = '354 hộp x 14.500đ; Người mua: Hải'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bánh gấu (%';

UPDATE charity_fund_entries 
SET actual_amount = 1645000, status = 'DONE', note = '350 túi x 4.700đ; Người mua: Hải'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Kẹo dẻo (%';

UPDATE charity_fund_entries 
SET actual_amount = 1750000, status = 'DONE', note = '350 bịch x 5.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Snack (%';

UPDATE charity_fund_entries 
SET actual_amount = 2275000, status = 'DONE', note = '350 cái x 6.500đ; Người mua: c. Trâm'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Lồng đèn (%';

UPDATE charity_fund_entries 
SET actual_amount = 1310000, status = 'DONE', note = '350 cái x 3.743đ; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đèn nháy (%';

UPDATE charity_fund_entries 
SET actual_amount = 600000, status = 'DONE', note = '350 cái x 1.714đ; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Túi đựng quà (%';

-- 4.2 Gian hàng ẩm thực (1.395.000 đ)
UPDATE charity_fund_entries 
SET actual_amount = 0, status = 'DONE', note = 'Quỹ còn'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Ly nhựa (%';

UPDATE charity_fund_entries 
SET actual_amount = 39000, status = 'DONE', note = 'Mua 240 cái (quỹ còn 100 cái); Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Ống hút (%';

UPDATE charity_fund_entries 
SET actual_amount = 200000, status = 'DONE', note = '4 kg x 50.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Tắc (%';

UPDATE charity_fund_entries 
SET actual_amount = 206000, status = 'DONE', note = '8 kg; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đường (%';

UPDATE charity_fund_entries 
SET actual_amount = 315000, status = 'DONE', note = '10 hộp; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Trà túi lọc (%';

UPDATE charity_fund_entries 
SET actual_amount = 125000, status = 'DONE', note = '5 bao x 25.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đá (%';

UPDATE charity_fund_entries 
SET actual_amount = 450000, status = 'DONE', note = '30 kg x 15.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Dưa Hấu (%';

UPDATE charity_fund_entries 
SET actual_amount = 60000, status = 'DONE', note = 'Khăn giấy, khăn ướt, băng keo; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Lặt vặt (%';

-- 4.3 Gian hàng hội chợ (175.000 đ)
UPDATE charity_fund_entries 
SET actual_amount = 42000, status = 'DONE', note = '10 cái; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Vòng ném vòng (%';

UPDATE charity_fund_entries 
SET actual_amount = 69000, status = 'DONE', note = '5 cái; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Chóp ném vòng (%';

UPDATE charity_fund_entries 
SET actual_amount = 37000, status = 'DONE', note = '10 quả; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bóng ném bóng vào rổ (%';

UPDATE charity_fund_entries 
SET actual_amount = 0, status = 'DONE', note = 'Quỹ còn 5 cái'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Rổ (%';

UPDATE charity_fund_entries 
SET actual_amount = 0, status = 'DONE', note = 'Quỹ còn 10 đôi'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đũa gắp bóng (%';

UPDATE charity_fund_entries 
SET actual_amount = 27000, status = 'DONE', note = '10 cái; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bóng bàn gắp bằng đũa (%';

-- 4.4 Nấu ăn (7.795.000 đ - Tất cả c.Yến mua)
UPDATE charity_fund_entries 
SET actual_amount = 600000, status = 'DONE', note = '20 kg x 30.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Nui (%';

UPDATE charity_fund_entries 
SET actual_amount = 3600000, status = 'DONE', note = '30 kg x 120.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Sườn heo (%';

UPDATE charity_fund_entries 
SET actual_amount = 1000000, status = 'DONE', note = '10 kg x 100.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Thịt xay (%';

UPDATE charity_fund_entries 
SET actual_amount = 840000, status = 'DONE', note = '6 kg x 140.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Chả xay (%';

UPDATE charity_fund_entries 
SET actual_amount = 720000, status = 'DONE', note = '900 quả x 800đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Trứng cút (%';

UPDATE charity_fund_entries 
SET actual_amount = 375000, status = 'DONE', note = '15 kg x 25.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Củ cải, cà rốt (%';

UPDATE charity_fund_entries 
SET actual_amount = 300000, status = 'DONE', note = 'Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Hành ngò, gia vị%';

UPDATE charity_fund_entries 
SET actual_amount = 280000, status = 'DONE', note = '8 lốc x 35.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Tô giấy (%';

UPDATE charity_fund_entries 
SET actual_amount = 60000, status = 'DONE', note = '4 lốc x 15.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Muỗng (%';

UPDATE charity_fund_entries 
SET actual_amount = 20000, status = 'DONE', note = 'Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bao tay%';

-- 4.5 Di chuyển (5.000.000 đ)
UPDATE charity_fund_entries 
SET actual_amount = 5000000, status = 'DONE', note = 'Hỗ trợ xe di chuyển & vận chuyển hàng hóa'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Phụ tiền xe%';


-- 5. RELOAD SCHEMA CACHE
NOTIFY pgrst, 'reload schema';


-- 6. KIỂM TRA ĐỐI SOÁT SAU KHI UPDATE
-- BẢNG 1: TỔNG THU - TỔNG CHI - TỒN QUỸ
SELECT 
    'QUỸ TỪ THIỆN' AS "Hạng mục",
    TO_CHAR((SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE'), 'FM999,999,999') || ' đ' AS "Tổng thu thực tế",
    TO_CHAR((SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE'), 'FM999,999,999') || ' đ' AS "Dự trù ban đầu",
    TO_CHAR((SELECT COALESCE(SUM(COALESCE(actual_amount, amount)), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE'), 'FM999,999,999') || ' đ' AS "Đã thực chi chốt",
    TO_CHAR((SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') 
    - (SELECT COALESCE(SUM(COALESCE(actual_amount, amount)), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE'), 'FM999,999,999') || ' đ' AS "TỒN QUỸ THỰC TẾ";

-- BẢNG 2: TỔNG TIỀN CHI THEO TỪNG NGƯỜI MUA
SELECT 
    CASE 
        WHEN note ILIKE '%Người mua: c.Yến%' THEN 'c. Yến'
        WHEN note ILIKE '%Người mua: Trân%' THEN 'Trân'
        WHEN note ILIKE '%Người mua: Hải%' THEN 'Hải'
        WHEN note ILIKE '%Người mua: Liền%' THEN 'Liền'
        WHEN note ILIKE '%Người mua: c. Trâm%' THEN 'c. Trâm'
        WHEN content ILIKE 'Phụ tiền xe%' THEN 'Quỹ xe di chuyển'
        WHEN actual_amount = 0 THEN 'Quỹ cũ còn (0đ)'
        ELSE 'Khác'
    END AS "Người phụ trách mua",
    COUNT(*) AS "Số món",
    TO_CHAR(SUM(COALESCE(actual_amount, amount)), 'FM999,999,999') || ' đ' AS "Tổng tiền đã chi"
FROM charity_fund_entries 
WHERE charity_id = 'GN2026' AND type = 'EXPENSE'
GROUP BY 1
ORDER BY SUM(COALESCE(actual_amount, amount)) DESC;
