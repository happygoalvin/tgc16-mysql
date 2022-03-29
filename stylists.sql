-- stylist table
create table stylists(
    stylist_id smallint unsigned auto_increment primary key,
    name varchar(80) not null,
    designation varchar(30) not null
) engine = innodb;

-- rewards table
create table rewards(
    reward_id int unsigned auto_increment primary key,
    name varchar (100) not null,
    type varchar (50) not null
) engine = innodb;

--insert sample data for stylists
insert into stylists (name, designation) values
    ("John Wick", "Director"),
    ("Barbra Streisand", "Senior Hairstylist"),
    ("Rupaul", "Senior Hairstylist"),
    ("Will Smith", "Celebrity Hairstylist"),
    ("Vincent Ang", "Hairstylist");

--insert sample data for rewards
insert into rewards (name, type) value
    ("$5 OFF", "Discount"),
    ("Tresemme Shampoo", "Product"),
    ("Hair Masque", "Product"),
    ("Argan Oil Conditioner", "Product"),
    ("Bumble and Bumble Pomade", "Product");

-- how to change primary key data type
--alter table stylists
--modify stylist_id smallint unsigned;

--alter table rewards
--modify reward_id smallint unsigned;

create table members(
    member_id int unsigned auto_increment primary key,
    first_name varchar(45) not null,
    last_name varchar(45) not null,
    contact_number varchar(15) not null
) engine = innodb;

create table services(
    service_id tinyint unsigned auto_increment primary key,
    name varchar(50) not null,
    cost mediumint unsigned not null
) engine = innodb;

insert into members (first_name, last_name, contact_number) values
    ("John", "Apple", "91234567"),
    ("Rob", "Stark", "81234567"),
    ("Peter", "Parker", "98765432");

insert into services (name, cost) values
    ("Haircut", "30"),
    ("Wash", "10"),
    ("Wash and massage", "50"),
    ("Hair straightening", 200);

create table appointments (
    appointment_id integer unsigned auto_increment primary key,
    datetime datetime not null,
    venue varchar(100) not null,
    points mediumint unsigned not null
) engine = innodb;

alter table appointments add column member_id int unsigned,
                        add column stylist_id smallint unsigned,
                        add column service_id tinyint unsigned;

alter table appointments add constraint appointments_stylists
    foreign key (stylist_id) references stylists(stylist_id);

alter table appointments add constraint appointments_members
    foreign key (member_id) references members(member_id);

alter table appointments add constraint appointments_services
    foreign key (service_id) references services(service_id);

insert into appointments(member_id, stylist_id, service_id, datetime, venue, points) values
(1,1,1, "2022-03-29 12:10:10", "The Continental Barber Shop", 100),
(2,2,2, "2022-03-29 12:11:10", "The Continental Barbershop", 100),
(3,3,3, "2022-03-29 12:15:30", "The Continental Barbershop", 100);


create table transactions(
    transaction_id integer unsigned auto_increment primary key
) engine = innodb;

alter table transactions add column service_id tinyint unsigned,
                         add column appointment_id integer unsigned,
                         add column reward_id smallint unsigned;

alter table transactions add constraint transactions_services
    foreign key (service_id) references services(service_id);

alter table transactions add constraint transactions_appointments
    foreign key (appointment_id) references appointments(appointment_id);

alter table transactions add constraint transactions_rewards
    foreign key (reward_id) references rewards(reward_id);

insert into transactions(service_id, appointment_id,reward_id) values
(1,1,1),
(2,2,2),
(3,3,3);