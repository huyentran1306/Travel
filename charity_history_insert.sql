-- ================================================================
-- 📜 GIEO NẮNG - SCRIPT TẠO & INSERT LỊCH SỬ 6 MÙA THIỆN NGUYỆN (2024 - 2026)
-- ================================================================
-- Nguồn dữ liệu: https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview
-- Mục đích: Lưu trữ lịch sử tất cả các đợt thiện nguyện vào Supabase để đối soát & hiển thị
-- ================================================================

-- BƯỚC 1: TẠO BẢNG LỊCH SỬ CÁC ĐỢT (NẾU CHƯA CÓ)
CREATE TABLE IF NOT EXISTS charity_history (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    order_num int,                         -- Thứ tự hiển thị (1 -> 6)
    season_code text UNIQUE NOT NULL,      -- Mã đợt (ví dụ: GN2026, MA2025, NY2025,...)
    title text NOT NULL,                   -- Tên đợt thiện nguyện
    year text NOT NULL,                    -- Năm tổ chức
    event_date text,                       -- Ngày diễn ra
    location text,                         -- Địa điểm
    beneficiaries text,                    -- Đối tượng nhận quà
    beneficiaries_count text,              -- Quy mô số lượng (ví dụ: 340 em, 550 em,...)
    total_income numeric DEFAULT 0,        -- Tổng thu / quyên góp
    total_expense numeric DEFAULT 0,       -- Tổng thực chi
    balance numeric DEFAULT 0,             -- Tồn quỹ chuyển tiếp
    status text DEFAULT 'COMPLETED',       -- Trạng thái: ONGOING (Đang diễn ra) | COMPLETED (Hoàn thành)
    description text,                      -- Nội dung hoạt động & quà tặng
    sheet_gid text,                        -- ID tab trên Google Sheet
    sheet_url text,                        -- Link trực tiếp tới tab Google Sheet
    created_at timestamptz DEFAULT now()
);

-- BẬT ROW LEVEL SECURITY CHO BẢNG LỊCH SỬ
ALTER TABLE charity_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "allow_read_charity_history" ON charity_history;
CREATE POLICY "allow_read_charity_history" ON charity_history FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all_charity_history" ON charity_history;
CREATE POLICY "allow_all_charity_history" ON charity_history FOR ALL USING (true) WITH CHECK (true);

