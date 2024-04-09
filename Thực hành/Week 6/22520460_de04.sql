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
CREATE TRIGGER TRG_INS_CTHD ON CTHD
FOR INSERT 
AS
BEGIN
	UPDATE HOADON
	SET KHUYENMAI = 10
	WHERE SOHD = (SELECT I.SOHD FROM INSERTED I, HOADON H, CTHD C
				WHERE I.SOHD = H.SOHD AND H.SOHD = C.SOHD
					AND H.KHUYENMAI < 10
				GROUP BY I.SOHD
				HAVING SUM(C.SOLUONG) >= 5)
END
GO
CREATE TRIGGER TRG_UPDATE_CTHD ON CTHD
FOR UPDATE
AS IF (UPDATE(SOHD) OR UPDATE(SOLUONG))
BEGIN
	UPDATE HOADON
	SET KHUYENMAI = 10
	WHERE SOHD = (SELECT I.SOHD FROM INSERTED I, HOADON H, CTHD C
				WHERE I.SOHD = H.SOHD AND H.SOHD = C.SOHD
					AND H.KHUYENMAI < 10
				GROUP BY I.SOHD
				HAVING SUM(C.SOLUONG) >= 5)
END


--- Câu 5. Tìm tất cả các hóa đơn có ngày lập hóa đơn trong quý 4 năm 2017, sắp xếp kết quả tăng dần theo phần trăm giảm giá.SELECT *FROM HOADONWHERE MONTH(NGHD) IN (10, 11, 12) AND YEAR(NGHD)=2017ORDER BY KHUYENMAI ASC;--- Câu 6. Tìm loại cây có số lượng mua ít nhất trong tháng 12.---	(Với kiến thức học được thì em chỉ có thể tìm ra được loại cây có số lượng mua ít nhất nếu nó được mua) SELECT TOP 1 WITH TIES MALC, SUM(CTHD.SOLUONG) AS TONGSOLUONGFROM CTHD	LEFT JOIN HOADON HD ON HD.SOHD = CTHD.SOHDWHERE MONTH(HD.NGHD) = 12GROUP BY MALCORDER BY TONGSOLUONG ASC;--- Câu 7. Tìm loại cây mà cả khách thường xuyên (LOAIKH là ‘Thuong xuyen’) và khách vãng lai (LOAIKH là ‘Vang lai’) đều mua.SELECT LC.MALC, LC.TENLCFROM LOAICAY LC, HOADON HD, KHACHHANG KH, CTHDWHERE LC.MALC = CTHD.MALC AND CTHD.SOHD = HD.SOHD AND HD.MAKH = KH.MAKH AND KH.LOAIKH = 'Thuong xuyen'INTERSECTSELECT LC.MALC, LC.TENLCFROM LOAICAY LC, HOADON HD, KHACHHANG KH, CTHDWHERE LC.MALC = CTHD.MALC AND CTHD.SOHD = HD.SOHD AND HD.MAKH = KH.MAKH AND KH.LOAIKH = 'Vang lai'--- Câu 8. Tìm khách hàng đã từng mua tất cả các loại cây.SELECT KH.MAKH, KH.TENKH
FROM KHACHHANG KH
WHERE NOT EXISTS
(
	SELECT LC.MALC
	FROM LOAICAY LC
	WHERE NOT EXISTS
	(
		SELECT *
		FROM CTHD
		JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
		WHERE LC.MALC = CTHD.MALC AND HD.MAKH = KH.MAKH
	)
)
