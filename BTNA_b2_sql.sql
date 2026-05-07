/*
PHẦN A – PHÂN TÍCH NGHIỆP VỤ
A1. Phân tích hệ thống
- Hệ thống cần quản lý những đối tượng nào?
	Users 
	Products 
	Categories 
	Orders 
	Order_Details 
- Dữ liệu nào có thể thay đổi theo thời gian?
	Tên khách hàng
	Địa chỉ
	Số điện thoại
	Giá sản phẩm
	Số lượng tồn kho
	Trạng thái đơn hàng
- Dữ liệu nào cần lưu lịch sử cố định?
	Giá sản phẩm tại thời điểm mua
	Thông tin người mua lúc đặt hàng
	Tổng tiền đơn hàng
	Danh sách sản phẩm đã mua
*/

/*
A2. Phân loại dữ liệu
1. Dữ liệu thay đổi (mutable data):Là dữ liệu có thể cập nhật nhiều lần.
Giải thích:
Các dữ liệu này thay đổi theo thời gian nên hệ thống phải cho phép sửa.

2. Dữ liệu giữ lịch sử (immutable data):Là dữ liệu sau khi tạo không nên thay đổi.
Giải thích:
Đơn hàng đã thanh toán cần giữ nguyên để báo cáo doanh thu chính xác.
*/

/*
A3. Phân tích vấn đề hệ thống
- Vì sao thay đổi địa chỉ làm ảnh hưởng đơn cũ là sai?
 + Vì đơn hàng cũ phải lưu đúng thông tin tại thời điểm mua hàng.Nếu khách đổi địa chỉ hiện tại mà đơn hàng lúc trước cũng đổi theo thì dữ liệu lịch sử bị sai.
- Vì sao không dùng trực tiếp giá hiện tại của sản phẩm?
+ Vì giá sản phẩm có thể thay đổi.Nếu lấy giá mới để xem đơn cũ thì cõ thể dẫn đến doanh thu bị sai, hóa đơn sai
- Vì sao cần kiểm tra tồn kho trước khi tạo đơn?
Để tránh:
	tồn kho bị âm
	khách đặt được sản phẩm không còn hàng
*/

-- PHẦN B – THIẾT KẾ HỆ THỐNG
/*
B3. Giải pháp nghiệp vụ
- Làm sao lưu giá tại thời điểm mua?
	b1:Trong bảng Order_Details lưu thêm:product_price
	b2:Khi khách mua copy giá hiện tại sang Order_Details

- Làm sao tránh tồn kho âm?

+Trước khi tạo đơn thì kiểm tra stock nếu stock < quantity → không cho đặt
+ Sau khi đặt thành công thì trừ số lượng trong kho
- Làm sao đảm bảo đơn hàng không bị thay đổi?
+ Lưu riêng:shipping_address,product_price,subtotal,total_money trong đơn hàng tại thời điểm mua.
*/

--  PHẦN C – MỞ RỘNG HỆ THỐNG
/*
C1. Mở rộng hệ thống
Nếu hệ thống tăng lên 1 triệu đơn/ngày:
Các em sẽ tối ưu database như thế nào?
=> Em sẽ tạo index cho các cột chưa id ở các bảng như user_id,product_id,order_id.Chỉ lưu dữ liệu cần thiết.Phân trang khi truy vấn

C2. Thiết kế tính năng mở rộng
=> Chọn mở rộng: Voucher.
+ thiết kế thêm bảng voucher:voucher_id,voucher_code,discount_percent,expired_date
*/

--  PHẦN D – SQL

create database rikkeistore;
use rikkeistore;

create table users (
    user_id int primary key auto_increment,
    full_name varchar(100),
    email varchar(100),
    phone varchar(20),
    address varchar(255)
);

create table categories (
    category_id int primary key auto_increment,
    category_name varchar(100)
);

create table products (
    product_id int primary key auto_increment,
    product_name varchar(100),
    price decimal(10,2),
    stock int,
    category_id int,
    foreign key (category_id) references categories(category_id)
);

create table orders (
    order_id int primary key auto_increment,
    user_id int,
    order_date datetime,
    status varchar(20),
    total_money decimal(10,2),
    shipping_address varchar(255),
    foreign key (user_id) references users(user_id)
);

