-- ================================================================
-- 🌟 GIEO NẮNG 2026 - SCRIPT CẬP NHẬT DỮ LIỆU TỪ GOOGLE SHEET (MỚI NHẤT)
-- ================================================================
-- Sheet nguồn: https://docs.google.com/spreadsheets/u/0/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview
-- Địa điểm: Buôn Ngô - Cư Pui - Dak Lak | Ngày: 19-20/09/2026 | Số lượng: 340 em
--
-- CÁCH DÙNG:
-- 1. Mở Supabase Dashboard -> chọn Project của bạn -> vào SQL Editor
-- 2. Dán toàn bộ nội dung file này vào và bấm [RUN] (hoặc Ctrl+Enter / Cmd+Enter)
-- 3. Script an toàn (idempotent), có thể chạy nhiều lần mà không lo trùng dữ liệu.
-- ================================================================

-- ================================================================
-- BƯỚC 1: ĐẢM BẢO CẤU TRÚC BẢNG & CÁC CỘT CẦN THIẾT
-- ================================================================
ALTER TABLE charity_fund_entries ADD COLUMN IF NOT EXISTS actual_amount numeric;
ALTER TABLE charity_member_expenses ADD COLUMN IF NOT EXISTS participants text;
ALTER TABLE charity_members ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE charity_members ADD COLUMN IF NOT EXISTS full_name text;

-- Đồng bộ tên thành viên nếu có
UPDATE charity_members SET full_name = name WHERE full_name IS NULL AND name IS NOT NULL;
UPDATE charity_members SET name = full_name WHERE name IS NULL AND full_name IS NOT NULL;

-- ================================================================
-- BƯỚC 2: CẬP NHẬT CẤU HÌNH HỆ THỐNG (SETTINGS)
-- ================================================================
CREATE TABLE IF NOT EXISTS charity_settings (
    key text PRIMARY KEY,
    value text,
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE charity_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_all_charity_settings" ON charity_settings;
CREATE POLICY "allow_all_charity_settings" ON charity_settings FOR ALL USING (true) WITH CHECK (true);

INSERT INTO charity_settings (key, value)
VALUES 
    ('access_password', 'gieonang2026'),
    ('member_target_amount', '1500000'),
    ('vehicle_subsidy_amount', '5000000'),
    ('children_count', '340') -- Cập nhật số lượng mới nhất: 340 em
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now();

-- ================================================================
-- BƯỚC 3: CẬP NHẬT DANH SÁCH GÓP TIỀN MẶT (INCOME)
-- ================================================================
-- Thêm mục mới STT 46: Ú - 500.000đ (nếu chưa có)
INSERT INTO charity_fund_entries (charity_id, type, donor_name, content, amount, date, status, note)
SELECT 'GN2026', 'INCOME', 'Ú', 'Ú', 500000, '2026-08-01', 'DONE', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM charity_fund_entries 
    WHERE charity_id = 'GN2026' AND type = 'INCOME' AND donor_name = 'Ú'
);

-- ================================================================
-- BƯỚC 4: CẬP NHẬT ĐÓNG GÓP HIỆN VẬT (DONATIONS)
-- ================================================================
-- 4.1 Thêm c. Phượng Lucy - Gấu bông (nếu chưa có)
INSERT INTO charity_donations (charity_id, donor_name, item_name, status, date)
SELECT 'GN2026', 'c. Phượng Lucy', 'Gấu bông', 'RECEIVED', '2026-08-01'
WHERE NOT EXISTS (
    SELECT 1 FROM charity_donations 
    WHERE charity_id = 'GN2026' AND donor_name = 'c. Phượng Lucy' AND item_name = 'Gấu bông'
);

-- 4.2 Thêm Bùi Thị Loan - 3 thùng sữa (nếu chưa có)
INSERT INTO charity_donations (charity_id, donor_name, item_name, quantity, unit, status, date)
SELECT 'GN2026', 'Bùi Thị Loan', 'Sữa', 3, 'thùng', 'RECEIVED', '2026-08-01'
WHERE NOT EXISTS (
    SELECT 1 FROM charity_donations 
    WHERE charity_id = 'GN2026' AND donor_name = 'Bùi Thị Loan'
);

-- 4.3 Chuẩn hóa tên c. Trâm -> c. Trâm Võ - b.Hải trong hiện vật
UPDATE charity_donations 
SET donor_name = 'c. Trâm Võ - b.Hải' 
WHERE charity_id = 'GN2026' AND donor_name = 'c. Trâm';

-- ================================================================
-- BƯỚC 5: CẬP NHẬT CHI TIÊU THỰC TẾ & TRẠNG THÁI 'DONE' (EXPENSE)
-- ================================================================

