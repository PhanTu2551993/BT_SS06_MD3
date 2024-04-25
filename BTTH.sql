create database btth_2;
use btth_2;

create table Category
(
    Id     int auto_increment primary key,
    Name   varchar(100) not null unique,
    Status tinyint default 1 check ( Status in (0, 1))
);

create table Customer
(
    Id          int auto_increment primary key,
    Name        varchar(150) not null,
    Email       varchar(150) not null unique,
    Phone       varchar(50)  not null unique,
    Address     varchar(255),
    CreatedDate date default (current_date),
    Gender      tinyint      not null check ( Gender in (0, 1, 2) ),
    BirthDay    date         not null
);

create table Room
(
    Id          int auto_increment primary key,
    Name        varchar(150) not null,
    Status      tinyint default 1 check ( Status in (0, 1) ),
    Price       float        not null,
    SalePrice   float   default 0,
    CreatedDate date    default (current_date),
    CategoryId  int          not null,
    FOREIGN KEY (CategoryId) REFERENCES Category (Id)
);

create table Booking
(
    Id          int auto_increment primary key,
    CustomerId  int not null,
    Status      tinyint  default 1 check ( Status in (0, 1, 2, 3)),
    BookingDate datetime default current_timestamp,
    FOREIGN KEY (CustomerId) REFERENCES Customer (Id)
);

create table BookingDetail
(
    BookingId int      not null,
    RoomId    int      not null,
    Price     float    not null,
    StartDate datetime not null,
    EndDate   datetime not null,
    primary key (BookingId, RoomId),
    FOREIGN KEY (BookingId) REFERENCES Booking (Id),
    FOREIGN KEY (RoomId) REFERENCES Room (Id)
);

# Nhập Price giá tr nhỏ nhất là 100000
delimiter //
create trigger check_min_price
    before insert
    on Room
    for each row
begin
    if NEW.Price < 100000 then
        signal sqlstate '45000' set message_text = 'Giá của phòng ít nhất phải là 100,000 đồng';
     end if;
end // 
delimiter ;
# Nhập SalePrice phải <= Price

create trigger check_saleprice
    before insert
    on Room
    for each row
begin
    if NEW.SalePrice is null then
        set NEW.SalePrice = 0;
    end if;
    if NEW.SalePrice > NEW.Price then
        signal sqlstate '45000'
            set message_text = 'Giá giảm không thể lớn hơn giá gốc';
    end if;
end;

# Nhập CreatDate phải lớn hơn ngày hiện tại

create trigger check_creatdate
    before insert
    on Customer
    for each row
begin
    if NEW.CreatedDate is null then
        set NEW.CreatedDate = current_date;
    end if;
    if NEW.CreatedDate < current_date then
        signal sqlstate '45000'
            set message_text = 'Ngày tạo phòng không thể trước ngày hiện tại';
    end if;
end;

# nhập ngày EndDate

create trigger check_enddate
    before insert
    on BookingDetail
    for each row
begin
    if NEW.EndDate < NEW.StartDate then
        signal sqlstate '45000'
            set message_text = 'Ngày kết thúc phải lớn hơn ngày bắt đầu';
    end if;
end;
insert into Category (Name, Status)
values ('Standard', 1),
       ('Deluxe', 1),
       ('Superior', 1),
       ('Suite', 1),
       ('Economy', 1);

insert into Customer (Name, Email, Phone, Address, CreatedDate, Gender, BirthDay)
values ('John Doe', 'john@example.com', '123456789', '123 Street, City', CURRENT_DATE, 1, '1990-01-01'),
       ('Jane Smith', 'jane@example.com', '987654321', '456 Avenue, Town', CURRENT_DATE, 0, '1992-03-15'),
       ('Alice Brown', 'alice@example.com', '456123789', '789 Road, Village', CURRENT_DATE, 0, '1988-07-20');

