defmodule KV.RegistryTest do
    use ExUnit.Case, async: true

    doctest KV.Registry

    setup_all do 
        IO.puts("Starting Registry test")
    end

    setup do
        registry = start_supervised!(KV.Registry)
        %{registry: registry}
    end

    test "spaws buckets", %{registry: registry} do
        assert KV.Registry.lookup(registry, "shopping") == :error
        KV.Registry.create(registry, "shopping")
        assert {:ok, shopping_bucket} = KV.Registry.lookup(registry, "shopping")

        KV.Bucket.put(shopping_bucket, "apple", 3)
        assert KV.Bucket.get(shopping_bucket, "apple") == 3
    end

    test "get all buckets", %{registry: registry} do
        KV.Registry.create(registry, "shopping")
        KV.Registry.create(registry, "market")
        assert KV.Registry.all(registry)
    end

    test "removes buckets on exit", %{registry: registry} do
        KV.Registry.create(registry, "shopping")
        {:ok, bucket_shopping} = KV.Registry.lookup(registry, "shopping")
        Agent.stop(bucket_shopping)
        assert KV.Registry.lookup(registry, "shopping") == :error
    end
end