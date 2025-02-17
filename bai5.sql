use ss_13;
-- 2) Tạo bảng transaction_log để ghi nhận lịch sử giao dịch
create table transaction_log (
	log_id int primary key auto_increment,
    log_message text not null,
    log_time timestamp default(current_timestamp())
) engine = 'MyISAM';
-- 3) Thêm cột last_pay_date để theo dõi ngày trả lương gần nhất cho nhân viên.
alter table employees
add column last_pay_date date not null;
-- 4) Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm chuyển lương cho nhân viên từ quỹ công ty, thực hiện theo các bước sau:
set autocommit = 0;
DELIMITER //
create procedure salary_transfer(
	In emp_id_in int,
		fund_id_in int
    )
begin 
	declare com_balance decimal(10,2);
	declare emp_salary decimal(10,2);
	START TRANSACTION;
	if(select count(emp_id) from employees where emp_id = emp_id_in) = 0
    or (select count(fund_id) from company_funds where fund_id = fund_id_in ) = 0 then
		insert into transaction_log(log_message)
			values('Mã nhân viên hoặc mã công ty không tồn tại');
		rollback;
	else
		select balance into com_balance from company_funds where fund_id = fund_id_in;
		select salary into emp_salary from employees where emp_id = emp_id_in;
        if com_balance < emp_salary then
			insert into transaction_log(log_message)
				values('Số dư tài khoản công ty không đủ');
			rollback;
        else
			update company_funds
            set balance = balance - emp_salary
            where fund_id = fund_id_in;
            insert into transaction_log(log_message)
			values('Thanh toán lương thành công');
            insert into payroll(emp_id,salary,pay_date)
            values(emp_id_in,emp_salary,curdate());
            commit;
		end if;
	end if;
end //
DELIMITER ;
-- 5) Gọi store procedure trên với tham số tương ứng
 select * from company_funds;
 select * from employees;
 select * from transaction_log;
 select * from payroll;
call salary_transfer(2,1);