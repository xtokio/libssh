# libssh

LibSSH implementation in Crystal Lang

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

session  = LibSSH.connect("example.com","user","password")
response = LibSSH.execute_command(session,"ls -aslh")
LibSSH.close_session(session)

puts response
```

## Contributing

1. Fork it (<https://github.com/xtokio/libssh/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Luis Gomez](https://github.com/xtokio) - creator and maintainer
