-- ==========================================================
-- 🌟 GIEO NẮNG 2026 - TẠO STORAGE BUCKET & CỘT HÓA ĐƠN MUA HÀNG
-- Chạy script này trong Supabase Dashboard -> SQL Editor -> Run
-- ==========================================================

-- BƯỚC 1: THÊM CỘT LƯU HÌNH ẢNH HÓA ĐƠN VÀO CÁC BẢNG DỮ LIỆU
ALTER TABLE charity_fund_entries 
ADD COLUMN IF NOT EXISTS receipt_images text;

ALTER TABLE charity_donations 
ADD COLUMN IF NOT EXISTS receipt_images text;

ALTER TABLE charity_member_expenses 
ADD COLUMN IF NOT EXISTS receipt_images text;

-- BƯỚC 2: TẠO BUCKET 'receipts' LƯU ẢNH HÓA ĐƠN TRÊN SUPABASE STORAGE
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- BƯỚC 3: PHÂN QUYỀN (POLICIES) CHO PHÉP XEM VÀ TẢI ẢNH LÊN
-- 3.1. Cho phép công chúng xem ảnh hóa đơn (Công khai minh bạch)
DROP POLICY IF EXISTS "Public View Receipts" ON storage.objects;
CREATE POLICY "Public View Receipts" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'receipts');

-- 3.2. Cho phép tải ảnh hóa đơn mới lên bucket
DROP POLICY IF EXISTS "Allow Upload Receipts" ON storage.objects;
CREATE POLICY "Allow Upload Receipts" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'receipts');

-- 3.3. Cho phép cập nhật ảnh
DROP POLICY IF EXISTS "Allow Update Receipts" ON storage.objects;
CREATE POLICY "Allow Update Receipts" 
ON storage.objects FOR UPDATE 
USING (bucket_id = 'receipts');

-- 3.4. Cho phép xóa ảnh cũ khi cần
DROP POLICY IF EXISTS "Allow Delete Receipts" ON storage.objects;
CREATE POLICY "Allow Delete Receipts" 
ON storage.objects FOR DELETE 
USING (bucket_id = 'receipts');

-- THÀNH CÔNG: Đã kích hoạt tính năng đính kèm ảnh hóa đơn mua hàng!
