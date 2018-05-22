# Packages installed and/or configured:
# Python 3
# pip
# Homebrew
# Java
# Gnu-sed
# Jupyter Notebook
# Hadoop
# Spark
# Mongo DB
# Mongo DB Java Driver
# Mongo-Hadoop Project
# pymongo-spark


set -e

# Update and install critical packages
LOG_FILE="/tmp/ec2_bootstrap.sh.log"
echo "Logging to \"$LOG_FILE\" ..." | tee -a $LOG_FILE

# Make backup of ~/.bash_profile
echo "Backing up ~/.bash_profile to ~/.bash_profile.ds_stack.bak" | tee -a $LOG_FILE
cp ~/.bash_profile ~/.bash_profile.agile_data_science.bak


# # From Jurney. I'm not sure what this does, but thinking it facilitates silent mode installation of packages?
# echo "Installing essential packages via apt-get in non-interactive mode ..." | tee -a $LOG_FILE
# sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade
# sudo apt-get install -y zip unzip curl bzip2 python-dev build-essential git libssl1.0.0 libssl-dev \
#     software-properties-common debconf-utils python-software-properties

# Install package manager
echo "Installing essential packages via apt-get in non-interactive mode ..." | tee -a $LOG_FILE
sudo apt update
sudo apt upgrade
yes | sudo apt-get install -y zip unzip curl bzip2 git python-pip python-dev build-essential

# Install Python 3
echo "============================" | tee -a $LOG_FILE
echo "Installing Python 3..." | tee -a $LOG_FILE
echo "============================" | tee -a $LOG_FILE
sleep 3
# Download
echo "Downloading..." | tee -a $LOG_FILE
wget -S -T 10 -t 5 https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh -O $HOME/anaconda.sh
# Install in silent mode ...
echo "Installing..." | tee -a $LOG_FILE
bash $HOME/anaconda.sh -b -p $HOME/anaconda
# Add Anaconda to current session's PATH

echo "Adding Anaconda to current session and future sessions' PATH..." | tee -a $LOG_FILE
export PATH=$HOME/anaconda/bin:$PATH
# Add Anaconda to PATH for future sessions via .bashrc
echo -e "\n\n# Anaconda" >> $HOME/.bashrc
echo "export PATH=$HOME/anaconda/bin:$PATH" >> $HOME/.bash_profile
echo "export PATH=$HOME/anaconda/bin:$PATH" >> $HOME/.bashrc
# Update to the current version

# echo "Updating Anaconda" | tee -a $LOG_FILE
# yes | conda update conda
# yes | conda update anaconda

# # Spark don't work with python 3.6
# echo "Downgrading Anaconda Python from 3.6 to 3.5, as 3.6 doesn't work with Spark 2.1.0 ..." | tee -a $LOG_FILE
# conda install -y python=3.5

echo "" | tee -a $LOG_FILE
echo "============================" | tee -a $LOG_FILE
echo "Python installed!" | tee -a $LOG_FILE
echo "============================" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
sleep 3

echo "Make sure we're using the anaconda version ($ source .bashrc). Not sure if this is necessary!" | tee -a $LOG_FILE
source ~/.bash_profile


echo "Installing Homebrew ..." | tee -a $LOG_FILE
yes | sudo apt install linuxbrew-wrapper
sleep 3


echo "Installing and configuring Java 8 from Oracle ..." | tee -a $LOG_FILE
sleep 3
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer oracle-java8-set-default

export JAVA_HOME=/usr/lib/jvm/java-8-oracle
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" | sudo tee -a /home/ubuntu/.bash_profile

# echo "Installing Java ..."
# sudo apt-get update
# sudo apt-get install default-jre
# export JAVA_HOME=/usr
# export PATH=$JAVA_HOME/bin:$PATH
#
# echo "Java installed. Checking version ..."
# java -version

# # Install GNU (For gsed in Jupyter config.)
# echo "Installing Gnu-sed..." | tee -a $LOG_FILE
# brew install gnu-sed


