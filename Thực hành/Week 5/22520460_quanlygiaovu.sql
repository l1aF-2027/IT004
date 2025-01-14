﻿USE QUANLYGIAOVU

---						PHẦN I.

--- Câu 9. Lớp trưởng của một lớp phải là học viên của lớp đó.

---				Thêm	Xóa		Sửa
--- LOP			  +		 -	  +(TRGLOP)
--- HOCVIEN		  -		 -	  +(MALOP)

GO
CREATE TRIGGER TRG_INS_UPDATE_LOP ON LOP 
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, HOCVIEN HV
			WHERE HV.MAHV = I.TRGLOP AND I.MALOP <> HV.MALOP
		)
		BEGIN 
			PRINT 'LOI: TRUONG LOP KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA LOP THANH CONG'
		END
END

GO
CREATE TRIGGER TRG_UPDATE_HOCVIEN ON HOCVIEN 
FOR UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, LOP L
			WHERE I.MAHV = L.TRGLOP AND I.MALOP <> L.MALOP
		)
		BEGIN 
			PRINT 'LOI: HOC VIEN KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'SUA HOC VIEN THANH CONG'
		END
END

--- Câu 10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.

---				Thêm	Xóa		Sửa
--- KHOA		  +		 -	  +(TRGKHOA)
--- GIAOVIEN	  - 	 -	  +(MAKHOA, HOCVI)

GO
CREATE TRIGGER TRG_INS_UPDATE_KHOA ON KHOA
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I
				JOIN GIAOVIEN GV ON I.TRGKHOA = GV.MAGV 
			WHERE I.MAKHOA <> GV.MAKHOA OR GV.HOCVI NOT IN ('TS', 'PTS')
		)
		BEGIN 
			PRINT 'LOI: TRUONG KHOA KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA KHOA THANH CONG'
		END
END

GO
CREATE TRIGGER TRG_UPDATE_GIAOVIEN ON GIAOVIEN
FOR UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I
				JOIN KHOA K ON I.MAGV = K.TRGKHOA 
			WHERE I.MAKHOA <> K.MAKHOA OR I.HOCVI NOT IN ('TS', 'PTS')
		)
		BEGIN 
			PRINT 'LOI: MA KHOA KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'SUA GIAO VIEN THANH CONG'
		END
END

--- Câu 15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.

---				Thêm	Xóa		Sửa
--- KETQUATHI     +		 -	  +(NGTHI)
--- GIANGDAY	  -		 -	  +(DENNGAY)

GO
CREATE TRIGGER TRG_INS_UPDATE_KETQUATHI ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, GIANGDAY GD
			WHERE LEFT(I.MAHV, 3) = GD.MALOP AND I.MAMH = GD.MAMH AND I.NGTHI < GD.DENNGAY
		)
		BEGIN 
			PRINT 'LOI: NGAY THI KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA KET QUA THI THANH CONG'
		END
END

GO
CREATE TRIGGER TRG_UPDATE_GIANGDAY ON GIANGDAY
FOR UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, KETQUATHI KQT
			WHERE LEFT(KQT.MAHV, 3) = I.MALOP AND I.MAMH = KQT.MAMH AND KQT.NGTHI < I.DENNGAY
		)
		BEGIN 
			PRINT 'LOI: NGAY KET THUC KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'SUA GIANG DAY THANH CONG'
		END
END

--- Câu 16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.

---				Thêm	Xóa				Sửa
--- GIANGDAY	  +		 -	  +(HOCKY, MALOP, MAMH, NAM)

GO
CREATE TRIGGER TRG_INSERT_GIANGDAY_MAMH ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED 
			GROUP BY MALOP, NAM, HOCKY
			HAVING COUNT(MAMH) > 3
		)
		BEGIN 
			PRINT 'LOI: TRONG HOC KY CUA NAM HOC NAY LOP NAY DA HOC 3 MON!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA GIANG DAY THANH CONG'
		END
END

--- Câu 17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.

---				Thêm	Xóa		Sửa
--- LOP			  +		 -	  +(SISO)
--- HOCVIEN		  +		 +	  +(MALOP)

