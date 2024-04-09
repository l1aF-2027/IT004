USE QUANLYGIAOVU

---					PHẦN II
--- Câu 1.	Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN 
SET HESO = HESO + 0.2
WHERE MAGV IN (SELECT TRGKHOA FROM KHOA)

--- Câu 2.	Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên 
---			(tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng).
WITH DIEMLANTHICUOI AS
(
	SELECT MAHV, MAMH, MAX(LANTHI) AS LANTHICUOI
	FROM KETQUATHI
	GROUP BY MAHV, MAMH
)

UPDATE HOCVIEN
SET DIEMTB = 
(
	SELECT AVG(DIEM)
	FROM KETQUATHI KQT
	WHERE KQT.MAHV = HOCVIEN.MAHV AND KQT.LANTHI = (SELECT LANTHICUOI FROM DIEMLANTHICUOI DLTC WHERE DLTC.MAHV = KQT.MAHV AND DLTC.MAMH = KQT.MAMH)
)

--- Câu 3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần thứ 3 dưới 5 điểm.
UPDATE HOCVIEN 
SET GHICHU = 'Cam thi'
WHERE MAHV IN (SELECT MAHV FROM KETQUATHI WHERE LANTHI = 3 AND DIEM < 5)

--- Câu 4.	Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
---			o	Nếu DIEMTB >= 9 thì XEPLOAI =”XS”
---			o	Nếu  8 <= DIEMTB < 9 thì XEPLOAI = “G”
---			o	Nếu  6.5 <= DIEMTB < 8 thì XEPLOAI = “K”
---			o	Nếu  5  <=  DIEMTB < 6.5 thì XEPLOAI = “TB”
---			o	Nếu  DIEMTB < 5 thì XEPLOAI = ”Y”
UPDATE HOCVIEN
SET XEPLOAI = 
    CASE
        WHEN DIEMTB >= 9 THEN 'XS'
        WHEN DIEMTB >= 8 AND DIEMTB < 9 THEN 'G'
        WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
        WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
        WHEN DIEMTB < 5 THEN 'Y'
    END

---					PHẦN III
--- Câu 6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006.
SELECT DISTINCT MH.TENMH
FROM MONHOC MH
	JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
	JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV
WHERE GV.HOTEN = 'Tran Tam Thanh' AND GD.HOCKY = 1 AND GD.NAM = 2006

--- Câu 7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.
SELECT DISTINCT MH.MAMH, MH.TENMH
FROM MONHOC MH
	JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
WHERE GD.MAGV = (SELECT MAGVCN FROM LOP WHERE MALOP = 'K11') AND GD.HOCKY = 1 AND GD.NAM = 2006 

--- Câu 8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”
SELECT HV.HO, HV.TEN
FROM HOCVIEN HV
WHERE HV.MAHV IN (SELECT TRGLOP FROM LOP)
	  AND HV.MALOP IN 
	  (
		SELECT MALOP 
		FROM GIANGDAY GD 
			JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV
			JOIN MONHOC MH ON GD.MAMH = MH.MAMH
		WHERE GV.HOTEN = 'Nguyen To Lan' AND MH.TENMH = 'Co So Du Lieu'
	  )

--- Câu 9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
SELECT MAMH, TENMH
FROM MONHOC 
WHERE MAMH IN 
(
	SELECT DK.MAMH_TRUOC 
	FROM DIEUKIEN DK
		JOIN MONHOC MH ON DK.MAMH = MH.MAMH
	WHERE MH.TENMH = 'Co So Du Lieu'
)

--- Câu 10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.
SELECT MAMH, TENMH
FROM MONHOC 
WHERE MAMH IN 
	  (
		  SELECT DK.MAMH 
		  FROM DIEUKIEN DK
			JOIN MONHOC MH ON DK.MAMH_TRUOC = MH.MAMH
		  WHERE MH.TENMH = 'Cau Truc Roi Rac'
	  )