echo "Configuring Jupyter Notebook ..." | tee -a $LOG_FILE
sleep 3

# Changing permissions for a share/jupyter file
# This was to correct an error running JN and trying to create a new NB that said the file did not exist
# Are these lines necessary???
sudo chown ubuntu:ubuntu .local
cd .local
sudo chown ubuntu:ubuntu share
cd share
mkdir jupyter

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

echo ""
echo "Test Jupyter Notebook by creating an ssh tunnel between ports 18888:"
echo ""
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${RED}ssh -NfL 18888:localhost:18888 <remote ec2 alias name>${NC}"
echo ""
echo "If closing down jupyter notebook, kill tunnel:"
echo ""
echo -e "${RED}ps aux | grep 18888${NC}"
echo -e "${RED}kill <process number>${NC}"
echo ""
read -p "Press Enter to continue."


# Setting directory for installation of additional packages via script in Russell Jurney,
# Agile Data Science 2.0 (manual_install.sh)
cd ~/
export PROJECT_HOME=`pwd`
echo "export PROJECT_HOME=$PROJECT_HOME" >> ~/.bash_profile

echo "Installing hadoop 2.7.3 into $PROJECT_HOME/hadoop ..." | tee -a $LOG_FILE

# May need to update this link... see http://hadoop.apache.org/releases.html
# Last updated on May 15, 2018
curl -Lko /tmp/hadoop-3.1.0.tar.gz http://apache.osuosl.org/hadoop/common/hadoop-3.1.0/hadoop-3.1.0.tar.gz

mkdir hadoop
tar -xvf /tmp/hadoop-3.1.0.tar.gz -C hadoop --strip-components=1
echo '# Hadoop environment setup' >> ~/.bash_profile
export HADOOP_HOME=$PROJECT_HOME/hadoop
echo 'export HADOOP_HOME=$PROJECT_HOME/hadoop' >> ~/.bash_profile
export PATH=$PATH:$HADOOP_HOME/bin
echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bash_profile
export HADOOP_CLASSPATH=$(hadoop classpath)
echo 'export HADOOP_CLASSPATH=$(hadoop classpath)' >> ~/.bash_profile
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> ~/.bash_profile



echo "Installing Spark 2.1.0 into $PROJECT_HOME/spark ..." | tee -a $LOG_FILE

# May need to update this link... see http://spark.apache.org/downloads.html
curl -Lko /tmp/spark-2.1.0-bin-without-hadoop.tgz http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-without-hadoop.tgz

mkdir spark
tar -xvf /tmp/spark-2.1.0-bin-without-hadoop.tgz -C spark --strip-components=1
echo "" >> ~/.bash_profile
echo "# Spark environment setup" >> ~/.bash_profile
export SPARK_HOME=$PROJECT_HOME/spark
echo 'export SPARK_HOME=$PROJECT_HOME/spark' >> ~/.bash_profile
export HADOOP_CONF_DIR=$PROJECT_HOME/hadoop/etc/hadoop/
echo 'export HADOOP_CONF_DIR=$PROJECT_HOME/hadoop/etc/hadoop/' >> ~/.bash_profile
export SPARK_DIST_CLASSPATH=`$HADOOP_HOME/bin/hadoop classpath`
echo 'export SPARK_DIST_CLASSPATH=`$HADOOP_HOME/bin/hadoop classpath`' >> ~/.bash_profile
export PATH=$PATH:$SPARK_HOME/bin
echo 'export PATH=$PATH:$SPARK_HOME/bin' >> ~/.bash_profile

echo "Have to set spark.io.compression.codec in Spark local mode ..." | tee -a $LOG_FILE
cp spark/conf/spark-defaults.conf.template spark/conf/spark-defaults.conf
echo 'spark.io.compression.codec org.apache.spark.io.SnappyCompressionCodec' >> spark/conf/spark-defaults.conf

echo "Give Spark 8GB of RAM" | tee -a $LOG_FILE
echo "spark.driver.memory 8g" >> $SPARK_HOME/conf/spark-defaults.conf

