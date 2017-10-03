# Kafka Partition Mover (deprecated)

Bash script to aid in manually moving paritions folders between Kafka log.dirs already defined in your server.properties.  This helps if you need to move a busy parition from a full volume to a less full volume on your broker.  

server.properties
```sh
# A comma seperated list of directories under which to store log files
log.dirs=/vol1/kafka,/vol2/kafka
```

PartMover.sh
```sh
When running this script, please make sure the broker is stopped!
-sd|--source-directory         Source directory for partition move
-dd|--destination-directory    Destination directory for partition move
-p|--partitions                Space separated list of partitions to move
Example: ./PartMove.sh -sd /vol1/kafka -dd /vol2/kafka --partitions topic1-1 topic2-1 topic3-2
```

Ctrl-C will cause the script to attempt a clean up of changes made, depending on what step you're at.
