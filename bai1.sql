-- 1) Tiến hành tạo bảng account đúng theo mô tả trên
create database ss_13;
use ss_13;

create table accounts(
	account_id int primary key auto_increment, 
    account_name varchar(50),
    balance decimal(10,2)
);
-- 2
INSERT INTO accounts (account_name, balance) VALUES 
('Nguyễn Văn An', 1000.00),
('Trần Thị Bảy', 500.00);

-- 3) Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm chuyển tiền từ tài khoản này sang tài khoản khác, thực hiện theo các bước sau:
set autocommit = 0;
DELIMITER //
create procedure acc_transaction(
	In from_account int,
		to_account  int,
		amount decimal(10,2)
)
begin
		START TRANSACTION;
        if(select count(account_id) from accounts where account_id = from_account) = 0 or
			(select count(account_id) from accounts where account_id = to_account) = 0 then
			rollback;
		else
			update accounts
			set balance = balance - amount
            where account_id = from_account;
			if(select balance from accounts where account_id = from_account) < amount then
				rollback;
			else
				update accounts
				set balance = balance + amount
				where account_id = to_account;
			commit;
		end if;
	end if;
end //
DELIMITER ;

-- 4) Gọi store procedure trên với tham số tương ứng.
call acc_transaction(1,2,100);
select * from accounts;

