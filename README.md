# Kafka Partition Mover

Bash script to aid in manually moving paritions from your broker's Kafka log directoy.
```sh
When running this script, please make sure the broker is stopped!
-sd|--source-directory         Source directory for partition move
-dd|--destination-directory    Destination directory for partition move
-p|--partitions                Space seperated list of partitions to move
Example: ./PartMove.sh -sd /vol1/kafka -dd /vol2/kafka --partitions topic1-1 topic2-1 topic3-2
```

Ctrl-C will cause the script to attempt a clean up of changes made, depending on what step you're at.
