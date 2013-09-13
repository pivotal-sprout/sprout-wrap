dmg_package "BitTorrent Sync" do
  dmg_name    'BTSync'
  source      'http://download-lb.utorrent.com/endpoint/btsync/os/osx/track/stable'
  action :install
  owner node['current_user']
end
