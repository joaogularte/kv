defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  doctest KV.Bucket

  setup_all do
    IO.puts("Starting Bucket test")
  end

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "remove values by key", %{bucket: bucket} do
    assert KV.Bucket.delete(bucket, "milk") == nil
    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.delete(bucket, "milk") == 1
  end
end
