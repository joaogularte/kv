defmodule KV.Bucket do
  use Agent

  @doc """
  Start a new bucket
  """
  def start_link(opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get a value from bucket by key
  """
  def get(bucket, key) do
    Agent.get(bucket, fn maps -> Map.get(maps, key) end)
  end

  @doc """
  Put the value for the given key in the bucket
  """
  def put(bucket, key, value) do
    Agent.update(bucket, fn maps -> Map.put(maps, key, value) end)
  end

  @doc """
  Remove the value for the given key in the bucket
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn maps -> Map.pop(maps, key) end)
  end
end
