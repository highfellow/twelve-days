mkdir -p lib
cd lib
git clone git://github.com/fabi1cazenave/webL10n.git
wget https://github.com/jquery/jquery/tarball/1.8.0
tar zxvf 1.8.0
rm 1.8.0
mv jquery* jquery
cd ..
