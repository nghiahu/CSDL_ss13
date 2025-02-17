use ss_13;
CREATE TABLE company_funds (
    fund_id INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(15,2) NOT NULL -- Số dư quỹ công ty
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,   -- Tên nhân viên
    salary DECIMAL(10,2) NOT NULL    -- Lương nhân viên
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,                      -- ID nhân viên (FK)
    salary DECIMAL(10,2) NOT NULL,   -- Lương được nhận
    pay_date DATE NOT NULL,          -- Ngày nhận lương
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);


INSERT INTO company_funds (balance) VALUES (50000.00);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);

-- 2) Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm chuyển lương cho nhân viên từ quỹ công ty
set autocommit = 0;
DELIMITER //
	create procedure transferMoneyToEmploye(In p_emp_id int)
begin
	declare v_salary decimal(10,2);
    declare v_balance decimal(15,2);
    declare bank_error int default 0;
	START TRANSACTION;
    if(select count(emp_id) from employees where emp_id = p_emp_id) = 0 then
		rollback;
	else
		select salary into v_salary from employees where emp_id = p_emp_id;
        select balance into v_balance from company_funds;
		if v_balance < v_salary then
			rollback;
		else 
			update company_funds 
            set balance = balance - v_salary;
			insert into payroll (emp_id, salary, pay_date) 
			values(p_emp_id, v_salary, curdate());
            if bank_error = 1 then
				rollback;
			end if;
		end if;
	end if;
	commit;	
end //
DELIMITER ;
-- 3) Gọi store procedure trên với tham số phù hợp.
call transferMoneyToEmployee(1);