-- Chèn các bản ghi cho phòng loại Standard
insert into Room (Name, Status, Price, CategoryId)
values ('Standard 101', 1, 150000, 1),
       ('Standard 102', 1, 150000, 1),
       ('Standard 103', 1, 150000, 1),
       ('Standard 201', 1, 150000, 1),
       ('Standard 202', 1, 150000, 1);

-- Chèn các bản ghi cho phòng loại Deluxe
insert into Room (Name, Status, Price, CategoryId)
values ('Deluxe 201', 1, 250000, 2),
       ('Deluxe 202', 1, 250000, 2),
       ('Deluxe 301', 1, 250000, 2),
       ('Deluxe 302', 1, 250000, 2),
       ('Deluxe 303', 1, 250000, 2);

-- Chèn các bản ghi cho phòng loại Superior
insert into Room (Name, Status, Price, CategoryId)
values ('Superior 401', 1, 350000, 3),
       ('Superior 402', 1, 350000, 3),
       ('Superior 403', 1, 350000, 3),
       ('Superior 501', 1, 350000, 3),
       ('Superior 502', 1, 350000, 3);

-- Chèn các bản ghi cho phòng loại Suite
insert into Room (Name, Status, Price, CategoryId)
values ('Suite 601', 1, 500000, 4),
       ('Suite 602', 1, 500000, 4),
       ('Suite 701', 1, 500000, 4),
       ('Suite 702', 1, 500000, 4),
       ('Suite 801', 1, 500000, 4);

-- Chèn các bản ghi cho phòng loại Economy
insert into Room (Name, Status, Price, CategoryId)
values ('Economy 101', 1, 100000, 5),
       ('Economy 102', 1, 100000, 5),
       ('Economy 103', 1, 100000, 5),
       ('Economy 104', 1, 100000, 5),
       ('Economy 105', 1, 100000, 5);

-- Chèn các bản ghi cho đặt phòng 1
insert into Booking (CustomerId, Status, BookingDate)
values (1, 1, CURRENT_TIMESTAMP);

insert into BookingDetail (BookingId, RoomId, Price, StartDate, EndDate)
values (1, 1, 150000, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 3 DAY)),
       (1, 6, 250000, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 3 DAY));

-- Chèn các bản ghi cho đặt phòng 2
insert into Booking (CustomerId, Status, BookingDate)
values (2, 1, CURRENT_TIMESTAMP);

insert into BookingDetail (BookingId, RoomId, Price, StartDate, EndDate)
values (2, 11, 350000, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 DAY)),
       (2, 16, 100000, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 DAY));

-- Chèn các bản ghi cho đặt phòng 3
insert into Booking (CustomerId, Status, BookingDate)
values (3, 1, CURRENT_TIMESTAMP);

insert into BookingDetail (BookingId, RoomId, Price, StartDate, EndDate)
values (3, 21, 500000, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 5 DAY)),
       (3, 25, 250000, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 5 DAY));


#1.	Lấy ra danh phòng có sắp xếp giảm dần theo Price gồm các cột sau: Id, Name, Price, SalePrice, Status, CategoryName, CreatedDate

select c.Id, r.Name, Price, SalePrice, r.Status, c.Name CategoryName, CreatedDate
from Room r
         join Category C on C.Id = r.CategoryId
order by Price desc;

#2.	Lấy ra danh sách Category gồm: Id, Name, TotalRoom, Status (Trong đó cột Status nếu = 0, Ẩn, = 1 là Hiển thị )
select c.Id, c.Name, count(r.Id) TotalRoom, if(c.Status = 0, 'Ẩn', 'Hiển thị') as 'Trạng thái'
from Category c
         join Room R on c.Id = R.CategoryId
group by c.Id;

#3.	Truy vấn danh sách Customer gồm: Id, Name, Email, Phone, Address, CreatedDate, Gender, BirthDay, Age (Age là cột suy ra từ BirthDay, Gender nếu = 0 là Nam, 1 là Nữ,2 là khác )
select Id,
       Name,
       Email,
       Phone,
       Address,
       CreatedDate,
       year(curdate()) - year(birthday)                               age,
       case Gender when 0 then 'Nam' when 1 then 'Nữ' else 'LGBT' end Gender
