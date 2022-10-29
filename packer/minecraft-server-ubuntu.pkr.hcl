packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

// Minecraft Settings Variables

variable "minecraft_server_name" {
  type        = string
  description = "The name of the server to be added to server.properties"
  default     = "my_minecraft_server"
}

variable "minecraft_gamemode" {
  type        = string
  description = "The gamemode to set for the Minecraft Server"
  default     = "survival"

  validation {
    condition     = var.minecraft_gamemode == "survival" || var.minecraft_gamemode == "creative" || var.minecraft_gamemode == "adventure"
    error_message = "The variable minecraft_gamemode must be one of the following:  survival, creative, adventure."
  }
}

variable "minecraft_difficulty" {
  type    = string
  default = "normal"

  validation {
    condition     = var.minecraft_difficulty == "normal" || var.minecraft_difficulty == "peaceful" || var.minecraft_difficulty == "easy" || var.minecraft_difficulty == "hard"
    error_message = "The variable minecraft_difficulty must be one of the following: peaceful, easy, normal, hard."
  }
}

variable "minecraft_max_players" {
  type    = number
  default = 10
}

variable "minecraft_allow_cheats" {
  type        = string
  default     = "false"
  description = "String of value true or false indicating if allow-cheats should be enabled."

  validation {
    condition     = var.minecraft_allow_cheats == "true" || var.minecraft_allow_cheats == "false"
    error_message = "The variable minecraft_allow_cheats must be a string of value true or false."
  }
}

variable "minecraft_allow_list_enabled" {
  type    = string
  default = "true"

  validation {
    condition     = var.minecraft_allow_list_enabled == "true" || var.minecraft_allow_list_enabled == "false"
    error_message = "The variable minecraft_allow_list_enabled must be a string of value true or false."
  }
}

variable "allowed_user_list" {
  type    = list(map(string))
  default = []
}

variable "permissions_list" {
  type    = list(map(string))
  default = []
}


// AMI Settings Variables

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "minecraft-server-ami"
}

variable "source_ami_filter_name" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "source_ami_filter_owner" {
  type    = string
  default = "099720109477"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name_prefix}-{{isotime \"2006-01-02T03_04_05\"}}"
  instance_type = "${var.instance_type}"
  region        = "${var.aws_region}"

  source_ami_filter {
    filters = {
      name                = "${var.source_ami_filter_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["${var.source_ami_filter_owner}"]
  }

  ssh_username = "${var.ssh_username}"
}

build {
  name = "minecraft-server"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-get update && sudo apt-get -y install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/main.yml"
    playbook_dir  = "../ansible/"

    extra_arguments = [
      "--extra-vars",
      "'minecraft_server_name=${var.minecraft_server_name}",
      "minecraft_gamemode=${var.minecraft_gamemode}",
      "minecraft_difficulty=${var.minecraft_difficulty}",
      "minecraft_max_players=${var.minecraft_max_players}",
      "minecraft_allow_cheats=${var.minecraft_allow_cheats}",
      "minecraft_allow_list_enabled=${var.minecraft_allow_list_enabled}",
      join("=", ["allowed_users", jsonencode("${var.allowed_user_list}")]),
      join("", [ join("=", ["permissions_list", jsonencode("${var.permissions_list}")]), "'" ])
    ]
  }
}