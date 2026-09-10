-- ================================================
-- 🌟 GIEO NẮNG 2026 - SQL SETUP SCRIPT (KHỞI TẠO MỚI)
-- Chạy script này trong Supabase SQL Editor
-- Dashboard -> SQL Editor -> New query -> Paste & Run
-- 
-- ⚠️ LƯU Ý: Nếu database của bạn ĐÃ CHẠY file này trước đó
-- và bạn chỉ muốn cập nhật dữ liệu (chuyển chi tiêu sang Dự trù),
-- hãy chạy file riêng: charity_update.sql
-- ================================================

-- BƯỚC 1: TẠO 3 BẢNG MỚI

CREATE TABLE IF NOT EXISTS charity_fund_entries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    charity_id text NOT NULL DEFAULT 'GN2026',
    type text NOT NULL CHECK (type IN ('INCOME', 'EXPENSE')),
    category text DEFAULT 'OTHER',
    content text,
    donor_name text,
    amount numeric DEFAULT 0,
    actual_amount numeric,
    date date,
    status text DEFAULT 'PENDING' CHECK (status IN ('DONE', 'PENDING')),
    note text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS charity_donations (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    charity_id text NOT NULL DEFAULT 'GN2026',
    donor_name text,
    item_name text,
    quantity numeric,
    unit text,
    estimated_value numeric,
    status text DEFAULT 'PENDING' CHECK (status IN ('RECEIVED', 'PENDING')),
    date date,
    note text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS charity_member_expenses (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    charity_id text NOT NULL DEFAULT 'GN2026',
    member_name text,
    category text DEFAULT 'OTHER',
    content text,
    amount numeric DEFAULT 0,
    payer text,
    participants text,
    date date,
    note text,
    created_at timestamptz DEFAULT now()
);

-- BẢNG THÀNH VIÊN THAM GIA ĐI CHUYẾN (QUỸ RIÊNG CỦA ĐOÀN)
CREATE TABLE IF NOT EXISTS charity_members (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    charity_id text NOT NULL DEFAULT 'GN2026',
    name text NOT NULL,
    full_name text,
    phone text,
    target_amount numeric DEFAULT 1500000,
    paid_amount numeric DEFAULT 0,
    payment_status text DEFAULT 'UNPAID' CHECK (payment_status IN ('PAID', 'UNPAID')),
    paid_date date,
    note text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS charity_settings (
    key text PRIMARY KEY,
    value text,
    updated_at timestamptz DEFAULT now()
);

-- BƯỚC 2: BẬT RLS + POLICIES

ALTER TABLE charity_fund_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE charity_donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE charity_member_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE charity_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE charity_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all_charity_fund" ON charity_fund_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_charity_donations" ON charity_donations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_charity_expenses" ON charity_member_expenses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_charity_members" ON charity_members FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_charity_settings" ON charity_settings FOR ALL USING (true) WITH CHECK (true);

-- CẤU HÌNH THÔNG SỐ & MẬT KHẨU HỆ THỐNG
INSERT INTO charity_settings (key, value)
VALUES 
    ('access_password', 'gieonang2026'),
    ('member_target_amount', '1500000'),
    ('vehicle_subsidy_amount', '5000000'),
    ('children_count', '350')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now();

-- BƯỚC 3: INSERT THU (GÓP)

INSERT INTO charity_fund_entries (charity_id, type, donor_name, content, amount, date, status, note) VALUES
('GN2026', 'INCOME', 'Quỹ Mid-Autumn 2025 còn', 'Quỹ Mid-Autumn 2025 còn lại', 1639800, '2026-08-01', 'DONE', 'Chuyển từ quỹ năm trước'),
('GN2026', 'INCOME', 'Liền', 'Liền', 1500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Hải', 'Hải', 2000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Sue', 'Sue', 2000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Chau Duy Canh', 'Chau Duy Canh', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Phạm Đức Tính', 'Phạm Đức Tính', 1500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Trân', 'Trân', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Hồng - Team Trân', 'Hồng - Team Trân', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Ng Thẻo Nguyên', 'Ng Thẻo Nguyên', 300000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Dũng', 'Dũng', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'a HùngVT3', 'a HùngVT3', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Vân', 'Vân', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Trâm - bạn Vân', 'c. Trâm - bạn Vân', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Võ Thị Tuyết Mai - bạn Trân', 'Võ Thị Tuyết Mai - bạn Trân', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Như', 'Như (21/08/2026 14:02)', 500000, '2026-08-21', 'DONE', NULL),
('GN2026', 'INCOME', 'Cô Cúc (from c.Nghi)', 'Cô Cúc (from c.Nghi)', 600000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c.Nhiên - bạn c.Nghi', 'c.Nhiên - bạn c.Nghi', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Nghi + c. Vân', 'c. Nghi + c. Vân', 2000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Mi + Cô Thảo (gđ c.Vân)', 'c. Mi + Cô Thảo (gđ c.Vân)', 3724000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Vy - em c. Vân', 'Vy - em c. Vân', 930000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Thiên Quân', 'Thiên Quân', 300000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Huynh Kim Ngoc', 'Huynh Kim Ngoc', 100000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Quí Đức TH3', 'Quí Đức TH3', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Tu Anh Duc', 'Tu Anh Duc', 200000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Sang', 'Sang', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Đậm - TymeX', 'c. Đậm - TymeX', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Nguyen Ngoc Minh Quang', 'Nguyen Ngoc Minh Quang', 100000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Trang - NAB', 'c. Trang - NAB', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Phượng Lucy', 'c. Phượng Lucy - Gấu bông', 500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Tâm Irene - JL', 'c. Tâm Irene - JL', 1500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'c. Trâm Võ - b.Hải', 'c. Trâm Võ - b.Hải', 8000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'bạn T giấu tên', 'bạn T giấu tên', 1500000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Dan Thanh', 'Dan Thanh', 1000000, '2026-08-01', 'DONE', NULL),
('GN2026', 'INCOME', 'Nguyet - JL', 'Nguyet - JL', 1000000, '2026-08-01', 'DONE', NULL);

-- BƯỚC 4: INSERT CHI (DỰ TRÙ KINH PHÍ / KẾ HOẠCH DỰ KIẾN)
-- Lưu ý: Các khoản chi dưới đây là DỰ TRÙ (status = 'PENDING').
-- Khi nào thực chi mua hàng thực tế sẽ cập nhật sang 'DONE'.

INSERT INTO charity_fund_entries (charity_id, type, category, content, amount, date, status, note) VALUES
-- 2.1 Quà trẻ em (Dự trù)
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Sữa (30 thùng x 295.000đ)', 8850000, '2026-09-19', 'PENDING', '1 thùng = 12 lốc; 1 lốc/em (Dự trù)'),
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Bánh gấu (354 hộp x 14.500đ)', 5133000, '2026-09-19', 'PENDING', '1 hộp/em (Dự trù)'),
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Kẹo dẻo (350 túi x 4.700đ)', 1645000, '2026-09-19', 'PENDING', '1 túi/em (Dự trù)'),
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Snack (350 bịch x 5.000đ)', 1750000, '2026-09-19', 'PENDING', '1 bịch/em (Dự trù)'),
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Lồng đèn (350 cái x 6.500đ)', 2275000, '2026-09-19', 'PENDING', '1 cái/em (Dự trù)'),
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Đèn nháy (350 cái x 2.800đ)', 980000, '2026-09-19', 'PENDING', '1 cái/em (Dự trù)'),
('GN2026', 'EXPENSE', 'GIFT_CHILDREN', 'Túi đựng quà (350 cái x 714đ)', 250000, '2026-09-19', 'PENDING', '1 túi/em (Dự trù)'),
-- 2.2 Ẩm thực (Dự trù)
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Ly nhựa (350 cái)', 0, '2026-09-19', 'PENDING', 'Lấy từ quỹ còn (Dự trù)'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Ống hút (200 cái)', 30000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Tắc (4 kg x 50.000đ/kg)', 200000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Đường (8 kg x 30.000đ/kg)', 240000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Trà túi lọc (10 hộp x 35.000đ)', 350000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Đá (5 bao x 25.000đ)', 125000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Dưa Hấu (30 kg x 15.000đ/kg)', 450000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'FOOD_STALL', 'Lặt vặt (dao, khăn giấy, băng keo, nước lọc)', 200000, '2026-09-19', 'PENDING', 'Dự trù'),
-- 2.3 Hội chợ (Dự trù)
('GN2026', 'EXPENSE', 'FAIR_GAMES', 'Vòng ném vòng (10 cái x 4.200đ)', 42000, '2026-09-19', 'PENDING', 'Trò: Ném vòng (Dự trù)'),
('GN2026', 'EXPENSE', 'FAIR_GAMES', 'Chóp ném vòng (5 cái x 13.800đ)', 69000, '2026-09-19', 'PENDING', 'Trò: Ném vòng (Dự trù)'),
('GN2026', 'EXPENSE', 'FAIR_GAMES', 'Bóng ném bóng vào rổ (10 quả x 3.700đ)', 37000, '2026-09-19', 'PENDING', 'Trò: Ném bóng vào rổ (Dự trù)'),
('GN2026', 'EXPENSE', 'FAIR_GAMES', 'Rổ (5 cái x 15.000đ)', 75000, '2026-09-19', 'PENDING', 'Trò: Ném bóng vào rổ (Dự trù)'),
('GN2026', 'EXPENSE', 'FAIR_GAMES', 'Đũa gắp bóng (10 đôi x 1.000đ)', 10000, '2026-09-19', 'PENDING', 'Trò: Gắp bóng bằng đũa (Dự trù)'),
('GN2026', 'EXPENSE', 'FAIR_GAMES', 'Bóng bàn gắp bằng đũa (10 cái x 2.700đ)', 27000, '2026-09-19', 'PENDING', 'Trò: Gắp bóng bằng đũa (Dự trù)'),
-- ⚠️ 2.4 GẠCH → KHÔNG INSERT (Gạo 50 bao, Mì 50 thùng)
-- 2.5 Nấu ăn (Dự trù)
('GN2026', 'EXPENSE', 'COOKING', 'Nui (20 kg x 30.000đ/kg)', 600000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Sườn heo (30 kg x 120.000đ/kg)', 3600000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Thịt xay (10 kg x 100.000đ/kg)', 1000000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Chả xay (6 kg x 140.000đ/kg)', 840000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Trứng cút (900 quả x 800đ)', 720000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Củ cải, cà rốt (15 kg x 25.000đ/kg)', 375000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Hành ngò, gia vị', 300000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Tô giấy (8 lốc x 35.000đ)', 280000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Muỗng (4 lốc x 15.000đ)', 60000, '2026-09-19', 'PENDING', 'Dự trù'),
('GN2026', 'EXPENSE', 'COOKING', 'Bao tay', 20000, '2026-09-19', 'PENDING', 'Dự trù'),
-- 2.6 Di chuyển (Dự trù)
('GN2026', 'EXPENSE', 'TRANSPORT', 'Phụ tiền xe di chuyển / hàng hóa', 5000000, '2026-09-19', 'PENDING', 'Dự trù');

-- BƯỚC 5: INSERT ĐỒ ĐÓNG GÓP (HIỆN VẬT)

INSERT INTO charity_donations (charity_id, donor_name, item_name, status, date) VALUES
('GN2026', 'c. Trâm', 'Gấu bông + quần áo + sữa', 'RECEIVED', '2026-08-01'),
('GN2026', 'c. Mai', 'Gấu bông', 'RECEIVED', '2026-08-01'),
('GN2026', 'Xuyên', 'Gấu bông + quần áo', 'RECEIVED', '2026-08-01'),
('GN2026', 'c. gái Vân Anh', 'Gấu bông', 'RECEIVED', '2026-08-01'),
('GN2026', 'Đức Anh', 'Gấu bông + quần áo', 'RECEIVED', '2026-08-01'),
('GN2026', 'a. Hoàng Henry - JL', 'Gấu bông + quần áo', 'RECEIVED', '2026-08-01'),
('GN2026', 'c. Nhân - JL', 'Gấu bông + quần áo + balo', 'RECEIVED', '2026-08-01'),
('GN2026', 'Trung ND', 'Quần áo + giày', 'RECEIVED', '2026-08-01');

-- BƯỚC 6: CẬP NHẬT DỮ LIỆU ĐÃ CÓ TRƯỚC ĐÓ (NẾU ĐÃ CHẠY SCRIPT CŨ)
-- Chuyển toàn bộ các khoản chi về DỰ KIẾN (PENDING)
UPDATE charity_fund_entries 
SET status = 'PENDING' 
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE';

-- BƯỚC 7: BÁO CÁO TỔNG KẾT & CÂN ĐỐI DỰ TRÙ
SELECT 
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') AS tong_thu_thuc_te,
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE') AS tong_du_tru_chi,
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE') AS da_thuc_chi,
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') 
    - (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE') AS ton_quy_thuc_te,
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') 
    - (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE') AS can_doi_du_tru;

SELECT category, COUNT(*) AS so_muc, SUM(amount) AS tong_du_tru 
FROM charity_fund_entries 
WHERE charity_id = 'GN2026' AND type = 'EXPENSE' 
GROUP BY category 
ORDER BY tong_du_tru DESC;

-- Reload Supabase Schema Cache để client nhận ngay cấu trúc mới
NOTIFY pgrst, 'reload schema';
