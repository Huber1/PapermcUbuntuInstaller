#!/bin/bash
# Original Minecraft Server Installation Script - James A. Chambers - https://www.jamesachambers.com.
# Changes and simplifications by Marc Tönsing
# V1.16.5 20.01.21
# GitHub Repository: https://github.com/mtoensing/RaspberryPiMinecraft

Version="1.16.5"

echo "Minecraft Server installation script by James Chambers and Marc Tönsing - V1.0"
echo "Latest version always at https://github.com/mtoensing/RaspberryPiMinecraft"

if [ -d "minecraft" ]; then
  echo "Directory minecraft already exists!  Exiting... "
  exit 1
fi

echo "Updating packages..."
sudo apt-get update

echo "Installing latest Java OpenJDK 11..."
sudo apt-get install openjdk-11-jre-headless -y

echo "Installing screen... "
sudo apt-get install screen -y

echo "Creating minecraft server directory..."
mkdir minecraft
cd minecraft

echo "Getting latest Paper Minecraft server..."

BuildJSON=$(curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://papermc.io/api/v2/projects/paper/versions/$Version)
Build=$(echo "$BuildJSON" | rev | cut -d, -f 1 | cut -d] -f 2 | rev)
Build=$(($Build + 0))
curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" -o paperclip.jar "https://papermc.io/api/v2/projects/paper/versions/$Version/builds/$Build/downloads/paper-$Version-$Build.jar"

echo "Building the Minecraft server... "
java -jar -Xms800M -Xmx800M paperclip.jar

echo "Accepting the EULA... "
echo eula=true > eula.txt

echo "Grabbing start.sh from repository... "
wget -O start.sh https://raw.githubusercontent.com/mtoensing/RaspberryPiMinecraft/master/start.sh
chmod +x start.sh

echo "Oh wait. Checking for total memory available..."
TotalMemory=$(awk '/MemTotal/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
if [ $TotalMemory -lt 3000 ]; then
  echo "Sorry, have to grab low spec start.sh from repository... "
  wget -O start.sh https://raw.githubusercontent.com/mtoensing/RaspberryPiMinecraft/master/start_lowspec.sh
fi

echo "Grabbing restart.sh from repository... "
wget -O restart.sh https://raw.githubusercontent.com/mtoensing/RaspberryPiMinecraft/master/restart.sh
chmod +x restart.sh

echo "Enter a name for your server "
read -p 'Server Name: ' servername
echo "server-name=$servername" >> server.properties
echo "motd=$servername" >> server.properties

echo "Setup is complete. To run the server go to the minecraft directory and type ./start.sh"
echo "Don't forget to set up port forwarding on your router. The default port is 25565"
