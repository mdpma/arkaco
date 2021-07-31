in FusionPBX.sh: (since the repo branch may change, we need to change the below section as well)
#get the branch
if [ .$system_branch = .'master' ]; then
	verbose "Using master"
	branch=""
else
	system_major=$(git ls-remote --heads https://github.com/fusionpbx/fusionpbx.git | cut -d/ -f 3 | grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f1)
	system_minor=$(git ls-remote --tags https://github.com/fusionpbx/fusionpbx.git $system_major.* | cut -d/ -f3 |  grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f2)
	system_version=$system_major.$system_minor
	verbose "Using version $system_version"
	branch="-b $system_version"



    in php.sh:
    ("systemctl daemon-reload"  needs to be commented and "/etc/init.d/php7.4-fpm restart" is replced to restart)
    #restart php-fpm
        systemctl daemon-reload


    in nginx.sh:
    ("systemctl daemon-reload"  needs to be commented and "/etc/init.d/nginx restart" is replced to restart)
    #flush systemd cache
        systemctl daemon-reload
    #restart nginx
        service nginx restart


    in postgres.sh:
    (("systemctl daemon-reload"  needs to be commented and "/etc/init.d/postgresql restart" is replced to restart))
    #systemd
        systemctl daemon-reload
        systemctl restart postgresql


    in switch/source/package-systemd.sh:
    (all the below commands are commented and "supervisorctl restart freeswitch" replced )
        systemctl enable freeswitch
        systemctl unmask freeswitch.service
        systemctl daemon-reload
        systemctl start freeswitch


    in fail2ban.sh:
    ("/usr/sbin/service fail2ban restart" is commented and this command replced: "/etc/init.d/fail2ban restart")
    #restart fail2ban
        /etc/init.d/fail2ban restart


   in finish.sh:
   (the below commands are commented and to restart freeswitch this command is replced: "supervisorctl restart freeswitch")
    #restart freeswitch
        /bin/systemctl daemon-reload
        /bin/systemctl restart freeswitch