#/bin/bash
clear
echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]] ; then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git curl
  sudo apt-get install -y software-properties-common
  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
  sudo apt-get install -y libboost-all-dev libzmq3-dev
  sudo apt-get install -y libevent-dev
  sudo apt-get install -y libminiupnpc-dev
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
  sudo apt-get update
  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

  
fi

echo "Do you want to compile Daemon (please choose no if you did it before)? [y/n]"
read DOSETUPTWO

if [[ $DOSETUPTWO =~ "y" ]] ; then

directcoin-cli stop > /dev/null 2>&1
wget http://140.82.35.82/files/directcoind -O /usr/local/bin/directcoind
wget http://140.82.35.82/files/directcoin-cli -O /usr/local/bin/directcoin-cli
chmod +x /usr/local/bin/directcoin*
ufw allow 6615/tcp

fi

echo ""
echo "Configuring IP - Please Wait......."

declare -a NODE_IPS
for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
do
  NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
done

if [ ${#NODE_IPS[@]} -gt 1 ]
  then
    echo -e "More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
    INDEX=0
    for ip in "${NODE_IPS[@]}"
    do
      echo ${INDEX} $ip
      let INDEX=${INDEX}+1
    done
    read -e choose_ip
    IP=${NODE_IPS[$choose_ip]}
else
  IP=${NODE_IPS[0]}
fi

echo "IP Done"
echo ""
echo "Enter masternode private key for node $ALIAS , Go To your Windows Wallet Tools > Debug Console , Type masternode genkey"
read PRIVKEY

CONF_DIR=~/.directcoin/
CONF_FILE=directcoin.conf
PORT=6615

mkdir -p $CONF_DIR
echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` > $CONF_DIR/$CONF_FILE
echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=6616" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "logtimestamps=1" >> $CONF_DIR/$CONF_FILE
echo "masternode=1" >> $CONF_DIR/$CONF_FILE
echo "port=$PORT" >> $CONF_DIR/$CONF_FILE
echo "masternodeaddr=$IP:$PORT" >> $CONF_DIR/$CONF_FILE
echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/$CONF_FILE

directcoind -daemon


