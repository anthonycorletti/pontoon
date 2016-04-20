# Pontoon

[![Build Status](https://travis-ci.org/anthcor/pontoon.svg?branch=master)](https://travis-ci.org/anthcor/pontoon)
[![Gem Version](https://badge.fury.io/rb/pontoon.svg)](http://badge.fury.io/rb/pontoon)

Pontoon is a Ruby implementation of the Raft algorithm.

Raft is a distributed consensus algorithm designed to be easy to understand. The algorithm is the work of Diego Ongaro and John Ousterhout at Stanford University.
The implementation here is based upon [this paper](https://ramcloud.stanford.edu/wiki/download/attachments/11370504/raft.pdf).

## Technical Design
This gem provides a `Pontoon::Node` class that handles log replication across a cluster of peer nodes.
Design decisions about the RPC protocol, concurrency mechanism, error handling and data persistence are left to the client.
For convenience and testing, an example implementation is provided based on Goliath and EventMachine, with in-memory data persistence.
Contributions of further examples are very welcome!

## Usage
Install the gem:
```bash
gem install pontoon
```

In your code, add a require:
```ruby
require 'pontoon'
```

If you'd like to use the example Goliath implementation, add:
```ruby
require 'pontoon/goliath'
```

Pontoon replicates commands across a cluster of nodes.  Each node in the cluster is aware of every other node in the
cluster.  Let's create a new cluster and define its configuration:
```ruby
@cluster = Pontoon::Cluster.new('alpha', 'beta', 'gamma')

@config = Pontoon::Config.new(
  rpc_provider,       # see Pontoon::RpcProvider
  async_provider,     # see Pontoon::AsyncProvider
  election_timeout,   # in seconds
  election_splay,     # in seconds
  update_interval,    # in seconds
  heartbeat_interval) # in seconds
```

Now we can create Pontoon nodes for each node defined in the cluster:
```ruby
@nodes = @cluster.node_ids.map do |node_id|
  Pontoon::Node.new(node_id, @config, @cluster)
end
```

Since the concurrency mechanism is left to the client, you must call `Pontoon::Node#update` regularly to allow the
node to participate in the cluster:
```ruby
# Threaded example:
@update_threads = @nodes.map do |node|
 Thread.new do
   while true
     node.update
     sleep(node.config.update_interval)
   end
 end
end
```
```ruby
# Evented example
@update_timers =  @nodes.map do |node|
  EventMachine.add_periodic_timer(node.config.update_interval) do
    EM.synchrony do
      node.update
    end
  end
end
```

We can send commands (which are strings) to the cluster and they will be appended to the command log, which will be
replicated across the cluster.
```ruby
command = 'example'
request = Pontoon::CommandRequest.new(command)
node = @nodes.sample
response = node.handle_command(request) # response is a Pontoon::CommandResponse
```

Note that `Pontoon::Node#handle_command` will not return success until the command has been replicated to a majority of nodes,
so that it is considered *committed* and is safe to execute.

If you would like to execute commands as they are committed, you can assign a commit handler for each node:
```ruby
@nodes.each do |node|
  node.commit_handler = Proc.new do |command|
    puts "Node #{node.id} executing command #{command}!"
  end
end
```

## Issues and Feedback
If you encounter problems with this gem, please feel free to raise an issue.

## Contributing
Fork this repository and make a pull request!

## License
Pontoon is released under the [MIT license](/LICENSE).
