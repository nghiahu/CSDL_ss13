use ss_13;
-- 2) Tiến hành tạo bảng enrollments_history
create table enrollments_history(
	history_id int primary key auto_increment,
    student_id int not null,
    course_id int not null,
    action varchar(50),
    time_stamp datetime,
    foreign key (student_id) references students(student_id),
    foreign key (course_id) references courses(course_id)
);
-- 3) Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm đăng ký học phần cho một sinh viên vào một môn học bất kỳ, thực hiện theo các bước sau
DELIMITER //
create procedure register_course(
    in p_student_name varchar(50),
	p_course_name varchar(100)
)
begin
declare v_student_id int;
declare v_course_id int;
declare v_seats int;
declare v_enrolled int default 0;
    START TRANSACTION;
    select student_id into v_student_id from students where student_name = p_student_name limit 1;
    select course_id, available_seats into v_course_id, v_seats from courses where course_name = p_course_name limit 1;
    select count(*) into v_enrolled from enrollments where student_id = v_student_id and course_id = v_course_id;
	if v_enrolled > 0 then
        insert into enrollments_history (student_id, course_id, action,time_stamp)
        values (v_student_id, v_course_id, 'FAILED',now());
    else
		if v_seats <= 0 then
            insert into enrollments_history (student_id, course_id, action,time_stamp)
			values (v_student_id, v_course_id, 'FAILED',now());
		else
			insert into enrollments (student_id, course_id)
			values (v_student_id, v_course_id);
			update courses
			set available_seats = available_seats - 1
			where course_id = v_course_id;
			insert into enrollments_history (student_id, course_id, action,time_stamp)
			values (v_student_id, v_course_id, 'REGISTERED',now());
		end if;
	end if;
    commit;
end //
DELIMITER ;
-- 4) Gọi STORE PROCEDURE trên với tham số thích hợp
call register_course('Nguyễn Văn An', 'Lập trình C');
-- 5) Hiển thị lại bảng enrollments, courses, enrollments_history để kiểm chứng
select * from enrollments;
select * from courses;
select * from enrollments_history;

