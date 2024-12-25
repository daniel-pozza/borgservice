# Borgbackup-docker
This project provides a Docker-based solution to host remote Borg repositories for multiple users.

## Container build
To build the Docker container, follow these steps:
```sh
git clone https://github.com/daniel-pozza/borgbackup-docker.git
cd borgbackup-docker
docker build . -t borgbackup:latest
```

## Users configuration
The Docker container expects one or more `/config/*.borgusers` files to define users and their Borg permissions. These files allow the container to configure users during the startup process.

Here is the template for a `.borgusers` file:
```txt
username1:username1_id
username1_authorized_keys_line_1

username2:username2_id
username2_authorized_keys_line_1
username2_authorized_keys_line_1
```

- The first line specifies the username and the user ID.
- Each subsequent line will be appended to the `~user/.ssh/authorized_keys` file.
  - Refer to the [borgbackup documentation](https://borgbackup.readthedocs.io/en/stable/deployment/hosting-repositories.html) for detailed information on configuring a secure deployment.
- Use an empty line to separate configurations for different users.

### Example
Given an `example.borgusers` file as follow:
```txt
user:1001
command="borg serve --storage-quota 10G --restrict-to-repository /home/user/repository",restrict ssh-rsa public_key user.example
```
Start the container by mounting the file:
```sh
docker run \
    -p 2222:22 \
    -v ./example.borgusers:/config/example.borgusers:ro \
    borgbackup:latest
```
This configuration enables access to the following Borg repository:
```
ssh://user@IP:2222/home/user/repository
```

## Additional configuration

### Host certificates
The container checks for host keys in the `/host_keys` folder. If the folder is empty, new keys will be generated automatically.

### Unix permissions
Since any path can be specified as a Borg repository destination, ensure the user has the appropriate permissions to access and write to the specified path.

For example: Given an `example.borgusers` file like this:
```txt
user:1001
command="borg serve --storage-quota 10G --restrict-to-repository /repos/user/repo1",restrict ssh-rsa public_key user.example
```
Create the folder with the correct ownership and permissions
```sh
mkdir -p ./repos/user
chown 1001:1001 ./repos/user
```
Then, make it accessible through a mount
```sh
docker run \
    --name borgbackup \
    -v ./example.borgusers:/config/example.borgusers:ro \
    -v ./repos:/repos \
    -p 2222:22 \
    borgbackup:latest
```

## Run the container
### Docker compose
Here’s an example `compose.yml` configuration:
```sh
services:
  borgserver:
    image: borgserver:latest
    container_name: borgbackup
    volumes:
      - ./config.borgusers:/config/config.borgusers:ro
      - ./host_keys:/host_keys:ro
      - /persistent:/repositories # All the necessary mounts to preserve backups
    ports:
      - 2222:22
```

### Docker run
Alternatively, run the container directly:
```sh
docker run \
    --name borgbackup \
    -v ./example.borgusers:/config/example.borgusers:ro \
    -v ./host_keys:/host_keys:ro \
    -v  /persistent:/repositories \
    -p 2222:22 \
    borgbackup:latest
```