#!/bin/bash
sudo yum -y install docker-io
sudo service docker start
sudo docker pull jlozano03/weatherapiamd64
sudo docker run -d -p 8080:80 jlozano03/weatherapiamd64