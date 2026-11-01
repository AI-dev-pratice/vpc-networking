names = {
  dev : {
    region   = "ap-south-1"
    vpc_cidr = "172.1.0.0/22"
    subnets = {
      pub-a = { cidr = "172.1.0.0/25", az = "ap-south-1a", tier = "pub" }
      pub-b = { cidr = "172.1.0.128/25", az = "ap-south-1b", tier = "pub" }
      app-a = { cidr = "172.1.1.0/25", az = "ap-south-1a", tier = "app" }
      app-b = { cidr = "172.1.1.128/25", az = "ap-south-1b", tier = "app" }
      db-a  = { cidr = "172.1.2.0/25", az = "ap-south-1a", tier = "db" }
      db-b  = { cidr = "172.1.2.128/25", az = "ap-south-1b", tier = "db" }
    }
  }
    prod : {
      region   = "ap-south-1"
      vpc_cidr = "172.1.4.0/22"
      subnets = {
        pub-a = { cidr = "172.1.4.0/25",   az = "ap-south-1a", tier = "pub" }
        pub-b = { cidr = "172.1.4.128/25", az = "ap-south-1b", tier = "pub" }
        app-a = { cidr = "172.1.5.0/25",   az = "ap-south-1a", tier = "app" }
        app-b = { cidr = "172.1.5.128/25", az = "ap-south-1b", tier = "app" }
        db-a  = { cidr = "172.1.6.0/25",   az = "ap-south-1a", tier = "db" }
        db-b  = { cidr = "172.1.6.128/25", az = "ap-south-1b", tier = "db" }
      }
    }
}
