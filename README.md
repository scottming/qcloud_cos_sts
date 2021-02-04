# QcloudCosSts

腾讯云临时密钥工具

## Installation

Adding `qcloud_cos_sts` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:qcloud_cos_sts, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
config :qcloud_cos_sts,
  secret_id: System.get_env("qcloud_cos_secret_id"),
  secret_key: System.get_env("qcloud_cos_secret_key"),
  bucket: System.get_env("qcloud_cos_bucket")
  region: "ap-beijing" # 默认是这种，可以换成你的区域
  action: ["name/cos:PutObject"] # policy 的 action
```
