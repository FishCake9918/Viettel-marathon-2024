# Project Background
Viettel Marathon 2024 là giải chạy quy mô lớn tại Việt Nam, thu hút nhiều vận động viên từ phong trào đến chuyên nghiệp. Dự án này tập trung xây dựng và phân tích cơ sở dữ liệu về vận động viên, thành tích và nhà tài trợ. Mục tiêu là rút ra các insight quan trọng như xu hướng thành tích, hiệu quả tài trợ và chiến lược tổ chức, hỗ trợ Viettel tối ưu hóa các sự kiện tiếp theo.

# Disclaimer
Một phần dữ liệu trong dự án này được AI tạo ra nhằm mục đích học tập. Thương hiệu và phần dữ liệu còn lại là thật, được sử dụng để phân tích, nhưng không nhằm tiết lộ thông tin nhạy cảm hay vi phạm quyền sở hữu dữ liệu.

Các insight và khuyến nghị được đưa ra cho các lĩnh vực trọng yếu sau:

- **Thành tích vận động viên** – phân tích kết quả theo nhóm tuổi, giới tính, quốc gia, elite vs open. 
- **Hiệu quả tài trợ** – đánh giá số tiền tài trợ, phân bố nhà tài trợ, mức độ xuất hiện của thương hiệu.
- **Xu hướng tham gia và cạnh tranh** – phân tích số lượng người tham gia, tỷ lệ hoàn thành, cự ly phổ biến.

Các truy vấn SQL được sử dụng để tạo cơ sở dữ liệu [Script tạo bảng]

Tập lệnh SQL dùng để nhập bộ dữ liệu [Dataset]

Các truy vấn SQL dùng để khám phá bộ dữ liệu [Explore_Query]

Các truy vấn SQL chuyên sâu liên quan đến 3 lĩnh vực nói trên có thể xem tại đây [Insights_Query]

Dashboard PowerBI tương tác dùng để báo cáo và khám phá xu hướng doanh số có thể xem tại đây [Dasboard]


# Data Structure & Initial Checks

Cấu trúc cơ sở dữ liệu chính của dự án được thể hiện bên dưới, bao gồm bảy bảng, mô tả của từng bảng như sau:

- **1. runners_id – Lưu thông tin vận động viên (ID, họ tên, giới tính, hạng thi đấu, quốc gia) để phân tích nhân khẩu học và phân nhóm.**

- **2. sponsors – Chứa thông tin nhà tài trợ (ID, tên, hạng tài trợ, số tiền tài trợ) để theo dõi đóng góp tài chính và phân loại đối tác.**

- **3. sponsorship – Ghi nhận mối quan hệ tài trợ giữa vận động viên và nhà tài trợ (ID quan hệ, ID vận động viên, ID nhà tài trợ, năm bắt đầu và kết thúc) để phân tích lịch sử và hiệu quả hợp tác.**

- **4. result_5k – Lưu kết quả cự ly 5km (số bib, ID vận động viên, thời gian tại mốc 3.9km, chip time, thời gian hoàn thành) để đánh giá hiệu suất cự ly ngắn.**

- **5. result_10k – Lưu kết quả cự ly 10km (số bib, ID vận động viên, thời gian tại mốc 5.5km và 8.9km, chip time, thời gian hoàn thành) để phân tích hiệu suất cự ly trung bình.**

- **6. result_half_marathon – Lưu kết quả bán marathon (số bib, ID vận động viên, thời gian tại các mốc 11.1km, 16.6km, 20.0km, 20.7km, chip time, thời gian hoàn thành) để đánh giá hiệu suất cự ly dài.**

- **7. result_marathon – Lưu kết quả marathon (số bib, ID vận động viên, thời gian tại các mốc 14.4km, 25.8km, 32.3km, 37.9km, chip time, thời gian hoàn thành) để phân tích thành tích đường dài.**

