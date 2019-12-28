defmodule KV.RegistryTest do
    use ExUnit.Case, async: true

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
end