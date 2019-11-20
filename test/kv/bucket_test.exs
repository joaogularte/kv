defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  doctest KV.Bucket

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    {:ok, bucket: bucket}  
  end

  test "stores values by key", context do
    assert KV.Bucket.get(context[:bucket], "milk") == nil
    
    KV.Bucket.put(context[:bucket], "milk", 1)
    assert KV.Bucket.get(context[:bucket], "milk") == 1
  end
end
