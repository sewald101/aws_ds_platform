# aws_ds_platform 
Linux/Ubuntu shell scripts and notes to create and automate initialization of Agile data science stacks on AWS.
##### Caveat: These are the products of learning-in-process; utilize at own risk to your systems and sanity.

##### Inspiration, ideas, snippets and scripts drawn gratefully from the following sources (who otherwise bear no responsibility for errors in the contents of this repo):
* Miles Erickson (miles.erickson@gmail.com), Galvanize Seattle  
 For further information: https://www.galvanize.com/seattle/data-science  
 
* Russell Jurney, _Agile Data Science 2.0: Building Full-Stack Data Analytics Applications with Spark_, O'Reilly 2017.  
 https://github.com/rjurney/Agile_Data_Code_2/ 
 
* Jose Marcial Portilla  
 https://medium.com/@josemarcialportilla/getting-spark-python-and-jupyter-notebook-running-on-amazon-ec2-dec599e1c297  
 
## Virtual Machine Initialization Procedure (as of May 22, 2018):
(Assumes a personal AWS account an familiarity with the AWS console.)
### WARNING: AWS instances below are NOT FREE. Stop and/or terminate instances when not in use.
### WARNING: Consult with AWS documentation or your sys admin to assess security. Procedure below does not necessarily reflect highest security practice.  

 #### `$` = local terminal in cloned repo directory  
 #### `SSH$` = secure shell terminal tunneled to AWS virtual hardware (EC2, EMR, etc.) 

#### 1. Spin up EC2 instance. (~5 minutes)  

    `$ bash /vm_launchers/ec2_SW.sh`

   This command initializes an r4.xlarge EC2 instance with 60GB EBS-based solid state drive.  
   At present writing, AWS charges ~$0.24/hr for this instance.

#### 2. Update EC2 alias in `$ .ssh/config` with EC2's public IP address copied from EC2 dashboard.  

#### 3. SSH into EC2.  
    `$ ssh <EC2 alias name>` 

#### 4. `$ scp -r /bootstraps <EC2 alias name>:~/`  
 Secure copy (scp) bootstraps directory to EC2 HOME directory.  
 
#### 5. `SSH$ source /bootstraps/bootstrap_python.sh` **~7 minutes**  
 Execute bootstrap_python.sh on remote terminal.  
 Installs:
   * Python 3.5, Anaconda build (Currently, Python 3.6 does not communicate with Spark.)
   * Packages: python-dev, build-essential, libssl-dev, debconf-utils, python-software-properties
   * Linuxbrew / Homebrew
   * Java 1.8
   * Configures Jupyter Notebook for local access on port 18888

