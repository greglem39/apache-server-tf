terraform {
  cloud {
    organization = "glitchycat"

    workspaces {
      name = "apache-server-tf"
    }

  }
}