create table order_details (
    order_detail_id int primary key auto_increment,
    order_id int,
    product_id int,
    quantity int,
    product_price decimal(10,2),
    subtotal decimal(10,2),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

insert into users(full_name,email,phone,address)
values
('Nguyen Van A','a@gmail.com','0901','Ha Noi'),
('Tran Thi B','b@gmail.com','0902','Hai Phong'),
('Le Van C','c@gmail.com','0903','Da Nang'),
('Pham Thi D','d@gmail.com','0904','Hue'),
('Hoang Van E','e@gmail.com','0905','HCM');

insert into categories(category_name)
values
('Electronics'),
('Fashion'),
('Books'),
('Food'),
('Laptop');

insert into products(product_name,price,stock,category_id)
values
('iPhone 15',2000,10,1),
('T-Shirt',20,50,2),
('SQL Book',15,30,3),
('Pizza',8,100,4),
('Macbook',3000,5,5);

insert into orders(user_id,order_date,status,total_money,shipping_address)
values
(1,now(),'Paid',2020,'Ha Noi'),
(2,now(),'Pending',40,'Hai Phong'),
(3,now(),'Cancelled',15,'Da Nang'),
(1,now(),'Paid',3000,'Ha Noi'),
(4,now(),'Paid',16,'Hue');

insert into order_details(order_id,product_id,quantity,product_price,subtotal)
values
(1,1,1,2000,2000),
(1,4,2,8,16),
(2,2,2,20,40),
(3,3,1,15,15),
(4,5,1,3000,3000);

-- Q1:Lấy danh sách tất cả đơn hàng
select 
    o.order_id,
    o.order_date,
    u.full_name,
    o.total_money
from orders o
join users u
on o.user_id = u.user_id;

-- Q2:Tìm tất cả sản phẩm thuộc category = 'Electronics'

select *
from products p
join categories c
on p.category_id = c.category_id
where c.category_name = 'Electronics';

-- Q3:Tìm danh sách users (user_id, full_name, email)

select user_id, full_name, email
from users;

-- Q4:Tính tổng số tiền tất cả đơn hàng trong hệ thống.
select sum(total_money) as total_revenue
from orders;

-- Q5:Tính tổng số lượng sản phẩm đã bán theo từng produc

select 
    p.product_id,
    p.product_name,
    sum(od.quantity) as total_quantity
from order_details od
inner join products p 
on od.product_id = p.product_id
group by p.product_id, p.product_name;

-- q6:Tìm sản phẩm có tổng số lượng bán lớn nhất.

select 
    p.product_id,
    p.product_name,
    sum(od.quantity) as total_quantity
from order_details od
inner join products p
on od.product_id = p.product_id
group by p.product_id, p.product_name
order by total_quantity desc
limit 1;

-- q7:Lấy danh sách đơn hàng
select
    o.order_id,
    u.full_name,
    o.total_money,
    sum(od.quantity) as total_product
from orders o
join users u
on o.user_id = u.user_id
join order_details od
on o.order_id = od.order_id
group by o.order_id, u.full_name, o.total_money;

-- q8:Tìm sản phẩm không xuất hiện trong bất kỳ Order_Details nào 
select *
from products
where product_id not in (
    select product_id
    from order_details
);

-- Q9:Tìm danh sách users đã từng mua hàng, kèm số đơn hàng của mỗi user.
select
    u.user_id,
    u.full_name,
    count(o.order_id) as total_orders
from users u
inner join orders o
on u.user_id = o.user_id
group by u.user_id, u.full_name;

-- q10:Tìm sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
select *
from products
where price > (
    select avg(price)
    from products
);

-- q11:Tìm users có tổng chi tiêu lớn hơn mức trung bình của tất cả users.
select
    u.user_id,
    u.full_name,
    sum(o.total_money) as total_spent
from users u
join orders o
on u.user_id = o.user_id
group by u.user_id, u.full_name
having total_spent > (
    select avg(total_money)
    from orders
);

-- q12:Tìm đơn hàng có giá trị lớn nhất trong hệ thống.
select *
from orders
where total_money = (
    select max(total_money)
    from orders
);
