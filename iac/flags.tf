terraform {
  required_providers {
    launchdarkly = {
      source  = "launchdarkly/launchdarkly"
      version = "~> 2.0"
    }
  }
}

variable "launchdarkly_access_token" {
    type=string
}

provider "launchdarkly" {
  access_token = var.launchdarkly_access_token
}

resource "launchdarkly_project" "proj" {
  key  = "nerdamigo"
  name = "Nerdamigo Sample"

  environments {
        key   = "production"
        name  = "Production"
        color = "EEEEEE"
    }
}

resource "launchdarkly_feature_flag" "bool" {
  project_key = launchdarkly_project.proj.key
  key         = "feature-bool"
  name        = "Boolean Feature"
  description = "Simple boolean flag"

  variation_type = "boolean"
}

resource "launchdarkly_feature_flag" "uid" {
  project_key = launchdarkly_project.proj.key
  key         = "feature-long-uid"
  name        = "Long UID Handling"
  description = "Trigger different handling based on user id length"

  variation_type = "string"

  variations {
    value       = "long"
    name        = "Long"
  }
  variations {
    value       = "short"
    name        = "short"
  }

  defaults {
    on_variation = 0
    off_variation = 1
  }
}

resource "launchdarkly_feature_flag" "preferred_greeting_by_gender" {
  project_key = launchdarkly_project.proj.key
  key         = "feature-gender-greeting"
  name        = "Gender Greeting"
  description = "Select a different greeting template based on gender"

  variation_type = "string"

  variations {
    value       = "Sample male greeting"
    name        = "Male"
  }
  variations {
    value       = "Sample female greeting"
    name        = "Female"
  }
  variations {
    value       = "Other or undefined gender greetings"
    name        = "Other"
  }
}

resource "launchdarkly_segment" "uid" {
  key         = "uid"
  project_key = launchdarkly_project.proj.key
  env_key     = "production"
  name        = "UID - Long"

  rules {
    clauses {
      attribute = "id-length"
      op        = "greaterThanOrEqual"
      values    = [ 8 ]
      value_type = "number"
      negate    = false
    }
  }
}

resource "launchdarkly_segment" "gender_male" {
  key         = "gender_male"
  project_key = launchdarkly_project.proj.key
  env_key     = "production"
  name        = "Gender - Male"

  rules {
    clauses {
      attribute = "gender"
      op        = "matches"
      values    = [ "^male" ]
      negate    = false
    }
  }
}

resource "launchdarkly_segment" "gender_female" {
  key         = "gender_female"
  project_key = launchdarkly_project.proj.key
  env_key     = "production"
  name        = "Gender - Female"

  rules {
    clauses {
      attribute = "gender"
      op        = "matches"
      values    = [ "^female" ]
      negate    = false
    }
  }
}

resource "launchdarkly_feature_flag_environment" "bool" {
  flag_id = launchdarkly_feature_flag.bool.id
  env_key = "production"

  on = true
  off_variation = 1

  fallthrough {
    variation = 1
  }
}

resource "launchdarkly_feature_flag_environment" "uid" {
  flag_id = launchdarkly_feature_flag.uid.id
  env_key = "production"

  on = true
  off_variation = 1

  fallthrough {
    variation = 1
  }

  rules {
    clauses {
      attribute = "segmentMatch"
      op        = "segmentMatch"
      values    = [launchdarkly_segment.uid.key]
      negate    = false
    }
    variation = 0
  }
}


resource "launchdarkly_feature_flag_environment" "preferred_greeting_by_gender" {
  flag_id = launchdarkly_feature_flag.preferred_greeting_by_gender.id
  env_key = "production"

  on = true
  off_variation = 2

  fallthrough {
    variation = 2
  }

  rules {
    clauses {
      attribute = "segmentMatch"
      op        = "segmentMatch"
      values    = [launchdarkly_segment.gender_male.key]
      negate    = false
    }
    variation = 0
  }

  rules {
    clauses {
      attribute = "segmentMatch"
      op        = "segmentMatch"
      values    = [launchdarkly_segment.gender_female.key]
      negate    = false
    }
    variation = 1
  }
}

resource "local_file" "foo" {
    content  = jsonencode({
        project = launchdarkly_project.proj
    })
    filename = "${path.module}/../ld-environment-config.json"
}