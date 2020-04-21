defmodule KV.Registry do
    use GenServer
    ## Client API
    @doc """
    Start the registry
    """
    def start_link(opts) do
        GenServer.start_link(__MODULE__.Server, :ok, opts)
    end

    @doc """
    Looks up the bucket for `name` stored in `server`
    Returns `{:ok, pid}` if the bucket exists, `:error` otherwise
    """
    def lookup(server, name) do
        GenServer.call(server, {:lookup, name})
    end

    @doc """
    Returns all buckets stored in `server`
    """
    def all(server) do
        GenServer.call(server, :all)
    end

    @doc """
    Ensures there is a bucket associated with given `name` in `server`.
    """
    def create(server, name) do
        GenServer.cast(server, {:create, name})
    end

end