--- Câu 11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
SELECT HOTEN
FROM GIAOVIEN 
WHERE MAGV IN (
	SELECT MAGV FROM GIANGDAY 
	WHERE MAMH = 'CTRR' AND MALOP IN ('K11', 'K12') AND HOCKY = 1 AND NAM = 2006
	GROUP BY MAGV 
	HAVING COUNT(DISTINCT MALOP) = 2
)

--- Câu 12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.
WITH LANTHICUOI_CSDl AS
(
    SELECT MAHV, MAMH, MAX(LANTHI) AS LANTHICUOI
    FROM KETQUATHI
    WHERE MAMH = 'CSDL'
    GROUP BY MAHV, MAMH
)

SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV 
	JOIN LANTHICUOI_CSDL LTC ON HV.MAHV = LTC.MAHV
	JOIN KETQUATHI KQT ON LTC.MAHV = KQT.MAHV AND LTC.MAMH = KQT.MAMH AND LTC.LANTHICUOI = KQT.LANTHI
WHERE LTC.LANTHICUOI = 1 AND KQT.KQUA = 'Khong dat'

--- Câu 13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT MAGV, HOTEN
FROM GIAOVIEN 
WHERE MAGV NOT IN
(
	SELECT DISTINCT MAGV 
	FROM GIANGDAY
)
	
--- Câu 14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN 
(
    SELECT DISTINCT GD.MAGV
    FROM GIANGDAY GD
		JOIN MONHOC MH ON GD.MAMH = MH.MAMH
    WHERE MH.MAKHOA = GIAOVIEN.MAKHOA
)

--- Câu 15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.
SELECT HO, TEN
FROM HOCVIEN
WHERE MAHV IN
(
	SELECT DISTINCT HV.MAHV
	FROM HOCVIEN HV
		JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
	WHERE HV.MALOP = 'K11' AND ((KQT.LANTHI >= 3 AND KQT.KQUA = 'Khong dat') OR (KQT.DIEM = 5 AND KQT.MAMH = 'CTRR' AND KQT.LANTHI = 2))
)

--- Câu 16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
SELECT HOTEN
FROM GIAOVIEN
WHERE MAGV IN
(
	SELECT MAGV
	FROM GIANGDAY
	WHERE MAMH = 'CTRR'
	GROUP BY MAGV, HOCKY, NAM
	HAVING COUNT(DISTINCT MALOP) >=2
)

--- Câu 17.	Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
WITH LANTHICUOI AS
(
    SELECT MAHV, MAMH, MAX(LANTHI) AS LANTHICUOI
    FROM KETQUATHI
    WHERE MAMH = 'CSDL'
    GROUP BY MAHV, MAMH
)

SELECT HV.MAHV, HV.HO, HV.TEN, KQT.LANTHI AS LANTHICUOI, KQT.DIEM
FROM HOCVIEN HV
	JOIN LANTHICUOI LTC ON HV.MAHV = LTC.MAHV
	JOIN KETQUATHI KQT ON LTC.MAHV = KQT.MAHV AND LTC.MAMH = KQT.MAMH AND LTC.LANTHICUOI = KQT.LANTHI
WHERE KQT.MAMH = 'CSDL'
ORDER BY HV.MAHV

--- Câu 18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
WITH DIEMTHICAONHAT AS
(
    SELECT MAHV, MAMH, MAX(DIEM) AS DIEMCAONHAT
    FROM KETQUATHI
    WHERE MAMH = 'CSDL'
    GROUP BY MAHV, MAMH
)

SELECT HV.MAHV, HV.HO, HV.TEN, KQT.DIEM AS DIEMCAONHAT
FROM HOCVIEN HV
	JOIN DIEMTHICAONHAT DTCN ON HV.MAHV = DTCN.MAHV
	JOIN KETQUATHI KQT ON DTCN.MAHV = KQT.MAHV AND DTCN.MAMH = KQT.MAMH AND DTCN.DIEMCAONHAT = KQT.DIEM
WHERE KQT.MAMH = 'CSDL'
