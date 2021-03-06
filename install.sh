#!/bin/bash
# @zyqf
# email:qq767026763@gmail.com

echo '|-------------------Installing---------------------|' ;
echo '|install gcc openssl openssl-devel perl bind-utils |' ;
echo '|Development Tools; About download size:60MB       |' ;
echo '|  PandaDNS Project : https://github.com/zyqf/DNS  |' ;
echo '|--------------------------------------------------|' ;

yum groupinstall "Development Tools" -y ;
yum install gcc openssl openssl-devel perl bind-utils -y;
yum groupinstall "Development Libraries" -y;

echo '|-------------------Downloading--------------------|' ;
echo '|download bind-9.10.3-P4 ..........................|' ;
echo '|--------------------------------------------------|' ;
cd /tmp;
wget -O bind.tar.gz "https://www.isc.org/downloads/file/bind-9-10-3-p4/?version=tar-gz";
tar -zxvf bind.tar.gz;


echo '|-------------------Configure----------------------|' ;
echo '|./configure --prefix=/usr/local/named ............|' ;
echo '|--------------------------------------------------|' ;


cd bind-9.10.3-P4;
./configure --prefix=/usr/local/named  --enable-threads --enable-largefile;

echo '|-------------------Make install-------------------|' ;
echo '|make install bind9.3.4 ...........................|' ;
echo '|--------------------------------------------------|' ;
make && make install;

echo '|-------------------Final treatment----------------|' ;
setenforce 0;
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config;

groupadd named;
useradd -g named -d /usr/local/named -s /sbin/nologin named;

cd /usr/local/named/etc;

/usr/local/named/sbin/rndc-confgen > rndc.conf;
cat rndc.conf > rndc.key;
chmod 777 /usr/local/named/var;
tail -10 rndc.conf | head -9 | sed s/#\ //g > named.conf;

cd /usr/local/named/var;

dig @a.root-servers.net . ns > named.root;
rm -rf /etc/rc.d/init.d/named;
python /root/DNS/bin/create_named_service.py;
chmod 755 /etc/rc.d/init.d/named;
chkconfig --add named;

touch /usr/local/named/var/rpz.zone;
python /root/DNS/bin/create_named.py;
python /root/DNS/bin/update.py;

mkdir /var/named;
ln -s /usr/local/named/var/* /var/named/;
ln -s /usr/local/named/etc/named.conf /etc/;
ln -s /usr/local/named/sbin/* /usr/bin/;

chown -R root:named /usr/local/named/var;
service named start;
service named status;
echo '|-------------------COMPLETE-----------------------|' ;
echo '|      The script was finish.Please Check!         |' ;
echo '|  PandaDNS Project : https://github.com/zyqf/DNS  |' ;
echo '|-------------------ENJOY IT!----------------------|' ;
