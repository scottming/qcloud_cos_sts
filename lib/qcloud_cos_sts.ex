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

    policy = %{
      "version" => "2.0",
      "statement" => [
        %{
          "action" => [
            "name/cos:PutObject",
            "name/cos:PostObject"
          ],
          "effect" => "allow",
          "principal" => %{"qcs" => ["*"]},
          "resource" => [
            "qcs::cos:" <>
              @config[:region] <>
              ":uid/" <>
              @config[:app_id] <>
              ":prefix//" <>
              @config[:app_id] <>
              "/" <> @config[:short_bucket_name] <> "/" <> (@config[:allow_prefix] || "*")
          ]
        }
      ]
    }

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
      "Policy" => policy |> Jason.encode!() |> URI.encode(),
      "SignatureMethod" => "HmacSHA256"
    }

    params =
      params |> Map.put("Signature", QcloudCosSts.Util.get_signature(params, secret_key, method))

    encoded_params = URI.encode_query(params)
    HTTPoison.post("https://#{host}", encoded_params, proxy: proxy) |> parse_response
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: status_code} = response})
       when status_code in 200..399 do
    {:ok,
     %{
       body: response.body,
       headers: response.headers,
       status_code: response.status_code,
       request: response.request,
       request_url: response.request_url
     }}
  end
end
