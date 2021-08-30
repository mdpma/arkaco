
--set the variables
	conf_dir = [[/etc/freeswitch]];
	sounds_dir = [[/usr/share/freeswitch/sounds]];
	database_dir = [[/var/lib/freeswitch/db]];
	recordings_dir = [[/var/lib/freeswitch/recordings]];
	storage_dir = [[/var/lib/freeswitch/storage]];
	voicemail_dir = [[/var/lib/freeswitch/storage/voicemail]];
	scripts_dir = [[/usr/share/freeswitch/scripts]];
	php_dir = [[/usr/bin]];
	php_bin = "php";
	document_root = [[/var/www/fusionpbx]];
	project_path = [[]];
	http_protocol = [[http]];

--cache settings
	cache = {}
	cache.method = [[file]];
	cache.location = [[/var/cache/fusionpbx]];
	cache.settings = false;

--database information
	database = {}
	database.type = "pgsql";
	database.name = "fusionpbx";
	database.path = [[]];
	database.system = "pgsql://hostaddr=127.0.0.1 port=5432 dbname=fusionpbx user=fusionpbx password=dzzONBAEm6ds6vBtqy5n1rzgTk options=''";
	database.switch = "pgsql://hostaddr=127.0.0.1 port=5432 dbname=freeswitch user=fusionpbx password=dzzONBAEm6ds6vBtqy5n1rzgTk options=''";

	database.backend = {}
	database.backend.base64 = 'luasql'

--set defaults
	expire = {}
	expire.default = "3600";
	expire.directory = "3600";
	expire.dialplan = "3600";
	expire.languages = "3600";
	expire.sofia = "3600";
	expire.acl = "3600";
	expire.ivr = "3600";

--set xml_handler
	xml_handler = {}
	xml_handler.fs_path = false;
	xml_handler.reg_as_number_alias = false;
	xml_handler.number_as_presence_id = true;

--set settings
	settings = {}
	settings.recordings = {}
	settings.voicemail = {}
	settings.fax = {}
	settings.recordings.storage_type = "";
	settings.voicemail.storage_type = "";
	settings.fax.storage_type = "";

--set the debug options
	debug.params = false;
	debug.sql = false;
	debug.xml_request = false;
	debug.xml_string = false;
	debug.cache = false;

--additional info
	domain_count = 1;
	temp_dir = [[/tmp]];
	dial_string = "{sip_invite_domain=${domain_name},leg_timeout=${call_timeout},presence_id=${dialed_user}@${dialed_domain}}${sofia_contact(*/${dialed_user}@${dialed_domain})}";

--include local.lua
	require("resources.functions.file_exists");
	if (file_exists("/etc/fusionpbx/local.lua")) then
		dofile("/etc/fusionpbx/local.lua");
	elseif (file_exists("/usr/local/etc/fusionpbx/local.lua")) then
		dofile("/usr/local/etc/fusionpbx/local.lua");
	elseif (file_exists(scripts_dir.."/resources/local.lua")) then
		require("resources.local");
	end
