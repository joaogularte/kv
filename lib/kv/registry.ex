defmodule KV.Registry do
    use GenServer

    ##Server Callback
    @impl true
    def init(:ok) do
        {:ok, %{}}
    end

    @impl true
    def handle_call({:lookup, name}, _from, state) do
        {:reply, Map.fetch(state, name), state}
    end

    def handle_call(:all, _from, state) do
        {:reply, state, state}
    end
    
    @impl true
    def handle_cast({:create, name}, state) do
        if Map.has_key?(state, name) do
            {:noreply, state}
        else
            {:ok, bucket } = KV.Bucket.start_link([])
            new_state = Map.put(state, name, bucket)
            {:noreply, new_state}
        end
    end


    ## Client API
    @doc """
    Start the registry
    """
    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
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