-- --- 5.1 Quà cho trẻ (Tổng thực chi: 20.678.000 đ) ---
-- Sữa: Mua 27 thùng x 295k = 7.965.000đ (do c.Loan góp 3 thùng sữa). Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 7965000, status = 'DONE', note = 'c.Loan góp 3 thùng -> mua 27 thùng (295k/thùng); Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Sữa (%';

-- Bánh gấu: 354 hộp x 14.500đ = 5.133.000đ. Người mua: Hải
UPDATE charity_fund_entries 
SET actual_amount = 5133000, status = 'DONE', note = '354 hộp x 14.500đ; Người mua: Hải'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bánh gấu (%';

-- Kẹo dẻo: 350 túi x 4.700đ = 1.645.000đ. Người mua: Hải
UPDATE charity_fund_entries 
SET actual_amount = 1645000, status = 'DONE', note = '350 túi x 4.700đ; Người mua: Hải'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Kẹo dẻo (%';

-- Snack: 350 bịch x 5.000đ = 1.750.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 1750000, status = 'DONE', note = '350 bịch x 5.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Snack (%';

-- Lồng đèn: 350 cái x 6.500đ = 2.275.000đ. Người mua: c. Trâm
UPDATE charity_fund_entries 
SET actual_amount = 2275000, status = 'DONE', note = '350 cái x 6.500đ; Người mua: c. Trâm'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Lồng đèn (%';

-- Đèn nháy: 350 cái x 3.743đ = 1.310.000đ. Người mua: Trân
UPDATE charity_fund_entries 
SET actual_amount = 1310000, status = 'DONE', note = '350 cái x 3.743đ; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đèn nháy (%';

-- Túi đựng quà: 350 cái x 1.714đ = 600.000đ. Người mua: Trân
UPDATE charity_fund_entries 
SET actual_amount = 600000, status = 'DONE', note = '350 cái x 1.714đ; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Túi đựng quà (%';


-- --- 5.2 Gian hàng ẩm thực (Tổng thực chi: 1.395.000 đ) ---
-- Ly nhựa: 0đ (Quỹ còn)
UPDATE charity_fund_entries 
SET actual_amount = 0, status = 'DONE', note = 'Quỹ còn'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Ly nhựa (%';

-- Ống hút: 39.000đ (Mua 240 cái; Quỹ còn 100 cái). Người mua: Trân
UPDATE charity_fund_entries 
SET actual_amount = 39000, status = 'DONE', note = 'Mua 240 cái (quỹ còn 100 cái); Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Ống hút (%';

-- Tắc: 4 kg x 50.000đ = 200.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 200000, status = 'DONE', note = '4 kg x 50.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Tắc (%';

-- Đường: 8 kg = 206.000đ. Người mua: Trân
UPDATE charity_fund_entries 
SET actual_amount = 206000, status = 'DONE', note = '8 kg; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đường (%';

-- Trà túi lọc: 10 hộp = 315.000đ. Người mua: Trân
UPDATE charity_fund_entries 
SET actual_amount = 315000, status = 'DONE', note = '10 hộp; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Trà túi lọc (%';

-- Đá: 5 bao x 25.000đ = 125.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 125000, status = 'DONE', note = '5 bao x 25.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đá (%';

-- Dưa Hấu: 30 kg x 15.000đ = 450.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 450000, status = 'DONE', note = '30 kg x 15.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Dưa Hấu (%';

-- Lặt vặt: 60.000đ (Khăn giấy, khăn ướt, băng keo). Người mua: Trân
UPDATE charity_fund_entries 
SET actual_amount = 60000, status = 'DONE', note = 'Khăn giấy, khăn ướt, băng keo; Người mua: Trân'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Lặt vặt (%';


-- --- 5.3 Gian hàng hội chợ (Tổng thực chi: 175.000 đ) ---
-- Vòng ném vòng: 42.000đ (10 cái). Người mua: Liền
UPDATE charity_fund_entries 
SET actual_amount = 42000, status = 'DONE', note = '10 cái; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Vòng ném vòng (%';

-- Chóp ném vòng: 69.000đ (5 cái). Người mua: Liền
UPDATE charity_fund_entries 
SET actual_amount = 69000, status = 'DONE', note = '5 cái; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Chóp ném vòng (%';

-- Bóng ném rổ: 37.000đ (10 quả). Người mua: Liền
UPDATE charity_fund_entries 
SET actual_amount = 37000, status = 'DONE', note = '10 quả; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bóng ném bóng vào rổ (%';

-- Rổ: 0đ (Quỹ còn 5 cái)
UPDATE charity_fund_entries 
SET actual_amount = 0, status = 'DONE', note = 'Quỹ còn 5 cái'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Rổ (%';

-- Đũa gắp bóng: 0đ (Quỹ còn 10 đôi)
UPDATE charity_fund_entries 
SET actual_amount = 0, status = 'DONE', note = 'Quỹ còn 10 đôi'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Đũa gắp bóng (%';

-- Bóng bàn: 27.000đ (10 cái). Người mua: Liền
UPDATE charity_fund_entries 
SET actual_amount = 27000, status = 'DONE', note = '10 cái; Người mua: Liền'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bóng bàn gắp bằng đũa (%';


-- --- 5.4 Nấu ăn (Tổng thực chi: 7.795.000 đ - Tất cả c.Yến mua) ---
-- Nui: 20 kg x 30.000đ = 600.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 600000, status = 'DONE', note = '20 kg x 30.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Nui (%';

-- Sườn heo: 30 kg x 120.000đ = 3.600.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 3600000, status = 'DONE', note = '30 kg x 120.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Sườn heo (%';

-- Thịt xay: 10 kg x 100.000đ = 1.000.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 1000000, status = 'DONE', note = '10 kg x 100.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Thịt xay (%';

-- Chả xay: 6 kg x 140.000đ = 840.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 840000, status = 'DONE', note = '6 kg x 140.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Chả xay (%';

-- Trứng cút: 900 quả x 800đ = 720.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 720000, status = 'DONE', note = '900 quả x 800đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Trứng cút (%';

-- Củ cải, cà rốt: 15 kg x 25.000đ = 375.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 375000, status = 'DONE', note = '15 kg x 25.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Củ cải, cà rốt (%';

-- Hành ngò, gia vị: 300.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 300000, status = 'DONE', note = 'Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Hành ngò, gia vị%';

-- Tô giấy: 8 lốc x 35.000đ = 280.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 280000, status = 'DONE', note = '8 lốc x 35.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Tô giấy (%';

-- Muỗng: 4 lốc x 15.000đ = 60.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 60000, status = 'DONE', note = '4 lốc x 15.000đ; Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Muỗng (%';

-- Bao tay: 20.000đ. Người mua: c.Yến
UPDATE charity_fund_entries 
SET actual_amount = 20000, status = 'DONE', note = 'Người mua: c.Yến'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Bao tay%';


-- --- 5.5 Di chuyển (5.000.000 đ) ---
-- Phụ tiền xe di chuyển / hàng hóa: 5.000.000đ
UPDATE charity_fund_entries 
SET actual_amount = 5000000, status = 'DONE', note = 'Hỗ trợ xe di chuyển & vận chuyển hàng hóa'
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND content ILIKE 'Phụ tiền xe%';


-- ================================================================
-- BƯỚC 6: RELOAD SUPABASE SCHEMA CACHE (BẮT BUỘC)
-- ================================================================
NOTIFY pgrst, 'reload schema';


-- ================================================================
-- BƯỚC 7: BÁO CÁO ĐỐI SOÁT VÀ TỔNG KẾT
-- ================================================================

-- BẢNG 1: ĐỐI SOÁT TỔNG THU - TỔNG CHI - TỒN QUỸ TỪ THIỆN
-- (Kỳ vọng: Tổng thu = 42.393.800 đ | Thực chi = 35.043.000 đ | Tồn quỹ = 7.350.800 đ)
SELECT 
    'QUỸ TỪ THIỆN (CHUNG)' AS "Hạng mục",
    TO_CHAR((SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE'), 'FM999,999,999') || ' đ' AS "Tổng thu thực tế",
    TO_CHAR((SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE'), 'FM999,999,999') || ' đ' AS "Dự trù ban đầu",
    TO_CHAR((SELECT COALESCE(SUM(COALESCE(actual_amount, amount)), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE'), 'FM999,999,999') || ' đ' AS "Đã thực chi chốt",
    TO_CHAR((SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') 
    - (SELECT COALESCE(SUM(COALESCE(actual_amount, amount)), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE'), 'FM999,999,999') || ' đ' AS "TỒN QUỸ THỰC TẾ";

-- BẢNG 2: TỔNG HỢP CHI THEO NGƯỜI MUA
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
    END AS "Người phụ trách mua / Hạng mục",
    COUNT(*) AS "Số món",
    TO_CHAR(SUM(COALESCE(actual_amount, amount)), 'FM999,999,999') || ' đ' AS "Tổng tiền đã chi"
FROM charity_fund_entries 
WHERE charity_id = 'GN2026' AND type = 'EXPENSE'
GROUP BY 1
ORDER BY SUM(COALESCE(actual_amount, amount)) DESC;

-- BẢNG 3: DANH SÁCH HIỆN VẬT
SELECT donor_name AS "Người đóng góp", item_name AS "Hiện vật", COALESCE(quantity::text, '') || ' ' || COALESCE(unit, '') AS "Số lượng"
FROM charity_donations 
WHERE charity_id = 'GN2026'
ORDER BY created_at ASC;
