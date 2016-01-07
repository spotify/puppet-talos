puppet-talos
============

Puppet module to manage [Talos](https://github.com/spotify/talos), Hiera secrets distribution tool.

Usage
-----

By default this module configures Talos user, Hiera git repository with
the secrets and Apache virtual host.

Typical usage:

```puppet
  class { 'talos':
    hiera_yaml_source => 'puppet:///modules/puppet/talos.hiera.yaml',
    talos_yaml_source => 'puppet:///modules/puppet/talos.yaml',
    configure_repo    => false,
  }
```

Contributing
------------
1. Fork the project on github
2. Create your feature branch
3. Open a Pull Request

This project adheres to the [Open Code of Conduct][code-of-conduct]. By
participating, you are expected to honor this code.

[code-of-conduct]:
https://github.com/spotify/code-of-conduct/blob/master/code-of-conduct.md

License
-------
```text
Copyright 2016 Spotify AB

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
