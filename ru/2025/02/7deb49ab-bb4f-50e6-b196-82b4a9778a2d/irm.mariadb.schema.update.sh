# 1.4.0
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.4.0/iredmail.mysql' | mariadb --user='root' --password --database='vmail'

# 1.4.1
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.4.1/iredmail.mysql' | mariadb --user='root' --password --database='vmail'
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.4.1/sogo.mysql' | mariadb --user='root' --password --database='sogo'

# 1.4.2
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.4.2/iredmail.mysql' | mariadb --user='root' --password --database='vmail'

# 1.6.3
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.6.3/iredmail.mysql' | mariadb --user='root' --password --database='vmail'

# 1.7.0
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.7.0/fail2ban.mysql' | mariadb --user='root' --password --database='fail2ban'

# 1.7.1
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.7.1/amavisd.mysql' | mariadb --user='root' --password --database='amavisd'

# 1.7.2
curl -fsSL 'https://raw.githubusercontent.com/iredmail/iRedMail/refs/heads/master/update/1.7.2/vmail.mysql' | mariadb --user='root' --password --database='vmail'
