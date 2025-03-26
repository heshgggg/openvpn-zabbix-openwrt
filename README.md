# openvpn-zabbix-openwrt

The scripts are intended for monitoring openvpn in OpenWrt router

![data](img1.png)

Latest Data Sections

![graph1](img2.png)

Graph

# Installation
1. Clone this repository
```
git clone https://github.com/heshgggg/openvpn-zabbix-openwrt; cd openvpn-zabbix-openwrt
```
2. Copy all scripts to somepath
```
cp -r * /somepath/
```
3. Set UserParameter on zabbix_agentd.conf

```
UserParameter=openvpn.monitor[*],/etc/openvpn/openvpn_monitor.sh $1 $2 $3
UserParameter=openvpn.authuser,/etc/openvpn/openvpn_auth_user_pass.sh
UserParameter=openvpn.authusercount,/etc/openvpn/openvpn_auth_user_pass_count.sh
UserParameter=openvpn.activeconnections,/etc/openvpn/openvpn_active_connection.sh
```

4. Restart zabbix_agent
```
/etc/init.d/zabbix_agentd restart
```
5. Import Zabbix Template from this repository xml file



Tested on Openwrt 24.10 and zabbix 7.2 
