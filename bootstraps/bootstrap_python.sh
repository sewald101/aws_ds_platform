# Packages installed and/or configured:
# Python 3.5, Anaconda build
# python-dev, build-essential, libssl-dev, debconf-utils, python-software-properties
# Homebrew
# Java
# Jupyter Notebook

set -e

# Update and install critical packages
LOG_FILE="/tmp/bootstrap_python.sh.log"
echo "Logging to \"$LOG_FILE\" ..." | tee -a $LOG_FILE

echo "Installing essential packages via apt-get in non-interactive mode ..." | tee -a $LOG_FILE
echo "apt-get -f -y install" | tee -a $LOG_FILE
# sudo apt-get -f -y install # Using -f flag to avert dependency errors (per error message during apt-get upgrade)
sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o \ DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade
echo "Installing individual packages ..." | tee -a $LOG_FILE
sudo apt-get install -y python-dev build-essential libssl-dev debconf-utils python-software-properties


# Install Python 3
echo "============================" | tee -a $LOG_FILE
echo "Installing Python 3..." | tee -a $LOG_FILE
echo "============================" | tee -a $LOG_FILE

echo "Downloading Anaconda installer 4.2.0 (last build with Python 3.5 default) ..." | tee -a $LOG_FILE
# Downloading the most recent Python installer
wget -S -T 10 -t 5 https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O $HOME/anaconda.sh
# Install in silent mode ...
echo "Installing Anaconda ..." | tee -a $LOG_FILE
bash $HOME/anaconda.sh -b -p $HOME/anaconda

echo "Adding Anaconda to current session and future sessions' PATH ..." | tee -a $LOG_FILE
export PATH=$HOME/anaconda/bin:$PATH
# Add Anaconda to PATH for future sessions via .bashrc and .bash_profile
echo -e "\n\n# Anaconda" >> $HOME/.bashrc
echo "export PATH=$HOME/anaconda/bin:$PATH" >> $HOME/.bashrc
echo -e "\n\n# Anaconda" >> $HOME/.bash_profile
echo "export PATH=$HOME/anaconda/bin:$PATH" >> $HOME/.bash_profile
# Update to the current version

echo "Updating Anaconda packages" | tee -a $LOG_FILE
yes | conda update conda
yes | conda update anaconda

echo "" | tee -a $LOG_FILE
echo "============================" | tee -a $LOG_FILE
echo "Python installed!" | tee -a $LOG_FILE
echo "============================" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE


echo "Installing Homebrew ..." | tee -a $LOG_FILE
sudo apt install -y linuxbrew-wrapper
sleep 3


echo "Installing and configuring Java 8 from Oracle ..." | tee -a $LOG_FILE
sleep 3
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer oracle-java8-set-default

export JAVA_HOME=/usr/lib/jvm/java-8-oracle
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" | sudo tee -a /home/ubuntu/.bash_profile


echo "Configuring Jupyter Notebook ..." | tee -a $LOG_FILE
jupyter notebook --generate-config
cd ~/.jupyter/

echo "Editing jupyter_notebook_config.py" | tee -a $LOG_FILE
sleep 3
sed -i "1i\c.NotebookApp.port = 18888\n" jupyter_notebook_config.py
sed -i "1i# Fix port to 18888\n" jupyter_notebook_config.py
sed -i "1i\c.NotebookApp.open_browser = False\n" jupyter_notebook_config.py
sed -i "1i# Don't open browser by default" jupyter_notebook_config.py
sed -i "1i\c.NotebookApp.ip = '*'\n" jupyter_notebook_config.py
sed -i "1i# Run on all IP addresses of your instance" jupyter_notebook_config.py
sed -i "1i\c = get_config()\n" jupyter_notebook_config.py
echo "Jupyter Notebook is configured." | tee -a $LOG_FILE

source .bashrc

echo ""
echo "Test Jupyter Notebook by creating an ssh tunnel between local and ec2 ports 18888."
echo ""
RED='\033[0;31m'
NC='\033[0m' # No Color
echo "In local terminal, enter:"
echo -e "${RED}$ ssh -NfL 18888:localhost:18888 <remote ec2 alias name>${NC}"
echo ""
echo "If closing down jupyter notebook, you may wish also to kill the ssh tunnel:"
echo -e "${RED}$ ps aux | grep 18888${NC}"
echo "Take note of the ssh process number, then:"
echo -e "${RED}$ kill <ssh process number>${NC}"
echo ""
echo "Script bootstrap_python.sh complete." | tee -a $LOG_FILE
