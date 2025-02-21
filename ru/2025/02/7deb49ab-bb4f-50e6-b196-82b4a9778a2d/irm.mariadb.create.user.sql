-- USER: 'amavisd'.
create user if not exists 'amavisd'@'127.0.0.1' identified by 'PASSWORD';
grant select, insert, update, delete on amavisd.* to 'amavisd'@'127.0.0.1';
-- USER: 'fail2ban'.
create user if not exists 'fail2ban'@'127.0.0.1' identified by 'PASSWORD';
grant all privileges on fail2ban.* to 'fail2ban'@'127.0.0.1';
-- USER: 'iredadmin'.
create user if not exists 'iredadmin'@'127.0.0.1' identified by 'PASSWORD';
grant all privileges on iredadmin.* to 'iredadmin'@'127.0.0.1';
-- USER: 'iredapd'.
create user if not exists 'iredapd'@'127.0.0.1' identified by 'PASSWORD';
grant all privileges on iredapd.* to 'iredapd'@'127.0.0.1';
-- USER: 'roundcube'.
create user if not exists 'roundcube'@'127.0.0.1' identified by 'PASSWORD';
grant all privileges on roundcubemail.* to 'roundcube'@'127.0.0.1';
grant select, update on vmail.mailbox to 'roundcube'@'127.0.0.1';
-- USER: 'vmail'.
create user if not exists 'vmail'@'127.0.0.1' identified by 'PASSWORD';
grant select on vmail.* to 'vmail'@'127.0.0.1';
-- USER: 'vmailadmin'.
create user if not exists 'vmailadmin'@'127.0.0.1' identified by 'PASSWORD';
grant select, insert, update, delete on vmail.* to 'vmailadmin'@'127.0.0.1';
-- INFO: Reload the grant tables.
flush privileges;