from Customer
group by Id;

#4.	Truy vấn xóa các sản phẩm chưa được bán
DELETE
FROM Room
WHERE Id NOT IN (SELECT RoomId FROM BookingDetail);

#5.	Cập nhật Cột SalePrice tăng thêm 10% cho tất cả các phòng có Price >= 250000
update Room
set SalePrice = Price * 1.1
where Price >= 25000;
# 1.	View v_getRoomInfo Lấy ra danh sách của 10 phòng có giá cao nhất
create view v_getRoomInfo
as
select id, name, status, price, saleprice, createddate
from Room
order by Price desc
limit 10;

# 2.	View v_getBookingList hiển thị danh sách phiếu đặt hàng gồm:
# Id, BookingDate, Status, CusName, Email, Phone,TotalAmount ( Trong đó cột Status nếu = 0 Chưa duyệt, = 1  Đã duyệt, = 2 Đã thanh toán, = 3 Đã hủy )

create view v_getBookingList
as
select b.Id,
       BookingDate,
       case (b.Status) when 0 then 'Chưa duyệt' when 1 then 'Đã duyệt' else 'Đã thanh toán' end 'Trạng Thái',
       c.Name CusName,
       Email,
       Phone,
       sum(bd.Price) TotalAmount
from booking b
         join Customer C on C.Id = b.CustomerId
         join BookingDetail BD on b.Id = BD.BookingId
GROUP BY b.Id, b.BookingDate, b.Status, c.Name, c.Email, c.Phone;

#1.	Thủ tục addRoomInfo thực hiện thêm mới Room, khi gọi thủ tục truyền đầy đủ các giá trị của bảng Room ( Trừ cột tự động tăng )
  delimiter //
    create procedure addRoomInfo(
        IN_Name        varchar(150),
        IN_Status      tinyint ,
        IN_Price       float,
        IN_CreatedDate date ,
        IN_CategoryId  int
    )
    begin
        insert into Room( name, status, price, createddate, categoryid)
            values (IN_Name,IN_Status,IN_Price,IN_CreatedDate,IN_CategoryId);
    end //
    delimiter ;

    call addRoomInfo('Deluxe 401', 1, 250000, curdate(),2);

#2.	Thủ tục getBookingByCustomerId hiển thị danh sách phieus đặt phòng của khách hàng theo Id khách hàng gồm:
# Id, BookingDate, Status, TotalAmount (Trong đó cột Status nếu = 0 Chưa duyệt, = 1  Đã duyệt,, = 2 Đã thanh toán, = 3 Đã hủy), Khi gọi thủ tục truyền vào id cảu khách hàng

    delimiter //
    create procedure getBookingByCustomerId(IN_Id int)
    begin
        select b.Id,
               BookingDate,
               case (b.Status) when 0 then 'Chưa duyệt' when 1 then 'Đã duyệt' else 'Đã thanh toán' end 'Trạng Thái',
               c.Name CusName,
               Email,
               Phone,
               sum(bd.Price) TotalAmount
        from booking b
                 join Customer C on C.Id = b.CustomerId
                 join BookingDetail BD on b.Id = BD.BookingId
        where b.Id = IN_Id
        GROUP BY b.Id, b.BookingDate, b.Status, c.Name, c.Email, c.Phone;
    end //
delimiter ;
call getBookingByCustomerId(2);

#3.	Thủ tục getRoomPaginate lấy ra danh sách phòng có phân trang gồm: Id, Name, Price, SalePrice, Khi gọi thủ tuc truyền vào limit và page

delimiter //
create procedure getRoomPaginate(page int , size int)
begin
    declare off_set int ;
    set off_set = page*size;
    select Id, Name, Status,Price,SalePrice,CreatedDate,CategoryId
    from Room limit off_set,size;
end ;
delimiter //

call getRoomPaginate(1,3);

