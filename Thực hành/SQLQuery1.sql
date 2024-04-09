--- Câu 1. Tạo database tên BAITHI gồm có 4 table KHACHHANG, LOAICAY, HOADON, CTHD. Tạo khóa chính, khóa ngoại cho các table đó

CREATE DATABASE BAITHI

USE BAITHI

SET DATEFORMAT DMY

CREATE TABLE KHACHHANG
(
	MAKH char(5) PRIMARY KEY,
	TENKH varchar(50),
	DIACHI varchar(20),
	LOAIKH varchar(20)
)

CREATE TABLE LOAICAY
(
	MALC char(4) PRIMARY KEY,
	TENLC varchar(50),
	XUATXU varchar(20),
	GIA money,
)

CREATE TABLE HOADON
(
	SOHD char(5) PRIMARY KEY,
	NGHD smalldatetime,
	MAKH char(5) REFERENCES KHACHHANG,
	KHUYENMAI tinyint,
)

CREATE TABLE CTHD
(
	SOHD char(5) REFERENCES HOADON,
	MALC char(4) REFERENCES LOAICAY,
	SOLUONG smallint,
	PRIMARY KEY (SOHD, MALC)
)

--- Câu 2. Nhập dữ liệu cho 4 table như đề bài

INSERT INTO KHACHHANG (MAKH, TENKH, DIACHI, LOAIKH) VALUES
('KH01', 'Liz Kim Cuong', 'Ha Noi', 'Vang lai'),
('KH02', 'Ivone Dieu Linh', 'Da Nang', 'Thuong xuyen'),
('KH03', 'Emma Nhat Khanh', 'TP.HCM', 'Vang lai');

INSERT INTO LOAICAY (MALC, TENLC, XUATXU, GIA) VALUES
('LC01', 'Xuong rong tai tho', 'Mexico', 180000),
('LC02', 'Sen thach ngoc', 'Anh', 300000),
('LC03', 'Ba mau rau', 'Nam Phi', 270000);


INSERT INTO HOADON (SOHD, NGHD, MAKH, KHUYENMAI) VALUES
('00001', '22/11/2017', 'KH01', 5),
('00002', '04/12/2017', 'KH03', 5),
('00003', '10/12/2017', 'KH02', 10);

INSERT INTO CTHD (SOHD, MALC, SOLUONG) VALUES
('00001', 'LC01', 1),
('00001', 'LC02', 2),
('00003', 'LC03', 5);

--- Câu 3. Hiện thực ràng buộc toàn vẹn sau: Tất cả các mặt hàng xuất xứ từ nước Anh đều có giá lớn hơn 250.000đ
ALTER TABLE LOAICAY ADD CONSTRAINT CK_GIA_NUOC_ANH CHECK(NOT(XUATXU = 'Anh' AND GIA <= 250000)) 

--- Câu 4. Hiện thực ràng buộc toàn vẹn sau: Hóa đơn mua với số lượng tổng cộng lớn hơn hoặc bằng 5 đều được giảm giá 10 phần trăm.
-- BANG TAM ANH HUONG
--              THEM    XOA    SUA 
--HOADON		  -		 -		+(KHUYENMAI)
--CTHD			  + 	 -		+(SOLUONG)
GO 
CREATE TRIGGER TRG_UPDATE_HOADON ON HOADON
FOR UPDATE
AS IF UPDATE (KHUYENMAI)
BEGIN
	IF EXISTS (SELECT * FROM INSERTED I, CTHD
				WHERE CTHD.SOHD = I.SOHD AND I.KHUYENMAI <> 10
				HAVING SUM(CTHD.SOLUONG) >= 5)
	BEGIN 
		ROLLBACK TRAN
	END
END
GO
CREATE TRIGGER TRG_INS_UPDATE_CTHD ON CTHD
FOR INSERT, UPDATE -- có thể thêm UPDATE vào đây và không cần viết trigger update PHIEUNHAP
AS
BEGIN
	IF EXISTS (SELECT * FROM INSERTED I, HOADON
				WHERE I.SOHD = HOADON.SOHD AND HOADON.KHUYENMAI <> 10
				HAVING SUM(I.SOLUONG) >= 5)
	BEGIN 
		ROLLBACK TRAN
	END
END

GO


--- Câu 5. Tìm tất cả các phiếu nhập có ngày nhập trong tháng 12 năm 2017, sắp xếp kết quả tăng dần theo ngày nhập.SELECT SOPNFROM PHIEUNHAPWHERE MONTH(NGNHAP) = 12 AND YEAR(NGNHAP) = 2017ORDER BY NGNHAP ASC;--- Câu 6. Tìm dược phẩm được nhập số lượng nhiều nhất trong năm 2017.SELECT TOP 1 MADP, SUM(SOLUONG) AS TONGSOLUONGFROM CTPNGROUP BY MADPORDER BY TONGSOLUONG DESC;--- Câu 7. Tìm dược phẩm chỉ có nhà cung cấp thường xuyên (LOAINCC là Thuong xuyen) cung cấp, nhà cung cấp vãng lai (LOAINCC là Vang lai) không cung cấp.SELECT DP.MADP, DP.TENDPFROM DUOCPHAM DP, PHIEUNHAP PN, CTPN, NHACUNGCAP NCCWHERE DP.MADP = CTPN.MADP AND PN.MANCC = NCC.MANCC AND CTPN.SOPN = PN.SOPN AND NCC.LOAINHACUNGCAP = 'Thuong xuyen'INTERSECTSELECT DP.MADP, DP.TENDPFROM DUOCPHAM DP, PHIEUNHAP PN, CTPN, NHACUNGCAP NCCWHERE DP.MADP = CTPN.MADP AND PN.MANCC = NCC.MANCC AND CTPN.SOPN = PN.SOPN AND NCC.LOAINHACUNGCAP <> 'Vang lai'--- Câu 8. Tìm nhà cung cấp đã từng cung cấp tất cả những dược phẩm có giá trên 100.000đ trong năm 2017.SELECT NCC.MANCC, NCC.TENNCC
FROM NHACUNGCAP NCC
WHERE NOT EXISTS
(
	SELECT DP.MADP
	FROM DUOCPHAM DP
	WHERE DP.GIA > 100000 AND NOT EXISTS
	(
		SELECT *
		FROM PHIEUNHAP PN
		JOIN CTPN ON PN.SOPN = CTPN.SOPN
		WHERE YEAR(PN.NGNHAP) = 2017 AND CTPN.MADP = DP.MADP AND PN.MANCC = NCC.MANCC
	)
)
