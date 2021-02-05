defmodule QcloudCosSts do
  @moduledoc """
  Documentation for `QcloudCosSts`.
  """

  def get_certificate() do
    config = Application.get_all_env(:qcloud_cos_sts)
    secret_id = config[:secret_id] || raise "Please config `:secret_id`"
    secret_key = config[:secret_key] || raise "Please config `:secret_key`"
    proxy = config[:proxy] || ""
    host = config[:host] || "sts.tencentcloudapi.com"
    region = config[:region] || "ap-beijing"
    duration_seconds = to_string(config[:duration_seconds] || 1800)
    bucket = config[:bucket] || raise "Please config `:bucket`"

    short_bucket_name =
      bucket
      |> String.split("-")
      |> Enum.slice(0..-2)
      |> Enum.join("-")

    app_id = bucket |> String.split("-") |> List.last()

    policy = %{
      "version" => "2.0",
      "statement" => [
        %{
          "action" =>
            config[:action] ||
              [
                "name/cos:PutObject",
                "name/cos:PostObject"
              ],
          "effect" => "allow",
          "principal" => %{"qcs" => ["*"]},
          "resource" => [
            "qcs::cos:" <>
              region <>
              ":uid/" <>
              app_id <>
              ":prefix//" <>
              app_id <>
              "/" <> short_bucket_name <> "/" <> (config[:allow_prefix] || "*")
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
    response.body |> Jason.decode!() |> Map.get("Response") |> parse_body(status_code)
  end

  defp parse_response(other) do
    other
  end

  defp parse_body(%{"Error" => error}, status_code) do
    {:error, %{errors: error, status_code: status_code}}
  end

  defp parse_body(body, status_code) do
    {:ok, %{data: body, status_code: status_code}}
  end
end
