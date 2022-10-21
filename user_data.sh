#!/usr/bin/env bash
yum -y update

yum -y install httpd
systemctl enable httpd
systemctl start httpd

