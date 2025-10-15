# specifying base image
FROM amazonlinux:2

#Description
LABEL description="Building the image for Apache container"
LABEL maintainer="Rokshana"

# Executing the command to update the package
RUN yum -y update

#Executing the command to install httpd
RUN yum -y install httpd

# copying the index file from local into the container at a specified location
COPY index.html /var/www/html/

EXPOSE 80

# Start the container with httpd
# systemctl start httpd
ENTRYPOINT ["/usr/sbin/httpd"]

# systemctl enable httpd
# /usr/sbin/httpd -D FOREGROUND
CMD ["-D", "FOREGROUND"]

