defmodule KV.Registry do
    use GenServer

    ##Server Callback
    @impl true
    def init(:ok) do
        names = %{}
        refs = %{}
        {:ok, {names, refs}}
    end

    @impl true
    def handle_call({:lookup, name}, _from, state) do
        {names, _} = state
        {:reply, Map.fetch(names, name), state}
    end
    
    @implt true
    def handle_call(:all, _from, state) do
        {names, _} = state
        {:reply, names, state}
    end
    
    @impl true
    def handle_cast({:create, name}, {names, refs}) do
        if Map.has_key?(names, name) do
            {:noreply, {names, refs}}
        else
            {:ok, bucket } = KV.Bucket.start_link([])
            ref_monitor = Process.monitor(bucket)
            new_refs = Map.put(refs, ref_monitor, name)
            new_names = Map.put(names, name, bucket)
            new_state = {new_names, new_refs}
            {:noreply, new_state}
        end
    end

    @implt true
    def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
        {name, refs} = Map.pop(refs, ref)
        names = Map.delete(names, name)
        {:noreply, {names, refs}}
    end 

    @implt true
    def handle_info(_msg, state) do
        {:noreply, state}
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