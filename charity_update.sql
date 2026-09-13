-- ================================================================
-- 🌟 GIEO NẮNG 2026 - SCRIPT CẬP NHẬT DỮ LIỆU & SCHEMA (MIGRATION)
-- ================================================================
-- Bạn chỉ cần copy TOÀN BỘ file này và chạy trong Supabase SQL Editor:
-- Supabase Dashboard -> SQL Editor -> New Query -> Dán toàn bộ & bấm RUN
-- ================================================================

-- ================================================================
-- BƯỚC 1: BỔ SUNG CÁC CỘT MỚI (ĐẢM BẢO KHÔNG BỊ LỖI SCHEMA CACHE)
-- ================================================================

-- 1.1 Thêm cột actual_amount để lưu số tiền thực tế đã chi nếu khác với dự trù
ALTER TABLE charity_fund_entries ADD COLUMN IF NOT EXISTS actual_amount numeric;

-- 1.2 Thêm cột participants để lưu danh sách người tham gia chia tiền trong chi phí đoàn
ALTER TABLE charity_member_expenses ADD COLUMN IF NOT EXISTS participants text;

-- 1.3 Đảm bảo tương thích cả 'name' và 'full_name' trong bảng thành viên
ALTER TABLE charity_members ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE charity_members ADD COLUMN IF NOT EXISTS full_name text;
UPDATE charity_members SET full_name = name WHERE full_name IS NULL AND name IS NOT NULL;
UPDATE charity_members SET name = full_name WHERE name IS NULL AND full_name IS NOT NULL;


-- ================================================================
-- BƯỚC 2: TẠO BẢNG & CẤU HÌNH THÔNG SỐ (NẾU CHƯA CÓ)
-- ================================================================

-- 2.1 Bảng cấu hình hệ thống
CREATE TABLE IF NOT EXISTS charity_settings (
    key text PRIMARY KEY,
    value text,
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE charity_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_all_charity_settings" ON charity_settings;
CREATE POLICY "allow_all_charity_settings" ON charity_settings FOR ALL USING (true) WITH CHECK (true);

-- Cập nhật thông số chuẩn của chuyến đi
INSERT INTO charity_settings (key, value)
VALUES 
    ('access_password', 'gieonang2026'),
    ('member_target_amount', '1500000'),
    ('vehicle_subsidy_amount', '5000000'),
    ('children_count', '350')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now();


-- 2.2 Bảng thành viên tham gia chuyến đi (Quỹ riêng của đoàn)
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

ALTER TABLE charity_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_all_charity_members_table" ON charity_members;
CREATE POLICY "allow_all_charity_members_table" ON charity_members FOR ALL USING (true) WITH CHECK (true);


-- 2.3 Bảng chi phí nội bộ của đoàn đi (Quỹ riêng của đoàn)
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

ALTER TABLE charity_member_expenses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_all_charity_expenses" ON charity_member_expenses;
CREATE POLICY "allow_all_charity_expenses" ON charity_member_expenses FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- BƯỚC 3: RELOAD SUPABASE SCHEMA CACHE (BẮT BUỘC)
-- ================================================================
-- Câu lệnh này giúp Supabase PostgREST nhận ngay các cột mới vừa thêm
NOTIFY pgrst, 'reload schema';


-- ================================================================
-- BƯỚC 4: BÁO CÁO KIỂM TRA ĐỐI SOÁT (2 QUỸ ĐỘC LẬP)
-- ================================================================

-- 4.1 BÁO CÁO QUỸ TỪ THIỆN (Dành cho trẻ em / bà con)
SELECT 
    'QUỸ TỪ THIỆN (CHUNG)' AS "Loại Quỹ",
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') AS "Thu thực tế (đ)",
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE') AS "Dự trù chi (đ)",
    (SELECT COALESCE(SUM(COALESCE(actual_amount, amount)), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE') AS "Đã thực chi (đ)",
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') 
    - (SELECT COALESCE(SUM(COALESCE(actual_amount, amount)), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE' AND status = 'DONE') AS "Tồn quỹ thực tế (đ)",
    (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'INCOME' AND status = 'DONE') 
    - (SELECT COALESCE(SUM(amount), 0) FROM charity_fund_entries WHERE charity_id = 'GN2026' AND type = 'EXPENSE') AS "Cân đối dự trù (Dư/Thiếu)";

-- 4.2 BÁO CÁO QUỸ THÀNH VIÊN ĐI CHUYẾN (Quỹ riêng)
SELECT 
    'QUỸ THÀNH VIÊN (RIÊNG)' AS "Loại Quỹ",
    (SELECT COUNT(*) FROM charity_members WHERE charity_id = 'GN2026') AS "Tổng số người đi",
    (SELECT COUNT(*) FROM charity_members WHERE charity_id = 'GN2026' AND payment_status = 'PAID') AS "Đã đóng (người)",
    (SELECT COUNT(*) FROM charity_members WHERE charity_id = 'GN2026' AND payment_status = 'UNPAID') AS "Chưa đóng (người)",
    (SELECT COALESCE(SUM(paid_amount), 0) FROM charity_members WHERE charity_id = 'GN2026') + 5000000 AS "Tổng thu quỹ đoàn (đã gồm 5tr xe)",
    (SELECT COALESCE(SUM(amount), 0) FROM charity_member_expenses WHERE charity_id = 'GN2026') AS "Tổng chi đoàn (đ)",
    ((SELECT COALESCE(SUM(paid_amount), 0) FROM charity_members WHERE charity_id = 'GN2026') + 5000000)
    - (SELECT COALESCE(SUM(amount), 0) FROM charity_member_expenses WHERE charity_id = 'GN2026') AS "Số dư quỹ đoàn còn lại (đ)";
