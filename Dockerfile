FROM taavitani/aws-bootcamp

# Install Packer.
RUN wget https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip \
    -O /tmp/packer.zip \
  && unzip /tmp/packer.zip -d /usr/local/bin \
  && rm /tmp/packer.zip

# You should run this image with -v /repo/clone:/root/aws-automation.
VOLUME /root/aws-automation

# Start the shell in the repo root.
WORKDIR /root/aws-automation

# A chainsaw! Find some meat!
CMD ["/usr/bin/env", "bash"]
