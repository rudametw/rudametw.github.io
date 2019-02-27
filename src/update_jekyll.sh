gem cleanup
bundle update

echo "***\n if any Errors... try C_INCLUDE_PATH=/usr/include/ImageMagick-6 gem install rmagick"

echo Or maybe
echo sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
echo sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

