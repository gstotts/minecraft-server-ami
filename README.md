# minecraft-server-ami

Uses packer to build an AMI for a minecraft server of given settings.

## Usage:

- Create a `variables.pkrvars.hcl` file of desired settings in the packer directory.  A sample is below:
```hcl
aws_region                   = "us-east-1"
ami_name_prefix              = "minecraft-server-ubuntu"
vpc_id                       = "vpc-01231223123123123123"
subnet_id                    = "subnet-001231231231231231"
source_ami_filter_name       = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
source_ami_filter_owner      = "099720109477"
instance_type                = "t3.small"
bedrock_server_version       = "1.19.41.01"
minecraft_server_name        = "my_minecraft_server"
minecraft_gamemode           = "survival"
minecraft_difficulty         = "normal"
minecraft_max_players        = "10"
minecraft_allow_list_enabled = "true"
allowed_user_list = [
  { "ignoresPlayerLimit" : false, "name" : "playername1", "xuid" : "1111121112121211" },
  { "ignoresPlayerLimit" : false, "name" : "playername2", "xuid" : "2223122323232232" },
  { "ignoresPlayerLimit" : false, "name" : "playername3", "xuid" : "2321323232323232" }
]
permissions_list = [
  { "permission" : "operator", "xuid" : "2223122323232232" },
  { "permission" : "member", "xuid" : "1111121112121211"},
  { "permission" : "member", "xuid" : "2321323232323232" }
```

- Export AWS credentials to use with packer
```bash
export AWS_ACCESS_KEY_ID="myaccesskeygoeshere123"
export AWS_SECRET_ACCESS_KEY="mysecretkeygoeshere123"
```

- Run packer from packer directory
```bash
cd packer
packer init .
packer build -var-file=variables.pkrvars.hcl minecraft-server-ubuntu.pkr.hcl
```