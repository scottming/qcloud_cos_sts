use Mix.Config

config :qcloud_cos_sts,
  secret_id: System.get_env("qcloud_cos_secret_id"),
  secret_key: System.get_env("qcloud_cos_secret_key"),
  bucket: System.get_env("qcloud_cos_bucket"),
  region: "ap-beijing"
