defmodule QcloudCosSts.Util do
  @sts_domain "sts.tencentcloudapi.com"

  def get_random(min, max) when is_integer(min) and is_integer(max) do
    Enum.random(min..max)
  end

  def to_param_string(params) when is_map(params) do
    for {k, v} <- params do
      k <> "=" <> v
    end
    |> Enum.join("&")
  end

  def to_param_string(params) when is_binary(params) do
    params
  end

  def get_signature(opt, key, method) when is_binary(method) do
    format_string = method <> @sts_domain <> "/?" <> to_param_string(opt)
    :crypto.hmac(:sha256, key, format_string) |> Base.encode64(case: :lower)
  end
end
