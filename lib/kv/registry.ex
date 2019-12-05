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
        {:ok, %{}}
    end

    @doc """
    Handle the call requests
    """
    @impl true
    def handle_call({:lookup, name}, _from, names) do
        {:reply, Map.fetch(names, name), names}
    end
    

    @doc """
    Handle the call requests
    """
    @impl true
    def handle_cast({:create, name}, names) do
        if Map.has_key?(names, name) do
            {:noreply, names}
        else
            {:ok, bucket} = KV.Bucket.start_link([])
            {:noreply, Map.put(names, name, bucket)}
        end 
    end


end