![alt text](https://github.com/FishCake9918/MDX_query/blob/main/ConstellationSchema.jpg)


# Executive Summary

### Overview of Findings

Phân tích dự án làm rõ ba lĩnh vực chính: thành tích vận động viên, hiệu quả tài trợ và xu hướng tham gia. Kết quả cho thấy khoảng cách rõ rệt giữa nhóm elite và open, đồng thời thành tích khác biệt đáng kể giữa các quốc gia. Về tài trợ, một số nhà tài trợ lớn chiếm ưu thế ở các vị trí podium, khẳng định độ phủ thương hiệu cao. Ở khía cạnh tham gia, các cự ly ngắn (5K, 10K) thu hút đông đảo nhất, trong khi half marathon và marathon thể hiện mức độ cạnh tranh gay gắt hơn ở nhóm elite.


# Insights Deep Dive
### Thành tích vận động viên:

* **Khoảng cách Elite vs Open** - Thời gian trung bình Marathon của Elite là 2h45’, nhanh hơn 35 phút so với Open (3h20’). Ở Half Marathon, Elite trung bình 1h18’, Open 1h45’ → chênh lệch gần 30%.
  
* **Khác biệt theo quốc gia** - VĐV Kenya và Ethiopia chiếm 70% top 10 Marathon, trong khi Việt Nam và Nhật Bản chiếm đa số ở 5K và 10K.
  
* **Cạnh tranh gay gắt ở cự ly dài** - Ở Marathon, khoảng cách giữa top 1 và top 10 chỉ 4 phút 30 giây, trong khi ở 5K chênh lệch lên đến 2 phút → chứng tỏ đường dài cạnh tranh hơn.
  



### Hiệu quả tài trợ:

* **Experience and flight-hour requirements vary widely** – Trong tổng số 200 Elite runners, có 65% được tài trợ. Open runners không có sponsor.
  
* **Sự phân bổ tài trợ không đồng đều** – Một số nhà tài trợ chỉ xuất hiện ở cự ly ngắn, trong khi sponsor lớn duy trì hiện diện ở nhiều cự ly khác nhau.
  
* **Top 3 thống trị thương hiệu** – Dữ liệu cho thấy 2–3 sponsor liên tục xuất hiện trong top 3 của các cự ly, qua đó khẳng định sự gắn kết thương hiệu với thành tích thể thao đỉnh cao.
  



### Xu hướng tham gia và cạnh tranh:

* **Cự ly ngắn thu hút đông đảo** – 5K có 4.200 runners (chiếm 40% tổng), 10K có 3.100 runners (30%). Trong khi đó Half Marathon chỉ có 2.000 runners (20%) và Marathon 1.200 runners (10%).
  
* **Cự ly dài khẳng định tính chuyên nghiệp** – Trong số 1.200 Marathon runners, có đến 400 Elite (chiếm 33%), cao hơn tỷ lệ Elite ở 5K (chỉ 5%).
  
* **Cơ cấu giới tính** – Nam giới chiếm ưu thế trong các cự ly dài, trong khi ở 5K và 10K tỷ lệ nữ cao hơn.
  
* **Đa dạng quốc gia** – Ở 5K, có 15 quốc gia tham gia, trong khi Marathon chỉ có 6 quốc gia. Điều này phản ánh phong trào phổ biến ở cự ly ngắn nhưng tập trung chuyên nghiệp ở cự ly dài.




# Recommendations:

Dựa trên các insight và phát hiện ở trên, chúng tôi khuyến nghị **Ban Tổ Chức Viettel Marathon 2025** trong tương lai cân nhắc những điểm sau:


* Đẩy mạnh phong trào cộng đồng qua các cự ly ngắn (5K, 10K), gắn với gia đình và người mới tham gia.**
  
* Tập trung phát triển chuyên nghiệp ở cự ly dài (Half Marathon, Marathon), khai thác như điểm nhấn thương hiệu.**
  
* Tối ưu chiến lược tài trợ, duy trì sponsor lớn nhưng mở rộng gói tài trợ cộng đồng để tăng độ phủ.**
  
* Quốc tế hóa sự kiện, tận dụng sự đa dạng quốc gia để quảng bá giải đấu ra khu vực và quốc tế.**
  


# Assumptions and Caveats:

Trong suốt quá trình phân tích, nhiều giả định đã được đưa ra để xử lý những thách thức của dữ liệu. Các giả định và lưu ý được nêu dưới đây:


* Kết quả phân tích mang tính giả định do thiếu một số trường dữ liệu (ví dụ: độ tuổi, thời gian đăng ký, tỉ lệ bỏ cuộc).
  
* Insight về tài trợ chỉ áp dụng cho nhóm Elite, vì nhóm Open không có dữ liệu sponsor.
  
* Các so sánh quốc gia và giới tính dựa trên dữ liệu hiện có, có thể chưa phản ánh toàn bộ thực tế.

* Khuyến nghị đưa ra mang tính tham khảo cho mục tiêu phân tích dữ liệu và định hướng quản lý sự kiện, không thay thế cho các quyết định chiến lược chính thức.