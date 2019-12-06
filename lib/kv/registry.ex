defmodule KV.Registry do
    use GenServer
    @moduledoc """
        Providers a set of functions that implement GenServer client and server 
    """ 
    #Implementation client
    @doc """
    Starts a registry
    """
    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Ensures there is a bucket associated with the given `name` in `server`     
    """
    def create(server, name) do
        GenServer.cast(server, {:create, name})
    end
    @doc """
    Returns {:ok, pid} if the bucket exists, `:error` otherwise
    """
    def lookup(server, name) do
        GenServer.call(server, {:lookup, name})
    end

    #Implementation server
    @doc """
    Handle the start_link requests
    """
    @impl true
    def init(:ok) do
        names = %{}
        refs = %{}
        {:ok, {names, refs}}
    end

    @doc """
    Handle the call requests
    """
    @impl true
    def handle_call({:lookup, name}, _from, state) do
        {names, _} = state
        {:reply, Map.fetch(names, name), state}
    end
    

    @doc """
    Handle the call requests
    """
    @impl true
    def handle_cast({:create, name}, state) do
        {names, refs} = state
        if Map.has_key?(names, name) do
            {:noreply, names}
        else
            {:ok, bucket} = KV.Bucket.start_link([])
            ref = Process.monitor(bucket)
            refs = Map.put(refs, ref, name)
            names = Map.put(names, name, bucket)
            {:noreply, {names, refs}}
        end 
    end
    
    @doc """
    
    """
    @impl true
    def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
        {name, refs} = Map.pop(refs, ref)
        names = Map.delete(names, name)
        {:noreply, {names, refs}}
    end
    @doc """
    
    """
    @impl true
    def handle_info(_msg, state) do
        {:noreply, state}
    end
end