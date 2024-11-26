provider "google" {
  project = "level-clone-442919-v0"
  region  = "us-central1"
}

resource "google_compute_instance" "jenkins_server2" {
  name         = "jenkins-server2"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Required for external IP
    }
  }

  metadata_startup_script = <<EOT
#!/bin/bash
#sudo apt update
@sudo apt install -y openjdk-11-jdk wget

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
sudo apt-get update
apt install -y openjdk-11-jdk wget
sudo apt-get install -y fontconfig openjdk-17-jre
sleep 10

#this need to be done manually if not done in script #check post RUN
update-alternatives --config java
echo| 2 
sleep 5

sudo add-apt-repository --remove ppa:dotnet/backports
sudo apt update
sudo apt install software-properties-common
# Get OS version info which adds the $ID and $VERSION_ID variables
source /etc/os-release

# Download Microsoft signing key and repository
wget https://packages.microsoft.com/config/$ID/$VERSION_ID/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install Microsoft signing key and repository
sudo dpkg -i packages-microsoft-prod.deb

# Clean up
rm packages-microsoft-prod.deb

# Update packages
sudo apt update

sudo apt install -y dotnet-sdk-8.0

sudo apt install -y jenkins
sudu systemctl enable jenkins
sudo systemctl start jenkins

EOT
}

output "jenkins_server_ip" {
  value = google_compute_instance.jenkins_server.network_interface.0.access_config.0.nat_ip
  description = "Public IP of the Jenkins server"
}