#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
apt_update "update the apt daily" do
	frequency 86_400
	action :periodic
end

package 'openjdk-7-jre'

package 'python3'

package 'nginx'

service 'nginx' do
	action [:enable, :start]
end

ruby_block "change port ssh" do
	block do
		sed = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
		sed.search_file_replace_line("^Port\s2020$", "Port 22")
		sed.write_file
	end
end

bash "create folder host" do
	user 'root'
	cwd '/home'
	code <<-EOH
		mkdir -p /usr/share/nginx/hello-agus.com/html
	EOH
end

template '/usr/share/nginx/hello-agus.com/html/index.html' do
	source 'index.html.erb'
end

template '/etc/nginx/sites-available/hello-agus.com' do
	source 'hello-agus.com.erb'
end

bash 'symlink nginx conf' do
	user 'root'
	cwd '/home'
	code <<-EOH
		ln -sf /etc/nginx/sites-available/hello-agus.com /etc/nginx/sites-enabled/

	EOH
end

ruby_block "change nginx conf" do
	block do
		ng = Chef::Util::FileEdit.new("/etc/nginx/nginx.conf")
		ng.search_file_replace_line("server_names_hash_bucket_size\s64;$", "server_names_hash_bucket_size 64;")
		ng.write_file
	end
end

service 'nginx' do 
	action :restart
end
