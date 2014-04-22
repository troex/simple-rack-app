#
# Cookbook Name:: phantomjs
# Recipe:: default
#

ey_cloud_report "phantomjs" do
  message "Installing PhantomJS recipe"
end

### Method 1: This is the more "EY way" of handling system packages but could take up to 3-5 hours to build on slow instance
# enable_package 'www-client/phantomjs' do
#   version '1.6.1'
# end
# 
# package 'www-client/phantomjs' do
#   version '1.6.1'
#   action :install
# end

# Method 2: Just grab the binary
execute "install-phantomjs-in-correct-place" do
  version = "1.9.2"
  arch = RUBY_PLATFORM == "x86_64-linux" ? "x86_64" : "i686"
  url = "http://phantomjs.googlecode.com/files/phantomjs-#{version}-linux-#{arch}.tar.bz2"

  command <<-CMD
    wget "#{url}"
    sudo tar xjvf phantomjs-#{version}-linux-#{arch}.tar.bz2
    sudo mv phantomjs-#{version}-linux-#{arch}/bin/phantomjs /usr/local/bin/phantomjs
    sudo ln -sf /usr/local/bin/phantomjs /usr/bin/phantomjs
    sudo rm -rf phantomjs-#{version}-linux-#{arch}.tar.bz2 phantomjs-#{version}-linux-#{arch}
  CMD
end

ey_cloud_report "phantomjs" do
  message "*** SB: phantomjs recipe complete"
end