GO
CREATE TRIGGER TRG_UPDATE_HOCVIEN_SISO ON HOCVIEN
FOR UPDATE
AS
BEGIN
	UPDATE LOP
	SET SISO = SISO
	+ ( 
		SELECT COUNT(I.MAHV)
		FROM INSERTED I 
		WHERE I.MALOP = LOP.MALOP
	  )
	- (	
		SELECT COUNT(D.MAHV)
		FROM DELETED D 
		WHERE D.MALOP = LOP.MALOP
	  )
	PRINT 'DA CAP NHAT SI SO LOP HOC'
END

GO
CREATE TRIGGER TRG_INSERT_HOCVIEN_SISO ON HOCVIEN
FOR INSERT
AS
BEGIN
	UPDATE LOP
	SET SISO = SISO
	+ ( 
		SELECT COUNT(I.MAHV)
		FROM INSERTED I 
		WHERE I.MALOP = LOP.MALOP
	  )
	PRINT('DA CAP NHAT SI SO LOP HOC')
END

GO
CREATE TRIGGER TRG_DELETE_HOCVIEN_SISO ON HOCVIEN
FOR DELETE
AS
BEGIN
	UPDATE LOP
	SET SISO = SISO
	- (	
		SELECT COUNT(D.MAHV)
		FROM DELETED D 
		WHERE D.MALOP = LOP.MALOP
	  )
	PRINT('DA CAP NHAT SI SO LOP HOC')
END

GO
CREATE TRIGGER TRG_INSERT_LOP_SISO ON LOP
FOR INSERT
AS
BEGIN
	UPDATE LOP
	SET SISO = 0
	FROM LOP L JOIN INSERTED I ON L.MALOP = I.MALOP
	PRINT 'DA CAP NHAT SI SO BAN DAU  LA 0'
END

GO
CREATE TRIGGER TRG_UPDATE_LOP_SISO ON LOP
FOR UPDATE
AS
BEGIN
	 IF EXISTS 
	 (
		SELECT * FROM INSERTED I,
			(
			SELECT MALOP, COUNT(MAHV) AS SISO
			FROM HOCVIEN 
			GROUP BY MALOP
			) AS KQ
		WHERE (I.MALOP = KQ.MALOP AND I.SISO <> KQ.SISO) OR I.MALOP NOT IN 
			(
			SELECT DISTINCT MALOP
			FROM HOCVIEN 
			) 
	 )
	 BEGIN
		PRINT ' CAP NHAT SI SO SAI '
		ROLLBACK TRANSACTION
	 END
END

--- Câu 18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau 
---			(“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).

---				Thêm	Xóa		Sửa
--- DIEUKIEN	  +		 -		-(*)

GO
CREATE TRIGGER TRG_INS_DIEUKIEN ON DIEUKIEN 
FOR INSERT
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I
			WHERE MAMH = MAMH_TRUOC OR EXISTS
			(
				SELECT * FROM DIEUKIEN DK
				WHERE I.MAMH = DK.MAMH_TRUOC AND I.MAMH_TRUOC = DK.MAMH
			)
		)
		BEGIN 
			PRINT 'LOI: DIEU KIEN KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
END

--- Câu 19.	Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.

---				Thêm	Xóa				Sửa
--- GIAOVIEN	  +		 -	  +(HOCVI, HOCHAM, HESO, MUCLUONG)

GO
CREATE TRIGGER TRG_INS_UPDATE_GIAOVIEN_LUONG ON GIAOVIEN 
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, GIAOVIEN GV
			WHERE I.HOCVI = GV.HOCVI AND I.HOCHAM = GV.HOCHAM AND I.HESO = GV.HESO AND I.MUCLUONG <> GV.MUCLUONG
		)
		BEGIN 
			PRINT 'LOI: GIAO VIEN KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA GIAO VIEN THANH CONG'
		END
END

--- Câu 20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.

---				Thêm	Xóa	 	Sửa
--- KETQUATHI	  +		 -	  +(DIEM)
  
GO
CREATE TRIGGER TRG_INS_UPDATE_KETQUATHI_LANTHI ON KETQUATHI 
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, KETQUATHI KQT
			WHERE KQT.MAHV = I.MAHV AND KQT.MAMH = I.MAMH AND I.LANTHI = KQT.LANTHI + 1 AND KQT.DIEM >= 5
		)
		BEGIN 
			PRINT 'LOI: KET QUA THI KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA KET QUA THI THANH CONG'
		END
