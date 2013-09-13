dmg_properties = node['sprout']['btsync']['dmg']

dmg_package "BitTorrent Sync" do
  dmg_name    dmg_properties['dmg_name']
  source      dmg_properties['source']
  checksum    dmg_properties['checksum']
  action :install
  owner node['current_user']
end
