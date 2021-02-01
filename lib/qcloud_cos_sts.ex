defmodule QcloudCosSts do
  @moduledoc """
  Documentation for `QcloudCosSts`.
  """
  @config Application.get_all_env(:qcloud_cos_sts)

  def get_policy() do
  end

  def get_certificate() do
    secret_id = @config[:secret_id]
    secret_key = @config[:secret_key]
    proxy = @config[:proxy] || ""
    host = @config[:host] || ""
    region = @config[:region] || "ap-beijing"
    duration_seconds = to_string(@config[:duration_seconds] || 1800)
    policy = @config[:policy]

    policy_str = QcloudCosSts.Util.to_param_string(policy)
    action = "GetFederationToken"
    nonce = QcloudCosSts.Util.get_random(10000, 20000)
    timestamp = :os.system_time(:second) |> to_string()
    method = "POST"

    params = %{
      "SecretId" => secret_id,
      "Timestamp" => timestamp,
      "Nonce" => nonce |> to_string(),
      "Action" => action,
      "DurationSeconds" => duration_seconds,
      "Name" => "cos-sts-elixir",
      "Version" => "2018-08-13",
      "Region" => region,
      "Policy" => URI.encode(policy_str)
    }

    params =
      params |> Map.put("Signature", QcloudCosSts.Util.get_signature(params, secret_key, method))

    encoded_params = URI.encode_query(params)
    HTTPoison.post(host, encoded_params, proxy: proxy)
  end
end