END

--- Câu 21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).

---				Thêm	Xóa	 	Sửa
--- KETQUATHI	  +		 -	  +(NGTHI)

GO
CREATE TRIGGER TRG_INS_UPDATE_KETQUATHI_NGTHI ON KETQUATHI 
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, KETQUATHI KQT
			WHERE KQT.MAHV = I.MAHV AND KQT.MAMH = I.MAMH AND I.LANTHI = KQT.LANTHI + 1 AND I.NGTHI < KQT.NGTHI
		)
		BEGIN 
			PRINT 'LOI: KET QUA THI KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA KET QUA THI THANH CONG'
		END
END

--- Câu 22. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học 
---			(sau khi học xong những môn học phải học trước mới được học những môn liền sau).

---				Thêm	Xóa	 	Sửa
--- DIEUKIEN	  +		 -		-(*)
--- GIANGDAY	  +		 -	  +(TUNGAY, DENNGAY)

GO
CREATE TRIGGER TRG_INS_DIEUKIEN_GD ON DIEUKIEN 
FOR INSERT
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM INSERTED I, GIANGDAY GD1, GIANGDAY GD2
			WHERE I.MAMH = GD1.MAMH AND I.MAMH_TRUOC = GD2.MAMH AND GD1.MALOP = GD2.MALOP AND GD1.TUNGAY < GD2.DENNGAY
		)
		BEGIN 
			PRINT 'LOI: DIEU KIEN KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
END

GO
CREATE TRIGGER TRG_INS_UPDATE_GIANGDAY ON GIANGDAY 
FOR INSERT, UPDATE
AS
BEGIN
		IF EXISTS
		(
			SELECT * FROM DIEUKIEN DK, INSERTED I, GIANGDAY GD
			WHERE DK.MAMH = I.MAMH AND DK.MAMH_TRUOC = GD.MAMH AND I.MALOP = GD.MALOP AND I.TUNGAY < GD.DENNGAY
		)
		BEGIN 
			PRINT 'LOI: GIANG DAY KHONG HOP LE!'
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN 
			PRINT 'THEM/SUA GIANG DAY THANH CONG'
		END
END

--- Câu 23. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.

---				Thêm	Xóa	 	Sửa
--- MONHOC		  -		 -	  +(MAKHOA)
--- GIANGDAY	  +		 -	  +(MAGV)
--- GIAOVIEN	  -		 -	  +(MAKHOA)

GO
CREATE TRIGGER TRG_UPDATE_MONHOC ON MONHOC
FOR UPDATE
AS
BEGIN
	IF EXISTS
	(
		SELECT * FROM INSERTED I, GIANGDAY GD, GIAOVIEN GV
		WHERE I.MAMH = GD.MAMH AND GV.MAGV = GD.MAGV AND I.MAKHOA <> GV.MAKHOA 
	)
	BEGIN
		PRINT 'LOI: MA KHOA CUA MON HOC KHONG HOP LE!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'SUA MON HOC THANH CONG'
	END
END

GO
CREATE TRIGGER TRG_UPDATE_GIAVOVIEN_GD ON GIAOVIEN
FOR UPDATE
AS
BEGIN
	IF EXISTS
	(
		SELECT * FROM INSERTED I, GIANGDAY GD, MONHOC MH
		WHERE MH.MAMH = GD.MAMH AND I.MAGV = GD.MAGV AND I.MAKHOA <> MH.MAKHOA
	)
	BEGIN
		PRINT 'LOI: MA KHOA CUA GIAO VIEN KHONG HOP LE!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'SUA GIAO VIEN THANH CONG'
	END
END

GO
CREATE TRIGGER TRG_INS_UPDATE_GIANGDAY_MH_GV ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS
	(
		SELECT * FROM INSERTED I, MONHOC MH, GIAOVIEN GV
		WHERE I.MAMH = MH.MAMH AND GV.MAGV = I.MAGV AND MH.MAKHOA <> GV.MAGV
	)
	BEGIN
		PRINT 'LOI: GIANG DAY KHONG HOP LE!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THEM/SUA GIANG DAY THANH CONG'
	END
END

--- Câu 24. Trong file bài tập em chỉ thấy tới câu 23 thôi ạ