-- BƯỚC 2: INSERT / UPSERT DỮ LIỆU CẢ 6 ĐỢT THIỆN NGUYỆN
INSERT INTO charity_history (
    order_num, season_code, title, year, event_date, location, 
    beneficiaries, beneficiaries_count, total_income, total_expense, balance, 
    status, description, sheet_gid, sheet_url
) VALUES
-- 1. MÙA HIỆN TẠI: TRUNG THU 2026
(
    6,
    'MA2026',
    'Gieo Nắng 2026 - Trung Thu Buôn Ngô',
    '2026',
    '19 - 20/09/2026',
    'Buôn Ngô, Xã Cư Pui, Huyện Krông Bông, Tỉnh Đắk Lắk',
    '340 em nhỏ đồng bào Buôn Ngô',
    '340 em nhỏ',
    42393800,
    35043000,
    7350800,
    'ONGOING',
    'Tổ chức Tết Trung Thu cho 340 em nhỏ Buôn Ngô. Mỗi em nhận túi quà đầy đặn (lồng đèn phát sáng, lốc sữa 4 hộp, bánh gấu, kẹo dẻo, bim bim), thưởng thức 1 tô nui sườn heo trứng cút nóng hổi kèm trà tắc, vui chơi 3 gian hàng hội chợ có thưởng, nhận thêm thú bông và quần áo sạch đẹp.',
    '992092527',
    'https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview#gid=992092527'
),
-- 2. TRUNG THU 2025
(
    5,
    'MA2025',
    'Trung Thu 2025 - Buôn Cư Tê & Điểm Trường Ea Rớt',
    '2025',
    '04 - 05/10/2025',
    'Buôn Cư Tê (150 em) & Điểm trường Ea Rớt (400 em) - Xã Cư Pui, Krông Bông, Đắk Lắk',
    '550 em nhỏ đồng bào vùng sâu vùng xa',
    '550 em nhỏ',
    52262800,
    50623000,
    1639800,
    'COMPLETED',
    'Mang Tết Trung Thu trọn vẹn đến 550 em nhỏ vùng sâu vùng xa khó khăn nhất xã Cư Pui. Tổ chức rước đèn, phát bánh kẹo, sữa, nấu nui sườn nóng sốt. Tồn quỹ kết chuyển trọn vẹn 1.639.800đ sang quỹ Gieo Nắng 2026.',
    '204179391',
    'https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview#gid=204179391'
),
-- 3. THIỆN NGUYỆN 11/04/2025
(
    4,
    'TN2025_04',
    'Chương Trình Phát Quà Thiện Nguyện Tháng 04/2025',
    '2025',
    '11/04/2025',
    'Chương trình thiện nguyện vì cộng đồng',
    'Học sinh và bà con có hoàn cảnh khó khăn',
    '200 - 250 phần quà',
    0,
    0,
    0,
    'COMPLETED',
    'Vận động các nguồn lực xã hội và mạnh thường quân, trao tặng trực tiếp 200 - 250 suất quà thiết thực gồm nhu yếu phẩm gia đình, sữa hộp dinh dưỡng, bánh kẹo và tập vở cho các em học sinh hiếu học.',
    '609801437',
    'https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview#gid=609801437'
),
-- 4. TẾT ẤT TỴ 2025 - BỆNH NHI UNG BƯỚU
(
    3,
    'NY2025',
    'Xuân Yêu Thương 2025 - Tết Cho Bệnh Nhi Ung Bướu',
    '2025',
    '12/01/2025',
    'Bệnh viện Ung Bướu Cơ sở 2 - TP. Thủ Đức, TP.HCM',
    '250 bệnh nhi ung bướu đang điều trị nội trú dịp cận Tết',
    '250 bệnh nhi',
    16600000,
    13953800,
    2646200,
    'COMPLETED',
    'Đến tận giường bệnh trao tặng 250 phần quà Tết kèm phong bao lì xì may mắn cho các bệnh nhi ung bướu điều trị nội trú, mang hơi ấm mùa xuân và lời động viên tinh thần to lớn giúp các bé và gia đình.',
    '1662176402',
    'https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview#gid=1662176402'
),
-- 5. THIỆN NGUYỆN 15/11/2024
(
    2,
    'TN2024_11',
    'Chương Trình Trao Sữa Fami & Nhu Yếu Phẩm Mùa Đông',
    '2024',
    '15/11/2024',
    'Thiện nguyện cộng đồng mùa đông',
    'Người già neo đơn và trẻ em cơ nhỡ',
    'Hàng trăm suất sữa & quà',
    0,
    0,
    0,
    'COMPLETED',
    'Phát động chiến dịch trao tặng các thùng sữa đậu nành dinh dưỡng Fami, bánh ngọt và nhu yếu phẩm thiết thực, sưởi ấm các hoàn cảnh khó khăn trước thềm mùa đông.',
    '0',
    'https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview#gid=0'
),
-- 6. TRUNG THU 2024 - MÁI ẤM CHÙA BÌNH AN
(
    1,
    'MA2024',
    'Trung Thu 2024 - Mái Ấm Chùa Bình An',
    '2024',
    '14/09/2024',
    'Mái Ấm Chùa Bình An - Quận Bình Tân, TP. Hồ Chí Minh',
    '30 trẻ mồ côi & 43 cụ bà neo đơn không nơi nương tựa',
    '73 người tại mái ấm',
    11987654,
    11987654,
    0,
    'COMPLETED',
    'Đêm hội Trăng Rằm khởi đầu hành trình: rước đèn ông sao truyền thống, tặng bánh trung thu, sữa hộp, thăm hỏi và tặng quà kinh phí chăm sóc các cụ bà neo đơn cùng các bé mồ côi tại chùa.',
    '2089917852',
    'https://docs.google.com/spreadsheets/d/1ElDTAyYTgFLVY-xLV6bO-6Db0TIYAWoTq3Sfsm1Gqe8/htmlview#gid=2089917852'
)
ON CONFLICT (season_code) DO UPDATE SET
    order_num = EXCLUDED.order_num,
    title = EXCLUDED.title,
    year = EXCLUDED.year,
    event_date = EXCLUDED.event_date,
    location = EXCLUDED.location,
    beneficiaries = EXCLUDED.beneficiaries,
    beneficiaries_count = EXCLUDED.beneficiaries_count,
    total_income = EXCLUDED.total_income,
    total_expense = EXCLUDED.total_expense,
    balance = EXCLUDED.balance,
    status = EXCLUDED.status,
    description = EXCLUDED.description,
    sheet_gid = EXCLUDED.sheet_gid,
    sheet_url = EXCLUDED.sheet_url;

-- BƯỚC 3: KIỂM TRA DỮ LIỆU ĐÃ NẠP
SELECT order_num, year, title, total_income, total_expense, balance, status 
FROM charity_history 
ORDER BY order_num DESC;

NOTIFY pgrst, 'reload schema';