echo "Set up communication between Spark and Python ..." | tee -a $LOG_FILE
echo "PYSPARK_PYTHON=python3" >> $SPARK_HOME/conf/spark-env.sh
echo "PYSPARK_DRIVER_PYTHON=python3" >> $SPARK_HOME/conf/spark-env.sh

## These three lines were hanging up as of Monday, May 21, 2018
# echo "Setup log4j config to reduce logging output ..." | tee -a $LOG_FILE
# cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties
# sed -i .bak 's/INFO/ERROR/g' $SPARK_HOME/conf/log4j.properties

echo "Installing pyspark..." | tee -a $LOG_FILE
pip install pyspark
export SPARK_HOME='/home/ubuntu/spark'
export PATH=$SPARK_HOME:$PATH
export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH

echo "Installing json lines..." | tee -a $LOG_FILE
pip install json-lines

echo "Installing MongoDB to $PROJECT_HOME/mongodb ..." | tee -a $LOG_FILE

# might need to update these
MONGO_FILENAME='mongodb-linux-x86_64-amazon-3.4.1.tgz'
# URL updated on May 21, 2018
MONGO_DOWNLOAD_URL='https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-amazon-3.6.4.tgz'

curl -Lko /tmp/$MONGO_FILENAME $MONGO_DOWNLOAD_URL
mkdir mongodb
tar -xvf /tmp/$MONGO_FILENAME -C mongodb --strip-components=1
export PATH=$PATH:$PROJECT_HOME/mongodb/bin
echo 'export PATH=$PATH:$PROJECT_HOME/mongodb/bin' >> ~/.bash_profile
mkdir -p mongodb/data/db

# Start Mongo
mongodb/bin/mongod --dbpath mongodb/data/db & # re-run if you shutdown your computer

# Get the MongoDB Java Driver
echo "Fetching the MongoDB Java Driver to $PROJECT_HOME/lib/ ..." | tee -a $LOG_FILE
# sudo added below to Jurney's script
# URL verified on May 21, 2018
sudo curl -Lko /lib/mongo-java-driver-3.7.0.jar http://central.maven.org/maven2/org/mongodb/mongo-java-driver/3.7.0/mongo-java-driver-3.7.0.jar

# Install the mongo-hadoop project in the mongo-hadoop directory in the root of our project.
echo "Installing the mongo-hadoop project in $PROJECT_HOME/mongo-hadoop ..." | tee -a $LOG_FILE
# URL verified on May 21, 2018
curl -Lko /tmp/mongo-hadoop-r2.0.2.tar.gz https://github.com/mongodb/mongo-hadoop/archive/r2.0.2.tar.gz
mkdir mongo-hadoop
tar -xvzf /tmp/mongo-hadoop-r2.0.2.tar.gz -C mongo-hadoop --strip-components=1

# Now build the mongo-hadoop-spark jars
echo "Building mongo-hadoop..." | tee -a $LOG_FILE
cd mongo-hadoop
./gradlew jar
cd ~
sudo cp mongo-hadoop/spark/build/libs/mongo-hadoop-spark-*.jar /lib/
sudo cp mongo-hadoop/build/libs/mongo-hadoop-*.jar /lib/

# Now build the pymongo_spark package
echo "Building pymongo_spark package ..." | tee -a $LOG_FILE
pip install py4j # add sudo if needed
pip install pymongo # add sudo if needed
# pip install pymongo-spark # add sudo if needed
cd mongo-hadoop/spark/src/main/python
sudo python setup.py install
cd $PROJECT_HOME
sudo cp mongo-hadoop/spark/src/main/python/pymongo_spark.py /lib/
export PYTHONPATH=$PYTHONPATH:$PROJECT_HOME/lib
echo 'export PYTHONPATH=$PYTHONPATH:$PROJECT_HOME/lib' >> ~/.bash_profile

echo "Done for now. Next, we'll try to get elasticsearch working!" | tee -a $LOG_FILE
