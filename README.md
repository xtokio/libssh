# libssh

LibSSH implementation in Crystal Lang to execute Cisco commands

## Installation

RedHat
```bash
sudo yum install libssh-devel
```

Debian / Ubuntu
```bash
sudo apt install libssh-dev
```

MAC OS
```bash
brew install libssh
```

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     libssh:
       github: xtokio/libssh
   ```

2. Run `shards install`

## Usage

```crystal
require "libssh"

ssh = LibSSH.new("example.com","user","password")

# Execute command
response = ssh.execute_command("show running-config interface gi1/0/1")
puts response

# Execute command in config mode
response ssh.execute_config_command(["do show running-config interface gi1/0/13"])
puts response

# Create VLAN
ssh.execute_config_command(["vlan 10","name vlan10"])

# Remove VLAN
ssh.execute_config_command(["no vlan 10"])
```

## Contributing

1. Fork it (<https://github.com/xtokio/libssh/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Luis Gomez](https://github.com/xtokio) - creator and maintainer
